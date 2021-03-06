data Resources {
    ConvertFrom-StringData -StringData @'
    FileNotFound = Cannot find file '{0}' because it does not exist.
    PathNotFound = Cannot find path '{0}' because it does not exist.
    ReadWriteFileNotFileSystemProvider = Cannot open file because the current provider ({0}) cannot open a file.
    SizeLargerThanFileSize = The input to Size parameter is larger than the file size.
    FileJoining = Concatenates multiple files into file '{0}'
    FileSplitting = Splits a file into multiple files
    FileWriting = Writing the file '{0}'
'@
}

#region variables
$PartFileNameTemplate = "{0}.{1:000}"
#endregion

function Join-File {
    [CmdletBinding(
        DefaultParameterSetName = "Path",
        SupportsShouldProcess = $true,
        HelpUri = "https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Join-File.md")]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "Path",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = "LiteralPath",
            ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath", "LP")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $LiteralPath,

        [Parameter(
            Mandatory = $true,
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Destination,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        $destinationFilePath = GetFullFilePath $Destination
        $concatFiles = @()
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $resolvedFilePaths = ResolveFilePath $Path $false
            }
            "LiteralPath" {
                $resolvedFilePaths = ResolveFilePath $LiteralPath $true
            }
        }

        foreach ($resolvedFilePath in $resolvedFilePaths) {
            ValidateFileExists $resolvedFilePath
        }

        $concatFiles += $resolvedFilePaths
    }
    end {
        if ($PSCmdlet.ShouldProcess($concatFiles, $Resources.FileJoining -f $destinationFilePath)) {
            ConcatenateFiles $concatFiles $destinationFilePath $Force.IsPresent

            Get-Item -LiteralPath $destinationFilePath
        }
    }
}

function Split-File {
    [CmdletBinding(
        DefaultParameterSetName = "Path",
        SupportsShouldProcess = $true,
        HelpUri = "https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Split-File.md")]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = "Path",
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]
        $Path,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = "LiteralPath",
            ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath", "LP")]
        [ValidateNotNullOrEmpty()]
        [string]
        $LiteralPath,

        [Parameter(
            Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Destination = ".",

        [Parameter(
            Mandatory = $true,
            Position = 2)]
        [ValidateRange(1, 1GB)]
        [int]
        $Size,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        $resolvedDestinationPath = ResolveFilePath $Destination $true
    }
    process {
        switch ($PSCmdlet.ParameterSetName) {
            "Path" {
                $resolvedFilePath = ResolveFilePath $Path $false
            }
            "LiteralPath" {
                $resolvedFilePath = ResolveFilePath $LiteralPath $true
            }
        }

        ValidateFileExists $resolvedFilePath

        if ($PSCmdlet.ShouldProcess($resolvedFilePath, $Resources.FileSplitting)) {
            $parts = SplitFiles $resolvedFilePath $resolvedDestinationPath $Size $Force.IsPresent

            Get-Item -LiteralPath $parts
        }
    }
}

#region utility functions
function ConcatenateFiles {
    param (
        [string[]]
        $ConcatFiles,

        [string]
        $Destination,

        [bool]
        $Overwrite
    )

    $activity = $PSCmdlet.MyInvocation.MyCommand.Name
    $status = $Resources.FileJoining -f $Destination
    $count = 0

    try {
        $mode = [System.IO.FileMode]::CreateNew
        if ($Overwrite) {
            $mode = [System.IO.FileMode]::Create
        }

        $writer = [System.IO.FileStream]::new(
            $Destination,
            $mode,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::Write)

        foreach ($path in $ConcatFiles) {
            $operation = $Resources.FileWriting -f $path
            $count += 1

            WriteProgress $activity $status $operation 1 $ConcatFiles.Length $count

            try {
                $reader = [System.IO.FileStream]::new(
                    $path,
                    [System.IO.FileMode]::Open,
                    [System.IO.FileAccess]::Read,
                    [System.IO.FileShare]::Read)

                $reader.CopyTo($writer, $reader.Length)
            }
            finally {
                if ($null -ne $reader) {
                    $reader.Dispose()
                }
            }
        }
    }
    catch [System.IO.IOException] {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $_.Exception,
            "FileAlreadyExists",
            [System.Management.Automation.ErrorCategory]::WriteError,
            $Destination)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    catch [System.UnauthorizedAccessException] {
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            $_.Exception,
            "UnauthorizedAccessError",
            [System.Management.Automation.ErrorCategory]::PermissionDenied,
            $Destination)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
    finally {
        if ($null -ne $writer) {
            $writer.Dispose()
        }
    }
}

function GetFullFilePath {
    [OutputType([string])]
    param (
        [string]
        $FilePath
    )

    $provider = [System.Management.Automation.ProviderInfo] $null
    $drive = [System.Management.Automation.PSDriveInfo] $null
    $path = $PSCmdlet.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $FilePath,
        [ref] $provider,
        [ref] $drive)

    if ($provider.Name -ne [Microsoft.PowerShell.Commands.FileSystemProvider]::ProviderName) {
        $errorMessage = $Resources.ReadWriteFileNotFileSystemProvider -f $provider.ToString()
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new($errorMessage),
            "ReadWriteFileNotFileSystemProvider",
            [System.Management.Automation.ErrorCategory]::InvalidArgument,
            $null)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }

    $path
}

function ResolveFilePath {
    [OutputType([string])]
    param (
        [string[]]
        $FilePaths,

        [bool]
        $IsLiteralPath
    )

    $pathIntrinsic = $PSCmdlet.SessionState.Path
    $paths = [System.Collections.Generic.List[string]]::new()

    foreach ($path in $FilePaths) {
        if (-not (Test-Path -LiteralPath $path)) {
            $errorMessage = $Resources.PathNotFound -f $path
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.Management.Automation.ItemNotFoundException]::new($errorMessage),
                "PathNotFound",
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $path)

            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $provider = [System.Management.Automation.ProviderInfo] $null
        $drive = [System.Management.Automation.PSDriveInfo] $null

        if ($IsLiteralPath) {
            $paths.Add($pathIntrinsic.GetUnresolvedProviderPathFromPSPath($path, [ref] $provider, [ref] $drive))
        }
        else {
            $paths.AddRange($pathIntrinsic.GetResolvedProviderPathFromPSPath($path, [ref] $provider))
        }

        if ($provider.Name -ne [Microsoft.PowerShell.Commands.FileSystemProvider]::ProviderName) {
            $errorMessage = $Resources.ReadWriteFileNotFileSystemProvider -f $provider.ToString()
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($errorMessage),
                "ReadWriteFileNotFileSystemProvider",
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $null)

            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    $paths.ToArray()
}

function SplitFiles {
    [OutputType([string])]
    param (
        [string]
        $FilePath,

        [string]
        $Destination,

        [string]
        $ChunkSize,

        [bool]
        $Overwrite
    )

    $outputs = [System.Collections.Generic.List[string]]::new()
    $activity = $PSCmdlet.MyInvocation.MyCommand.Name

    try {
        $reader = [System.IO.FileStream]::new(
            $FilePath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::Read)

        if ($reader.Length -le $ChunkSize) {
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                [System.InvalidOperationException]::new($Resources.SizeLargerThanFileSize),
                "SizeLargerThanFileSize",
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $null)

            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        $partHead = [System.IO.Path]::Combine($Destination, [System.IO.Path]::GetFileName($FilePath))
        $chunk = [byte[]]::new($ChunkSize)
        $count = 0
        $mode = [System.IO.FileMode]::CreateNew
        if ($Overwrite) {
            $mode = [System.IO.FileMode]::Create
        }

        while ($reader.Position -lt $reader.Length) {
            $output = $PartFileNameTemplate -f $partHead, $count
            $operation = $Resources.FileWriting -f $output
            $count += 1

            WriteProgress $activity $Resources.FileSplitting $operation $ChunkSize $reader.Length $count

            try {
                $writer = [System.IO.FileStream]::new(
                    $output,
                    $mode,
                    [System.IO.FileAccess]::Write,
                    [System.IO.FileShare]::Write)

                $bytesRead = $reader.Read($chunk, 0, $chunk.Length)
                $writer.Write($chunk, 0, $bytesRead)
            }
            catch [System.IO.IOException] {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $_.Exception,
                    "FileAlreadyExists",
                    [System.Management.Automation.ErrorCategory]::WriteError,
                    $output)

                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
            catch [System.UnauthorizedAccessException] {
                $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                    $_.Exception,
                    "UnauthorizedAccessError",
                    [System.Management.Automation.ErrorCategory]::PermissionDenied,
                    $output)

                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }
            finally {
                if ($null -ne $writer) {
                    $writer.Dispose()
                }
            }

            $outputs.Add($output)
        }
    }
    finally {
        if ($null -ne $reader) {
            $reader.Dispose()
        }

        Write-Progress -Activity $activity -Status "Finish" -Completed
    }

    $outputs.ToArray()
}

function ValidateFileExists {
    param (
        [string]
        $FilePath
    )

    if (-not [System.IO.File]::Exists($FilePath)) {
        $errorMessage = $Resources.FileNotFound -f $FilePath
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
            [System.IO.FileNotFoundException]::new($errorMessage),
            "FileNotFound",
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $FilePath)

        $PSCmdlet.ThrowTerminatingError($errorRecord)
    }
}

function WriteProgress {
    param (
        [string]
        $Activity,

        [string]
        $Status,

        [string]
        $CurrentOperation,

        [double]
        $Unit,

        [double]
        $Total,

        [int]
        $NumberOfTimes
    )

    $percentComplete = $Unit / $Total * 100 * $NumberOfTimes
    if ($percentComplete -gt 100) {
        $percentComplete = 100
    }

    $WriteProgressParameters = @{
        Activity         = $Activity
        Status           = $Status
        PercentComplete  = $percentComplete
        CurrentOperation = $CurrentOperation
    }
    Write-Progress @WriteProgressParameters
}
#endregion

Export-ModuleMember -Function "Join-File", "Split-File"

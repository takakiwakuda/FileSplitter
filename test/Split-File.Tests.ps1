Set-StrictMode -Version 3.0

$ModuleRoot = Split-Path -LiteralPath $PSScriptRoot -Resolve

Import-Module -Name $ModuleRoot -Force

Describe "Split-File" {
    BeforeAll {
        . "$PSScriptRoot\Utility.ps1"

        $nonExistPath = "TestDrive:\NonExist"
        $notFileSystemPath = "TestRegistry:"
        $destinationPath = "TestDrive:\{0}" -f (New-Guid)
        $path = "TestDrive:\Test.txt"
        $partPath = "{0}\{1}.001" -f $destinationPath, (Split-Path -Path $path -Leaf)
        $concatedFile = Join-Path -Path $destinationPath -ChildPath (Split-Path -Path $path -Leaf)

        New-Item -Path $destinationPath -ItemType Directory | Out-Null
        New-EmptyFile -Path $path -Size 10MB

        $originalHash = (Get-FileHash -LiteralPath $path).Hash
    }

    AfterEach {
        Get-ChildItem -LiteralPath $destinationPath | Remove-Item -Force
        if (Test-Path -LiteralPath $concatedFile) {
            Remove-Item -LiteralPath $concatedFile
        }
    }

    Context "Path parameter" {
        It "Throws an exception if the path does not exist" {
            { Split-File -Path $nonExistPath -Size 1MB } |
            Should -Throw -ErrorId "PathNotFound,Split-File"
        }

        It "Throws an exception if the path is not file system provider" {
            { Split-File -Path $notFileSystemPath -Size 1MB } |
            Should -Throw -ErrorId "ReadWriteFileNotFileSystemProvider,Split-File"
        }

        It "Throws an exception if the file does not exist" {
            { Split-File -Path $destinationPath -Size 1MB } |
            Should -Throw -ErrorId "FileNotFound,Split-File"
        }

        It "Throws an exception if the destination path does not exist" {
            { Split-File -Path $path -Destination $nonExistPath -Size 1MB } |
            Should -Throw -ErrorId "PathNotFound,Split-File"
        }

        It "Throws an exception if the size is larger than the path size" {
            { Split-File -Path $path -Destination $destinationPath -Size 11MB } |
            Should -Throw -ErrorId "SizeLargerThanFileSize,Split-File"
        }

        It "Throws an exception if the output file already exists" {
            New-Item -Path $partPath -ItemType File | Out-Null

            { Split-File -Path $path -Destination $destinationPath -Size 1MB } |
            Should -Throw -ErrorId "FileAlreadyExists,Split-File"
        }

        It "Throws an exception if access to the output file is denied" {
            $item = New-Item -Path $partPath -ItemType File
            $item.Attributes += [System.IO.FileAttributes]::ReadOnly

            { Split-File -Path $path -Destination $destinationPath -Size 1MB -Force } |
            Should -Throw -ErrorId "UnauthorizedAccessError,Split-File"
        }

        It "Should split a file into multiple files" {
            $splitFiles = Split-File -Path $path -Destination $destinationPath -Size 1MB
            $splitFiles | Should -BeOfType ([System.IO.FileInfo])
            $splitFiles.Count | Should -Be 10

            (Join-File -LiteralPath $splitFiles -Destination $concatedFile | Get-FileHash).Hash |
            Should -BeExactly $originalHash
        }

        It "Should split a file into multiple files even if part of output files is already exists" {
            New-Item -Path $partPath -ItemType File | Out-Null

            $splitFiles = Split-File -Path $path -Destination $destinationPath -Size 1MB -Force
            $splitFiles | Should -BeOfType ([System.IO.FileInfo])
            $splitFiles.Count | Should -Be 10

            (Join-File -LiteralPath $splitFiles -Destination $concatedFile | Get-FileHash).Hash |
            Should -BeExactly $originalHash
        }
    }

    Context "LiteralPath parameter" {
        It "Throws an exception if the path does not exist" {
            { Split-File -LiteralPath $nonExistPath -Size 1MB } |
            Should -Throw -ErrorId "PathNotFound,Split-File"
        }

        It "Throws an exception if the path is not file system provider" {
            { Split-File -LiteralPath $notFileSystemPath -Size 1MB } |
            Should -Throw -ErrorId "ReadWriteFileNotFileSystemProvider,Split-File"
        }

        It "Throws an exception if the file does not exist" {
            { Split-File -LiteralPath $destinationPath -Size 1MB } |
            Should -Throw -ErrorId "FileNotFound,Split-File"
        }

        It "Throws an exception if the destination path does not exist" {
            { Split-File -LiteralPath $path -Destination $nonExistPath -Size 1MB } |
            Should -Throw -ErrorId "PathNotFound,Split-File"
        }

        It "Throws an exception if the size is larger than the path size" {
            { Split-File -LiteralPath $path -Destination $destinationPath -Size 11MB } |
            Should -Throw -ErrorId "SizeLargerThanFileSize,Split-File"
        }

        It "Throws an exception if the output file already exists" {
            New-Item -Path $partPath -ItemType File | Out-Null

            { Split-File -LiteralPath $path -Destination $destinationPath -Size 1MB } |
            Should -Throw -ErrorId "FileAlreadyExists,Split-File"
        }

        It "Throws an exception if access to the output file is denied" {
            $item = New-Item -Path $partPath -ItemType File
            $item.Attributes += [System.IO.FileAttributes]::ReadOnly

            { Split-File -LiteralPath $path -Destination $destinationPath -Size 1MB -Force } |
            Should -Throw -ErrorId "UnauthorizedAccessError,Split-File"
        }

        It "Should split a file into multiple files" {
            $splitFiles = Split-File -LiteralPath $path -Destination $destinationPath -Size 1MB
            $splitFiles | Should -BeOfType ([System.IO.FileInfo])
            $splitFiles.Count | Should -Be 10

            (Join-File -LiteralPath $splitFiles -Destination $concatedFile | Get-FileHash).Hash |
            Should -BeExactly $originalHash
        }

        It "Should split a file into multiple files even if part of output files is already exists" {
            New-Item -Path $partPath -ItemType File | Out-Null

            $splitFiles = Split-File -LiteralPath $path -Destination $destinationPath -Size 1MB -Force
            $splitFiles | Should -BeOfType ([System.IO.FileInfo])
            $splitFiles.Count | Should -Be 10

            (Join-File -LiteralPath $splitFiles -Destination $concatedFile | Get-FileHash).Hash |
            Should -BeExactly $originalHash
        }

        It "Should split a pipe file into multiple files" {
            $splitFiles = $path | Split-File -Destination $destinationPath -Size 1MB
            $splitFiles | Should -BeOfType ([System.IO.FileInfo])
            $splitFiles.Count | Should -Be 10

            (Join-File -LiteralPath $splitFiles -Destination $concatedFile | Get-FileHash).Hash |
            Should -BeExactly $originalHash
        }
    }
}

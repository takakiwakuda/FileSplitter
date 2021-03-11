Set-StrictMode -Version 3.0

$ModuleRoot = Split-Path -LiteralPath $PSScriptRoot -Resolve

Import-Module -Name $ModuleRoot -Force

Describe "Join-File" {
    BeforeAll {
        . "$PSScriptRoot\Utility.ps1"

        $nonExistPath = "TestDrive:\NonExistFirst", "TestDrive:\NonExistSecond"
        $notFileSystemPath = "TestRegistry:"
        $originalPath = "TestDrive:\Test.txt"
        $directoryPath = "TestDrive:\{0}" -f (New-Guid)
        $destinationPath = Join-Path -Path $directoryPath -ChildPath (Split-Path -Path $originalPath -Leaf)

        New-Item -Path $directoryPath -ItemType Directory | Out-Null
        New-EmptyFile -Path $originalPath -Size 10MB

        $originalHash = (Get-FileHash -LiteralPath $originalPath).Hash
        $concatFiles = (Split-File -LiteralPath $originalPath -Destination $directoryPath -Size 1MB).FullName
    }

    AfterEach {
        if (Test-Path -LiteralPath $destinationPath) {
            Remove-Item -LiteralPath $destinationPath -Force
        }
    }

    Context "Path parameter" {
        It "Throws an exception if the path does not exist" {
            { Join-File -Path $nonExistPath -Destination $destinationPath } |
            Should -Throw -ErrorId "PathNotFound,Join-File"
        }

        It "Throws an exception if the path is not file system provider" {
            { Join-File -Path $notFileSystemPath -Destination $destinationPath } |
            Should -Throw -ErrorId "ReadWriteFileNotFileSystemProvider,Join-File"
        }

        It "Throws an exception if the file does not exist" {
            { Join-File -Path $directoryPath -Destination $destinationPath } |
            Should -Throw -ErrorId "FileNotFound,Join-File"
        }

        It "Throws an exception if the output file already exists" {
            New-Item -Path $destinationPath -ItemType File | Out-Null

            { Join-File -Path $concatFiles -Destination $destinationPath } |
            Should -Throw -ErrorId "FileAlreadyExists,Join-File"
        }

        It "Throws an exception if access to the output file is denied" {
            $item = New-Item -Path $destinationPath -ItemType File
            $item.Attributes += [System.IO.FileAttributes]::ReadOnly

            { Join-File -Path $concatFiles -Destination $destinationPath -Force } |
            Should -Throw -ErrorId "UnauthorizedAccessError,Join-File"
        }

        It "Should concatenate all files" {
            $concatedFile = Join-File -Path $concatFiles -Destination $destinationPath
            $concatedFile | Should -BeOfType ([System.IO.FileInfo])
            (Get-FileHash -LiteralPath $concatedFile).Hash | Should -Be $originalHash
        }

        It "Should concatenate all files even if the output file already exists" {
            New-Item -Path $destinationPath -ItemType File | Out-Null

            $concatedFile = Join-File -Path $concatFiles -Destination $destinationPath -Force
            $concatedFile | Should -BeOfType ([System.IO.FileInfo])
            (Get-FileHash -LiteralPath $concatedFile).Hash | Should -Be $originalHash
        }
    }

    Context "LiteralPath parameter" {
        It "Throws an exception if the path does not exist" {
            { Join-File -LiteralPath $nonExistPath -Destination $destinationPath } |
            Should -Throw -ErrorId "PathNotFound,Join-File"
        }

        It "Throws an exception if the path is not file system provider" {
            { Join-File -LiteralPath $notFileSystemPath -Destination $destinationPath } |
            Should -Throw -ErrorId "ReadWriteFileNotFileSystemProvider,Join-File"
        }

        It "Throws an exception if the file does not exist" {
            { Join-File -LiteralPath $directoryPath -Destination $destinationPath } |
            Should -Throw -ErrorId "FileNotFound,Join-File"
        }

        It "Throws an exception if the output file already exists" {
            New-Item -Path $destinationPath -ItemType File | Out-Null

            { Join-File -LiteralPath $concatFiles -Destination $destinationPath } |
            Should -Throw -ErrorId "FileAlreadyExists,Join-File"
        }

        It "Throws an exception if access to the output file is denied" {
            $item = New-Item -Path $destinationPath -ItemType File
            $item.Attributes += [System.IO.FileAttributes]::ReadOnly

            { Join-File -LiteralPath $concatFiles -Destination $destinationPath -Force } |
            Should -Throw -ErrorId "UnauthorizedAccessError,Join-File"
        }

        It "Should concatenate all files" {
            $concatedFile = Join-File -LiteralPath $concatFiles -Destination $destinationPath
            $concatedFile | Should -BeOfType ([System.IO.FileInfo])
            (Get-FileHash -LiteralPath $concatedFile).Hash | Should -Be $originalHash
        }

        It "Should concatenate all files even if the output file already exists" {
            New-Item -Path $destinationPath -ItemType File | Out-Null

            $concatedFile = Join-File -LiteralPath $concatFiles -Destination $destinationPath -Force
            $concatedFile | Should -BeOfType ([System.IO.FileInfo])
            (Get-FileHash -LiteralPath $concatedFile).Hash | Should -Be $originalHash
        }

        It "Should concatenate all pipe files" {
            $concatedFile = $concatFiles | Join-File -Destination $destinationPath
            $concatedFile | Should -BeOfType ([System.IO.FileInfo])
            (Get-FileHash -LiteralPath $concatedFile).Hash | Should -Be $originalHash
        }
    }
}

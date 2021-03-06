function New-EmptyFile {
    param (
        [string]
        $Path,

        [int]
        $Size
    )

    $fs = [System.IO.FileStream]::new(
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path),
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write)

    try {
        $tmp = [byte[]]::new($Size)
        $fs.Write($tmp, 0, $tmp.Length)
    }
    finally {
        $fs.Dispose()
    }
}

---
external help file: FileSplitter-help.xml
Module Name: FileSplitter
online version: https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Join-File.md
schema: 2.0.0
---

# Join-File

## SYNOPSIS

Concatenates multiple files into a file.

## SYNTAX

### Path (Default)

```powershell
Join-File [-Path] <String[]> [-Destination] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### LiteralPath

```powershell
Join-File -LiteralPath <String[]> [-Destination] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Join-File` cmdlet concatenates multiple files into a file.

## EXAMPLES

### Example 1

```powershell
PS C:\> Join-File -Path "C:\Parts\Foo.txt.000", "C:\Parts\Foo.txt001" -Destination "C:\Foo.txt"

    Directory: C:\

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          2021/03/01    12:00       20971520 Foo.txt
```

This example concatenates multiple files into one file.

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Destination

Specifies the path to the location where the file is written.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Overwrites a file that already exists. By default, `Join-File` does not overwrite a file.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath

Specifies the path to one or more locations.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath, LP

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

Specifies a path to one or more locations. Wildcards are permitted.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

You can pipe a string that contains a file path to `Join-File`.

## OUTPUTS

### System.IO.FileInfo

`Join-File` returns a `FileInfo` object representing a file path.

## NOTES

## RELATED LINKS

[Split-File](https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Split-File.md)

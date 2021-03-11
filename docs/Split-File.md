---
external help file: FileSplitter-help.xml
Module Name: FileSplitter
online version: https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Split-File.md
schema: 2.0.0
---

# Split-File

## SYNOPSIS

Splits a file into multiple files.

## SYNTAX

### Path (Default)

```powershell
Split-File [-Path] <String> [[-Destination] <String>] [-Size] <Int32> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### LiteralPath

```powershell
Split-File -LiteralPath <String> [[-Destination] <String>] [-Size] <Int32> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The `Split-File` cmdlet splits a file into multiple files.

## EXAMPLES

### Example 1

```powershell
PS C:\> Split-File -Path "C:\Foo.txt" -Destination "C:\Parts" -Size 10MB

    Directory: C:\Parts

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          2021/03/01    12:00       10485760 Foo.txt.000
-a---          2021/03/01    12:00       10485760 Foo.txt.001
```

This example splits the file into multiple files of 10MB each.

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

Required: False
Position: 1
Default value: .
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Overwrites files that already exists. By default, `Split-File` does not overwrite files.

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

Specifies the path to the location.

```yaml
Type: String
Parameter Sets: LiteralPath
Aliases: PSPath, LP

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

Specifies the path to the location. Wildcards are permitted.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### -Size

Specifies the split size of files.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
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

You can pipe a string that contains a file path to `Split-File`.

## OUTPUTS

### System.IO.FileInfo

`Split-File` returns a FileInfo object representing a file path.

## NOTES

## RELATED LINKS

[Join-File](https://github.com/takakiwakuda/FileSplitter/blob/main/docs/Join-File.md)

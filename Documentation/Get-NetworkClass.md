# Get-NetworkClass

## SYNOPSIS
Use to determine the network class of a given IP address.

## SYNTAX

```
Get-NetworkClass [-IP] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns A, B, C, D or E depending on the numeric value of the first octet of a given IP address.

## EXAMPLES

### EXAMPLE 1
```
Get-NetworkClass -IP 172.16.1.2
```

Result
------
B

### EXAMPLE 2
```
'10.1.1.1' | Get-NetworkClass
```

Result
------
A

## PARAMETERS

### -IP
The IP address to test.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

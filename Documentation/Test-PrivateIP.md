# Test-PrivateIP

## SYNOPSIS
Use to determine if a given IP address is within the IPv4 private address space ranges.

## SYNTAX

```
Test-PrivateIP [-IP] <String> [<CommonParameters>]
```

## DESCRIPTION
Returns $true or $false for a given IP address string depending on whether or not is is within the private IP address ranges.

## EXAMPLES

### EXAMPLE 1
```
Test-PrivateIP -IP 172.16.1.2
```

Result
------
True

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

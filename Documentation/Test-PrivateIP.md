# Test-PrivateIP

## SYNOPSIS
Use to determine if a given IP address is within the IPv4 private address space ranges.

## SYNTAX

```
Test-PrivateIP [-IP] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns $true or $false for a given IP address string depending on whether or not it is within the
RFC 1918 private IP address ranges (10.0.0.0/8, 172.16.0.0/12 and 192.168.0.0/16) or the loopback
range (127.0.0.0/8, RFC 1122).

Loopback is not an RFC 1918 range, but has always been included here for compatibility.
Note that
an address that isn't private is not necessarily public (e.g.
link-local or carrier-grade NAT
addresses), so use Test-PublicIP to test for that.

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

### -ProgressAction
{{Fill ProgressAction Description}}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

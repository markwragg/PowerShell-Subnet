# Get-SubnetHostAddress

## SYNOPSIS
Returns the list of usable host IP addresses for a given network address and mask.

## SYNTAX

```
Get-SubnetHostAddress [[-IP] <String>] [[-MaskBits] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Unlike Get-Subnet, this always calculates and returns the full list of host addresses
regardless of subnet size, since that's this cmdlet's only job.
It still warns (but does not
refuse) when the subnet is larger than /16, since generating the full list for a very large
subnet can take some time.

## EXAMPLES

### EXAMPLE 1
```
Get-SubnetHostAddress 10.1.2.3/24
```

Description
-----------
Returns the list of host addresses for the specified network and mask.

### EXAMPLE 2
```
Get-SubnetHostAddress -IP 192.168.0.1 -MaskBits 12
```

Description
-----------
Returns the list of host addresses for the specified (large) network and mask.
A warning is
shown that this may take some time, but the addresses are still returned.

### EXAMPLE 3
```
'10.1.2.3/24','10.1.2.4/24' | Get-SubnetHostAddress
```

Description
-----------
Returns the list of host addresses for two specified networks.

## PARAMETERS

### -IP
The network IP address or IP address with subnet mask via slash notation.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MaskBits
The numerical representation of the subnet mask.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: CIDR

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
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

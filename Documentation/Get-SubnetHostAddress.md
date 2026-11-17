# Get-SubnetHostAddress

## SYNOPSIS
Returns the list of usable host IP addresses, as \[ipaddress\] objects, for a given network
address and mask.

## SYNTAX

```
Get-SubnetHostAddress [-IP] <Object> [[-MaskBits] <Object>] [-AsString] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Unlike Get-Subnet, this always calculates and returns the full list of host addresses
regardless of subnet size, since that's this cmdlet's only job.
It still warns (but does not
refuse) when the subnet is larger than /16, since generating the full list for a very large
subnet can take some time.

If no mask is specified (either via slash notation or -MaskBits), one is inferred from the
address class (/8 for Class A, /16 for Class B, /24 for Class C) and a warning is shown.
Be
aware that for a Class A or B address this can mean a very large number of addresses.

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
Get-SubnetHostAddress 10.1.2.3/24 -AsString
```

Description
-----------
Returns the list of host addresses for the specified network and mask, as strings instead of
\[ipaddress\] objects.

### EXAMPLE 3
```
Get-SubnetHostAddress -IP 192.168.0.1 -MaskBits 12
```

Description
-----------
Returns the list of host addresses for the specified (large) network and mask.
A warning is
shown that this may take some time, but the addresses are still returned.

### EXAMPLE 4
```
'10.1.2.3/24','10.1.2.4/24' | Get-SubnetHostAddress
```

Description
-----------
Returns the list of host addresses for two specified networks.

### EXAMPLE 5
```
Get-Subnet 10.1.2.3/24 | Get-SubnetHostAddress
```

Description
-----------
Returns the list of host addresses for the network and mask resolved by Get-Subnet.

## PARAMETERS

### -IP
The network IP address or IP address with subnet mask via slash notation.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MaskBits
The numerical representation of the subnet mask.

```yaml
Type: Object
Parameter Sets: (All)
Aliases: CIDR

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsString
Return the host addresses as strings instead of \[ipaddress\] objects.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

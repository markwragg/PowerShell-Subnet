# Get-Subnet

## SYNOPSIS
Returns subnet details for the local IP address, or a given network address and mask.

## SYNTAX

```
Get-Subnet [[-IP] <String>] [[-MaskBits] <Int32>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
Use to get subnet details  for a given network address and mask, including network address, broadcast address, network class, address range, host addresses and host address count.

## EXAMPLES

### EXAMPLE 1
```
Get-Subnet 10.1.2.3/24
```

Description
-----------
Returns the subnet details for the specified network and mask, specified as a single string to the -IP parameter.

### EXAMPLE 2
```
Get-Subnet 192.168.0.1 -MaskBits 23
```

Description
-----------
Returns the subnet details for the specified network and mask.

### EXAMPLE 3
```
Get-Subnet
```

Description
-----------
Returns the subnet details for the current local IP.

### EXAMPLE 4
```
'10.1.2.3/24','10.1.2.4/24' | Get-Subnet
```

Description
-----------
Returns the subnet details for two specified networks.

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

### -Force
Use to force the return of all host IP addresses regardless of the subnet size (skipped by default for subnets larger than /16).

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

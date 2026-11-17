# Test-PublicIP

## SYNOPSIS
Use to determine if a given IP address is within the IPv4 public address space.

## SYNTAX

```
Test-PublicIP [-IP] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns $true or $false for a given IP address string depending on whether or not it is a public
(globally reachable) unicast address.

An address is not public if it is within any of the ranges the IANA IPv4 Special-Purpose Address
Registry (RFC 6890) marks as not globally reachable, or is a multicast address:

0.0.0.0/8        "This network" (RFC 791)
10.0.0.0/8       Private-Use (RFC 1918)
100.64.0.0/10    Shared Address Space / carrier-grade NAT (RFC 6598)
127.0.0.0/8      Loopback (RFC 1122)
169.254.0.0/16   Link-Local (RFC 3927)
172.16.0.0/12    Private-Use (RFC 1918)
192.0.0.0/24     IETF Protocol Assignments (RFC 6890), except 192.0.0.9 and 192.0.0.10
192.0.2.0/24     Documentation, TEST-NET-1 (RFC 5737)
192.168.0.0/16   Private-Use (RFC 1918)
198.18.0.0/15    Benchmarking (RFC 2544)
198.51.100.0/24  Documentation, TEST-NET-2 (RFC 5737)
203.0.113.0/24   Documentation, TEST-NET-3 (RFC 5737)
224.0.0.0/4      Multicast (RFC 5771)
240.0.0.0/4      Reserved (RFC 1112), including 255.255.255.255, Limited Broadcast (RFC 919)

This is not simply the inverse of Test-PrivateIP, which only tests for the RFC 1918 private ranges
and loopback.

## EXAMPLES

### EXAMPLE 1
```
Test-PublicIP -IP 8.8.8.8
```

Result
------
True

### EXAMPLE 2
```
Test-PublicIP -IP 169.254.1.1
```

Result
------
False

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

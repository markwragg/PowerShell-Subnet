function Convert-IPtoInt64 ($ip) { 
    $octets = $ip.split(".") 
    [int64]([int64]$octets[0] * 16777216 + [int64]$octets[1] * 65536 + [int64]$octets[2] * 256 + [int64]$octets[3]) 
} 
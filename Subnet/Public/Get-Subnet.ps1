function Get-Subnet {
    param ( 
        [parameter(ValueFromPipeline)]
        [String]
        $IP,

        [ValidateRange(0, 32)]
        [int]
        $MaskBits,

        [switch]
        $Force
    )
    Process {
        If ($PSBoundParameters.ContainsKey('MaskBits')) { 
            $Mask = $MaskBits 
        }

        If (-not $IP) { 
            $LocalIP = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.PrefixOrigin -ne 'WellKnown' })

            $IP = $LocalIP.IPAddress
            If ($Mask -notin 0..32) { $Mask = $LocalIP.PrefixLength }
        }

        If ($IP -match '/\d') { 
            $IPandMask = $IP -Split '/' 
            $IP = $IPandMask[0]
            $Mask = $IPandMask[1]
        }
        
        $IPAddr = [Net.IPAddress]::Parse($IP)

        $Class = Switch ($IP.Split('.')[0]) {
            { $_ -in 0..127 } { 'A' }
            { $_ -in 128..191 } { 'B' }
            { $_ -in 192..223 } { 'C' }
            { $_ -in 224..239 } { 'D' }
            { $_ -in 240..255 } { 'E' }
            
        }

        If ($Mask -notin 0..32) {
            $Mask = Switch ($Class) {
                'A' { 8 }
                'B' { 16 }
                'C' { 24 }
                default { Throw "Subnet mask size was not specified and could not be inferred because the address is Class $Class." }
            }

            Write-Warning "Subnet mask size was not specified. Using default subnet size for a Class $Class network of /$Mask."
        }

        $MaskAddr = [IPAddress]::Parse((Convert-Int64toIP -int ([convert]::ToInt64(("1" * $Mask + "0" * (32 - $Mask)), 2))))        
        $NetworkAddr = [IPAddress]($MaskAddr.address -band $IPAddr.address) 
        $BroadcastAddr = [IPAddress](([IPAddress]::parse("255.255.255.255").address -bxor $MaskAddr.address -bor $NetworkAddr.address))
        
        $HostStartAddr = (Convert-IPtoInt64 -ip $NetworkAddr.ipaddresstostring) + 1
        $HostEndAddr = (Convert-IPtoInt64 -ip $broadcastaddr.ipaddresstostring) - 1

        $HostAddressCount = ($HostEndAddr - $HostStartAddr) + 1
        
        If ($Mask -ge 16 -or $Force) {
            
            Write-Progress "Calcualting host addresses for $NetworkAddr/$Mask.."

            $HostAddresses = for ($i = $HostStartAddr; $i -le $HostEndAddr; $i++) {
                Convert-Int64toIP -int $i
            }
        }
        Else {
            Write-Warning "Host address calculation was not performed because it would take some time for a /$Mask subnet. `nUse -Force if you want it to occur."
        }

        [pscustomobject]@{
            IPAddress        = $IPAddr
            MaskBits         = $Mask
            NetworkAddress   = $NetworkAddr
            BroadcastAddress = $broadcastaddr
            SubnetMask       = $MaskAddr
            NetworkClass     = $Class
            Range            = "$networkaddr ~ $broadcastaddr"
            HostAddresses    = $HostAddresses
            HostAddressCount = $HostAddressCount
        }
    }
}
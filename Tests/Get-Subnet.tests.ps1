if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Subnet'

. (Resolve-Path $Root\$Module\Public\Get-Subnet.ps1)

Describe "Get-Subnet PS$PSVersion" {

    It 'Should calculate a Subnet IP with mask' {

        $Result = Get-Subnet -IP 1.2.3.4/24
        
        $Result | Should -BeOfType [pscustomobject]
        $Result.IPAddress | Should -Be '1.2.3.4'
        $Result.MaskBits | Should -Be 24
        $Result.NetworkAddress | Should -Be '1.2.3.0'
        $Result.BroadcastAddress | Should -Be '1.2.3.255'
        $Result.NetworkClass | Should -Be 'A'
        $Result.Range | Should -Be '1.2.3.0 ~ 1.2.3.255'
        $Result.HostAddresses | Should -HaveCount 254
    }

    It 'Should calculate a Subnet IP with mask declared separately' {

        $Result = Get-Subnet -IP 1.2.3.4 -Mask 24
        
        $Result | Should -BeOfType [pscustomobject]
        $Result.IPAddress | Should -Be '1.2.3.4'
        $Result.MaskBits | Should -Be 24
        $Result.NetworkAddress | Should -Be '1.2.3.0'
        $Result.BroadcastAddress | Should -Be '1.2.3.255'
        $Result.NetworkClass | Should -Be 'A'
        $Result.Range | Should -Be '1.2.3.0 ~ 1.2.3.255'
        $Result.HostAddresses | Should -HaveCount 254
    }

    It 'Should calculate the Subnet of the local NIC IP' {

        $Result = Get-Subnet

        $Result | Should -BeOfType [pscustomobject]
        $Result.IPAddress | Should -Not -Be $null
        $Result.MaskBits | Should -Not -Be $null
        $Result.NetworkAddress | Should -Not -Be $null
        $Result.BroadcastAddress | Should -Not -Be $null
        $Result.NetworkClass | Should -Not -Be $null
        $Result.Range | Should -Not -Be $null
    }

    Context 'CIDR to Subnet conversions' {
        $TestCases = @(
            @{'CIDR' = 0; 'Subnet' = '0.0.0.0' }
            @{'CIDR' = 1; 'Subnet' = '128.0.0.0' }
            @{'CIDR' = 2; 'Subnet' = '192.0.0.0' }
            @{'CIDR' = 3; 'Subnet' = '224.0.0.0' }
            @{'CIDR' = 4; 'Subnet' = '240.0.0.0' }
            @{'CIDR' = 5; 'Subnet' = '248.0.0.0' }
            @{'CIDR' = 6; 'Subnet' = '252.0.0.0' }
            @{'CIDR' = 7; 'Subnet' = '254.0.0.0' }
            @{'CIDR' = 8; 'Subnet' = '255.0.0.0' }
            @{'CIDR' = 9; 'Subnet' = '255.128.0.0' }
            @{'CIDR' = 10; 'Subnet' = '255.192.0.0' }
            @{'CIDR' = 11; 'Subnet' = '255.224.0.0' }
            @{'CIDR' = 12; 'Subnet' = '255.240.0.0' }
            @{'CIDR' = 13; 'Subnet' = '255.248.0.0' }
            @{'CIDR' = 14; 'Subnet' = '255.252.0.0' }
            @{'CIDR' = 15; 'Subnet' = '255.254.0.0' }
            @{'CIDR' = 16; 'Subnet' = '255.255.0.0' }
            @{'CIDR' = 17; 'Subnet' = '255.255.128.0' }
            @{'CIDR' = 18; 'Subnet' = '255.255.192.0' }
            @{'CIDR' = 19; 'Subnet' = '255.255.224.0' }
            @{'CIDR' = 20; 'Subnet' = '255.255.240.0' }
            @{'CIDR' = 21; 'Subnet' = '255.255.248.0' }
            @{'CIDR' = 22; 'Subnet' = '255.255.252.0' }
            @{'CIDR' = 23; 'Subnet' = '255.255.254.0' }
            @{'CIDR' = 24; 'Subnet' = '255.255.255.0' }
            @{'CIDR' = 25; 'Subnet' = '255.255.255.128' }
            @{'CIDR' = 26; 'Subnet' = '255.255.255.192' }
            @{'CIDR' = 27; 'Subnet' = '255.255.255.224' }
            @{'CIDR' = 28; 'Subnet' = '255.255.255.240' }
            @{'CIDR' = 29; 'Subnet' = '255.255.255.248' }
            @{'CIDR' = 30; 'Subnet' = '255.255.255.252' }
            @{'CIDR' = 31; 'Subnet' = '255.255.255.254' }
            @{'CIDR' = 32; 'Subnet' = '255.255.255.255' }
        )

        It "Should convert /<CIDR> to <Subnet>" -TestCases $TestCases {
            param($CIDR, $Subnet)

            (Get-Subnet -IP 10.1.2.3 -MaskBits $CIDR).SubnetMask | Should -BeExactly $Subnet
        }
    }

    Context 'Network class identification' {
        $TestCases = @(
            @{'IP' = '0.1.2.3'; 'Class' = 'A'; 'SubnetMask' = '255.0.0.0' }
            @{'IP' = '128.1.2.3'; 'Class' = 'B'; 'SubnetMask' = '255.255.0.0' }
            @{'IP' = '192.1.2.3'; 'Class' = 'C'; 'SubnetMask' = '255.255.255.0' }
        )

        It "Should identify <IP> as <Class> with Mask <SubnetMask>" -TestCases $TestCases {
            param($IP, $Class, $SubnetMask)

            $Result = (Get-Subnet -IP $IP)

            $Result.NetworkClass | Should -Be $Class
            $Result.SubnetMask | Should -Be $SubnetMask
        }

        $TestCases = @(
            @{'IP' = '224.1.2.3'; 'Class' = 'D' }
            @{'IP' = '240.1.2.3'; 'Class' = 'E' }
        )

        It "Should identify <IP> as <Class>" -TestCases $TestCases {
            param($IP, $Class)

            $Result = (Get-Subnet -IP $IP -MaskBits 24)

            $Result.NetworkClass | Should -Be $Class
        }
    }

    Context 'Invalid IP' {
        
        It "Should throw for an invalid IP" {
            { Get-Subnet -IP 300.1.2.3 } | Should -Throw
        }
    }
}
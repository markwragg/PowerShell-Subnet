if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Subnet'

. (Resolve-Path $Root\$Module\Public\Get-Subnet.ps1)

Describe "Get-Subnet PS$PSVersion" {

    It 'Should calculate a subnet IP with mask' {

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

    It 'Should calculate a subnet IP with mask declared separately' {

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

    It 'Should calculate the subnet of the local NIC IP' {

        $Result = Get-Subnet

        $Result | Should -BeOfType [pscustomobject]
        $Result.IPAddress | Should -Not -Be $null
        $Result.MaskBits | Should -Not -Be $null
        $Result.NetworkAddress | Should -Not -Be $null
        $Result.BroadcastAddress | Should -Not -Be $null
        $Result.NetworkClass | Should -Not -Be $null
        $Result.Range | Should -Not -Be $null
    }
}

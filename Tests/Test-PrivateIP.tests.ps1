if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot/.."
$Module = 'Subnet'

Import-Module "$Root/$Module/$Module.psd1" -Force

Describe 'Test-PrivateIP' {

    Context 'Private IPs' {

        $PrivateIPs = '10.0.0.0', '10.255.255.255', '172.16.0.0', '172.31.255.255', '192.168.0.0', '192.168.255.255'

        ForEach ($PrivateIP in $PrivateIPs) {
            It "Should return $true for $PrivateIP" {
                Test-PrivateIP -IP $PrivateIP | Should -Be $true
            }
        }
    }

    Context 'Public IPs' {

        $PublicIPs = '9.255.255.255', '11.0.0.0', '172.15.255.255', '172.32.0.0', '192.167.255.255', '192.169.0.0'

        ForEach ($PublicIP in $PublicIPs) {
            It "Should return $false for $PublicIP" {
                Test-PrivateIP -IP $PublicIP | Should -Be $false
            }
        }
    }
}
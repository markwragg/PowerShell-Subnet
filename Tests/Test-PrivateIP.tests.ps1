if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot/.."
$Module = 'Subnet'

Get-Module $Module | Remove-Module -Force
Import-Module "$Root/$Module/$Module.psd1" -Force

Describe "Test-PrivateIP PS$PSVersion" {

    $PrivateIPs = '10.0.0.0', '10.255.255.255', '172.16.0.0', '172.31.255.255', '192.168.0.0', '192.168.255.255'

    Context 'Private IPs' {

        ForEach ($PrivateIP in $PrivateIPs) {
            It "Should return $true for $PrivateIP" {
                Test-PrivateIP -IP $PrivateIP | Should -Be $true
            }
        }
    }

    Context 'Private IPs with pipeline input' {

        ForEach ($PrivateIP in $PrivateIPs) {
            It "Should return $true for $PrivateIP" {
                $PrivateIP | Test-PrivateIP | Should -Be $true
            }
        }
    }

    
    $PublicIPs = '9.255.255.255', '11.0.0.0', '172.15.255.255', '172.32.0.0', '192.167.255.255', '192.169.0.0'
    
    Context 'Public IPs' {

        ForEach ($PublicIP in $PublicIPs) {
            It "Should return $false for $PublicIP" {
                Test-PrivateIP -IP $PublicIP | Should -Be $false
            }
        }
    }

    Context 'Public IPs with pipeline input' {

        ForEach ($PublicIP in $PublicIPs) {
            It "Should return $false for $PublicIP" {
                $PublicIP | Test-PrivateIP | Should -Be $false
            }
        }
    }
}
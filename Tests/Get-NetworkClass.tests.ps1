if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot/.."
$Module = 'Subnet'

Get-Module $Module | Remove-Module -Force
Import-Module "$Root/$Module/$Module.psd1" -Force

Describe "Get-NetworkClass PS$PSVersion" {

    Context 'Class A IPs' {

        $ClassAIPs = '0.0.0.0', '1.1.1.1', '127.0.0.0'

        ForEach ($ClassAIP in $ClassAIPs) {
            It "Should return A for $ClassAIP" {
                Get-NetworkClass -IP $ClassAIP | Should -Be 'A'
            }
        }
    }

    Context 'Class B IPs' {

        $ClassBIPs = '128.0.0.0', '175.255.0.0', '191.255.0.0'

        ForEach ($ClassBIP in $ClassBIPs) {
            It "Should return B for $ClassBIP" {
                Get-NetworkClass -IP $ClassBIP | Should -Be 'B'
            }
        }
    }

    Context 'Class C IPs' {

        $ClassCIPs = '192.0.0.0', '200.255.255.0', '223.255.255.0'

        ForEach ($ClassCIP in $ClassCIPs) {
            It "Should return C for $ClassCIP" {
                Get-NetworkClass -IP $ClassCIP | Should -Be 'C'
            }
        }
    }

    Context 'Class D IPs' {

        $ClassDIPs = '224.0.0.0', '235.0.0.0', '239.255.255.255'

        ForEach ($ClassDIP in $ClassDIPs) {
            It "Should return D for $ClassDIP" {
                Get-NetworkClass -IP $ClassDIP | Should -Be 'D'
            }
        }
    }

    Context 'Class E IPs' {

        $ClassEIPs = '240.0.0.0', '245.0.0.0', '255.255.255.255'

        ForEach ($ClassEIP in $ClassEIPs) {
            It "Should return E for $ClassEIP" {
                Get-NetworkClass -IP $ClassEIP | Should -Be 'E'
            }
        }
    }


}
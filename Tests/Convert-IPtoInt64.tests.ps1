Describe "Convert-IPtoInt64 PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    Context 'IP to Int64 conversions' {
        $TestCases = @(
            @{ IP = '0.0.0.0'; Int = 0 }
            @{ IP = '10.0.0.0'; Int = 167772160 }
            @{ IP = '1.2.3.4'; Int = 16909060 }
            @{ IP = '255.0.0.0'; Int = 4278190080 }
            @{ IP = '255.255.255.0'; Int = 4294967040 }
            @{ IP = '255.255.255.255'; Int = 4294967295 }
        )

        It "Should convert <IP> to <Int>" -TestCases $TestCases {
            InModuleScope Subnet -Parameters @{ IP = $IP; Int = $Int } {
                Convert-IPtoInt64 -ip $IP | Should -Be $Int
            }
        }
    }
}

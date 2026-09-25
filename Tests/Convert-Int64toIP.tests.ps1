Describe "Convert-Int64toIP PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    Context 'Int64 to IP conversions' {
        $TestCases = @(
            @{ Int = 0; IP = '0.0.0.0' }
            @{ Int = 167772160; IP = '10.0.0.0' }
            @{ Int = 16909060; IP = '1.2.3.4' }
            @{ Int = 4278190080; IP = '255.0.0.0' }
            @{ Int = 4294967040; IP = '255.255.255.0' }
            @{ Int = 4294967295; IP = '255.255.255.255' }
        )

        It "Should convert <Int> to <IP>" -TestCases $TestCases {
            InModuleScope Subnet -Parameters @{ Int = $Int; IP = $IP } {
                Convert-Int64toIP -int $Int | Should -BeExactly $IP
            }
        }
    }
}

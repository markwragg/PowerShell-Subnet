Describe "Convert-SubnetMaskToPrefixLength PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    Context 'Subnet mask to prefix length conversions' {
        $TestCases = @(
            @{ SubnetMask = '0.0.0.0'; PrefixLength = 0 }
            @{ SubnetMask = '128.0.0.0'; PrefixLength = 1 }
            @{ SubnetMask = '255.0.0.0'; PrefixLength = 8 }
            @{ SubnetMask = '255.255.0.0'; PrefixLength = 16 }
            @{ SubnetMask = '255.255.255.0'; PrefixLength = 24 }
            @{ SubnetMask = '255.255.255.252'; PrefixLength = 30 }
            @{ SubnetMask = '255.255.255.255'; PrefixLength = 32 }
        )

        It "Should convert <SubnetMask> to a prefix length of <PrefixLength>" -TestCases $TestCases {
            InModuleScope Subnet -Parameters @{ SubnetMask = $SubnetMask; PrefixLength = $PrefixLength } {
                Convert-SubnetMaskToPrefixLength -SubnetMask $SubnetMask | Should -Be $PrefixLength
            }
        }
    }
}

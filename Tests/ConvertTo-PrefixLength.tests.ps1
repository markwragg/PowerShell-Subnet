Describe "ConvertTo-PrefixLength PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    It 'Should return <Expected> as an [int] for <Label>' -ForEach @(
        @{ Label = '0'; MaskBits = 0; Expected = 0 }
        @{ Label = '32'; MaskBits = 32; Expected = 32 }
        @{ Label = "'0'"; MaskBits = '0'; Expected = 0 }
        @{ Label = "'8'"; MaskBits = '8'; Expected = 8 }
        @{ Label = "'24'"; MaskBits = '24'; Expected = 24 }
        @{ Label = '[byte]24'; MaskBits = [byte]24; Expected = 24 }
        @{ Label = '[long]24'; MaskBits = [long]24; Expected = 24 }
    ) {
        InModuleScope Subnet -Parameters @{ MaskBits = $MaskBits; Expected = $Expected } {
            $Result = ConvertTo-PrefixLength -MaskBits $MaskBits
            $Result | Should -Be $Expected
            $Result | Should -BeOfType [int]
        }
    }

    It 'Should return $null for <Label>' -ForEach @(
        @{ Label = '$null'; MaskBits = $null }
        @{ Label = "''"; MaskBits = '' }
        @{ Label = "' '"; MaskBits = ' ' }
        @{ Label = "' 24'"; MaskBits = ' 24' }
        @{ Label = "'24\n'"; MaskBits = "24`n" }
        @{ Label = "'+24'"; MaskBits = '+24' }
        @{ Label = "'-1'"; MaskBits = '-1' }
        @{ Label = "'00'"; MaskBits = '00' }
        @{ Label = "'03'"; MaskBits = '03' }
        @{ Label = "'08'"; MaskBits = '08' }
        @{ Label = "'003'"; MaskBits = '003' }
        @{ Label = "'024'"; MaskBits = '024' }
        @{ Label = "'33'"; MaskBits = '33' }
        @{ Label = "'abc'"; MaskBits = 'abc' }
        @{ Label = '-1'; MaskBits = -1 }
        @{ Label = '33'; MaskBits = 33 }
        @{ Label = '24.0'; MaskBits = 24.0 }
        @{ Label = '$true'; MaskBits = $true }
        @{ Label = 'an array'; MaskBits = @(24) }
    ) {
        InModuleScope Subnet -Parameters @{ MaskBits = $MaskBits } {
            ConvertTo-PrefixLength -MaskBits $MaskBits | Should -BeNullOrEmpty
        }
    }
}

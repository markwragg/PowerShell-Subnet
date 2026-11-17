Describe "Test-IPv4Address PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }
    }

    It "Should return `$true for the valid address '<IP>'" -ForEach @(
        @{ IP = '0.0.0.0' }
        @{ IP = '1.2.3.4' }
        @{ IP = '10.20.30.40' }
        @{ IP = '192.168.1.100' }
        @{ IP = '255.255.255.255' }
    ) {
        InModuleScope Subnet -Parameters @{ IP = $IP } {
            Test-IPv4Address -IP $IP | Should -BeTrue
        }
    }

    It "Should return `$false for the invalid address '<IP>'" -ForEach @(
        @{ IP = 'blah' }
        @{ IP = '' }
        @{ IP = '1' }
        @{ IP = '0' }
        @{ IP = '1.2' }
        @{ IP = '1.2.3' }
        @{ IP = '1.2.3.4.5' }
        @{ IP = '0x7f.1' }
        @{ IP = '010.1.1.1' }
        @{ IP = '192.168.001.001' }
        @{ IP = '256.1.1.1' }
        @{ IP = '999.1.2.3' }
        @{ IP = '10.evil' }
        @{ IP = ' 1.2.3.4' }
        @{ IP = '1.2.3.4 ' }
        @{ IP = '1.2.3.4/24' }
        @{ IP = '::1' }
        @{ IP = "1.2.3.4`n" }
        @{ IP = "1.2.3.4`r`n" }
        @{ IP = "`n1.2.3.4" }
        @{ IP = ([string][char]0x0661) + '.2.3.4' }  # Arabic-Indic digit one
        @{ IP = '1.2.3.' + ([string][char]0xFF14) }  # Fullwidth digit four
    ) {
        InModuleScope Subnet -Parameters @{ IP = $IP } {
            Test-IPv4Address -IP $IP | Should -BeFalse
        }
    }
}

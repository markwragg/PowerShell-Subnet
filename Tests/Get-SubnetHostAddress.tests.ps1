Describe "Get-SubnetHostAddress PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }

        Mock Write-Warning {} -ModuleName Subnet
        Mock Write-Progress {} -ModuleName Subnet
    }

    It 'Should return just the host addresses for a subnet given via IP/Mask notation' {
        Get-SubnetHostAddress -IP 1.2.3.4/30 | Should -Be @('1.2.3.5', '1.2.3.6')
    }

    It 'Should return just the host addresses for a subnet given via -MaskBits' {
        Get-SubnetHostAddress -IP 1.2.3.4 -MaskBits 30 | Should -Be @('1.2.3.5', '1.2.3.6')
    }

    It 'Should accept pipeline input' {
        '1.2.3.4/30' | Get-SubnetHostAddress | Should -Be @('1.2.3.5', '1.2.3.6')
    }

    It 'Should return the same host addresses as Get-Subnet for the same input' {
        $Expected = (Get-Subnet -IP 1.2.3.4/28).HostAddresses
        Get-SubnetHostAddress -IP 1.2.3.4/28 | Should -Be $Expected
    }

    It 'Should always calculate and return host addresses, even for a subnet larger than /16' {

        $Result = Get-SubnetHostAddress -IP 10.0.0.0 -MaskBits 14

        $Result | Should -HaveCount 262142
        $Result[0] | Should -Be '10.0.0.1'
        $Result[-1] | Should -Be '10.3.255.254'
    }

    It 'Should warn when the subnet is larger than /16' {

        Get-SubnetHostAddress -IP 10.0.0.0 -MaskBits 14 | Out-Null

        Should -Invoke Write-Warning -ModuleName Subnet -Times 1 -Exactly
    }

    It 'Should not warn when the subnet is /16 or smaller' {

        Get-SubnetHostAddress -IP 1.2.3.4/24 | Out-Null

        Should -Invoke Write-Warning -ModuleName Subnet -Times 0 -Exactly
    }
}

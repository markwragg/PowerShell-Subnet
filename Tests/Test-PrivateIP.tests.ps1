Describe "Test-PrivateIP PS$PSVersion" {

    InModuleScope Subnet {
        $PrivateIPs = '10.0.0.0', '10.255.255.255', '172.16.0.0', '172.31.255.255', '192.168.0.0', '192.168.255.255'

        Context 'Private IPs' {

            It "Should return $true for <_>" -TestCases $PrivateIPs {
                Test-PrivateIP -IP $_ | Should -Be $true
            }
        }

        Context 'Private IPs with pipeline input' {

            It "Should return $true for <_>" -TestCases $PrivateIPs {
                $_ | Test-PrivateIP | Should -Be $true
            }   
        }

    
        $PublicIPs = '9.255.255.255', '11.0.0.0', '172.15.255.255', '172.32.0.0', '192.167.255.255', '192.169.0.0'
    
        Context 'Public IPs' {

        
            It "Should return $false for <_>" -TestCases $PublicIPs {
                Test-PrivateIP -IP $_ | Should -Be $false
            }
        }

        Context 'Public IPs with pipeline input' {

            It "Should return $false for <_>" -TestCases $PublicIPs {
                $_ | Test-PrivateIP | Should -Be $false
            }
        }
    }
}
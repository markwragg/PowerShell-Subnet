Describe "Get-UnicastAddressPrefixLength PS$PSVersion" {

    BeforeAll {
        if (-not (Get-Module -Name 'Subnet')) {
            Import-Module $PSScriptRoot\..\Subnet
        }

        # Real compiled types, rather than a [pscustomobject] with a NoteProperty/ScriptProperty -- the
        # function under test resolves .PrefixLength via reflection (see its own notes for why), and
        # reflection only sees genuine CLR properties, not PowerShell's dynamic ETS members.
        if (-not ('FakeUnicastAddressInformation' -as [type])) {
            Add-Type -TypeDefinition @'
using System;
using System.Net;

public class FakeUnicastAddressInformation
{
    public IPAddress IPv4Mask { get; set; }
    public int PrefixLength { get; set; }
}

public class FakeUnicastAddressInformationWithUnimplementedPrefixLength
{
    public IPAddress IPv4Mask { get; set; }
    public int PrefixLength { get { throw new NotImplementedException(); } }
}
'@
        }
    }

    It 'Should return .PrefixLength when it is implemented' {
        InModuleScope Subnet {
            $UnicastAddress = [FakeUnicastAddressInformation]@{ PrefixLength = 24; IPv4Mask = [ipaddress]'255.255.0.0' }

            Get-UnicastAddressPrefixLength -UnicastAddress $UnicastAddress | Should -Be 24
        }
    }

    It 'Should fall back to counting the bits of .IPv4Mask when .PrefixLength is not implemented' {
        InModuleScope Subnet {
            $UnicastAddress = [FakeUnicastAddressInformationWithUnimplementedPrefixLength]@{ IPv4Mask = [ipaddress]'255.255.255.0' }

            Get-UnicastAddressPrefixLength -UnicastAddress $UnicastAddress | Should -Be 24
        }
    }
}

if(-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

$PSVersion = $PSVersionTable.PSVersion.Major
$Root = "$PSScriptRoot\.."
$Module = 'Subnet'

Describe "Subnet Module Tests PS$PSVersion" {
  
    It "Should import $Module without errors" {
        { Import-Module (Join-Path $Root $Module) -Force -ErrorAction Stop } | Should -Not -Throw
    }
}

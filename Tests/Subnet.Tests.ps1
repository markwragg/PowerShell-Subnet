Describe "Subnet Module Tests PS$PSVersion" {

    BeforeAll {
        if (-not $PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }

        $PSVersion = $PSVersionTable.PSVersion.Major
        $Root = "$PSScriptRoot\.."
        $Module = 'Subnet'

        # Remember whatever is already loaded (e.g. the build's staged module) so it can be restored
        # afterwards -- otherwise this test's own forced reimport from source leaves that module
        # swapped out for the rest of the Pester run. Since code coverage is measured against the
        # staged file, that silently breaks coverage attribution for whichever test file runs next.
        $script:PreviousModulePath = (Get-Module -Name $Module | Select-Object -First 1).Path

        Get-Module $Module | Remove-Module -Force
    }

    It "Should import $Module without errors" {
        { Import-Module (Join-Path $Root $Module) -Force -ErrorAction Stop } | Should -Not -Throw
    }

    AfterAll {
        if ($script:PreviousModulePath) {
            Get-Module $Module | Remove-Module -Force
            Import-Module -Name $script:PreviousModulePath -Force -Global
        }
    }
}

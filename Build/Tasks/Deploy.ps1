Task 'Deploy' -Depends 'Init' {
    $lines

    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions -Name $env:BHPSModuleManifest

    # Only proceed -- and only bump the version below -- once we know a real deploy is going to happen.
    # Bumping the version unconditionally here would commit the manifest ahead of PSGallery on every build
    # that reaches this task without a pending release, which is exactly the drift this guard prevents.
    $ChangeLogPath = "$ProjectRoot/CHANGELOG.md"
    if (-not (Test-Path $ChangeLogPath)) {
        Write-Host "$ProjectRoot/CHANGELOG.md not found. Skipping deployment."
        return
    }

    # The !Deploy heading may pin an explicit version, e.g. '## !Deploy [2.0.0]', which always wins over
    # the version Get-NextPSGalleryVersion would otherwise compute.
    $ChangeLogContent = Get-Content $ChangeLogPath -Raw
    if ($ChangeLogContent -notmatch '(?m)^## !Deploy(?:\s*\[(?<ExplicitVersion>[^\]]+)\])?\s*$') {
        Write-Host 'CHANGELOG.md did not contain ## !Deploy. Skipping deployment.'
        return
    }
    $DeployHeading = $Matches[0]
    $ExplicitVersion = $Matches['ExplicitVersion']

    # Bump the module version
    try {
        if ($ExplicitVersion) {
            $Version = [Version]$ExplicitVersion
        }
        else {
            $Version = Get-NextPSGalleryVersion -Name $env:BHProjectName -ErrorAction 'Stop'

            # Ensure the next deploy is at least 1.2.0. Once the Gallery has a 1.2.0+ release published, Get-NextPSGalleryVersion will always be >= this floor
            # on its own, so this check becomes a no-op and doesn't need to be removed later.
            $MinimumVersion = [Version]'1.2.0'
            if ($Version -lt $MinimumVersion) { $Version = $MinimumVersion }

            # A [Breaking] entry in the unreleased ('!Deploy') CHANGELOG section marks this as a breaking release,
            # so bump the major version instead of the usual patch bump Get-NextPSGalleryVersion applies. Only
            # relevant here -- an explicit version above already states the intent directly.
            if ($ChangeLogContent -match '(?s)## !Deploy(.*?)(\n## |\z)' -and $Matches[1] -match '\[Breaking\]') {
                $Version = [Version]::new($Version.Major + 1, 0, 0)
                Write-Host "CHANGELOG contains a [Breaking] entry - bumping the major version to $Version instead" -ForegroundColor 'Yellow'
            }
        }

        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName 'ModuleVersion' -Value $Version -ErrorAction 'Stop'
    }
    catch {
        throw "Failed to update version for '$env:BHProjectName': $_.`n"
    }

    # deploy.psdeploy.ps1 publishes the combined module built by CombineFunctionsAndStage, not the source --
    # its manifest was copied from source before this task bumped the version above, so it needs the same
    # updates applied to it directly too.
    if (Test-Path $StagingModuleManifestPath) {
        Set-ModuleFunctions -Name $StagingModuleManifestPath
        Update-Metadata -Path $StagingModuleManifestPath -PropertyName 'ModuleVersion' -Value $Version -ErrorAction 'Stop'

        # Invoke-PSDeploy runs deploy.psdeploy.ps1 from inside the PSDeploy module's own function scope, which
        # can't see this task's local $StagingModulePath -- module scope boundaries block that. An environment
        # variable crosses the boundary instead.
        $env:BHStagingModulePath = $StagingModulePath
    }
    else {
        Write-Warning "Staging module not found at [$StagingModulePath] -- run the CombineFunctionsAndStage task first. Falling back to publishing directly from source."
    }

    $Params = @{
        Path    = "$ProjectRoot/Build/deploy.psdeploy.ps1"
        Force   = $true
        Recurse = $false
    }

    Invoke-PSDeploy @Verbose @Params

    # Update ChangeLog with deployment version and date
    $ChangeLogContent = $ChangeLogContent.Replace($DeployHeading, "## [$Version] - $(Get-Date -Format 'yyyy-MM-dd')")
    Set-Content -Path $ChangeLogPath -Value $ChangeLogContent -NoNewline

    # Signal to the pipeline that a real deploy happened, so the GitHubRelease step (which runs as a
    # later, separate step in the same job) knows to run. Only set when actually running in GitHub Actions.
    if ($env:GITHUB_OUTPUT) {
        "DidDeploy=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
    }
}

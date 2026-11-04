Task 'Commit' -Depends 'Init' {
    $lines

    Set-Location $ProjectRoot

    git --version
    git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git config --global user.name "github-actions[bot]"
    git checkout $env:GITHUB_REF_NAME

    git add Documentation/*.md
    git add README.md
    git add CHANGELOG.md
    git add $env:BHPSModuleManifest

    git commit -m "[skip ci] GitHub Actions Build $env:GITHUB_RUN_NUMBER"
    git push
}

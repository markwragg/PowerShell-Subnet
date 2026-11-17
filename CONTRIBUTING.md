# Contributing

## Guidelines

Contributions to this module are welcomed. Please consider the following guidance when making a contribution:

- Create an Issue for any features/bugs/questions and (if you submit a code change) reference this via your Pull Request.
- In general, this repository follows the guidance in the PowerShell Best Practices and Style Guide here: https://github.com/PoshCode/PowerShellPracticeAndStyle. In particular:
  - Use full cmdlet names
  - Be consistent with the existing code layout style (this is Stroustrup and its the default behaviour of the code auto-formatter for PowerShell in VSCode which I encourage you to use).
  - Function names should follow the Verb-Noun structure (even Private functions).
- Where possible please create a Pester test to cover any code changes you make and/or modify existing tests.
- Please ensure you update the comment-based help text for any new parameters you add as well as add new examples where it may be useful.

## Deployment

This module uses GitHub Actions for CI/CD. When a version of the code is ready for deployment, the following change needs to be committed in order for a new version to be deployed to the PowerShell Gallery:

- Update [CHANGELOG.md](CHANGELOG.md) to have a new section, titled `## !Deploy` followed by a list of changes for the new version.

By default the next version is calculated automatically (a patch bump, or a major bump if the section contains a `[Breaking]` entry). To pin a specific version instead, add it after `!Deploy`, e.g. `## !Deploy 2.0.0` -- when a version is given this way it's always used as-is, and the `[Breaking]` auto-bump is skipped. The build will fail if that version isn't later than what's already published to the PowerShell Gallery.

As part of the CI/CD pipeline the CHANGELOG.md file will then be automatically updated with the date and version of the module deployed, replacing the `!Deploy` heading.

Note deployments only occur from the Master branch.

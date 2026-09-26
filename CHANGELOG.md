# Change Log

## [Unreleased]

* [Feature] `Get-Subnet` now determines the local IPv4 address (when `-IP` is not specified) using .NET's cross-platform `NetworkInterface` API instead of the Windows-only `Get-NetIPAddress` cmdlet, so it now works on Linux and macOS. Throws a clear error if no local IPv4 address can be found.
* [Fix] Specifying a network as a combined `IP/Mask` string (e.g. `10.0.0.0/8`) with a single-digit mask (`/0` - `/9`) no longer silently skips the large-subnet warning and returns only a single host address -- the mask is now correctly parsed as a number instead of being compared as text.
* Migrated the module's Pester tests to Pester 6.
* Added unit tests for the module's private helper functions (`Convert-Int64toIP`, `Convert-IPtoInt64`, `Convert-SubnetMaskToPrefixLength`).

## [1.0.14] - 2019-09-10

* Test deployment, no changes.

## [1.0.12] - 2019-04-15

* [Fix] The `Test-PrivateIP` cmdlet now returns a correct result when a Private IP is provided via pipeline input.
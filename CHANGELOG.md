# Change Log

## [Unreleased]

* [Feature] Added `Get-SubnetHostAddress`, a cmdlet that returns just the list of host addresses for a given subnet, as `[ipaddress]` objects (use `-AsString` for plain strings instead). Unlike `Get-Subnet`, it always calculates and returns the addresses regardless of subnet size (that's its only job, so there's no `-Force`) -- it still warns if the subnet is larger than /16, since that may take some time. `Get-Subnet` now uses it internally to populate its own `HostAddresses` (still a string array). `Get-SubnetHostAddress` also accepts the object output by `Get-Subnet` via the pipeline.
* [Feature] `Get-Subnet`'s `HostAddressCount` is now always calculated, regardless of subnet size, since it's just arithmetic -- only the full `HostAddresses` list is skipped for subnets larger than /16 without `-Force`.
* [Fix] `Get-Subnet` and `Get-SubnetHostAddress` now throw a clear error for an invalid IP address, instead of silently treating it as a /0 network -- which, for `Get-SubnetHostAddress`, meant trying to enumerate all ~4.3 billion IPv4 addresses.
* Improved the performance of generating host addresses by roughly 20x for large `-Force`'d subnets, by replacing floating-point division with bitwise arithmetic.

## [1.1.0] - 2026-09-26

* [Feature] `Get-Subnet` now determines the local IPv4 address (when `-IP` is not specified) using .NET's cross-platform `NetworkInterface` API instead of the Windows-only `Get-NetIPAddress` cmdlet, so it now works on Linux and macOS. Throws a clear error if no local IPv4 address can be found.
* [Fix] Specifying a network as a combined `IP/Mask` string (e.g. `10.0.0.0/8`) with a single-digit mask (`/0` - `/9`) no longer silently skips the large-subnet warning and returns only a single host address -- the mask is now correctly parsed as a number instead of being compared as text.
* Migrated the module's Pester tests to Pester 6.
* Added unit tests for the module's private helper functions (`Convert-Int64toIP`, `Convert-IPtoInt64`, `Convert-SubnetMaskToPrefixLength`).

## [1.0.14] - 2019-09-10

* Test deployment, no changes.

## [1.0.12] - 2019-04-15

* [Fix] The `Test-PrivateIP` cmdlet now returns a correct result when a Private IP is provided via pipeline input.

# Change Log

## !Deploy 2.0.0

This release makes input validation stricter and changes some results. The `[Breaking]` entries below may need changes to existing scripts.

* [Breaking] `Test-PublicIP` now returns `$true` only for globally reachable unicast addresses, per the IANA IPv4 Special-Purpose Address Registry (RFC 6890). **This changes its result for some valid addresses.** Previously it was just the inverse of `Test-PrivateIP`, so it returned `$true` for addresses that are not public, including `0.0.0.0/8`, carrier-grade NAT (`100.64.0.0/10`), link-local (`169.254.0.0/16`), `192.0.0.0/24`, the documentation ranges (`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`), benchmarking (`198.18.0.0/15`), multicast (`224.0.0.0/4`), reserved (`240.0.0.0/4`) and broadcast (`255.255.255.255`). These now return `$false`. The full list is in the cmdlet's help.
* [Breaking] Invalid input to any cmdlet in the module is now reported as a non-terminating error, so when piping in several values, the valid ones are still processed. Use `-ErrorAction Stop` to stop at the first invalid value instead. Previously `Get-Subnet` and `Get-SubnetHostAddress` threw a terminating error for an invalid IP address, which stopped the whole pipeline, and could be caught by `try`/`catch` without `-ErrorAction Stop`.
* [Breaking] `Get-Subnet` and `Get-SubnetHostAddress` now only accept an IP address written as four plain decimal octets (e.g. `192.168.1.10`), as defined by RFC 3986 section 3.2.2, with no surrounding whitespace or line breaks. Previously .NET's lenient parsing let short, hex and octal forms through and silently resolved them to a different address than the one typed -- e.g. `1.2.3` became `1.2.0.3`, `0` became `0.0.0.0` (so `-IP 0` enumerated a `/0` network), and `010.1.1.1` became `8.1.1.1`. Those inputs, and non-string values such as `0` or a hashtable passed as `-IP`, now return a clear "not a valid IPv4 address" error. Note that zero-padded addresses which previously happened to resolve correctly (e.g. `192.168.001.001`) are now rejected too.
* `Test-PrivateIP`'s help now states exactly which ranges it tests (the RFC 1918 ranges plus loopback, `127.0.0.0/8`), and that an address which isn't private is not necessarily public. Its results are unchanged for valid addresses.
* [Fix] `Get-Subnet` and `Get-SubnetHostAddress` now return a clear error for an invalid mask in slash notation. Previously a mask outside /0 - /32 (e.g. `1.2.3.4/33`) was silently discarded and replaced with the address class default, with a warning that wrongly said no mask was specified, and anything after a second `/` (e.g. `1.2.3.4/24/8`) was ignored.
* [Fix] `Get-Subnet` and `Get-SubnetHostAddress` now return a clear error for an invalid `-MaskBits` value. Previously `-MaskBits` was an `[int]` parameter, so PowerShell silently converted `$null`, `''` and whitespace to `0` before validation ran, and they were treated as a `/0` network -- for `Get-SubnetHostAddress`, enumerating all ~4.3 billion IPv4 addresses. `-MaskBits` now accepts only an integer, or a numeric string with no leading zeros, from 0 to 32. The same applies to a mask given in slash notation (e.g. `10.0.0.0/08` is rejected), matching the no-leading-zeros rule for the address itself.
* [Fix] `Get-SubnetHostAddress` now accepts an `[ipaddress]` object as `-IP`, as `Get-Subnet` does.
* [Fix] `Get-SubnetHostAddress` no longer misbehaves when run without an `-IP`. Previously a missing `-IP` was treated as a piped `Get-Subnet` object, which threw an error on `$IP.IPAddress.ToString()` and left the mask unset, after which it began enumerating a `0.0.0.0/0` network. `-IP` is now mandatory, and a null, empty or whitespace value (including pressing Enter at the interactive prompt) returns a clear error instead of silently falling back to the local subnet.
* [Fix] `Get-NetworkClass`, `Test-PrivateIP` and `Test-PublicIP` now apply the same IP address input validation, via a new private function, `Test-IPv4Address`. Previously they did no validation; they now return a "not a valid IPv4 address" error instead.
* [Fix] `Get-SubnetHostAddress` given a piped object that has an `IPAddress` but no `MaskBits` no longer treats the missing mask as `/0`; the mask is inferred from the address class as usual.
* The `Get-SubnetHostAddress` help now documents that, when no mask is specified, one is inferred from the address class (/8, /16 or /24), which can mean a very large number of addresses for Class A and B networks.

## [1.2.2] - 2026-11-14
* Module Manifest improvements: Added `IconUri`, `'LicenseUri` and updated `ReleaseNotes` to point to this ChangeLog instead of the Readme.

## [1.2.1] - 2026-11-04

* [Fix] `Get-LocalIPv4Address` now correctly falls back to counting subnet mask bits when a network interface's `.PrefixLength` isn't implemented (e.g. on .NET Framework). PowerShell silently swallows exceptions thrown by a .NET property getter accessed via `.`, so the previous `try`/`catch` around `$UnicastAddress.PrefixLength` could never actually catch anything there and would silently end up with a `$null` prefix length instead of falling back. The property is now read via reflection, in a new private function, `Get-UnicastAddressPrefixLength`, so the fallback is reachable (and directly testable).

## [1.2.0] - 2026-09-26

* [Feature] Added `Test-PublicIP`, a cmdlet that returns `$true` or `$false` for a given IP address depending on whether or not it is within the public IP address space (i.e. the inverse of `Test-PrivateIP`).
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

# Guard Riverpod Example

Example using [riverpod `1.0.0-dev.7`](https://pub.dev/packages/riverpod).
The `1.0.0` (still as a `dev` release) introduces many breaking changes to `riverpod`,
which could be confusing if not used properly with `beamer`. These changes can be
read in detail in the package's [CHANGELOG](https://github.com/rrousselGit/river_pod/blob/master/packages/riverpod/CHANGELOG.md).

This example aims to be a simple approach on how to use provider (in this case, used
to change a `BeamGuard.check` return).

It also shows how it's trivial to pass a `Reader` instance, which can be obtained
anywhere a `riverpod` reference is available, and it's the recommended instance to pass
for objects that don't have access to the `build` lifecycle, meaning that they should
only read stuff - and is exactly our use-case here with the `beamer` delegate, guards
and locations.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/guard_riverpod/example-guard-riverpod.gif" alt="guard-riverpod-example">

Run `flutter create .` to generate all necessary files, if needed.

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Keyb is a macOS app (deployment target 13.0, Swift 6.4) for one-handed typing. It installs a system-wide `CGEvent` tap. While the spacebar is held, it mirrors the keyboard left-to-right. A space is typed on space key-up, but only if no other key was flipped during the hold. The mirror mapping is built for US-English QWERTY only.

## Open source: keep sensitive information out

This repo is public. Take extra care that nothing personal, secret or sensitive gets committed, including in code comments, docs, commit messages, test fixtures and screenshots. Feedback from users, especially users with disabilities, can be sensitive: never put their names, or anything else that identifies them, in the repo unless they have expressly given permission. Describe the feedback and its effect on the app without saying who it came from.

## Setup

- `Scripts/bootstrap.sh` must run once per clone. It installs the git pre-commit hook (which runs lint), Git LFS, and `blame.ignoreRevsFile`. It also marks `Keyb/Resources/xcconfig/BuildNumber.xcconfig` as `--skip-worktree`.
- The Keyb target has a build phase that runs `Scripts/environment-check.sh`. That script **fails the build** if the pre-commit hook isn't installed (it's skipped when `CI` is set).
- Another build phase runs `Keyb/Scripts/buildnumber.rb` via `mise x -- ruby`. It rewrites `BuildNumber.xcconfig`.
- To reset accessibility permissions while testing: `tccutil reset Accessibility com.zeveisenberg.Keyb`

## Tracking work

Open work is tracked in the public GitHub Issues (`gh issue`). Keep tickets terse, covering just the ask, without detailed project context.

## Building and testing

Source of truth for OS version is the Xcode project. Source of truth for Swift tools version is the top of `Packages/Package.swift`. Always build and test via the Xcode MCP tools (`mcp__xcode__BuildProject`, `mcp__xcode__RunAllTests`, etc.), not `swift build` / `xcodebuild`, unless explicitly instructed otherwise, so the stuff you are doing is visible in Xcode and build products are shared. If the Xcode MCP is disconnected or its tools aren't available, stop and ask the user to reconnect it rather than falling back to `xcodebuild`.

But when the MCP genuinely lacks a capability, reach for `xcodebuild` (or `swift test`) instead of doing without — e.g. repeating tests (`-test-iterations` / `-run-tests-until-failure`), which the MCP cannot do at all:

```sh
xcodebuild test -project Keyb.xcodeproj -scheme Keyb -destination 'platform=macOS' \
  -only-testing:KeyProcessorTests -test-iterations 100 -run-tests-until-failure
```

The `Keyb` scheme's tests are `KeyProcessorTests` and `UserInterfaceTests`.

## Other commands

- After any SwiftPM command in `Packages/`, delete `Packages/Package.resolved`. The resolved file that gets committed is the one in `Keyb.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/`.
- Lint runs automatically in the pre-commit hook, so don't run it manually. The exceptions are after editing `.swiftformat` or `.swiftlint.yml`, or when fixing lint failures from a rejected commit. In those cases run `Scripts/lint.sh`, which auto-applies SwiftFormat and then runs `swiftlint --strict`.
- Release (Developer ID build, uploaded to GitHub Releases): `GITHUB_TOKEN=$(gh auth token) bundle exec fastlane release tag:1.2.3`

## Architecture

The app target (`Keyb/KeybApp.swift`) is a thin shell. Nearly all code lives in the local SwiftPM package `Packages/`, which has one library product per target. The package uses The Composable Architecture (TCA) and swift-dependencies, both pinned to exact versions.

Layering, from low level to high level:

- **KeyProcessor**: a pure state machine. `process(event:type:)` takes a `CGEvent` and returns `Events`: optional `preEvents` to post first, plus an optional `mainEvent` to return from the tap (`nil` swallows the keystroke). The mirror mapping table lives here. It's separate so it can be unit-tested with synthetic `CGEvent`s (see `KeyProcessorTests`).
- **EventHandler**: owns the `CGEvent.tapCreate` session tap and the C callback trampoline. The callback passes `KeyProcessor` through `userInfo` as an unretained pointer. It has two modes: `.provisional` starts and then immediately stops the tap, only to trigger the system Accessibility prompt; `.active` intercepts keystrokes for real.
- **HumanReadable**: debug descriptions of event types and flags, used for privacy-preserving `os.log` output in DEBUG builds.
- **Dependency clients**: each side effect has an interface target and a separate `*Live` target. `AccessibilityClient` / `AccessibilityClientLive` and `EventHandlerClient` / `EventHandlerClientLive` are `@DependencyClient` structs. The interface target defines only `testValue` and preview helpers such as `.noop(enabled:)` and `.accessibilityIsEnabled`. The `liveValue` (`DependencyKey` conformance) is defined only in the `*Live` target. `UserInterface` depends only on the interface targets. The app target imports the `*Live` modules so that the live values get linked.
- **UserInterface**: the TCA feature. `UserInterface.State.mode` is either `.hasAccessibilityPermission(isRunning:)` or `.noAccessibilityPermission(reason)`, and `UserInterfaceView` switches on it to choose the onboarding, permission-error, or enable/disable view. While waiting for the user to grant permission, the reducer polls `isCurrentlyTrusted` every 0.5s on `mainQueue`. `AppFeature` combines `UserInterface` with `AppDelegateFeature`, which is scoped through a computed `State.appDelegate` and backs the Dock menu's "Enable One-Handed Typing" item in `KeybApp.swift`'s `AppDelegate`.

Tests use Swift Testing (`@Suite`/`@Test`), not XCTest. Reducer tests use TCA's `TestStore` with `DispatchQueue.test`.


---
description: Testing guidance for My Launchpad
applyTo: "**/*.swift"
---

# Testing Skills - My Launchpad

## Test Strategy

- Add tests with each feature or bug fix.
- Cover happy paths, edge cases, and failure paths.
- Keep tests deterministic and isolated from environment noise.
- Use fixtures and test doubles for I/O or external systems.

## Domain Focus

For My Launchpad (macOS app launcher with groups, hotkeys, and drag-drop organization):
- Validate core user flows and critical state transitions.
- Test import/export, persistence, and recovery scenarios where applicable.
- Verify behavior with malformed input and partial data.

## Quality Gates

- Unit tests should be fast and run in CI on every change.
- Integration tests should cover key boundaries between modules.
- Regressions should get a dedicated test before closing the fix.

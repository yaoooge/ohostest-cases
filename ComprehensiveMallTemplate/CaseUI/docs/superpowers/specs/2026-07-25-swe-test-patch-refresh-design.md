# SWE Test Patch Refresh Design

## Goal

Refresh `ComprehensiveMallTemplate/CaseUI/swe` and `test_patch.patch` from the
fully implemented and device-verified `answer` test suite without copying the
responsive solution into the base project.

## Source of Truth

The current `answer/products/entry/src/ohosTest` directory is the source of
truth for the complete test payload.

Test-support changes are selected from:

- committed `answer` changes after `f0be93e`, the last commit that synchronized
  test observability into `swe`;
- the current uncommitted `answer` changes that were included in the successful
  device test run.

Only changes required to make tests observable, deterministic, and navigable
are eligible for synchronization into `swe`.

## SWE Synchronization Boundary

Eligible changes include:

- component IDs used by UI TestKit;
- deterministic mock records and mock timing used by the tests;
- exports needed by test navigation;
- test-only navigation and observation support that does not implement a
  responsive layout requirement.

The following remain exclusive to `answer`:

- breakpoint selection or breakpoint state;
- responsive column templates and row/column switching;
- adaptive sizes, ratios, gaps, margins, panes, and popup placement;
- any other behavior that directly satisfies the task prompt.

Each selected support change is applied to the corresponding path under
`swe`. Files are not copied wholesale when the `answer` version also contains
responsive solution logic; only the support hunk is transferred.

## Test Patch Generation

`swe/products/entry/src/ohosTest` remains absent from the base project.
`test_patch.patch` is regenerated as a Git-compatible no-index diff whose
paths are relative to the `swe` project:

```text
a/products/entry/src/ohosTest/...
b/products/entry/src/ohosTest/...
```

The patch contains the complete current test directory, including the suite
entrypoint, common tests, SM/MD/LG suites, shared helper, and test module
configuration. Test-support production changes are deliberately excluded
because they are stored directly in `swe`.

## Validation

Validation proceeds in four layers:

1. Before synchronization, confirm the current `swe` and patch lack newly
   required IDs/tests, establishing the expected failing baseline.
2. Run the repository's static Node tests in `swe`.
3. Apply `test_patch.patch` to a temporary copy of `swe`, then verify:
   - `git apply --check` succeeds;
   - the applied `ohosTest` tree is byte-identical to the current `answer`
     test tree;
   - the generated patch contains no paths outside
     `products/entry/src/ohosTest`.
4. Run the available HarmonyOS build/test validation against the patched
   temporary project. Device matrix execution is repeated when the configured
   devices are available.

`git diff --check` must report no whitespace errors. Existing unrelated
working-tree changes and design/plan files are preserved.


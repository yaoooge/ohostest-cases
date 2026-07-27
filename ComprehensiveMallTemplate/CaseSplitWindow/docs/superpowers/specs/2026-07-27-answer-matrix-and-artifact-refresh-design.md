# CaseSplitWindow Answer Matrix and Artifact Refresh Design

## Goal

Make `ComprehensiveMallTemplate/CaseSplitWindow/answer` the reviewable source
of truth, prove every configured ohosTest case passes there with
`ohostest:matrix`, and only then rebuild the solution-with-errors (`swe`)
project and the test patch.

## Source of Truth and Execution Order

The current `test_patch.patch` is applied in place to `answer` first. This
preserves the requested baseline and makes both its test-support changes and
its ohosTest payload visible for review.

All implementation and test corrections made before the matrix is green are
made in `answer`. The existing `swe` and final `test_patch.patch` are not
rebuilt while any configured answer test is failing.

Validation runs directly against `answer` with the runner at:

```text
/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner
```

The matrix may be split by `--device phone`, `--device foldable`, and
`--device tablet` for faster diagnosis. After device-specific failures are
fixed, a final complete answer matrix confirms the combined result.

## Answer Repair Boundary

The answer must implement the split-shopping requirements in `PROMPT.md`
without adding responsive UI capabilities that belong to other cases.

Changes may include:

- split-window lifecycle and navigation behavior;
- test observability such as stable component IDs;
- deterministic data or timing needed for reliable tests;
- corrections to the ohosTest implementation when a test itself is invalid,
  flaky, or inconsistent with the prompt.

Every failure is diagnosed from the matrix result, per-suite output, and
per-case hilog before changing code. Device-specific reruns are used until the
affected suites pass, followed by the full matrix.

## SWE Reconstruction

The new `swe` is derived only after the answer matrix is fully passing.

The base project receives non-solution test support that is required for the
same tests to compile and observe behavior, including stable IDs,
test-navigation exports, and deterministic mock data. It must not receive:

- split-window implementation;
- answer-only window or navigation state;
- any behavior that satisfies a fail-to-pass requirement;
- unrelated responsive layout behavior.

The new `swe` must not contain
`products/entry/src/ohosTest`. The fail-to-pass behavior remains absent, while
all pass-to-pass behavior remains intact.

## Test Patch Contract

The final `test_patch.patch` is regenerated from the verified
`answer/products/entry/src/ohosTest` tree.

It has one strict scope:

```text
products/entry/src/ohosTest/**
```

No production source, build configuration outside the ohosTest module, stable
ID, mock-data, or other project modification may appear in the patch. Such
support belongs directly in both `answer` and `swe`.

Patch validation must prove:

1. every `diff --git` source and destination is under the allowed directory;
2. the patch applies cleanly to a disposable copy of the new `swe`;
3. the applied test tree is byte-identical to the verified answer test tree;
4. no file outside the allowed directory changes after application.

## Verification

Verification proceeds in this order:

1. Check the HarmonyOS build environment required by the Hvigor workflow.
2. Apply the existing test patch to `answer` and verify its payload.
3. Run answer-only matrix suites, optionally split by device.
4. Diagnose and fix answer failures, rerunning affected devices.
5. Run a final complete matrix against `answer`; every configured case must
   pass.
6. Rebuild `swe` with test support but without the split-window solution or
   embedded ohosTest directory.
7. Regenerate and scope-check `test_patch.patch`.
8. Apply the patch to a disposable `swe` copy, compare the test payload, run
   static checks and a HarmonyOS build, and confirm the intended SWE
   pass-to-pass/fail-to-pass behavior when device validation is required.
9. Run `git diff --check` and report the exact artifacts and matrix evidence.

The final handoff distinguishes test-case failures from infrastructure
failures. A device or emulator infrastructure failure is not treated as a
passing test and does not permit artifact generation before the answer matrix
has actually completed successfully.

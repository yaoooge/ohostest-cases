# Golden Patch Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Regenerate a project-relative golden patch that transforms the current SWE into the current answer while excluding generated artifacts and entry UI tests.

**Architecture:** Filtered disposable mirrors provide stable diff roots. A binary no-index diff becomes the artifact; a second clean SWE copy proves applicability and filtered-tree identity.

**Tech Stack:** Git binary patches, rsync, Node.js tests, HarmonyOS Hvigor

---

### Task 1: Establish the Stale Baseline

- [ ] Apply the old patch to a temporary current SWE copy.
- [ ] Compare the patched filtered tree with current filtered answer.
- [ ] Confirm they differ because the old patch predates the shared test-support synchronization.

### Task 2: Build Filtered Mirrors

- [ ] Create temporary `swe` and `answer` directories.
- [ ] Copy source trees with rsync while excluding `.DS_Store`, `.hvigor`,
  `.idea`, `.ohostest-runs`, `.test`, `build`, `oh_modules`,
  `BuildProfile.ets`, `oh-package-lock.json5`, and
  `products/entry/src/ohosTest`.
- [ ] List the remaining differences and confirm they contain answer/source
  changes only.

### Task 3: Generate the Artifact

- [ ] Run `git diff --no-index --binary` from filtered SWE to filtered answer.
- [ ] Normalize both temporary root prefixes to `a/` and `b/`.
- [ ] Replace `ComprehensiveMallTemplate/CaseUI/golden_patch.patch`.
- [ ] Assert no patch path references an excluded artifact.

### Task 4: Prove Applicability and Identity

- [ ] Copy current SWE to a fresh temporary directory using the same filters.
- [ ] Run `git apply --check` and apply the new golden patch.
- [ ] Compare the patched directory with the filtered answer using
  `git diff --no-index`; require exit code zero.
- [ ] Run `git diff --check`.

### Task 5: Regression and Build Validation

- [ ] Run all Node static tests in the patched project.
- [ ] Run `ohpm install` in the patched project.
- [ ] Run:

```bash
hvigorw --mode project -p product=default assembleApp \
  --analyze=normal --parallel --incremental --no-daemon
```

- [ ] Require `BUILD SUCCESSFUL` and report any non-blocking pre-existing
  warnings separately.

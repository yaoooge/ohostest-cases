# CaseSplitWindow Answer Matrix and Artifact Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the existing test payload to `answer`, make every configured answer matrix case pass, then rebuild a solution-free `swe` and an ohosTest-only `test_patch.patch`.

**Architecture:** `answer` is the only implementation source of truth until phone, foldable, tablet, and full matrix runs pass. Test-support production changes are copied into `swe` only after that gate; the final patch is regenerated solely from the verified `answer/products/entry/src/ohosTest` tree and proved not to touch any other path.

**Tech Stack:** ArkTS, HarmonyOS UI TestKit, Hypium, Hvigor, ohpm, hdc, HarmonyOS Emulator, Git patches, Node.js test runner

---

## File Structure

The existing patch initially modifies these answer test-support files:

- `answer/commons/lib_widget/src/main/ets/components/CommonSymbol.ets`
- `answer/features/product/src/main/ets/components/ProductInfoCards.ets`
- `answer/features/product/src/main/ets/views/ProductInfoPage.ets`
- `answer/products/entry/src/main/ets/tabviews/CartPage.ets`
- `answer/products/entry/src/main/ets/views/MainEntry.ets`

It creates the complete test payload under:

- `answer/products/entry/src/ohosTest/ets/test/CommonPassToPass.test.ets`
- `answer/products/entry/src/ohosTest/ets/test/List.test.ets`
- `answer/products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets`
- `answer/products/entry/src/ohosTest/ets/test/SplitFailToPass.test.ets`
- `answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`
- `answer/products/entry/src/ohosTest/module.json5`

Split-window behavior is implemented in or coordinated by:

- `answer/features/product/src/main/ets/utils/SplitCapability.ets`
- `answer/features/product/src/main/ets/views/ProductInfoPage.ets`
- `answer/products/entry/src/main/ets/entryability/EntryAbility.ets`
- `answer/products/entry/src/main/ets/secondability/SecondAbility.ets`
- `answer/products/entry/src/main/ets/utils/SplitNavStore.ets`
- `answer/products/entry/src/main/ets/utils/SetupUtil.ets`
- `answer/products/entry/src/main/ets/views/Index.ets`

The rebuilt SWE receives the five production-side test-support changes listed
above at their corresponding `swe/` paths, plus any later production-side
test support proved necessary by a failing answer test. It does not receive
the split-window solution files or an embedded entry ohosTest directory.

Regenerate:

- `ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch`

## Task 1: Establish Repository and Build Preconditions

- [ ] **Step 1: Confirm the worktree contains no unrelated uncommitted edits**

Run:

```bash
git status --short --branch
```

Expected: the branch header and only changes created by this plan. Stop rather
than overwrite any unrelated user change under `CaseSplitWindow`.

- [ ] **Step 2: Run the required HarmonyOS environment self-check**

Run:

```bash
java -version
node -v
ohpm -v
hvigorw -v
node -e "console.log(process.env.DEVECO_SDK_HOME || 'NOT SET')"
```

Expected: JDK 17 or newer, Node.js and ohpm versions, a working Hvigor command,
and a non-empty SDK path. If the shell Hvigor command is absent, use the
absolute `paths.hvigorw` value from the runner's `config/machine.json` for the
version check and subsequent direct build checks.

- [ ] **Step 3: Verify the existing patch is the intended failing-test baseline**

Run:

```bash
git apply --check \
  --directory=ComprehensiveMallTemplate/CaseSplitWindow/answer \
  ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch
rg '^diff --git ' ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch
```

Expected: the apply check exits `0`; eleven patch entries are listed, including
five production test-support files and six files below
`products/entry/src/ohosTest`.

## Task 2: Apply the Existing Test Patch to Answer

- [ ] **Step 1: Apply the patch in place**

Run:

```bash
git apply \
  --directory=ComprehensiveMallTemplate/CaseSplitWindow/answer \
  ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch
```

Expected: exit code `0`.

- [ ] **Step 2: Verify the expected answer payload**

Run:

```bash
find ComprehensiveMallTemplate/CaseSplitWindow/answer/products/entry/src/ohosTest \
  -type f -print | sort
rg -n "common-symbol|product-swiper|product-info-card|product-info-page|product-info-header-actions|product-info-scroll|product-cart-action|product-purchase-actions|cart-page|mall-root" \
  ComprehensiveMallTemplate/CaseSplitWindow/answer
```

Expected: the six entry ohosTest files and all ten stable IDs are present.

- [ ] **Step 3: Run the repository-local static answer tests**

Run:

```bash
node --test ComprehensiveMallTemplate/CaseSplitWindow/answer/tests/*.test.mjs
```

Expected: all tests pass with zero failures.

## Task 3: Verify the Phone Answer Suites

- [ ] **Step 1: Run the phone matrix**

From the runner directory, run:

```bash
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device phone \
  --keep-emulators true
```

Expected: `CommonPassToPassTest` has five passes and `SmPassToPassTest` has one
pass; no failed or errored test case.

- [ ] **Step 2: Verify the machine-readable phone result**

Open the run's `result.json` and confirm the phone device has six test cases,
each with status `passed`. A matrix-level `completed` status is necessary but
is not sufficient without the per-case check.

## Task 4: Verify the Foldable Answer Suites

- [ ] **Step 1: Run the foldable matrix**

From the runner directory, run:

```bash
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device foldable \
  --keep-emulators true
```

Expected: `CommonPassToPassTest` has five passes and
`SplitFailToPassTest` has seven passes; no failed or errored test case.

- [ ] **Step 2: Verify the machine-readable foldable result**

Open the run's `result.json` and confirm the foldable device has twelve test
cases, each with status `passed`.

## Task 5: Verify the Tablet Answer Suites

- [ ] **Step 1: Run the tablet matrix**

From the runner directory, run:

```bash
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device tablet \
  --keep-emulators true
```

Expected: `CommonPassToPassTest` has five passes and
`SplitFailToPassTest` has seven passes; no failed or errored test case.

- [ ] **Step 2: Verify the machine-readable tablet result**

Open the run's `result.json` and confirm the tablet device has twelve test
cases, each with status `passed`.

## Task 6: Repair Any Demonstrated Answer Failure

This task is skipped when Tasks 3–5 are green.

- [ ] **Step 1: Preserve the failing test as the RED proof**

For the failing device, retain the exact test in
`answer/products/entry/src/ohosTest/ets/test/CommonPassToPass.test.ets`,
`SmPassToPass.test.ets`, or `SplitFailToPass.test.ets`. Record its failed
assertion and matching per-case hilog. Do not change production code until the
failure is reproducible with the corresponding `--device` and
`--test-class`.

- [ ] **Step 2: Diagnose the responsible boundary**

Use the failed assertion to select the narrow implementation boundary:

- split action visibility: `SplitCapability.ets` and `ProductInfoPage.ets`;
- secondary creation/mode: `ProductInfoPage.ets` and `SecondAbility.ets`;
- initial product/navigation: `SetupUtil.ets`, `Index.ets`, and
  `SplitNavStore.ets`;
- merge and close recovery: `EntryAbility.ets`, `SecondAbility.ets`, and
  `SplitNavStore.ets`;
- test lookup/timing only: `TestHelper.ets` and the five stable-ID source
  files from File Structure.

Confirm from the log and source that the selected boundary explains the exact
failed assertion before editing it.

- [ ] **Step 3: Implement the smallest correction**

Modify only the selected boundary. Preserve the fixed single-column UI and all
existing pass-to-pass behavior. If the failure is a test defect, correct the
test/helper rather than weakening its product requirement.

- [ ] **Step 4: Re-run the exact failing suite for GREEN**

From the runner directory, run:

```bash
# Phone common suite
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device phone \
  --test-class CommonPassToPassTest \
  --keep-emulators true

# Phone SM suite
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device phone \
  --test-class SmPassToPassTest \
  --keep-emulators true

# Foldable common or split suite
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device foldable \
  --test-class CommonPassToPassTest \
  --keep-emulators true
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device foldable \
  --test-class SplitFailToPassTest \
  --keep-emulators true

# Tablet common or split suite
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device tablet \
  --test-class CommonPassToPassTest \
  --keep-emulators true
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --device tablet \
  --test-class SplitFailToPassTest \
  --keep-emulators true
```

Run only the command matching the RED result. Expected: every test in that
suite passes. Then rerun the full device command from Task 3, 4, or 5.

## Task 7: Run the Full Answer Matrix Gate

- [ ] **Step 1: Run all configured devices together**

From the runner directory, run:

```bash
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer \
  --keep-emulators false
```

Expected: phone has 6/6 passes, foldable has 12/12 passes, tablet has 12/12
passes, for 30/30 total passes and zero failures/errors.

- [ ] **Step 2: Enforce the artifact-generation gate**

Inspect `result.json`, not only the terminal summary. Do not modify `swe` or
regenerate `test_patch.patch` unless all thirty per-case statuses are
`passed`.

## Task 8: Rebuild SWE Test Support Without the Solution

- [ ] **Step 1: Establish that SWE still lacks fail-to-pass behavior**

Run the existing static tests:

```bash
node --test ComprehensiveMallTemplate/CaseSplitWindow/swe/tests/*.test.mjs
```

Expected: all tests pass.

- [ ] **Step 2: Copy only verified production-side test support**

Apply the stable-ID statements from the verified answer to these corresponding
SWE files:

- `swe/commons/lib_widget/src/main/ets/components/CommonSymbol.ets`
- `swe/features/product/src/main/ets/components/ProductInfoCards.ets`
- `swe/features/product/src/main/ets/views/ProductInfoPage.ets`
- `swe/products/entry/src/main/ets/tabviews/CartPage.ets`
- `swe/products/entry/src/main/ets/views/MainEntry.ets`

If Task 6 added another production-side test support statement, copy only that
statement. Do not copy split behavior from the answer.

- [ ] **Step 3: Prove the SWE does not contain the solution**

Run:

```bash
test ! -e ComprehensiveMallTemplate/CaseSplitWindow/swe/features/product/src/main/ets/utils/SplitCapability.ets
test ! -e ComprehensiveMallTemplate/CaseSplitWindow/swe/products/entry/src/main/ets/utils/SplitNavStore.ets
test ! -e ComprehensiveMallTemplate/CaseSplitWindow/swe/products/entry/src/main/ets/secondability/SecondAbility.ets
node --test ComprehensiveMallTemplate/CaseSplitWindow/swe/tests/*.test.mjs
```

Expected: all three absence checks exit `0` and every static SWE test passes.

## Task 9: Regenerate an ohosTest-Only Test Patch

- [ ] **Step 1: Generate the patch from the verified answer test tree**

Create a disposable empty directory, then run a Git no-index diff between it
and `answer/products/entry/src/ohosTest`. Normalize both path prefixes so
every entry is rooted at:

```text
a/products/entry/src/ohosTest/
b/products/entry/src/ohosTest/
```

Write the normalized diff to
`ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch`.

- [ ] **Step 2: Enforce the strict patch scope**

Run:

```bash
rg '^diff --git ' ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch
```

Expected: exactly six entries, all beneath
`products/entry/src/ohosTest/`. No `src/main`, project configuration, or
other path appears.

- [ ] **Step 3: Prove patch applicability and payload identity**

Copy the rebuilt SWE to a disposable temporary directory, initialize Git,
apply the final patch, and run:

```bash
diff -r \
  products/entry/src/ohosTest \
  /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseSplitWindow/answer/products/entry/src/ohosTest
git status --short
```

Expected: the recursive diff is empty; Git reports changes only below
`products/entry/src/ohosTest`.

## Task 10: Build and Final Verification

- [ ] **Step 1: Compile the patched disposable SWE**

In the patched SWE copy, run:

```bash
ohpm install
hvigorw --mode project -p product=default assembleApp \
  --analyze=normal --parallel --incremental --no-daemon
```

Expected: both commands exit `0` and the application/test build artifacts are
generated.

- [ ] **Step 2: Run final repository integrity checks**

Run:

```bash
git diff --check
git status --short
rg '^diff --git ' ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch
```

Expected: no whitespace errors; only intended `answer`, `swe`, test patch,
report, and plan changes are present; every patch entry remains under
`products/entry/src/ohosTest`.

- [ ] **Step 3: Report exact evidence**

Report the answer matrix run directories, per-device and total pass counts,
static test results, SWE build result, final patch entry list, and every
changed source file. Do not claim completion from a matrix-level `completed`
status alone.

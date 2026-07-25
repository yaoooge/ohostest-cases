# CaseUI Test Stability Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the CaseUI UITests deterministic while keeping every component test ID in the base project and limiting `test_patch.patch` to `ohosTest/`.

**Architecture:** Stable `mall-*` IDs are shared source-level contracts present in both `swe` and `answer`, so neither runtime patch carries them. `test_patch.patch` injects only the test module and uses bounded polling with `Driver.delayMs`; case runner remains the only end-to-end verifier.

**Tech Stack:** ArkTS, Hypium, HarmonyOS TestKit, unified diff patches, harmonyos-ohostest-runner.

---

### Task 1: Establish patch-boundary RED

**Files:**
- Test: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`

- [ ] **Step 1: Run a structural assertion that rejects non-ohosTest paths**

```bash
awk '/^diff --git / { if ($3 !~ /\/ohosTest\// || $4 !~ /\/ohosTest\//) { print; bad=1 } } END { exit bad }' \
  ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: FAIL and print the seven current `src/main/ets` diff headers.

### Task 2: Move stable IDs into the base contract

**Files:**
- Modify in both `ComprehensiveMallTemplate/CaseUI/swe` and `ComprehensiveMallTemplate/CaseUI/answer`:
  - `components/module_product_category/src/main/ets/views/ProductCategory.ets`
  - `features/product/src/main/ets/components/ProductInfoCards.ets`
  - `features/product/src/main/ets/components/ProductOperationButton.ets`
  - `features/product/src/main/ets/components/ProductWaterFlow.ets`
  - `features/product/src/main/ets/views/ProductInfoPage.ets`
  - `products/entry/src/main/ets/components/HomePageContent.ets`
  - `products/entry/src/main/ets/tabviews/HomePage.ets`
  - `products/entry/src/main/ets/views/MainEntry.ets`

- [ ] **Step 1: Add the existing IDs identically to swe and answer**

Keep the existing IDs from `test_patch.patch` and add:

```arkts
.id('mall-add-to-cart')
.id('mall-buy-now')
```

to the two product operation buttons.

- [ ] **Step 2: Verify every required ID exists exactly once per side where applicable**

Run `rg -n "mall-(...)"` over both trees and compare the ID name sets.

Expected: identical ID sets in `swe` and `answer`.

### Task 3: Make UITest polling deterministic

**Files:**
- Modify: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`

- [ ] **Step 1: Replace idle polling with real bounded delay**

Use `await driver.delayMs(300)` between lookup attempts in both `waitForComponentById` and `waitForComponentByText`, retaining the retry-count API.

- [ ] **Step 2: Isolate state without synthetic scrolling**

Call `prepareHome()` in `should_keep_home_content_available`, then verify the successful home-content state through the home root, search, and banner IDs. Do not synthesize swipe or component scrolling in the common test: the dedicated SM/MD/LG cases own product-column discrimination, and `Refresh + Scroll + WaterFlow` does not expose a stable TestKit scrolling surface on all devices.

Keep each product-column case self-contained by calling `prepareHome()` immediately before `countItemsInFirstRow`.

- [ ] **Step 3: Replace localized purchase text selectors with IDs**

Assert `mall-customer-service`, `mall-shopping-cart`, `mall-add-to-cart`, and `mall-buy-now`.

- [ ] **Step 4: Remove every non-ohosTest diff from test patch**

The first diff in the resulting patch must be `products/entry/src/ohosTest/ets/test/CommonPassToPass.test.ets`.

### Task 4: Verify patch composition

**Files:**
- Verify: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`
- Verify: `ComprehensiveMallTemplate/CaseUI/golden_patch.patch`

- [ ] **Step 1: Re-run patch-boundary assertion**

Expected: PASS with no output.

- [ ] **Step 2: Apply test patch to a clean copy of swe**

Expected: patch applies and only creates or changes `products/entry/src/ohosTest/**`.

- [ ] **Step 3: Apply golden patch after test patch**

Expected: patch applies without conflict and retains all base IDs.

### Task 5: Run Case Runner validation

**Files:**
- Verify all assets under `ComprehensiveMallTemplate/CaseUI`

- [ ] **Step 1: Execute the complete matrix**

```bash
npm run ohostest:case -- \
  --case /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI \
  --run all
```

Working directory:

```text
/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner
```

Expected: SWE pass-to-pass cases pass, SWE fail-to-pass cases fail, and all answer cases pass.

- [ ] **Step 2: If emulator orchestration blocks the matrix, rerun each selected device through the same case command**

Use `--device phone`, `--device foldable`, and `--device tablet` separately with `--run all`. Do not invoke matrix mode or raw HDC as a substitute.

- [ ] **Step 3: Run repository integrity checks**

```bash
git diff --check
```

Expected: exit code 0.

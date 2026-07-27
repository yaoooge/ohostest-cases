# Home Test Visibility Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the CaseUI UI tests independent of whether the oversized SWE home Banner leaves product content inside the initial viewport, regenerate `test_patch.patch`, and verify the SWE classification with the requested runner command.

**Architecture:** `prepareHome()` establishes only the home route and visible shell. A separate `revealHomeProducts()` performs bounded swipe-and-detect attempts until product cards are realized. Each Common test prepares its own state, and entries below the fold are revealed before interaction.

**Tech Stack:** ArkTS, HarmonyOS UI TestKit, Hypium, Git patches, Node.js static tests, Hvigor, harmonyos-ohostest-runner

---

## Files

- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/CommonPassToPass.test.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/MdFailToPass.test.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/components/module_product_category/src/main/ets/views/ProductCategory.ets`
- Modify: `ComprehensiveMallTemplate/CaseUI/swe/components/module_product_category/src/main/ets/views/ProductCategory.ets`
- Regenerate: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`

## Task 1: Record the Failing Baseline

- [ ] **Step 1: Confirm the supplied report failure signatures**

Run:

```bash
rg -n "component not found: mall-product-item|component not found: mall-home-content|incorrect" \
  ComprehensiveMallTemplate/CaseUI/.ohostest-runs/2026-07-25T08-44-29-751Z
```

Expected: foldable/tablet Common setup failures reference `mall-product-item`;
the phone category failure references `mall-home-content`; the summary reports
11 incorrect results.

- [ ] **Step 2: Confirm the current helper couples shell and products**

Run:

```bash
rg -n "returnToHome|mall-home-content|mall-product-item|openSeckill" \
  ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets
```

Expected: `returnToHome()` waits for `mall-product-item`, and `openSeckill()`
does not scroll the home container.

## Task 2: Separate Shell Readiness from Product Visibility

- [ ] **Step 1: Stabilize route replacement**

In `returnToHome()`, pop secondary destinations back to the existing
`MAIN_ENTRY` root with `popToName()`. Use `replacePath()` only as a fallback
when the root shell is genuinely missing, then explicitly select the home Tab
and use bounded downward Driver swipes until the top search node is visible.
Do not call Component `scrollToTop()` or `scrollSearch()` on the nested home
container. After either path, wait for
`mall-main-entry`, `mall-home-page`, `mall-home-content`, and all four main Tab
IDs, but do not wait for `mall-product-item`.

- [ ] **Step 2: Add an explicit product reveal helper**

Add exported `revealHomeProducts(driver)`. It calls `prepareHome()`, calculates
the visible `mall-home-scroll` bounds, and performs at most six upward swipes
with component checks between them. Do not use `scrollSearch()` because it can
outlive Hypium's 15-second timeout on the nested `Scroll + WaterFlow`.

- [ ] **Step 3: Keep direct-route tests independent of home scroll state**

For seckill, search, category, and product-detail helpers, restore the existing
home root and directly push the destination route. Do not reverse-scroll a
WaterFlow that a preceding pinch test may have left in a transformed state.

## Task 3: Make Test Setup Match Each Assertion

- [ ] **Step 1: Remove the Common suite setup cascade**

Make Common `beforeAll` obtain only the shared Driver. Call `prepareHome()` in
the startup, main-tab, home-content, and split-action tests.

- [ ] **Step 2: Update product layout tests**

Import and call `revealHomeProducts()` before all home product row-count and
pinch assertions:

- SM: product columns and pinch behavior.
- MD: product columns and pinch behavior.
- LG: product columns and pinch behavior.

Banner, search-position, and home-category tests continue to use
`prepareHome()` so they remain at the top of the page.

- [ ] **Step 3: Stabilize tab clicks and transient skeleton reads**

Wait for category/cart/profile Tab IDs before locating and clicking them. When
counting transient skeleton nodes, catch stale widget handles and reacquire the
current node list with a short retry interval. Tab-switch helpers should reuse
an existing home shell without resetting its scroll position; Tab interaction
does not depend on top-of-page content. Add the same category Skeleton item ID
to answer and SWE, then count those transient items because they use the exact
same responsive grid as product cards without depending on request completion.

- [ ] **Step 4: Check ArkTS source integrity**

Run:

```bash
git diff --check -- \
  ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest
```

Expected: no output and exit code `0`.

## Task 4: Regenerate and Prove the Test Patch

- [ ] **Step 1: Regenerate the complete ohosTest patch**

Create a no-index diff from an empty directory to
`answer/products/entry/src/ohosTest`, normalize paths to
`products/entry/src/ohosTest`, and replace
`ComprehensiveMallTemplate/CaseUI/test_patch.patch`.

- [ ] **Step 2: Validate patch scope and content**

Run:

```bash
rg '^diff --git ' ComprehensiveMallTemplate/CaseUI/test_patch.patch
rg -n "revealHomeProducts|revealHomeComponent|waitForIdle|driver.swipe" \
  ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: the patch contains the seven ohosTest files only and includes all
new synchronization behavior.

- [ ] **Step 3: Apply to a disposable SWE copy**

Initialize a temporary Git repository from the current SWE directory, run
`git apply --check`, apply the patch, and compare the resulting
`products/entry/src/ohosTest` tree byte-for-byte with answer.

Expected: patch application succeeds and the test trees are identical.

## Task 5: Run Local Static and Build Verification

- [ ] **Step 1: Run SWE static tests**

Run:

```bash
node --test ComprehensiveMallTemplate/CaseUI/swe/tests/*.test.mjs
```

Expected: all tests pass.

- [ ] **Step 2: Build a patched disposable SWE project**

After applying `test_patch.patch` to the temporary SWE project, run the
project's Hvigor test/application build command used by CaseUI.

Expected: ArkTS compilation and HAP assembly complete successfully.

## Task 6: Run the Requested SWE Evaluation

- [ ] **Step 1: Execute the exact case runner command**

From
`/Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner`:

```bash
npm run ohostest:case -- \
  --case /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI \
  --run swe
```

- [ ] **Step 2: Inspect the generated summary and device logs**

Expected:

- Common pass-to-pass tests no longer fail in `beforeAll`.
- The SM category test no longer loses `mall-home-content` during route
  replacement.
- MD/LG fail-to-pass tests fail at their intended responsive assertions.
- The final classification contains no incorrect test cases.

- [ ] **Step 3: Report evidence**

Provide the runner exit status, summary path, correct/incorrect totals, and any
remaining failure signature. Do not claim success unless the fresh output
supports it.

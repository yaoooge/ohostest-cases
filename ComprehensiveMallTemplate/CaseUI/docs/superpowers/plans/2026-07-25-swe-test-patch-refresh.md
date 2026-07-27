# SWE Test Patch Refresh Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Synchronize all non-solution test support from the verified `answer` into `swe` and regenerate a complete, cleanly applicable `test_patch.patch`.

**Architecture:** Production-side observability and deterministic test data live directly in `swe`; the HarmonyOS test source tree remains absent from `swe` and is delivered only by `test_patch.patch`. Support hunks are sourced from the test-focused commits after `f0be93e` plus the current verified answer diff, while responsive implementation hunks are excluded.

**Tech Stack:** ArkTS, HarmonyOS UI TestKit, Hypium, Git patches, Node.js static tests, Hvigor, harmonyos-ohostest-runner

---

## File Structure

Modify the following `swe` test-support files:

- `commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets`
- `commons/lib_network/src/main/ets/httpsmock/mockapis/ProductMock.ets`
- `commons/lib_network/src/main/ets/httpsmock/mockapis/ShoppingCartMock.ets`
- `commons/lib_network/src/main/ets/httpsmock/mockdata/MockProductData.ets`
- `commons/lib_widget/src/main/ets/components/CommonSkeletons.ets`
- `components/module_product_review/Index.ets`
- `components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`
- `components/module_product_search/src/main/ets/components/SearchBar.ets`
- `components/module_shopping_cart/src/main/ets/components/CartControlPanel.ets`
- `components/module_shopping_cart/src/main/ets/components/CartListView.ets`
- `features/order/src/main/ets/components/OrderInfoCard.ets`
- `features/order/src/main/ets/views/OrderListPage.ets`
- `features/order/src/main/ets/views/OrderReviewCreatePage.ets`
- `features/points/src/main/ets/views/PointsMallPage.ets`
- `features/product/src/main/ets/components/ProductInfoCards.ets`
- `features/product/src/main/ets/components/ProductReviewCard.ets`
- `features/product/src/main/ets/views/ProductInfoPage.ets`
- `features/setting/src/main/ets/components/ProductList.ets`
- `features/shopping/src/main/ets/components/SortBar.ets`
- `features/shopping/src/main/ets/views/ProductSearchResultsPage.ets`
- `features/shopping/src/main/ets/views/SeckillListPage.ets`
- `products/entry/src/main/ets/components/HomePageContent.ets`
- `products/entry/src/main/ets/tabviews/HomePage.ets`
- `products/entry/src/main/ets/tabviews/ProfilePage.ets`

Regenerate:

- `ComprehensiveMallTemplate/CaseUI/test_patch.patch`

Do not create:

- `ComprehensiveMallTemplate/CaseUI/swe/products/entry/src/ohosTest`

### Task 1: Establish the Failing Baseline

- [ ] **Step 1: Confirm new coverage is absent from the current patch**

Run:

```bash
rg -n "should_show_two_order_columns_on_lg|should_show_four_points_products_on_lg|should_show_two_seckill_columns_on_lg" \
  ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: exit code `1`; none of the three verified tests is present.

- [ ] **Step 2: Confirm required SWE observability is absent**

Run:

```bash
rg -n "mall-order-item|mall-points-product-item|mall-seckill-item" \
  ComprehensiveMallTemplate/CaseUI/swe/features
```

Expected: exit code `1`; the new list item IDs are absent.

### Task 2: Synchronize Committed Test Support

- [ ] **Step 1: Inspect the exact support hunks**

Run:

```bash
git show --format= --no-ext-diff 9764e73 358c85e e3041ff 17ea73e -- \
  ComprehensiveMallTemplate/CaseUI/answer \
  ':(exclude)ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/**'
```

Expected: only component IDs, deterministic mock data/timing, and test navigation exports from the four test commits.

- [ ] **Step 2: Apply the same support hunks to SWE**

Use `apply_patch` to add the corresponding committed hunks to the 19 matching
`swe` files listed in File Structure. Preserve every existing SWE layout
expression. In files that differ because `answer` contains responsive logic,
transfer only the added ID/export/mock-data statements from the commit diff.

- [ ] **Step 3: Verify no responsive implementation was copied**

Run:

```bash
git diff -- ComprehensiveMallTemplate/CaseUI/swe | \
  rg "Breakpoint|columnTemplate|LG|MD|SM|isExpanded|windowWidth|2\.5|5:1"
```

Expected: exit code `1`; the SWE diff contains no breakpoint or adaptive-layout implementation.

### Task 3: Synchronize Current Verified Test Support

- [ ] **Step 1: Inspect current answer-only production changes**

Run:

```bash
git diff -- \
  ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets \
  ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ProductMock.ets \
  ComprehensiveMallTemplate/CaseUI/answer/features/order/src/main/ets/views/OrderListPage.ets \
  ComprehensiveMallTemplate/CaseUI/answer/features/points/src/main/ets/views/PointsMallPage.ets \
  ComprehensiveMallTemplate/CaseUI/answer/features/setting/src/main/ets/components/ProductList.ets \
  ComprehensiveMallTemplate/CaseUI/answer/features/shopping/src/main/ets/views/SeckillListPage.ets \
  ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/main/ets/components/HomePageContent.ets \
  ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/main/ets/tabviews/ProfilePage.ets
```

Expected: deterministic mock adjustments plus IDs for order, points,
collection/history, seckill, home entry, and profile entries.

- [ ] **Step 2: Apply the current support hunks to SWE**

Use `apply_patch` to transfer those exact support statements into the eight
matching `swe` files. Do not replace full files or change responsive layout
properties.

- [ ] **Step 3: Confirm all new IDs exist**

Run:

```bash
rg -n "mall-order-item|mall-points-product-item|mall-setting-product-item|mall-seckill-item" \
  ComprehensiveMallTemplate/CaseUI/swe/features
```

Expected: all four IDs are reported from their corresponding SWE components.

### Task 4: Run SWE Static Regression Tests

- [ ] **Step 1: Run all standalone Node tests**

Run:

```bash
node --test ComprehensiveMallTemplate/CaseUI/swe/tests/*.test.mjs
```

Expected: every test passes with zero failures.

- [ ] **Step 2: Check source diff integrity**

Run:

```bash
git diff --check -- ComprehensiveMallTemplate/CaseUI/swe
```

Expected: no output and exit code `0`.

### Task 5: Regenerate the Complete Test Patch

- [ ] **Step 1: Generate a no-index test-tree diff**

From `ComprehensiveMallTemplate/CaseUI`, run:

```bash
git diff --no-index --src-prefix=a/ --dst-prefix=b/ \
  /dev/null answer/products/entry/src/ohosTest
```

Normalize the generated paths so every patch entry is rooted at:

```text
products/entry/src/ohosTest/
```

Write the normalized generated artifact to
`ComprehensiveMallTemplate/CaseUI/test_patch.patch`.

- [ ] **Step 2: Validate patch scope**

Run:

```bash
rg '^diff --git ' ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: seven entries, all under `products/entry/src/ohosTest`:
`CommonPassToPass.test.ets`, `LgFailToPass.test.ets`, `List.test.ets`,
`MdFailToPass.test.ets`, `SmPassToPass.test.ets`, `TestHelper.ets`, and
`module.json5`.

- [ ] **Step 3: Confirm the new coverage is present**

Run:

```bash
rg -n "should_show_two_order_columns_on_lg|should_show_four_points_products_on_lg|should_show_two_seckill_columns_on_lg" \
  ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: all three test names are found.

### Task 6: Prove Patch Applicability and Payload Identity

- [ ] **Step 1: Create a disposable SWE copy**

Run:

```bash
mktemp -d /tmp/caseui-patch-check.XXXXXX
```

Copy `ComprehensiveMallTemplate/CaseUI/swe` into the returned temporary
directory. This copy is validation-only and must not alter the workspace.

- [ ] **Step 2: Check and apply the patch**

Inside the temporary SWE copy, run:

```bash
git init
git add .
git apply --check /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/test_patch.patch
git apply /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: both apply commands exit `0`.

- [ ] **Step 3: Compare the applied test tree to answer**

Run:

```bash
diff -r \
  products/entry/src/ohosTest \
  /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest
```

Expected: no output and exit code `0`.

### Task 7: Build and Final Verification

- [ ] **Step 1: Run the HarmonyOS compile check on patched SWE**

In the patched temporary SWE project, run the project compile command selected
by the `harmonyos-hvigor` skill.

Expected: build exits `0`.

- [ ] **Step 2: Run device suites when configured devices are available**

Run the `ohostest:matrix` suites for:

```text
phone    SmPassToPassTest
foldable MdFailToPassTest
tablet   LgFailToPassTest
```

Expected: all suites pass. If a configured device is unavailable, record the
exact runner output and retain the successful build, patch-apply, payload, and
static-test evidence.

- [ ] **Step 3: Perform final repository checks**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; only the intended SWE support changes,
`test_patch.patch`, the pre-existing answer changes, and pre-existing plan
files are present.

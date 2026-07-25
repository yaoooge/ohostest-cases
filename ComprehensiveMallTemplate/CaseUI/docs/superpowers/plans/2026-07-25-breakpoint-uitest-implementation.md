# Comprehensive Mall Breakpoint UI Test Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the approved SM, MD, and LG breakpoint UI tests to the `answer` project, prove every Answer test passes with `ohostest:matrix`, then regenerate `test_patch.patch` from a clean SWE base and verify SWE classification with `ohostest:case --run swe`.

**Architecture:** `answer` is the only development and review project. Production components receive stable test IDs, while `TestHelper.ets` owns navigation, geometry, row-count, and pinch operations; breakpoint suites contain only page setup and assertions. After Answer passes on phone, foldable, and tablet, test-only changes are extracted into a patch that applies cleanly to the unchanged `swe` baseline.

**Tech Stack:** HarmonyOS ArkTS, Hypium, `@kit.TestKit` UI Test, Hvigor, `harmonyos-ohostest-runner` matrix/case modes, Git patches.

---

## File Structure

### Test files

- Modify `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`
  - Shared navigation, component lookup, relative-position checks, first-row counting, and pinch actions.
- Modify `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets`
  - All SM-only breakpoint assertions.
- Modify `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/MdFailToPass.test.ets`
  - All MD-only breakpoint assertions.
- Modify `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets`
  - All LG-only breakpoint assertions.

### Test observability files

- Modify `answer/products/entry/src/main/ets/components/HomePageContent.ets`
- Modify `answer/products/entry/src/main/ets/tabviews/ProfilePage.ets`
- Modify `answer/features/shopping/src/main/ets/views/ProductSearchResultsPage.ets`
- Modify `answer/features/shopping/src/main/ets/views/SeckillListPage.ets`
- Modify `answer/features/product/src/main/ets/components/ProductReviewCard.ets`
- Modify `answer/features/product/src/main/ets/components/ProductInfoCards.ets`
- Modify `answer/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`
- Modify `answer/features/order/src/main/ets/views/OrderReviewCreatePage.ets`
- Modify `answer/commons/lib_network/src/main/ets/httpsmock/mockdata/MockProductData.ets`
- Modify `answer/components/module_shopping_cart/src/main/ets/components/CartListView.ets`
- Modify `answer/components/module_shopping_cart/src/main/ets/components/CartControlPanel.ets`
- Modify `answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ShoppingCartMock.ets`
- Modify `answer/features/order/src/main/ets/views/OrderListPage.ets`
- Modify `answer/features/order/src/main/ets/components/OrderInfoCard.ets`
- Modify `answer/features/points/src/main/ets/views/PointsMallPage.ets`
- Modify `answer/features/setting/src/main/ets/components/ProductList.ets`
- Modify `answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ProductMock.ets`
- Modify `answer/commons/lib_widget/src/main/ets/components/CommonSkeletons.ets`
- Modify `answer/commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets`

These source changes may only add stable IDs or deterministic test timing. They must not change responsive behavior.

### Final case files

- Modify `ComprehensiveMallTemplate/CaseUI/metadata.json`
- Replace `ComprehensiveMallTemplate/CaseUI/test_patch.patch`
- Keep `ComprehensiveMallTemplate/CaseUI/swe/**` unchanged in the final repository state.

## Task 1: Add Shared Geometry and Pinch Helpers

**Files:**

- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`

- [ ] **Step 1: Add reusable relative-position helpers**

Add these functions after `countItemsInFirstRow`:

```ts
export async function isComponentBelow(
  driver: Driver,
  upperId: string,
  lowerId: string,
  tolerance: number = 12,
): Promise<boolean> {
  const upper = await driver.findComponent(ON.id(upperId));
  const lower = await driver.findComponent(ON.id(lowerId));
  const upperBounds = await upper.getBounds();
  const lowerBounds = await lower.getBounds();
  return lowerBounds.top >= upperBounds.bottom - tolerance;
}

export async function isComponentLeftOf(
  driver: Driver,
  leftId: string,
  rightId: string,
  tolerance: number = 12,
): Promise<boolean> {
  const left = await driver.findComponent(ON.id(leftId));
  const right = await driver.findComponent(ON.id(rightId));
  const leftBounds = await left.getBounds();
  const rightBounds = await right.getBounds();
  return leftBounds.right <= rightBounds.left + tolerance;
}

export async function areComponentsOnSameRow(
  driver: Driver,
  firstId: string,
  secondId: string,
  tolerance: number = 3,
): Promise<boolean> {
  const first = await driver.findComponent(ON.id(firstId));
  const second = await driver.findComponent(ON.id(secondId));
  const firstBounds = await first.getBounds();
  const secondBounds = await second.getBounds();
  return Math.abs(firstBounds.top - secondBounds.top) <= tolerance;
}
```

- [ ] **Step 2: Add pinch helpers using the supported TestKit component APIs**

```ts
export async function pinchOutById(driver: Driver, id: string, scale: number = 2): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchOut(scale);
  await driver.waitForIdle(300, 1500);
}

export async function pinchInById(driver: Driver, id: string, scale: number = 0.5): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchIn(scale);
  await driver.waitForIdle(300, 1500);
}

export async function resetPinchById(driver: Driver, id: string): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchOut(1.01);
  await driver.waitForIdle(300, 1500);
}
```

`pinchOut(1.01)` deliberately enters the production reset branch `0.9 < scale < 1.1`.

- [ ] **Step 3: Build the Answer test module through matrix mode**

Run:

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:matrix -- --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer --device phone --test-class SmPassToPassTest
```

Expected: matrix status `completed`; no ArkTS type errors for `pinchOut`, `pinchIn`, or the new helpers.

- [ ] **Step 4: Commit**

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets
git commit -m "test: add breakpoint geometry helpers"
```

## Task 2: Add Home, Category, and Pinch Coverage

**Files:**

- Modify: `answer/products/entry/src/main/ets/components/HomePageContent.ets`
- Modify: `answer/products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets`
- Modify: `answer/products/entry/src/ohosTest/ets/test/MdFailToPass.test.ets`
- Modify: `answer/products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets`
- Modify: `answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`

- [ ] **Step 1: Add stable category IDs**

In `HomePageContent.ets`, add IDs to the category row and repeated category item:

```ts
Row({ space: 16 }) {
  ForEach(this.categoryList, (category: CategoryItem) => {
    Column() {
      // existing image and text
    }
    .id('mall-home-category-item')
    // existing modifiers
  }, (category: CategoryItem) => category.id)
}
.id('mall-home-category-row')
```

- [ ] **Step 2: Add the SM home-position and pinch tests**

Add imports for `isComponentBelow`, `pinchOutById`, and `pinchInById`, then add:

```ts
it('should_keep_search_below_title_on_sm', Level.LEVEL2, async (done: Function) => {
  await prepareHome();
  expect(await isComponentBelow(driver, 'mall-home-title-row', 'mall-home-search')).assertTrue();
  done();
});

it('should_ignore_product_pinch_on_sm', Level.LEVEL2, async (done: Function) => {
  await prepareHome();
  await pinchOutById(driver, 'mall-product-waterflow');
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
  await pinchInById(driver, 'mall-product-waterflow');
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
  done();
});
```

- [ ] **Step 3: Add the MD pinch-range test**

```ts
it('should_change_product_columns_between_two_and_four_on_md', Level.LEVEL2, async (done: Function) => {
  await prepareHome();
  await pinchOutById(driver, 'mall-product-waterflow', 2);
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
  await resetPinchById(driver, 'mall-product-waterflow');
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(3);
  await pinchInById(driver, 'mall-product-waterflow', 0.5);
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(4);
  done();
});
```

Also add `should_keep_search_below_title_on_md` with the same relative-position assertion as SM.

- [ ] **Step 4: Add LG category and pinch tests**

Add:

```ts
it('should_show_four_category_columns_on_lg', Level.LEVEL2, async (done: Function) => {
  await openCategory(driver);
  expect(await countItemsInFirstRow(driver, 'mall-category-item')).assertEqual(4);
  done();
});

it('should_change_product_columns_between_four_and_six_on_lg', Level.LEVEL2, async (done: Function) => {
  await prepareHome();
  await pinchOutById(driver, 'mall-product-waterflow', 2);
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(4);
  await resetPinchById(driver, 'mall-product-waterflow');
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(5);
  await pinchInById(driver, 'mall-product-waterflow', 0.5);
  expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(6);
  done();
});
```

Implement `should_distribute_home_categories_across_available_width_on_lg` by collecting
`ON.id('mall-home-category-item')`, asserting the first visible row contains every category, and checking that the
first item starts in the left half while the last item ends in the right half of `mall-home-category-row`. Do not
assert item widths.

- [ ] **Step 5: Run the three breakpoint suites separately**

Run the three matrix commands:

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:matrix -- --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer --device phone --test-class SmPassToPassTest
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:matrix -- --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer --device foldable --test-class MdFailToPassTest
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:matrix -- --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer --device tablet --test-class LgFailToPassTest
```

Expected: every registered test in each selected suite is `passed`.

- [ ] **Step 6: Commit**

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/main/ets/components/HomePageContent.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test
git commit -m "test: cover responsive home layouts"
```

## Task 3: Add Search List and Skeleton Coverage

**Files:**

- Modify: `answer/features/shopping/src/main/ets/views/ProductSearchResultsPage.ets`
- Modify: `answer/commons/lib_widget/src/main/ets/components/CommonSkeletons.ets`
- Modify: `answer/commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets`
- Modify: the three breakpoint suites and `TestHelper.ets`

- [ ] **Step 1: Add stable list-toggle and skeleton IDs**

Add `.id('mall-display-mode-toggle')` to the `CommonSymbol` that changes `isGrid`.
Add `.id('mall-horizontal-skeleton-item')` and `.id('mall-vertical-skeleton-item')` to the repeated skeleton card
container according to `isVertical`.

- [ ] **Step 2: Make skeleton observation deterministic**

In `MockAdapter.ets`, change only:

```ts
delayResponse: 1500,
```

Do not change mock payloads.

- [ ] **Step 3: Add search navigation**

Add `openSearchResults(driver)` to `TestHelper.ets`: click `mall-home-search`, wait for `search_bar`, call
`inputText('针织')`, call `driver.triggerKey(2054)` (`KEYCODE_ENTER`), wait for `mall-product-waterflow`, then wait for
`mall-product-item`. Add `switchToListMode(driver)` that clicks `mall-display-mode-toggle` and waits for
`mall-list-product-item`.

- [ ] **Step 4: Add list-mode tests**

Add `should_keep_list_mode_single_column_on_sm`, `should_keep_list_mode_single_column_on_md`, and
`should_show_two_list_mode_columns_on_lg`. Each test opens search results, switches mode, and calls:

```ts
expect(await countItemsInFirstRow(driver, 'mall-list-product-item')).assertEqual(expectedColumns);
```

Expected columns: SM `1`, MD `1`, LG `2`.

- [ ] **Step 5: Add skeleton tests**

Add the six tests named in the design:

```text
should_keep_horizontal_skeleton_two_columns_on_sm
should_keep_vertical_skeleton_single_column_on_sm
should_show_three_horizontal_skeleton_columns_on_md
should_keep_vertical_skeleton_single_column_on_md
should_show_four_horizontal_skeleton_columns_on_lg
should_show_two_vertical_skeleton_columns_on_lg
```

For horizontal skeletons, submit a fresh product search and assert `mall-horizontal-skeleton-item` before the 1500ms
mock response completes. For vertical skeletons, submit a fresh product search, immediately click
`mall-display-mode-toggle`, and assert `mall-vertical-skeleton-item` before the response completes. Expected horizontal
columns are `2/3/4`; expected vertical columns are `1/1/2`.

- [ ] **Step 6: Run each affected matrix suite and commit**

Use the three commands from Task 2 Step 5. Expected: all selected tests pass.

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/commons/lib_widget/src/main/ets/components/CommonSkeletons.ets ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets ComprehensiveMallTemplate/CaseUI/answer/features/shopping/src/main/ets/views/ProductSearchResultsPage.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test
git commit -m "test: cover responsive product lists"
```

## Task 4: Add Product Detail and Review Coverage

**Files:**

- Modify: `answer/features/product/src/main/ets/components/ProductReviewCard.ets`
- Modify: `answer/features/product/src/main/ets/components/ProductInfoCards.ets`
- Modify: `answer/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`
- Modify: `answer/features/order/src/main/ets/views/OrderReviewCreatePage.ets`
- Modify: `answer/features/order/src/main/ets/components/OrderInfoCard.ets`
- Modify: `answer/commons/lib_network/src/main/ets/httpsmock/mockdata/MockProductData.ets`
- Modify: the three breakpoint suites and `TestHelper.ets`

- [ ] **Step 1: Add IDs**

Add:

```ts
.id('mall-review-media-item')
.id('mall-review-picker-item')
.id('mall-order-action-' + action.actionType)
```

Attach them respectively to each review media cell, each creation picker/media cell, and each order action button.

- [ ] **Step 2: Provide deterministic media counts**

Append two more image items to `MockProductData.REVIEW_ITEM_MOCK1.mediaList`, reusing existing
`MockImageMap.PRODUCT_10001_*` resources, so the product review has five media cells.

Add an optional `initialMediaList` parameter to `ProductReviewCreation`:

```ts
@Param
initialMediaList: ReviewMediaItem[] = []
```

When each `SkuReviewModel` is created, copy it:

```ts
item.mediaList = this.initialMediaList.slice()
```

In `OrderReviewCreatePage.ets`, pass four deterministic image entries to `initialMediaList`; together with the add
cell this produces five picker cells without opening the system photo picker. This is test-support data included only
through `test_patch.patch`.

- [ ] **Step 3: Add vertical detail tests**

For SM and MD, open product detail and assert:

```ts
expect(await isComponentBelow(driver, 'mall-product-swiper', 'mall-product-info-card')).assertTrue();
```

Use the approved test names `should_show_product_detail_vertically_on_sm` and
`should_show_product_detail_vertically_on_md`.

- [ ] **Step 4: Add review media tests**

Scroll the detail right/vertical content until `mall-review-media-item` is visible, then use
`countItemsInFirstRow`. Expected columns are SM `3`, MD `5`, LG `5`.

- [ ] **Step 5: Add review creation navigation and picker tests**

`openReviewCreation(driver)` must open Profile, tap the pending-review order entry, wait for the first order action
button with review action type, click it, and wait for `mall-review-picker-item`. Add the three picker tests with
expected columns `3/5/5`.

- [ ] **Step 6: Add the MD adjacent-image arrangement test**

In `ProductInfoCards.ets`, add `.id('mall-product-swiper-image')` to every repeated swiper `Image`. Assert that at
least two `mall-product-swiper-image` components intersect the visible `mall-product-swiper` horizontal range. Do
not assert image width or swiper height.

- [ ] **Step 7: Run matrix suites and commit**

Run phone, foldable, and tablet suites. Expected: all selected tests pass.

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/features/product/src/main/ets/components/ProductReviewCard.ets ComprehensiveMallTemplate/CaseUI/answer/features/product/src/main/ets/components/ProductInfoCards.ets ComprehensiveMallTemplate/CaseUI/answer/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets ComprehensiveMallTemplate/CaseUI/answer/features/order/src/main/ets/views/OrderReviewCreatePage.ets ComprehensiveMallTemplate/CaseUI/answer/features/order/src/main/ets/components/OrderInfoCard.ets ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/mockdata/MockProductData.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test
git commit -m "test: cover responsive product reviews"
```

## Task 5: Add Cart and Profile Coverage

**Files:**

- Modify: `answer/components/module_shopping_cart/src/main/ets/components/CartListView.ets`
- Modify: `answer/components/module_shopping_cart/src/main/ets/components/CartControlPanel.ets`
- Modify: `answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ShoppingCartMock.ets`
- Modify: `answer/products/entry/src/main/ets/tabviews/ProfilePage.ets`
- Modify: the three breakpoint suites and `TestHelper.ets`

- [ ] **Step 1: Add stable IDs**

Add:

```text
mall-cart-item
mall-cart-control-panel
mall-profile-user-area
mall-profile-checkin-area
mall-profile-main-menu-area
mall-profile-checkin-menu-area
mall-profile-submenu-item
```

Use the same repeated ID for repeated list items so `findComponents` can count the first row.

- [ ] **Step 2: Seed two deterministic cart cards**

In `ShoppingCartMock.ets`, change only the empty `_getCartData()` branch. Create two `CartSkuItem` values from the
first two entries of `MockProductData.PRODUCT_SKU_TABLE`, with count `1` and `PriceType.NORMAL`, and return
`total: 2`. Preserve existing persisted cart data when `mockCart.data` is non-empty.

- [ ] **Step 3: Add navigation helpers**

`openCart(driver)` clicks `mall-tab-2` and waits for two `mall-cart-item` components.
`openProfile(driver)` clicks `mall-tab-3` and waits for `mall-profile-user-area`.

- [ ] **Step 4: Add cart column tests**

Add SM/MD/LG tests and assert first-row counts `1/1/2`.

- [ ] **Step 5: Add LG bottom-gap test**

Read bounds for `mall-cart-control-panel` and the active app window. Assert only that the control panel bottom is
within `12px` of the usable window bottom. Do not assert panel height, color, or radius.

- [ ] **Step 6: Add profile arrangement tests**

For SM and MD, assert `mall-profile-user-area` is above `mall-profile-checkin-area`, and the check-in area is above
`mall-profile-main-menu-area`. For LG, assert the user area is left of `mall-profile-checkin-menu-area` and the two
areas have vertical overlap. Count `mall-profile-submenu-item` first-row items as `1/1/2`.

- [ ] **Step 7: Run matrix suites and commit**

Run all three breakpoint suites. Expected: all selected tests pass.

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/components/module_shopping_cart/src/main/ets/components/CartListView.ets ComprehensiveMallTemplate/CaseUI/answer/components/module_shopping_cart/src/main/ets/components/CartControlPanel.ets ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ShoppingCartMock.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/main/ets/tabviews/ProfilePage.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test
git commit -m "test: cover responsive cart and profile"
```

## Task 6: Add Order, Points, Collection, History, and Seckill Coverage

**Files:**

- Modify: `answer/features/order/src/main/ets/views/OrderListPage.ets`
- Modify: `answer/features/points/src/main/ets/views/PointsMallPage.ets`
- Modify: `answer/features/setting/src/main/ets/components/ProductList.ets`
- Modify: `answer/features/shopping/src/main/ets/views/SeckillListPage.ets`
- Modify: `answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ProductMock.ets`
- Modify: `answer/products/entry/src/main/ets/components/HomePageContent.ets`
- Modify: `answer/products/entry/src/main/ets/tabviews/ProfilePage.ets`
- Modify: the three breakpoint suites and `TestHelper.ets`

- [ ] **Step 1: Add list and entry IDs**

Add:

```text
mall-order-item
mall-points-product-item
mall-setting-product-item
mall-seckill-item
mall-points-entry
mall-seckill-entry
mall-order-entry
mall-collection-entry
mall-history-entry
```

- [ ] **Step 2: Seed collection and history data**

In `ProductMock.ets`, initialize `CollectedProduct.list` and `ViewHistoryProduct.list` with two `BaseIDModel`
entries whose product IDs are `product_10001` and `product_10002`. Keep all existing add/delete/persistence behavior.

- [ ] **Step 3: Add navigation helpers**

Implement `openOrderList`, `openPointsMall`, `openCollection`, `openHistory`, and `openSeckill` by starting from
`openProfile` or `prepareHome`, clicking the corresponding entry ID, and waiting for at least two target items.

- [ ] **Step 4: Add order and points tests**

Assert order first-row counts `1/1/2` for SM/MD/LG and points first-row counts `2/3/4`.

- [ ] **Step 5: Add LG collection, history, and seckill tests**

Add:

```text
should_show_two_collection_columns_on_lg
should_show_two_history_columns_on_lg
should_show_two_seckill_columns_on_lg
```

Each opens the page and expects `countItemsInFirstRow(...) === 2`.

- [ ] **Step 6: Run matrix suites and commit**

Run all three breakpoint suites. Expected: all selected tests pass.

```bash
git add ComprehensiveMallTemplate/CaseUI/answer/features/order/src/main/ets/views/OrderListPage.ets ComprehensiveMallTemplate/CaseUI/answer/features/points/src/main/ets/views/PointsMallPage.ets ComprehensiveMallTemplate/CaseUI/answer/features/setting/src/main/ets/components/ProductList.ets ComprehensiveMallTemplate/CaseUI/answer/features/shopping/src/main/ets/views/SeckillListPage.ets ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/mockapis/ProductMock.ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/main/ets ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test
git commit -m "test: cover responsive account lists"
```

## Task 7: Verify the Complete Answer Matrix

**Files:**

- No source changes unless a failing test requires a targeted correction.

- [ ] **Step 1: Run the full Answer matrix**

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:matrix -- --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer --device phone --device foldable --device tablet
```

Expected:

- matrix status `completed`;
- `SmPassToPassTest`, `MdFailToPassTest`, and `LgFailToPassTest` all execute on their configured devices;
- every test case is `passed`;
- no `none parsed`, blocked device, build failure, install failure, or test failure.

- [ ] **Step 2: Confirm the approved scope**

Run:

```bash
rg -n "sheet|popup|cornerRadius|backgroundColor|200vp|360vp" ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest
```

Expected: no new breakpoint test that asserts a popup, radius, background, or component width/height. Existing banner
ratio and LG search-width tests are allowed.

- [ ] **Step 3: Commit any verification-only corrections**

```bash
git add ComprehensiveMallTemplate/CaseUI/answer
git commit -m "test: stabilize breakpoint UI matrix"
```

Skip this commit only if Task 7 made no changes.

## Task 8: Update Metadata and Generate the New Test Patch

**Files:**

- Modify: `ComprehensiveMallTemplate/CaseUI/metadata.json`
- Replace: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`
- Do not retain changes under: `ComprehensiveMallTemplate/CaseUI/swe/**`

- [ ] **Step 1: Update metadata classification**

Copy every new name from design sections 9.1 and 9.2 into exactly one matching metadata array. Keep
`device_test_suites` unchanged.

- [ ] **Step 2: Create a temporary SWE working copy**

Run:

```bash
case_tmp=$(mktemp -d)
cp -R ComprehensiveMallTemplate/CaseUI/swe "$case_tmp/base"
cp -R ComprehensiveMallTemplate/CaseUI/swe "$case_tmp/patched"
(
  cd "$case_tmp/patched"
  git apply /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/test_patch.patch
)
git diff --binary 1016524..HEAD -- ComprehensiveMallTemplate/CaseUI/answer > "$case_tmp/incremental-answer.patch"
sed \
  -e 's#a/ComprehensiveMallTemplate/CaseUI/answer/#a/#g' \
  -e 's#b/ComprehensiveMallTemplate/CaseUI/answer/#b/#g' \
  "$case_tmp/incremental-answer.patch" > "$case_tmp/incremental-project.patch"
(
  cd "$case_tmp/patched"
  git apply "$case_tmp/incremental-project.patch"
)
```

Expected: both patch applications exit 0. `ComprehensiveMallTemplate/CaseUI/swe` remains untouched.

- [ ] **Step 3: Generate test_patch.patch**

Run:

```bash
(
  cd "$case_tmp"
  git diff --no-index --binary base patched > raw-test.patch
)
diff_status=$?
test "$diff_status" -eq 1
sed \
  -e 's#a/base/#a/#g' \
  -e 's#b/patched/#b/#g' \
  "$case_tmp/raw-test.patch" > ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Exit status `1` from `git diff --no-index` is expected because the directories differ. The `test` command must pass.

- [ ] **Step 4: Validate patch application**

```bash
git apply --check --directory=ComprehensiveMallTemplate/CaseUI/swe ComprehensiveMallTemplate/CaseUI/test_patch.patch
```

Expected: exit code 0.

- [ ] **Step 5: Validate metadata completeness**

Extract every `it('...')` name from the patch and confirm it appears exactly once across `pass_to_pass` and
`fail_to_pass`. Expected: no unclassified or conflicting name.

Run:

```bash
node -e '
const fs=require("fs");
const patch=fs.readFileSync("ComprehensiveMallTemplate/CaseUI/test_patch.patch","utf8");
const metadata=JSON.parse(fs.readFileSync("ComprehensiveMallTemplate/CaseUI/metadata.json","utf8"));
const names=[...patch.matchAll(/it\\(\\x27([^\\x27]+)\\x27,/g)].map(m=>m[1]);
const pass=new Set(metadata.pass_to_pass);
const fail=new Set(metadata.fail_to_pass);
const invalid=names.filter(name=>(pass.has(name)?1:0)+(fail.has(name)?1:0)!==1);
if(invalid.length){console.error(invalid.join("\\n"));process.exit(1)}
console.log(`classified ${names.length} tests`);
'
```

Expected: exit code 0 and `classified 54 tests`.

- [ ] **Step 6: Commit**

```bash
git add ComprehensiveMallTemplate/CaseUI/metadata.json ComprehensiveMallTemplate/CaseUI/test_patch.patch
git commit -m "test: expand comprehensive mall breakpoint coverage"
```

## Task 9: Verify SWE Classification with case-runner

**Files:**

- No source changes unless patch or metadata corrections are required.

- [ ] **Step 1: Run SWE case validation**

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner run ohostest:case -- --case /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI --run swe
```

Expected:

- case status `completed`;
- all three devices execute;
- every `pass_to_pass` test passes on SWE;
- every `fail_to_pass` test fails on SWE;
- `Incorrect` is 0 for every device;
- no `unclassified`, `conflict`, or `none parsed`.

- [ ] **Step 2: Inspect the generated summary**

Open the newest:

```text
ComprehensiveMallTemplate/CaseUI/.ohostest-runs/<timestamp>/summary.md
```

Confirm Totals and Device Results match Step 1.

- [ ] **Step 3: Make only classification or patch corrections**

If a test passes on both SWE and Answer, it must be classified `pass_to_pass` or strengthened so it actually detects
the golden change. If a fail-to-pass test fails on Answer, return to the corresponding Answer task and fix it before
regenerating the patch.

- [ ] **Step 4: Final verification**

Repeat the full Answer matrix command from Task 7 and the SWE case command from Task 9. Both must meet their complete
acceptance conditions in fresh runs.

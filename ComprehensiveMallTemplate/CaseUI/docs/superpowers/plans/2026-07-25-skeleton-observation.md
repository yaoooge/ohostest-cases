# Skeleton Observation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Observe search-result skeleton row geometry reliably within the existing 2000-millisecond mock loading window.

**Architecture:** A transient geometry helper reads skeleton bounds in List order and stops at the first item in row two. `openSearchSkeleton` performs direct search-result navigation and returns the geometry snapshot before the skeleton disappears.

**Tech Stack:** ArkTS, HarmonyOS UI TestKit, Hypium, NavPathStack, harmonyos-ohostest-runner

---

## File Structure

- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`
  - Add transient first-row capture and return the captured count from `openSearchSkeleton`.
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets`
  - Assert the count returned inside the loading window.
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/MdFailToPass.test.ets`
  - Assert the count returned inside the loading window.
- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets`
  - Assert the count returned inside the loading window.

### Task 1: Capture Transient Skeleton Geometry

- [ ] **Step 1: Use the existing matrix failures as RED**

Evidence:

```text
should_show_four_horizontal_skeleton_columns_on_lg: expect 0 equals 4
should_show_two_vertical_skeleton_columns_on_lg:
  component not found: mall-vertical-skeleton-item
```

Report:

```text
ComprehensiveMallTemplate/CaseUI/answer/.ohostest-runs/
2026-07-25T06-51-59-947Z/summary.md
```

- [ ] **Step 2: Add the transient first-row helper**

Add to `TestHelper.ets`:

```ts
async function countTransientItemsInFirstRow(driver: Driver, itemId: string): Promise<number> {
  for (let attempt = 0; attempt < 6; attempt++) {
    const items = await driver.findComponents(ON.id(itemId));
    if (items !== null && items !== undefined && items.length > 0) {
      const firstBounds = await items[0].getBounds();
      let count = 1;
      for (let index = 1; index < items.length; index++) {
        const bounds = await items[index].getBounds();
        if (Math.abs(bounds.top - firstBounds.top) <= 3) {
          count++;
        } else if (bounds.top > firstBounds.top + 3) {
          return count;
        }
      }
      return count;
    }
    await driver.delayMs(100);
  }
  return 0;
}
```

- [ ] **Step 3: Make skeleton navigation return the snapshot**

Replace `openSearchSkeleton` with:

```ts
export async function openSearchSkeleton(driver: Driver, listMode: boolean): Promise<number> {
  await prepareHome();
  routerStack.pushPath({
    name: RouterMap.PRODUCT_SEARCH_RESULTS,
    param: {
      keywords: '针织',
    } as ProductSearchResultsPageParam,
  }, false);
  if (listMode) {
    const toggle = await driver.findComponent(ON.id('mall-display-mode-toggle'));
    await toggle.click();
    return await countTransientItemsInFirstRow(driver, 'mall-vertical-skeleton-item');
  }
  return await countTransientItemsInFirstRow(driver, 'mall-horizontal-skeleton-item');
}
```

- [ ] **Step 4: Assert the returned counts**

Change each skeleton test from:

```ts
await openSearchSkeleton(driver, false);
expect(await countItemsInFirstRow(driver, 'mall-horizontal-skeleton-item')).assertEqual(expected);
```

to:

```ts
expect(await openSearchSkeleton(driver, false)).assertEqual(expected);
```

Apply the same change to the vertical skeleton assertion with `true`.

- [ ] **Step 5: Run all breakpoint suites independently**

Run `ohostest:matrix` with:

```text
phone    / SmPassToPassTest
foldable / MdFailToPassTest
tablet   / LgFailToPassTest
```

Expected skeleton results:

```text
SM:  horizontal=2, vertical=1
MD:  horizontal=3, vertical=1
LG:  horizontal=4, vertical=2
```

- [ ] **Step 6: Verify scope**

Run:

```bash
git diff --check
rg -n "delayResponse" \
  ComprehensiveMallTemplate/CaseUI/answer/commons/lib_network/src/main/ets/httpsmock/MockAdapter.ets
```

Expected: no whitespace errors and `delayResponse: 2000`.

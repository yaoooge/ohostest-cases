# ReturnToHome Navigation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace UI-driven home navigation in `TestHelper.returnToHome` with a non-animated `NavPathStack.replacePath` to `RouterMap.MAIN_ENTRY`.

**Architecture:** The shared test helper uses the application's registered root `routerStack` to replace the current destination with a newly created `MainEntry`. UI TestKit remains responsible only for waiting until the home content and deterministic product data are rendered.

**Tech Stack:** ArkTS, HarmonyOS Navigation (`NavPathStack`), Hypium, UI TestKit, harmonyos-ohostest-runner

---

## File Structure

- Modify: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets`
  - Replace the page-detection and UI-input loop in `returnToHome`.
- Test: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets`
  - Existing collection/history/seckill sequence verifies that repeated calls return to a fresh home destination.

### Task 1: Replace UI-Driven Home Navigation

- [ ] **Step 1: Run the existing LG suite to verify the regression**

Run:

```bash
npm run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer \
  --device tablet \
  --test-class LgFailToPassTest
```

Expected: `should_show_two_seckill_columns_on_lg` fails because the current
`returnToHome` depends on UI state inspection and click/back input after the
preceding history test.

- [ ] **Step 2: Replace the current implementation**

Replace the body of `returnToHome` with:

```ts
export async function returnToHome(driver: Driver): Promise<void> {
  routerStack.replacePath({
    name: RouterMap.MAIN_ENTRY,
  }, false);
  await waitForComponentById(driver, HOME_ID, 12);
  await waitForComponentById(driver, 'mall-home-content', 12);
  await waitForComponentById(driver, 'mall-product-item', 20);
  await driver.delayMs(500);
}
```

This removes component-based navigation decisions, `click`, and `pressBack`
from the helper while retaining render synchronization.

- [ ] **Step 3: Run the focused LG suite**

Run the same `ohostest:matrix` command from Step 1.

Expected: `LgFailToPassTest` passes all 21 tests, including
`should_show_two_seckill_columns_on_lg`.

- [ ] **Step 4: Check the diff**

Run:

```bash
git diff --check
rg -n "pressBack|mall-search-back|mall-tab-0" \
  ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/TestHelper.ets
```

Expected: `git diff --check` prints nothing. Any remaining matches belong to
other helpers; `returnToHome` contains none.

- [ ] **Step 5: Commit with the remaining Task 6 implementation**

After all three breakpoint suites pass, stage the Task 6 test files and helper
changes together and commit:

```bash
git commit -m "test: cover responsive account lists"
```

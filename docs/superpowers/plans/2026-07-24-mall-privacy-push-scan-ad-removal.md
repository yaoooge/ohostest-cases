# Mall Privacy, Push, Scan, and Advertisement Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Physically remove the mall template's first-launch privacy confirmation, Push, scan, and advertisement capabilities while preserving direct main-page startup, product deep links, split-screen product details, and the order shortcut.

**Architecture:** Remove the three dedicated component modules and the foundation Push implementation at their ownership boundaries, then detach every route, UI entry, shortcut, resource, and package reference. Replace the privacy/advertisement startup chain with a direct `MAIN_ENTRY` route and enforce the resulting boundary with source-contract tests plus a full Hvigor build.

**Tech Stack:** HarmonyOS ArkTS/ArkUI, JSON5 resource and build configuration, Node.js `node:test`, OHPM, Hvigor

---

## File Structure

- `CaseComprehensiveMallTemplate/tests/capability-removal.test.mjs`: source-contract tests for removed capabilities and preserved navigation.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/Index.ets`: direct normal startup route.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SafePage.ets`: delete privacy startup page.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SplashPage.ets`: delete advertisement startup page.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets`: remove Push token initialization.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets`: remove Push request and scan/image-recognition behavior.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/HomePage.ets`: remove scan button.
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/SetupUtil.ets`: remove scan shortcut routing while preserving product links and order routing.
- `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/PermissionUtil.ets`: retain generic runtime permissions but remove notification permission behavior.
- `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/push/`: delete Push implementation and model.
- `CaseComprehensiveMallTemplate/commons/lib_foundation/Index.ets`: remove `PushUtil` export.
- `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets`: remove privacy and splash route names.
- `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/route_map.json`: remove privacy and splash page registrations.
- `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/shortcuts_config.json`: retain only the order shortcut.
- `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/element/string.json`: remove scan shortcut text.
- `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_shortcuts_scan.png`: delete scan shortcut icon.
- `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_scan.png`: delete unused scan media.
- `CaseComprehensiveMallTemplate/components/module_privacy_agreement/`: delete privacy component.
- `CaseComprehensiveMallTemplate/components/module_product_scan/`: delete scan component.
- `CaseComprehensiveMallTemplate/components/module_advertisement/`: delete advertisement component.
- `CaseComprehensiveMallTemplate/build-profile.json5`: unregister deleted modules.
- `CaseComprehensiveMallTemplate/products/entry/oh-package.json5`: remove deleted local dependencies.
- `CaseComprehensiveMallTemplate/products/entry/oh-package-lock.json5`: regenerate the entry dependency graph.
- `CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json`: remove the scan component AGC identifier.
- `CaseComprehensiveMallTemplate/README.md`: remove capability descriptions, component tree entries, page entries, and Push instructions.
- `docs/non-module-components-removal.md`: record the additional explicitly requested module removals.
- `docs/multi-device-adaptation-inventory.md`: record startup and scan-entry changes without removing breakpoint or split-screen support.

### Task 1: Add capability-removal contract tests

**Files:**
- Create: `CaseComprehensiveMallTemplate/tests/capability-removal.test.mjs`

- [ ] **Step 1: Write tests for physical removal and preserved behavior**

Create the test with these assertions:

```js
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const read = (path) => readFileSync(join(projectRoot, path), 'utf8');

test('privacy, scan, advertisement, and Push implementations are removed', () => {
  for (const path of [
    'components/module_privacy_agreement',
    'components/module_product_scan',
    'components/module_advertisement',
    'commons/lib_foundation/src/main/ets/push',
    'products/entry/src/main/ets/views/SafePage.ets',
    'products/entry/src/main/ets/views/SplashPage.ets',
  ]) {
    assert.equal(existsSync(join(projectRoot, path)), false, path);
  }
});

test('normal startup enters MainEntry while split and deep-link behavior remain', () => {
  const index = read('products/entry/src/main/ets/views/Index.ets');
  const setup = read('products/entry/src/main/ets/utils/SetupUtil.ets');
  assert.match(index, /name:\s*RouterMap\.MAIN_ENTRY/);
  assert.doesNotMatch(index, /SAFE_PAGE|SPLASH_PAGE/);
  assert.match(index, /SecondAbility/);
  assert.match(index, /RouterMap\.PRODUCT_INFO/);
  assert.match(setup, /productId/);
  assert.match(setup, /OrderPage/);
});

test('Push and notification permission behavior are detached', () => {
  const ability = read('products/entry/src/main/ets/entryability/EntryAbility.ets');
  const home = read('products/entry/src/main/ets/viewmodels/HomePageVM.ets');
  const permission = read('commons/lib_foundation/src/main/ets/utils/PermissionUtil.ets');
  const foundation = read('commons/lib_foundation/Index.ets');
  for (const source of [ability, home, permission, foundation]) {
    assert.doesNotMatch(source, /PushUtil|requestNotificationPermission|NotificationKit/);
  }
  assert.match(permission, /requestPermissions\(/);
});

test('scan entry is removed while order shortcut remains', () => {
  const homePage = read('products/entry/src/main/ets/tabviews/HomePage.ets');
  const homeVm = read('products/entry/src/main/ets/viewmodels/HomePageVM.ets');
  const setup = read('products/entry/src/main/ets/utils/SetupUtil.ets');
  const shortcuts = read('products/entry/src/main/resources/base/profile/shortcuts_config.json');
  assert.doesNotMatch(homePage, /jumpToScanPage|line_viewfinder/);
  assert.doesNotMatch(homeVm, /module_product_scan|subjectSegmentation|CoreVisionKit/);
  assert.doesNotMatch(setup, /ScanPage|ScanRouterMap/);
  assert.doesNotMatch(shortcuts, /shortcuts_scan|ScanPage/);
  assert.match(shortcuts, /shortcuts_orders|OrderPage/);
});

test('build and package configuration no longer reference deleted modules', () => {
  const sources = [
    read('build-profile.json5'),
    read('products/entry/oh-package.json5'),
    read('products/entry/src/main/resources/base/profile/route_map.json'),
  ];
  for (const source of sources) {
    assert.doesNotMatch(
      source,
      /module_privacy_agreement|module_product_scan|module_advertisement|SafePage|SplashPage/,
    );
  }
});
```

- [ ] **Step 2: Run the test and verify the current implementation fails**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/capability-removal.test.mjs
```

Expected: five failing subtests because the modules, routes, Push behavior, and scan entries still exist.

- [ ] **Step 3: Commit the failing contract**

```bash
git add CaseComprehensiveMallTemplate/tests/capability-removal.test.mjs
git commit -m "test: guard mall capability removal"
```

### Task 2: Replace the privacy and advertisement startup chain

**Files:**
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/Index.ets`
- Delete: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SafePage.ets`
- Delete: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SplashPage.ets`
- Modify: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/route_map.json`

- [ ] **Step 1: Route ordinary startup directly to the main entry**

Change the final `else` branch in `Index.ets` to:

```ts
    } else {
      this.stack.pushPath({
        name: RouterMap.MAIN_ENTRY,
      }, false)
    }
```

- [ ] **Step 2: Remove obsolete startup routes**

Delete `SAFE_PAGE` and `SPLASH_PAGE` from `RouterMap.ets`. Remove the `SafePage` and `SplashPage` objects from the entry `route_map.json`, leaving `MainEntry`, `CategoryPage`, and `CartPage`.

- [ ] **Step 3: Delete the two obsolete page files**

```bash
git rm CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SafePage.ets
git rm CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/SplashPage.ets
```

- [ ] **Step 4: Run only the startup contract**

```bash
cd CaseComprehensiveMallTemplate
node --test --test-name-pattern="normal startup" tests/capability-removal.test.mjs
```

Expected: the startup subtest passes.

- [ ] **Step 5: Commit the startup change**

```bash
git add CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/Index.ets \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/route_map.json
git commit -m "refactor: enter mall directly on startup"
```

### Task 3: Remove Push and notification authorization behavior

**Files:**
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets`
- Modify: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/PermissionUtil.ets`
- Modify: `CaseComprehensiveMallTemplate/commons/lib_foundation/Index.ets`
- Delete: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/push/PushUtil.ets`
- Delete: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/push/Model.ets`

- [ ] **Step 1: Remove Push initialization and homepage mock sending**

In `EntryAbility.ets`, remove `PushUtil` from the `lib_foundation` import and delete:

```ts
          PushUtil.getTokenSyn();
```

In `HomePageVM.ets`, remove `PushUtil` and `PermissionUtil` from the foundation import and delete:

```ts
    PermissionUtil.requestNotificationPermission(() => {
      // push能力测试
      PushUtil.pushMessageMock();
    });
```

- [ ] **Step 2: Keep generic permissions and remove notification-only code**

In `PermissionUtil.ets`, change the imports to:

```ts
import { abilityAccessCtrl, Permissions, bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { WindowUtil } from './WindowUtil';
```

Delete the complete `requestNotificationPermission` method. Leave `requestPermissions`, `_checkPermissions`, `_checkAccessToken`, and `_requestPermissionsOnSetting` unchanged.

- [ ] **Step 3: Delete the Push implementation and export**

Delete this line from `commons/lib_foundation/Index.ets`:

```ts
export { PushUtil } from './src/main/ets/push/PushUtil';
```

Then delete the directory:

```bash
git rm -r CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/push
```

- [ ] **Step 4: Run the Push contract**

```bash
cd CaseComprehensiveMallTemplate
node --test --test-name-pattern="Push and notification" tests/capability-removal.test.mjs
```

Expected: the Push subtest passes.

- [ ] **Step 5: Commit the Push removal**

```bash
git add CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/PermissionUtil.ets \
  CaseComprehensiveMallTemplate/commons/lib_foundation/Index.ets
git commit -m "refactor: remove mall push capability"
```

### Task 4: Remove scan UI, routing, shortcut, and image recognition

**Files:**
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/HomePage.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/SetupUtil.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/shortcuts_config.json`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/element/string.json`
- Delete: `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_shortcuts_scan.png`
- Delete: `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_scan.png`

- [ ] **Step 1: Remove scan and image-recognition code from the homepage view model**

Remove these imports from `HomePageVM.ets`:

```ts
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { subjectSegmentation } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { CustomScanOptions, ScanRouterMap } from 'module_product_scan';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
```

Remove `WindowUtil`, `ProductInfoPageParam`, and `ProductSearchResultsPageParam` from the foundation import. Remove `TAG`, `jumpToScanPage`, `_getSegmentationImage`, and `_readFileToPixelMap`. Keep category navigation and text search unchanged.

- [ ] **Step 2: Remove the homepage scan button**

Delete this builder block from `HomePage.ets`:

```ts
      CommonSymbol({
        src: $r('sys.symbol.line_viewfinder'),
      })
        .onClick(() => {
          this.vm.jumpToScanPage()
        })
```

- [ ] **Step 3: Remove scan shortcut routing**

In `SetupUtil.ets`, remove:

```ts
import { ScanRouterMap } from 'module_product_scan';
```

Remove the `case 'ScanPage'` branch. Keep the `OrderPage` branch:

```ts
        case 'OrderPage':
          SetupUtil.navInfo = {
            name: RouterMap.ORDER_LIST, param: 3,
          };
```

- [ ] **Step 4: Retain only the order shortcut and its resources**

Replace `shortcuts_config.json` with:

```json
{
  "shortcuts": [
    {
      "shortcutId": "shortcuts_orders",
      "label": "$string:shortcuts_orders",
      "icon": "$media:ic_shortcuts_orders",
      "wants": [
        {
          "bundleName": "zhsc.1.1",
          "moduleName": "entry",
          "abilityName": "EntryAbility",
          "parameters": {
            "shortCutKey": "OrderPage"
          }
        }
      ]
    }
  ]
}
```

Remove the `shortcuts_scan` object from `string.json`, then delete the scan media:

```bash
git rm CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_shortcuts_scan.png
git rm CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/media/ic_scan.png
```

- [ ] **Step 5: Run the scan contract**

```bash
cd CaseComprehensiveMallTemplate
node --test --test-name-pattern="scan entry" tests/capability-removal.test.mjs
```

Expected: the scan subtest passes.

- [ ] **Step 6: Commit the scan detachment**

```bash
git add CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/HomePage.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/SetupUtil.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/profile/shortcuts_config.json \
  CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/element/string.json
git commit -m "refactor: detach mall scan entry points"
```

### Task 5: Delete capability modules and detach build dependencies

**Files:**
- Delete: `CaseComprehensiveMallTemplate/components/module_privacy_agreement/`
- Delete: `CaseComprehensiveMallTemplate/components/module_product_scan/`
- Delete: `CaseComprehensiveMallTemplate/components/module_advertisement/`
- Modify: `CaseComprehensiveMallTemplate/build-profile.json5`
- Modify: `CaseComprehensiveMallTemplate/products/entry/oh-package.json5`
- Modify: `CaseComprehensiveMallTemplate/products/entry/oh-package-lock.json5`
- Modify: `CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json`

- [ ] **Step 1: Remove module registrations and local package dependencies**

Delete the `module_privacy_agreement`, `module_product_scan`, and `module_advertisement` module objects from root `build-profile.json5`. Delete these dependencies from `products/entry/oh-package.json5`:

```json5
"module_privacy_agreement": "file:../../components/module_privacy_agreement",
"module_product_scan": "file:../../components/module_product_scan",
"module_advertisement": "file:../../components/module_advertisement",
```

- [ ] **Step 2: Remove the scan AGC component identifier**

In `AppScope/resources/base/element/string.json`, remove:

```text
agcit_huawei_comprehensive_mall_module_product_scan/1.0.1
```

and its adjacent comma, leaving the other component identifiers unchanged.

- [ ] **Step 3: Delete the three component trees**

```bash
git rm -r CaseComprehensiveMallTemplate/components/module_privacy_agreement
git rm -r CaseComprehensiveMallTemplate/components/module_product_scan
git rm -r CaseComprehensiveMallTemplate/components/module_advertisement
```

- [ ] **Step 4: Regenerate the dependency lock**

Run:

```bash
cd CaseComprehensiveMallTemplate
ohpm install
```

Expected: dependency installation succeeds and `products/entry/oh-package-lock.json5` no longer contains file dependencies for the three deleted modules.

- [ ] **Step 5: Run removal and configuration contracts**

```bash
cd CaseComprehensiveMallTemplate
node --test --test-name-pattern="implementations are removed|build and package" tests/capability-removal.test.mjs
```

Expected: both selected subtests pass.

- [ ] **Step 6: Commit module deletion**

```bash
git add CaseComprehensiveMallTemplate/build-profile.json5 \
  CaseComprehensiveMallTemplate/products/entry/oh-package.json5 \
  CaseComprehensiveMallTemplate/products/entry/oh-package-lock.json5 \
  CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json
git commit -m "refactor: remove mall privacy scan and ad modules"
```

### Task 6: Update removal and adaptation documentation

**Files:**
- Modify: `CaseComprehensiveMallTemplate/README.md`
- Modify: `docs/non-module-components-removal.md`
- Modify: `docs/multi-device-adaptation-inventory.md`

- [ ] **Step 1: Update the template README**

Remove:

- the product scan component row;
- the privacy, scan, and advertisement module tree entries;
- the `SafePage` and `SplashPage` page tree entries;
- Push service enablement and mock-send instructions.

Add one sentence to the startup description:

```markdown
当前模板普通启动直接进入商城主页；商品深链、分屏商品详情和订单快捷入口保持可用。
```

- [ ] **Step 2: Extend the deletion inventory**

Add a section to `docs/non-module-components-removal.md` named `后续显式剥离能力（2026-07-24）` with this table:

```markdown
| 能力 | 删除实现 | 主流程替代行为 |
| --- | --- | --- |
| 首次启动隐私协议 | `module_privacy_agreement`、`SafePage` | 普通启动直接进入 `MainEntry` |
| Push | `PushUtil`、token 获取、模拟推送、通知授权 | 首页加载不再请求通知权限或发送推送 |
| 扫码 | `module_product_scan`、首页入口、桌面快捷入口、图片识别 | 保留文本搜索、商品深链和订单快捷入口 |
| 广告 | `module_advertisement`、`SplashPage` | 启动不再经过开屏广告 |
```

- [ ] **Step 3: Update the multi-device inventory**

Add a `本轮剥离影响（2026-07-24）` section to `docs/multi-device-adaptation-inventory.md` stating:

```markdown
- 删除隐私协议页和开屏广告页只缩短启动路由，不改变断点注册、窗口尺寸监听或分屏路由栈复制。
- 删除首页扫码按钮及扫码快捷入口，不改变首页在手机和平板断点下的主体布局。
- `SecondAbility`、`SplitNavStore`、商品详情分屏参数和 `BreakpointSystem` 均继续保留。
- 后续剥离多端适配时，不应再把本次删除的三个组件列为适配文件。
```

- [ ] **Step 4: Verify documentation contains the new inventory**

Run:

```bash
rg -n "后续显式剥离能力|首次启动隐私协议|本轮剥离影响|SecondAbility" \
  docs/non-module-components-removal.md \
  docs/multi-device-adaptation-inventory.md
```

Expected: matches in both inventory documents.

- [ ] **Step 5: Commit documentation**

```bash
git add CaseComprehensiveMallTemplate/README.md \
  docs/non-module-components-removal.md \
  docs/multi-device-adaptation-inventory.md
git commit -m "docs: record mall capability removal"
```

### Task 7: Verify source boundaries and build the application

**Files:**
- Test: `CaseComprehensiveMallTemplate/tests/capability-removal.test.mjs`
- Test: `CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs`

- [ ] **Step 1: Run all mall contract tests**

```bash
cd CaseComprehensiveMallTemplate
node --test tests/capability-removal.test.mjs tests/non-module-components-removal.test.mjs
```

Expected: all subtests pass.

- [ ] **Step 2: Scan for capability residue**

Run:

```bash
rg -n "module_privacy_agreement|module_product_scan|module_advertisement|PushUtil|getTokenSyn|pushMessageMock|requestNotificationPermission|SafePage|SplashPage|ScanPage|shortcuts_scan" \
  CaseComprehensiveMallTemplate \
  --glob '!README.md' \
  --glob '!oh-package-lock.json5'
```

Expected: no matches in active source, build configuration, or resources.

- [ ] **Step 3: Run the full HarmonyOS build**

```bash
cd CaseComprehensiveMallTemplate
hvigorw --mode project -p product=default assembleApp --analyze=normal --parallel --incremental --no-daemon
```

Expected: `BUILD SUCCESSFUL`.

- [ ] **Step 4: Review the final diff without touching unrelated staged files**

```bash
git status --short
git diff --stat HEAD~6..HEAD
```

Expected: mall capability-removal commits are present; pre-existing staged deletions under `projects/grid-swe-evaluation_ppt169_20260706/` remain uncommitted.

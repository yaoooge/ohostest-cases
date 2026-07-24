# Mall Non-`module_*` Components Removal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Delete every component directory whose name does not start with `module_`, remove its secondary UI entry points, and preserve the mall browse-to-order flow with deterministic login, address, and payment fallbacks.

**Architecture:** Keep the retained `module_*`, product, feature, and commons modules as the application structure. Replace only main-flow component dependencies inside existing state and order classes; delete secondary routes instead of introducing compatibility packages. Guard the boundary with a repository-level Node test, then prove ArkTS consistency with a full Hvigor project build.

**Tech Stack:** HarmonyOS ArkTS, ArkUI, Hvigor, OHPM, Node.js built-in test runner, Markdown.

---

## File map

- `CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs`: static contract for deleted directories, dependency cleanup, route cleanup, and required fallbacks.
- `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/IData.ets`: default logged-in mock user state.
- `CaseComprehensiveMallTemplate/features/order/**`: default address and direct-payment-success order flow.
- `CaseComprehensiveMallTemplate/products/entry/**`: remove login, membership, address, coupon, feedback, settings, and sharing entry points.
- `CaseComprehensiveMallTemplate/features/{setting,points,product,member}/**`: remove pages and interactions backed by deleted components.
- `CaseComprehensiveMallTemplate/components/module_product_review/**`: keep review display/creation while removing `image_preview`.
- `CaseComprehensiveMallTemplate/build-profile.json5` and module `oh-package.json5` files: remove module registration and file dependencies.
- `CaseComprehensiveMallTemplate/components/{address_management,...,membership}/`: delete all 10 non-`module_*` component trees.
- `docs/non-module-components-removal.md`: final deletion/function/fallback inventory.
- `docs/multi-device-adaptation-inventory.md`: breakpoints, responsive grids, window sizing, split-screen, device declarations, and documentation inventory.

### Task 1: Add the failing removal contract

**Files:**
- Create: `CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs`

- [ ] **Step 1: Write the failing test**

```javascript
import assert from 'node:assert/strict';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const projectRoot = dirname(dirname(fileURLToPath(import.meta.url)));
const removed = [
  'address_management',
  'aggregated_login',
  'aggregated_payment',
  'aggregated_share',
  'app_setting',
  'collect_personal_info',
  'coupons',
  'feedback',
  'image_preview',
  'membership',
];

function sourceFiles(root) {
  if (!existsSync(root)) return [];
  return readdirSync(root).flatMap((name) => {
    const path = join(root, name);
    if (path.includes(`${join('components', 'module_')}`)) {
      return statSync(path).isDirectory() ? sourceFiles(path) : [path];
    }
    if (statSync(path).isDirectory()) return sourceFiles(path);
    return /\.(ets|ts|json5|json)$/.test(path) ? [path] : [];
  });
}

test('all non-module component directories are deleted', () => {
  for (const name of removed) {
    assert.equal(existsSync(join(projectRoot, 'components', name)), false, name);
  }
});

test('build and source files do not reference removed component packages', () => {
  const files = [
    join(projectRoot, 'build-profile.json5'),
    ...sourceFiles(join(projectRoot, 'products')),
    ...sourceFiles(join(projectRoot, 'features')),
    ...sourceFiles(join(projectRoot, 'commons')),
    ...sourceFiles(join(projectRoot, 'components')),
  ];
  for (const file of files) {
    const content = readFileSync(file, 'utf8');
    for (const name of removed) {
      const patterns = [
        new RegExp(`from\\s+['"]${name}['"]`),
        new RegExp(`["']${name}["']\\s*:\\s*["']file:`),
        new RegExp(`["']name["']\\s*:\\s*["']${name}["']`),
      ];
      for (const pattern of patterns) {
        assert.doesNotMatch(content, pattern, `${file} references ${name}`);
      }
    }
  }
});

test('main-flow fallbacks remain explicit', () => {
  const state = readFileSync(
    join(projectRoot, 'commons/lib_foundation/src/main/ets/utils/IData.ets'),
    'utf8',
  );
  const order = readFileSync(
    join(projectRoot, 'features/order/src/main/ets/utils/OrderUtil.ets'),
    'utf8',
  );
  const submit = readFileSync(
    join(projectRoot, 'features/order/src/main/ets/viewmodels/OrderSubmitVM.ets'),
    'utf8',
  );
  assert.match(state, /ensureDefaultUserState/);
  assert.match(state, /12345678900/);
  assert.match(order, /订单支付成功/);
  assert.doesNotMatch(order, /CashierPicker|PaymentType/);
  assert.match(submit, /12300000000/);
});
```

- [ ] **Step 2: Run the test and verify RED**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: FAIL because `components/address_management` exists and current source files still reference removed packages.

- [ ] **Step 3: Commit the red test**

```bash
git add CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs
git commit --only -m "test: guard mall component removal" -- CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs
```

### Task 2: Establish default login and clean module registration

**Files:**
- Modify: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/IData.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/MainEntryVM.ets`
- Modify: `CaseComprehensiveMallTemplate/build-profile.json5`
- Modify: `CaseComprehensiveMallTemplate/products/entry/oh-package.json5`
- Modify: `CaseComprehensiveMallTemplate/features/{setting,order,points,product,shopping}/oh-package.json5`
- Modify: `CaseComprehensiveMallTemplate/components/module_product_review/oh-package.json5`

- [ ] **Step 1: Add the deterministic user fallback**

Add to `IData.ets` and call it at the start of `MainEntryVM.initData()`:

```typescript
export function ensureDefaultUserState(): void {
  iData.global.isLogin = true;
  if (!iData.global.userInfo.phone) {
    iData.global.userInfo.nickname = '华为用户';
    iData.global.userInfo.phone = '12345678900';
    iData.global.userInfo.anonymousPhone = '123****8900';
    iData.global.userInfo.avatar = '';
    iData.global.userInfo.isMember = false;
  }
}
```

```typescript
public initData() {
  ensureDefaultUserState();
  ShoppingCartApis.getCartData().then((res) => {
    if (res.code === 0) {
      iData.global.cartVersion = res.data.version;
      iData.global.cartTotal = res.data.total;
    }
  });
  SetupUtil.jumpToTarget();
}
```

Remove the `membership` import and purchase query from `MainEntryVM`. Keep `UserInfoModel.reset()` unchanged because logout mock behavior is outside the startup fallback.

- [ ] **Step 2: Remove module and package declarations**

Delete the 10 non-`module_*` module objects plus the now-unused `member` feature module from root `build-profile.json5`. Remove matching `file:../../components/...` or `file:../image_preview` dependency properties from every listed `oh-package.json5`.

- [ ] **Step 3: Run the contract to observe the narrowed failure**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: FAIL only for remaining component directories and source imports/routes; the fallback assertions pass.

- [ ] **Step 4: Commit**

```bash
git add CaseComprehensiveMallTemplate/build-profile.json5 \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/IData.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/MainEntryVM.ets \
  CaseComprehensiveMallTemplate/products/entry/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/setting/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/order/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/points/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/product/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/shopping/oh-package.json5 \
  CaseComprehensiveMallTemplate/components/module_product_review/oh-package.json5
git commit --only -m "refactor: default mall user and detach component modules" -- \
  CaseComprehensiveMallTemplate/build-profile.json5 \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/IData.ets \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/MainEntryVM.ets \
  CaseComprehensiveMallTemplate/products/entry/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/setting/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/order/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/points/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/product/oh-package.json5 \
  CaseComprehensiveMallTemplate/features/shopping/oh-package.json5 \
  CaseComprehensiveMallTemplate/components/module_product_review/oh-package.json5
```

### Task 3: Replace payment and address selection in the order flow

**Files:**
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/utils/OrderUtil.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/viewmodels/OrderSubmitVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/views/OrderSubmitPage.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/viewmodels/OrderInfoPageVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/viewmodels/OrderListPageVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/ets/common/Constants.ets`
- Modify: `CaseComprehensiveMallTemplate/features/order/src/main/resources/base/profile/route_map.json`
- Delete: `CaseComprehensiveMallTemplate/features/order/src/main/ets/views/UpdateAddressSheet.ets`

- [ ] **Step 1: Replace the cashier callback with direct success**

Replace `handleImmediatePayment` with:

```typescript
public static handleImmediatePayment(param: OrderActionReq): void {
  const order = param.data as OrderItem;
  const payStatus = order.orderInfo.receivingMethod === OrderShipmentMap.SELF_PICK_UP
    ? OrderStatusMap.PENDING_PICKUP
    : OrderStatusMap.PENDING_SHIPMENT;
  OrderApis.updateDetail(param.orderNo, { status: payStatus })
    .then((res) => {
      if (res.code === 0) {
        WindowUtil.toast('订单支付成功！');
        param.callback?.();
      }
    })
    .finally(() => {
      routerStack.replacePathByName(RouterMap.ORDER_INFO, param.orderNo);
    });
}
```

Remove `CashierPicker`, `PaymentType`, `aggregatedPaymentService`, `_startPayment`, payment callback registration, and payment callback cleanup.

- [ ] **Step 2: Set an always-valid default express address**

Initialize `OrderSubmitVM` fields as:

```typescript
customerAddress: string = '广东省深圳市南山区科技园';
customerName: string = '华为用户';
customerPhone: string = '12300000000';
getPosition: OrderPosition = { latitude: 22.5405, longitude: 113.9345 };
city: string = '深圳市';
```

Remove `AddressManageUtil.getDefaultAddress()` from `initData`. In `OrderSubmitPage`, retain address display but remove its `.onClick(...)`. Retain discount rows as read-only and remove the `CouponsController` callback.

- [ ] **Step 3: Remove order address-edit routes and actions**

Delete `UpdateAddressSheet.ets`, its route-map item, `RouterMap.ORDER_UPDATE_ADDRESS`, update-address actions from order constants, and all branches in `OrderInfoPageVM` / `OrderListPageVM` that open the sheet. Make `enableEditAddress` always return `false` or remove it if no view consumes it.

- [ ] **Step 4: Run focused contract**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: payment and default-address assertions pass; other source-reference and directory tests still fail.

- [ ] **Step 5: Commit**

```bash
git add CaseComprehensiveMallTemplate/features/order
git commit --only -m "refactor: default mall payment and shipping address" -- CaseComprehensiveMallTemplate/features/order
```

### Task 4: Remove profile, setting, login, coupon, feedback, and membership entry points

**Files:**
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/ProfileUtil.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/ProfilePage.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/commons/Enums.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/components/HomePageContent.ets`
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/CartPage.ets`
- Modify: `CaseComprehensiveMallTemplate/features/product/src/main/ets/components/ProductOperationButton.ets`
- Modify: `CaseComprehensiveMallTemplate/features/product/src/main/ets/viewmodels/ProductInfoVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/shopping/src/main/ets/viewmodel/SeckillListVM.ets`
- Modify: `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets`
- Modify: `CaseComprehensiveMallTemplate/features/setting/src/main/resources/base/profile/route_map.json`
- Delete: `CaseComprehensiveMallTemplate/features/setting/src/main/ets/views/{LoginPage,SettingPage,SettingPrivacyPage,EditProfilePage,CouponPage}.ets`
- Delete: `CaseComprehensiveMallTemplate/features/setting/src/main/ets/viewmodels/{LoginVM,EditProfileVM}.ets`
- Delete: `CaseComprehensiveMallTemplate/features/member/`

- [ ] **Step 1: Reduce profile menus to retained features**

Keep only collection/message in `MAIN_MENU_LIST` and history/customer-service in `SUB_MENU_LIST`:

```typescript
export enum MainMenuOption {
  COLLECTION,
  MESSAGE,
}

export enum SubMenuOption {
  VIEW_HISTORY,
  CUSTOM_SERVICE,
}
```

Remove login guards, `ProfileUtil.login()`, address/coupon/feedback/settings cases, profile edit click behavior, and the membership center row. The user info area remains display-only.

- [ ] **Step 2: Remove deleted routes and pages**

Delete the five setting pages, two viewmodels, their route-map items, and these router constants:

```text
SETTING
SETTING_PRIVACY
USER_LOGIN
USER_OTHER_LOGIN
USER_PROFILE_EDIT
USER_COUPON_PAGE
USER_MEMBER_SUBSCRIPTION
ORDER_UPDATE_ADDRESS
UPDATE_ADDRESS
```

Remove login branches in home, cart, seckill, product operations, and order/profile navigation so the now-default authenticated flow proceeds directly.

- [ ] **Step 3: Delete the membership feature**

Delete `features/member/` because its only implementation dependency is the removed membership component and its entry points have been removed.

- [ ] **Step 4: Run the contract**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: profile and routing references are gone; failures remain for product sharing/image preview, points address imports, and component directories.

- [ ] **Step 5: Commit**

```bash
git add CaseComprehensiveMallTemplate/products/entry \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets \
  CaseComprehensiveMallTemplate/features/setting \
  CaseComprehensiveMallTemplate/features/member
git commit --only -m "refactor: remove detached profile component features" -- \
  CaseComprehensiveMallTemplate/products/entry \
  CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets \
  CaseComprehensiveMallTemplate/features/setting \
  CaseComprehensiveMallTemplate/features/member
```

### Task 5: Remove product sharing, image preview, and points address editing

**Files:**
- Modify: `CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets`
- Modify: `CaseComprehensiveMallTemplate/features/product/src/main/ets/viewmodels/ProductInfoVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/{ProductInfoPage,ProductSwiperPage}.ets`
- Modify: `CaseComprehensiveMallTemplate/features/product/src/main/ets/components/{ProductInfoCards,ProductReviewCard}.ets`
- Delete: `CaseComprehensiveMallTemplate/features/product/src/main/ets/utils/ShareUtil.ets`
- Modify: `CaseComprehensiveMallTemplate/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`
- Modify: `CaseComprehensiveMallTemplate/features/points/src/main/ets/viewmodels/RedemptionSubmitVM.ets`
- Modify: `CaseComprehensiveMallTemplate/features/points/src/main/ets/views/{RedemptionSubmitPage,RedemptionInfoPage}.ets`
- Modify: `CaseComprehensiveMallTemplate/features/points/src/main/resources/base/profile/route_map.json`
- Delete: `CaseComprehensiveMallTemplate/features/points/src/main/ets/utils/PointsAddressUtil.ets`

- [ ] **Step 1: Remove all explicit share UI and service setup**

Remove `ShareService` initialization from `EntryAbility`, share buttons from both product pages, `SharePicker` / `ShareRecordData` state and methods from `ProductInfoVM`, member promotion cards, and `ShareUtil.ets`.

- [ ] **Step 2: Keep review images without preview interaction**

In both review display and review creation, keep the `Image(...)` and moving-photo badge but remove `ImagePreview*` imports, option state, `aboutToAppear` preview model conversion, and `.onClick(...)` preview calls:

```typescript
Image(item.uri)
  .width($r('app.string.size_percent_full'))
  .aspectRatio(1)
  .borderRadius($r('app.float.border_radius_s'))
```

- [ ] **Step 3: Apply deterministic points address**

Initialize `RedemptionSubmitVM` with the same default recipient:

```typescript
customerAddress: string = '广东省深圳市南山区科技园';
customerName: string = '华为用户';
customerPhone: string = '12300000000';
```

Remove `AddressManageUtil`, the address click handler, `PointsAddressUtil`, and points address-update routes/buttons. Retain redemption submission and address display.

- [ ] **Step 4: Run the contract**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: only the 10 still-present component directories and descriptive metadata references fail.

- [ ] **Step 5: Commit**

```bash
git add CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets \
  CaseComprehensiveMallTemplate/features/product \
  CaseComprehensiveMallTemplate/features/points \
  CaseComprehensiveMallTemplate/components/module_product_review
git commit --only -m "refactor: remove share preview and address component flows" -- \
  CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets \
  CaseComprehensiveMallTemplate/features/product \
  CaseComprehensiveMallTemplate/features/points \
  CaseComprehensiveMallTemplate/components/module_product_review
```

### Task 6: Delete component trees and clear metadata

**Files:**
- Delete: `CaseComprehensiveMallTemplate/components/{address_management,aggregated_login,aggregated_payment,aggregated_share,app_setting,collect_personal_info,coupons,feedback,image_preview,membership}/`
- Modify: `CaseComprehensiveMallTemplate/README.md`
- Modify: `CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json`

- [ ] **Step 1: Delete the 10 component directories**

Delete only the explicitly listed directories. Confirm `find CaseComprehensiveMallTemplate/components -mindepth 1 -maxdepth 1 -type d -name 'module_*'` still lists every retained module component.

- [ ] **Step 2: Remove obsolete component catalog metadata**

Remove the deleted component rows/tree entries from the mall README. Remove deleted AGC template component identifiers from the AppScope component-version string while keeping identifiers for retained `module_*` components and unrelated libraries.

- [ ] **Step 3: Run GREEN**

Run:

```bash
cd CaseComprehensiveMallTemplate
node --test tests/non-module-components-removal.test.mjs
```

Expected: PASS, 3 tests, 0 failures.

- [ ] **Step 4: Run residual-reference scan**

Run:

```bash
node --test CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs
rg -n "agcit_huawei_common_(address_management|login|payment|share|app_setting|collect_personal_info|coupons|feedback|imagepreview|membership)" \
  CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json
```

Expected: the Node contract passes and the AGC metadata scan has no output. Domain words such as
`membership` or `coupons` may remain in network mock types and are not package references.

- [ ] **Step 5: Commit**

```bash
git add CaseComprehensiveMallTemplate/components \
  CaseComprehensiveMallTemplate/README.md \
  CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json
git commit --only -m "refactor: remove non-module mall components" -- \
  CaseComprehensiveMallTemplate/components \
  CaseComprehensiveMallTemplate/README.md \
  CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json
```

### Task 7: Write the removal inventory

**Files:**
- Create: `docs/non-module-components-removal.md`

- [ ] **Step 1: Generate evidence lists**

Run:

```bash
git diff 8c02f47 --name-status -- CaseComprehensiveMallTemplate
rg -n "ensureDefaultUserState|订单支付成功|12300000000" \
  CaseComprehensiveMallTemplate/commons \
  CaseComprehensiveMallTemplate/features
```

Expected: the diff lists all deleted component trees and affected consumer/config files; fallback scan lists login, payment, and address evidence.

- [ ] **Step 2: Write the inventory**

Use this exact structure and fill rows only from the verified diff:

```markdown
# Mall 非 module_ 组件删除清单

## 范围与结论
## 删除组件与原功能
## 消费位置及处理方式
## 主流程兜底
### 默认登录
### 默认支付成功
### 默认地址
## 配置、路由与依赖清理
## 明确保留的 module_ 组件
## 验证结果
```

The component table must contain all 10 deleted names, former function, former consumers, and final behavior.

- [ ] **Step 3: Verify inventory completeness**

Run:

```bash
for name in address_management aggregated_login aggregated_payment aggregated_share app_setting collect_personal_info coupons feedback image_preview membership; do
  rg -q "$name" docs/non-module-components-removal.md || exit 1
done
```

Expected: exit 0.

### Task 8: Analyze and document multi-device adaptation

**Files:**
- Create: `docs/multi-device-adaptation-inventory.md`

- [ ] **Step 1: Collect runtime and configuration evidence**

Run:

```bash
rg -l "BreakpointSystem|BreakpointTypeEnum|BreakpointStorage|onBreakpointChange|GridRow|GridCol|windowSizeChange|WindowMode|WINDOW_MODE_SPLIT|isSplitScreen|splitNavStore|deviceTypes|isTablet|foldable|tablet" \
  CaseComprehensiveMallTemplate \
  --glob '*.{ets,ts,json5,json,md}' \
  --glob '!build/**' \
  --glob '!oh_modules/**' \
  | sort
```

Expected: a sorted list spanning foundation breakpoint utilities, entry/product split-screen code, responsive feature/component views, module declarations, and multi-device documentation/screenshots.

- [ ] **Step 2: Write the inventory with reproducible counts**

Use this structure:

```markdown
# Mall 多端适配能力盘点

## 统计口径与摘要
## 全局断点系统
## GridRow / GridCol 响应式布局
## 平板与宽屏专用布局
## 分屏与第二 Ability
## 窗口尺寸、高度和方向响应
## deviceTypes 配置声明
## 截图与说明材料
## 文件统计
## 后续剥离影响与建议顺序
```

For every category record feature, exact file path, key symbol or line, and removal impact. Separate runtime files, configuration files, tests, and documentation; deduplicate files before reporting totals.

- [ ] **Step 3: Verify every documented path exists**

Run:

```bash
rg -o 'CaseComprehensiveMallTemplate/[A-Za-z0-9_./-]+' docs/multi-device-adaptation-inventory.md \
  | sort -u \
  | while read path; do test -e "$path" || { echo "missing: $path"; exit 1; }; done
```

Expected: exit 0 with no `missing:` lines.

### Task 9: Full verification

**Files:**
- Modify only if verification exposes a scoped defect in files already listed above.

- [ ] **Step 1: Run HarmonyOS environment self-check**

Run from `CaseComprehensiveMallTemplate`:

```bash
java -version
node -v
ohpm -v
hvigorw -v
node -e "console.log(process.env.DEVECO_SDK_HOME || 'NOT SET')"
```

Expected: JDK 17+, Node/OHPM/Hvigor versions print successfully, and `DEVECO_SDK_HOME` resolves. If only Java or SDK variables are missing, use DevEco Studio's bundled runtime for this shell without changing the user's persistent environment.

- [ ] **Step 2: Install/synchronize dependencies**

Run:

```bash
ohpm install
```

Expected: exit 0 and dependency graph contains no removed local component.

- [ ] **Step 3: Run contract tests**

Run:

```bash
node --test tests/non-module-components-removal.test.mjs
```

Expected: PASS, 3 tests, 0 failures.

- [ ] **Step 4: Run full project build**

Run:

```bash
hvigorw --mode project -p product=default assembleApp --analyze=normal --parallel --incremental --no-daemon
```

Expected: exit 0 with `BUILD SUCCESSFUL` and an APP artifact under `build/`.

- [ ] **Step 5: Review final scope**

Run:

```bash
git diff --check 8c02f47
git status --short
git diff --stat 8c02f47 -- CaseComprehensiveMallTemplate docs
```

Expected: no whitespace errors; only the mall implementation, two requested docs, the implementation plan, the known user-owned unrelated changes, and local ignored/generated artifacts appear.

- [ ] **Step 6: Commit documentation**

```bash
git add docs/non-module-components-removal.md \
  docs/multi-device-adaptation-inventory.md \
  docs/superpowers/plans/2026-07-24-mall-non-module-components-removal.md
git commit --only -m "docs: record mall removal and adaptation inventory" -- \
  docs/non-module-components-removal.md \
  docs/multi-device-adaptation-inventory.md \
  docs/superpowers/plans/2026-07-24-mall-non-module-components-removal.md
```

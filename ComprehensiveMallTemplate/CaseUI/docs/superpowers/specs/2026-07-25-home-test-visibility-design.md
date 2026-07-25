# 首页测试可见性设计

## 背景

最新 SWE 执行报告中，折叠屏和平板的 Common 用例在 `beforeAll` 阶段统一失败，错误为找不到
`mall-product-item`；手机端分类宫格用例偶发找不到 `mall-home-content`。SWE 首页 Banner 使用固定
`4 / 3` 比例，在中大屏上高度明显增加，首屏中的商品卡片可能尚未进入可见区域或尚未实例化。
现有 `prepareHome()` 把“首页路由就绪”和“商品卡片可见”绑定在一起，导致只验证页壳、导航栏或
搜索框的用例也被商品可见性阻塞，并通过 `beforeAll` 放大为整组失败。

## 目标

- 首页通用准备只保证路由和首屏页壳稳定，不依赖屏外商品。
- 真正需要商品卡片或秒杀入口的用例显式滚动到目标组件。
- 路由替换后等待 UI 空闲，避免旧页面节点短暂命中后又消失的竞态。
- 单个用例负责自己的页面准备，避免一次 `beforeAll` 失败让整组用例失去诊断价值。
- 保持产品实现和 SWE 首页 Banner 不变，只调整测试观察方式。

## 设计

### 1. 分离“首页就绪”和“商品可见”

`returnToHome()` 执行 `routerStack.replacePath()` 后先调用 `driver.waitForIdle()`，随后只等待：

- `mall-main-entry`
- `mall-home-page`
- `mall-home-content`

它不再等待 `mall-product-item`。

新增 `revealHomeProducts()`。该方法先准备首页页壳，再通过 `mall-home-scroll` 的
`scrollSearch()` 查找 `mall-product-item`，最后等待商品节点稳定出现。

### 2. 按断言目标选择准备方法

- 启动、主导航、首页内容、Banner、搜索：使用 `prepareHome()`，停留在首页顶部。
- 首页商品列数、商品卡片和捏合布局：使用 `revealHomeProducts()`。
- 分类、购物车、我的：先使用 `prepareHome()`，再切换对应 Tab。
- 秒杀入口：在首页滚动容器内 `scrollSearch()` 到 `mall-seckill-entry` 后点击。
- 商品详情等直接路由场景：只依赖稳定的首页页壳，不额外要求商品处于首屏。

### 3. 降低套件级联失败

Common 套件的 `beforeAll` 只获取 Driver。每个 Common 用例在自己的执行路径中准备所需页面，
从而让失败准确归因于该用例断言。

断点套件仍可在套件初始化时建立断点基线，但涉及首页商品可见性的测试必须显式调用
`revealHomeProducts()`，不能依赖初始化时的首屏状态。

## 预期结果

- Common 的 5 个 pass-to-pass 用例在手机、折叠屏和平板上均正常执行，不再因屏外商品在
  `beforeAll` 中整体失败。
- 手机端 `should_keep_sm_category_grid_two_columns` 在路由替换完成后再切换分类页，不再受旧首页
  节点竞态影响。
- SM 的商品布局用例会主动滚动到商品区后断言。
- MD/LG 的 fail-to-pass 用例应在各自真实布局断言处失败，而不是在通用准备阶段失败。
- `test_patch.patch` 重新生成后可干净应用到 SWE，并与 answer 中的 ohosTest 测试树一致。

## 验证

1. 静态检查测试清单、helper 调用和 patch 内容。
2. 将新 `test_patch.patch` 应用到临时 SWE 副本，比较测试树。
3. 执行相关 Hvigor 构建检查。
4. 使用指定 runner 命令运行 SWE：

   `npm run ohostest:case -- --case /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI --run swe`

5. 检查报告中 incorrect 是否清零，并确认 MD/LG 用例在预期业务断言处失败。

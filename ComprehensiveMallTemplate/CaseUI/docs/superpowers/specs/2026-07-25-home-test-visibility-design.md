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

`returnToHome()` 先把二级路由通过 `routerStack.popToName()` 弹回已经存在的 `MAIN_ENTRY` 根页面；
只有根页面节点确实不存在时才使用 `routerStack.replacePath()` 兜底，避免把栈顶替换成第二个同名首页造成
路由竞态。随后显式切回首页 Tab，并使用有限次数的 Driver 向下手势直到顶部搜索框可见。该流程最终等待：

- `mall-main-entry`
- `mall-home-page`
- `mall-home-content`
- `mall-tab-0` 至 `mall-tab-3`

它不再等待 `mall-product-item`。

新增 `revealHomeProducts()`。该方法先准备首页页壳，再在 `mall-home-scroll` 可见区域内执行
有限次数的向上滑动，每次滑动后检测 `mall-product-item`，最后等待商品节点稳定出现。所有首页
滚动都使用有界 Driver 手势，不使用 `scrollSearch()` 或 `scrollToTop()`，避免嵌套
`Scroll + WaterFlow` 的 Component 自动滚动超过 Hypium 单用例超时。

### 2. 按断言目标选择准备方法

- 启动、主导航、首页内容、Banner、搜索：使用 `prepareHome()`，停留在首页顶部。
- 首页商品列数、商品卡片和捏合布局：使用 `revealHomeProducts()`。
- 分类宫格：创建带确定性分类 ID 的分类页，统计与商品卡共用同一网格的加载 Skeleton 首行列数。
  answer 与 SWE 为 Skeleton 单元添加相同测试 ID；用例不再依赖分类商品请求完成时机。
- 购物车、我的：只保证首页页壳存在，不改变首页滚动位置，再切换对应 Tab。
- 切换 Tab 前显式等待目标 Tab 节点，避免页壳已出现但导航节点尚未可交互的短暂窗口。
- 秒杀、搜索、分类和商品详情等直接路由场景：只恢复首页根路由与主 Tab，不改变首页滚动位置，
  然后直接进入目标路由。它们不再依赖大 Banner 下方的入口是否可见。

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
- Skeleton 列数读取在瞬态节点句柄失效时重新获取节点，避免加载完成瞬间的陈旧句柄错误。
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

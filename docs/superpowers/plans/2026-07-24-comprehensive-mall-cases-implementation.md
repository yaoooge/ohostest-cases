# Comprehensive Mall Multi-Device Cases Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:test-driven-development while implementing each behavior. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 从现有综合商城派生两个共享同一手机基线的评测用例，分别提供纯 UI 一多适配 answer 和纯分屏购物 answer，并配套可执行的 pass-to-pass/fail-to-pass 测试资产。

**Architecture:** 先从当前商城生成不含断点适配和分屏能力的共同 swe，再复制为两个字节一致的基础工程。UI answer 从共同 swe 恢复响应式 UI；分屏 answer 从共同 swe 恢复多窗口购物；测试以用例级 test patch 注入，避免破坏两份 swe 的一致性。

**Tech Stack:** HarmonyOS ArkTS、Hvigor、Hypium、UI TestKit、Markdown、Git patch。

---

### Task 1: 建立红灯验证与共同工程骨架

**Files:**
- Create: `ComprehensiveMallTemplate/validate-cases.sh`
- Populate: `ComprehensiveMallTemplate/CaseUI/swe`
- Populate: `ComprehensiveMallTemplate/CaseSplitWindow/swe`
- Populate: `ComprehensiveMallTemplate/CaseUI/answer`
- Populate: `ComprehensiveMallTemplate/CaseSplitWindow/answer`

- [ ] 写验证脚本，检查四个工程存在、两份 swe 哈希一致、首页 tablet 资源不存在、UI/分屏 answer 的禁止能力不串入。
- [ ] 在空目录状态运行脚本，确认因缺少工程文件而失败。
- [ ] 仅复制原商城已跟踪源码和资源，排除 `build`、`.hvigor`、`oh_modules`、`.idea` 和运行日志。

### Task 2: 生成共同 swe 的单窗口路由基线

**Files:**
- Modify: both swe copies under `products/entry/src/main`
- Modify: both swe copies under `commons/lib_foundation/src/main/ets/utils`
- Modify: both swe copies under `commons/lib_foundation/Index.ets`

- [ ] 先增加结构验证，要求 swe 中不存在第二购物窗口声明、分屏状态、双栈复制迁移和多窗口上下文。
- [ ] 删除第二购物窗口及其文案、商品参数中转和生命周期。
- [ ] 将根导航收敛为 EntryAbility 单栈，同时保留商城首页、商品链接直达和订单快捷入口。
- [ ] 将窗口上下文收敛为单活动上下文。

### Task 3: 生成共同 swe 的固定手机 UI

**Files:**
- Modify: both swe copies under `commons/lib_foundation`
- Modify: both swe copies under `commons/lib_widget`
- Modify: both swe copies under `products/entry`
- Modify: both swe copies under `components/module_product_category`
- Modify: both swe copies under `components/module_product_review`
- Modify: both swe copies under `components/module_shopping_cart`
- Modify: both swe copies under `features/order`
- Modify: both swe copies under `features/points`
- Modify: both swe copies under `features/product`
- Modify: both swe copies under `features/setting`
- Modify: both swe copies under `features/shopping`

- [ ] 先增加结构验证，要求 swe 中不存在断点系统、响应式 Grid、宽屏分支、瀑布流缩放和 tablet 首页资源。
- [ ] 将所有断点消费者固定为设计文档中的 SM 表现。
- [ ] 删除断点定义、导出、注册和遗留重复实现。
- [ ] 固定分类为 2 列、评价媒体为 3 列、列表为 1 列、商品详情为单列、首页横幅为 4:3。
- [ ] 删除瀑布流捏合缩放；保留转场窗口几何。
- [ ] 同步两份 swe，并验证源文件哈希一致。

### Task 4: 构建纯 UI answer

**Files:**
- Modify: `ComprehensiveMallTemplate/CaseUI/answer`

- [ ] 从共同 swe 复制 UI answer。
- [ ] 先增加验证规则，要求 MD/LG 断点值、页面列数和首页图片比例存在。
- [ ] 恢复唯一的全局断点系统和窗口变化监听。
- [ ] 恢复首页、商品流、分类、评价、购物车、个人中心、订单、积分、收藏、秒杀和商品详情的 SM/MD/LG 表现。
- [ ] 恢复 MD/LG 瀑布流捏合列数。
- [ ] 不恢复 tablet 首页图片、分屏入口、第二购物窗口和双栈方法。

### Task 5: 构建纯分屏 answer

**Files:**
- Modify: `ComprehensiveMallTemplate/CaseSplitWindow/answer`

- [ ] 从共同 swe 复制分屏 answer。
- [ ] 先增加验证规则，要求主/分屏窗口、分屏启动、双栈复制迁移和状态恢复能力存在。
- [ ] 恢复第二购物窗口、分屏入口、商品参数传递和主从窗口生命周期。
- [ ] 恢复窗口独立路由、活动上下文、主窗口合并接管和从窗口自行关闭。
- [ ] 增加仅服务分屏入口资格的窗口能力判断。
- [ ] 不恢复全局断点系统、响应式列数、宽屏左右分栏、瀑布流缩放或 tablet 首页图片。

### Task 6: 创建 CaseUI 测试资产

**Files:**
- Create: `ComprehensiveMallTemplate/CaseUI/README.md`
- Create: `ComprehensiveMallTemplate/CaseUI/CHANGE_LOG.md`
- Create: `ComprehensiveMallTemplate/CaseUI/metadata.json`
- Create: `ComprehensiveMallTemplate/CaseUI/test_patch.patch`
- Create: `ComprehensiveMallTemplate/CaseUI/golden_patch.patch`

- [ ] 按 spec 写 phone 的 common/SM pass-to-pass。
- [ ] 写 foldable MD fail-to-pass，覆盖 2.5:1 横幅、3 列商品、4 列分类和 5 列评价媒体。
- [ ] 写 tablet LG fail-to-pass，覆盖首页标题搜索、5:1 横幅、主要双列页面和商品详情左右分栏。
- [ ] 测试 patch 同时适用于 swe 和 answer；golden patch 只包含 UI 能力差异。

### Task 7: 创建 CaseSplitWindow 测试资产

**Files:**
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/README.md`
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/CHANGE_LOG.md`
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/metadata.json`
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/test_patch.patch`
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/golden_patch.patch`

- [ ] 写启动、商品链接直达、购买入口和分屏前单窗口 pass-to-pass。
- [ ] 写分屏入口、主从窗口模式、相同商品、双窗口合并入口 fail-to-pass。
- [ ] 写从窗口关闭、从窗口合并和主窗口接管从窗口路由的 fail-to-pass。
- [ ] 测试 patch 同时适用于 swe 和 answer；golden patch 只包含分屏能力差异。

### Task 8: 构建、隔离与补丁验证

**Files:**
- Verify all files under `ComprehensiveMallTemplate`

- [ ] 运行 `validate-cases.sh`，确认两份 swe 一致且能力不串入。
- [ ] 对两个用例分别验证 `golden_patch.patch` 可从干净 swe 应用并得到 answer。
- [ ] 对 swe 和 answer 分别执行依赖同步及 Hvigor 编译。
- [ ] 在可用设备上运行 metadata 指定的 phone、foldable、tablet 测试套件。
- [ ] 更新 README/CHANGE_LOG 中的实际验证结果。
- [ ] 运行 `git diff --check` 并提交。

# Mall 多端适配能力盘点

## 统计口径与摘要

本文以完成非 `module_*` 组件删除后的 `CaseComprehensiveMallTemplate` 当前工作树为准，扫描范围包括 ArkTS 运行时代码、`module.json5` 配置、`ohosTest` 配置、资源限定目录、README/CHANGELOG 和随附截图；排除 `build`、`oh_modules` 与已删除组件。文件数按真实路径去重，符号出现次数不作为文件数。

判定规则：

- “运行时适配”指代码直接读取宽度断点、窗口状态/尺寸、设备宽度，或按这些状态切换布局、列数、弹窗形态和多 Ability 路由。
- `deviceTypes` 只计为部署能力声明，不等同于对应模块已经实现响应式布局。
- `GridRow` / `GridCol` 只计入显式使用者；当前工程没有直接调用 `onBreakpointChange`，响应更新依赖 `windowSizeChange`、`AppStorageV2` 和 `@Local` / `@Computed` 观察链。
- 文档和截图只作为支持范围与视觉基线材料，不作为运行时能力证据。

本轮隐私协议、Push、扫码和广告能力剥离后，去重共涉及 **88 个当前文件**：

| 类型 | 文件数 | 说明 |
| --- | ---: | --- |
| ArkTS 运行时代码 | 38 | 断点基础设施与消费者、栅格、宽屏、分屏、多窗口、窗口尺寸 |
| 生产配置 | 19 | 18 个 `src/main/module.json5`，另含 SecondAbility 文案资源 |
| 测试配置 | 14 | `src/ohosTest/module.json5` 的设备类型声明；没有多端行为专项测试 |
| 平板限定资源 | 1 | `resources/tablet` 下首页横幅 |
| 说明文档与截图 | 16 | 7 个 Markdown 文件、9 张截图 |

核心结论：

1. 主断点链位于 `lib_foundation`，把系统宽度档位归并为 `SM` / `MD` / `LG`；业务代码通常把 `LG` 直接解释为“平板”，因此“宽窗口”和“设备类型”目前存在语义耦合。
2. 商品详情另有独立的应用内分屏链：`SecondAbility`、双路由栈、`WINDOW_MODE_SPLIT_SECONDARY` 和窗口状态监听。它不是普通 Grid 响应式布局，剥离时必须单独处理。
3. 商品瀑布流、首页、个人中心、订单/秒杀/收藏列表、购物车和商品详情均有实际宽屏分支；不能只删除断点工具。
4. `lib_foundation` 与 `module_ui_base` 各保留了一套近似重复的 `BreakpointSystem`，当前业务消费的是 `lib_foundation` 导出；后者属于组件侧遗留实现。
5. 配置声明并不统一：生产/测试模块混用 `default`、`phone`、`tablet`，且部分主模块和测试模块的声明不一致。

## 本轮剥离影响（2026-07-24）

- 首次隐私确认页和启动广告页已删除，普通启动直接进入 `MainEntry`。这只缩短启动路由，不改变 `BreakpointSystem` 注册、宽屏布局或窗口监听。
- 扫码组件及扫码桌面快捷入口已删除，因此原先只服务相机预览的默认显示尺寸读取不再计入当前多端文件；订单桌面快捷入口继续保留。
- Push token、模拟推送和通知授权请求已删除，与断点、分屏及多 Ability 路由没有依赖关系。
- 商品 App Linking 深链、商品详情 `SecondAbility` 分屏/合并、双路由栈，以及 `SM/MD/LG` 断点和 ArkUI Grid 响应式布局均保持不变。

因此，本轮变化不是多端适配能力剥离。后续若执行多端能力剥离，仍需按本文其余章节处理断点、Grid、平板资源、分屏 Ability 和窗口尺寸链路。

## 全局断点系统

| 文件 | 关键符号/行为 | 功能与剥离影响 |
| --- | --- | --- |
| `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/BreakpointSystem.ets` | `BreakpointTypeEnum`、`BreakpointModel`、`BreakpointStorage`、`BreakpointSystem.register()` / `unregister()` / `updateBreakpoint()`、`isTablet` | 通过 `UIContext.getWindowWidthBreakpoint()` 将 `WIDTH_XS/SM` 映射为 `SM`、`WIDTH_MD` 映射为 `MD`、其余映射为 `LG`；监听 `windowSizeChange`，结果存入 `AppStorageV2`。这是当前业务适配主干，提前删除会使大量 `@Computed`、列表列数和宽屏分支失去状态源。 |
| `CaseComprehensiveMallTemplate/commons/lib_foundation/Index.ets` | 导出 `BreakpointTypeEnum`、`BreakpointSystem`、`BreakpointModel`、`BreakpointStorage` | 所有现有业务消费者均通过 `lib_foundation` 包引用；剥离最后才可删除这些出口。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/Index.ets` | `BreakpointSystem.register(uiContext)` | EntryAbility 与 SecondAbility 共用的根页面负责注册当前窗口；分屏窗口销毁后还会重新绑定主窗口。 |
| `CaseComprehensiveMallTemplate/components/module_ui_base/src/main/ets/utils/BreakpointSystem.ets` | 同名枚举、模型、存储与窗口监听 | 与 foundation 版本近似重复，但当前商城业务未从该包消费。可先确认组件外无消费者，再作为独立遗留能力清理。 |
| `CaseComprehensiveMallTemplate/components/module_ui_base/Index.ets` | 导出组件侧 `BreakpointSystem` 系列 | 删除组件侧断点实现时需同步移除导出，避免留下无效公共 API。 |

断点直接消费者及其功能：

| 文件 | 当前适配功能 |
| --- | --- |
| `CaseComprehensiveMallTemplate/commons/lib_widget/src/main/ets/components/CommonSkeletons.ets` | 商品骨架屏：横向卡片 `SM/MD/LG = 2/3/4` 列，纵向卡片手机 1 列、`LG` 2 列。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/HomePageVM.ets` | 把 `LG` 暴露为首页 `isTablet`。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/components/HomePageContent.ets` | 首页横幅宽高比 `SM/MD/LG = 4:3/2.5:1/5:1`；平板分类入口均匀分布。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/HomePage.ets` | 平板把搜索框放入标题行并固定宽 400；手机使用可随滚动收起的独立搜索区；背景色也不同。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/tabviews/ProfilePage.ets` | `LG` 将用户信息与签到/主菜单横向并排，子菜单两列；`SM` 与其他断点采用不同菜单对齐策略。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/MainEntry.ets` | 平板主容器使用灰色背景，其他窗口透明；底部 Tabs 仍使用系统自适应材质。 |
| `CaseComprehensiveMallTemplate/components/module_shopping_cart/src/main/ets/components/CartListView.ets` | 购物车列表 `LG` 两列，否则一列。 |
| `CaseComprehensiveMallTemplate/components/module_shopping_cart/src/main/ets/components/CartControlPanel.ets` | 平板不为底部 Tab 额外预留 56vp，避免宽屏布局底部空隙。 |
| `CaseComprehensiveMallTemplate/components/module_shopping_cart/src/main/ets/components/PopupSheet.ets` | 平板金额明细为居中、40% 宽、32vp 圆角弹窗；手机为底部、全宽、无圆角弹层。 |
| `CaseComprehensiveMallTemplate/features/order/src/main/ets/views/OrderListPage.ets` | `LG` 订单卡片两列，否则一列。 |
| `CaseComprehensiveMallTemplate/features/points/src/main/ets/viewmodels/PointsMallVM.ets` | 积分商品模板 `SM/MD/LG = 2/3/4` 列。 |
| `CaseComprehensiveMallTemplate/features/setting/src/main/ets/components/ProductList.ets` | 收藏/浏览记录等商品列表 `LG` 两列，否则一列。 |
| `CaseComprehensiveMallTemplate/features/shopping/src/main/ets/views/SeckillListPage.ets` | 秒杀列表平板两列、手机一列。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/commons/StyleConfig.ets` | 商品轮播图最大高度、宽高比、相邻图片露出宽度及边距随 `SM/MD/LG` 改变。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/components/ProductOperationButton.ets` | 平板“加入购物车/立即购买”按钮各固定宽 200，其他窗口按可用宽度伸展。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/utils/WaterFlowScaleUtil.ets` | 初始瀑布流 `SM/MD/LG = 2/3/5` 列；手机禁用捏合，折叠/中宽窗口在 2–4 列、平板/宽窗口在 4–6 列间缩放。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/viewmodels/ProductWaterFlowVM.ets` | 列表模式在 `LG` 两列，否则一列；普通模式接入可捏合瀑布流模板。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/ProductInfoPage.ets` | `LG` 进入左右两列商品详情，手机为单列滚动；分屏按钮在非 `SM` 或已经分屏时展示。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/ProductSwiperPage.ets` | 保存断点观察对象（当前未用于布局），并用 `onSizeChange` 把新尺寸传给一镜到底会话；剥离时应同时清掉无效断点状态，但保留尺寸回调所需的转场修正。 |

## GridRow / GridCol 响应式布局

当前共有 4 个真实 Grid 使用文件，且没有显式 `onBreakpointChange`：

| 文件 | 栅格设置 | 功能与剥离影响 |
| --- | --- | --- |
| `CaseComprehensiveMallTemplate/components/module_product_category/src/main/ets/views/ProductCategory.ets` | `GridRow` 的 `xs: 2, md: 4` | 分类商品从窄屏两列切换为中宽及以上四列；改成固定列数会直接改变分类浏览密度。 |
| `CaseComprehensiveMallTemplate/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets` | 媒体选择器 `xs: 3, md: 5` | 待评价图片/动态照片在宽窗口显示五列，窄窗口三列。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/components/ProductReviewCard.ets` | 评价媒体 `xs: 3, md: 5` | 商品详情中的评价缩略图响应式增列。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/ProductInfoPage.ets` | 平板分支内 `columns: { lg: 2 }`，两个 `GridCol(span: 1)` | 商品图和详情信息左右分栏；与 `BreakpointSystem.isTablet` 分支共同构成宽屏详情。 |

这里的 Grid 档位由 ArkUI 自身解析，和工程自定义 `SM/MD/LG` 状态并存。后续若剥离自定义断点，不代表 Grid 会自动被移除；需要明确选择保留 ArkUI 原生响应式栅格还是改为固定布局。

## 平板与宽屏专用布局

除上述直接断点消费者外，还有一项平板资源限定：

| 文件 | 作用 | 剥离影响 |
| --- | --- | --- |
| `CaseComprehensiveMallTemplate/products/entry/src/main/resources/tablet/media/mock_homepage_banner1.png` | `tablet` 资源限定目录中的首页横幅替代图 | 删除平板支持时可删除；若保留平板但剥离代码分支，应保留资源限定能力并验证实际资源解析。 |

当前代码中的 `isTablet` 本质是 `LG` 宽度判断，并未读取物理设备类型。这使展开态折叠屏、桌面自由窗口或分屏后的平板可能随窗口宽度在“手机/平板布局”之间切换。剥离时建议以“是否保留宽窗口体验”为决策依据，不要只按设备名机械删除。

## 分屏与第二 Ability

应用内分屏的完整链路如下：

| 文件 | 关键符号/行为 | 功能与剥离影响 |
| --- | --- | --- |
| `CaseComprehensiveMallTemplate/products/entry/src/main/module.json5` | `SecondAbility`；`supportWindowMode: ["fullscreen", "split"]` | 声明可用于分屏的第二 UIAbility。剥离分屏时需删除 Ability 声明，而不是只隐藏按钮。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/resources/base/element/string.json` | `SecondAbility_label` | SecondAbility 配套资源；Ability 删除后可一并清理。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/viewmodels/ProductInfoVM.ets` | `startSplitScreen()`、`mergeSplitScreen()`、`isSplitScreen`、`WINDOW_MODE_SPLIT_SECONDARY`、`windowStatusChange` | 启动次窗口、更新分屏状态、合并时迁移路由并关闭 SecondAbility；主窗口恢复全屏时修正状态。是分屏业务控制中心。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/ProductInfoPage.ets` | 分屏/合并按钮及 `vm.isSplitScreen` 条件 | 用户入口；分屏时即使窗口变窄仍保留合并按钮。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/secondability/SecondAbility.ets` | 第二窗口生命周期、活动上下文切换、销毁时恢复主窗口断点监听 | 删除后需同步收敛 `WindowUtil`、路由栈与传参缓存，否则会留下无效 ability 名称和状态。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets` | 从 Want 写入 `splitNavStore`，窗口激活时切换活动路由/上下文 | 同时服务普通深链和分屏传参；剥离时保留普通 `SetupUtil` 深链逻辑，只移除分屏专用字段。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/SplitNavStore.ets` | `productId`、`slotId`、`isSplitPage` 临时缓存 | 在 Ability 创建与根页面建栈之间传递商品导航参数。 |
| `CaseComprehensiveMallTemplate/products/entry/src/main/ets/views/Index.ets` | 按 Ability 名注册独立栈；SecondAbility `cloneStackTo()`；主窗口按缓存直达商品页 | 是两窗口共用的导航根。剥离必须恢复单 Ability 初始化路径。 |
| `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/RouterUtil.ets` | `isSplitActive`、`stackMap`、`activeAbilityName`、`cloneStackTo()`、`migrateStack()` | 为每个 Ability 维护独立 `NavPathStack`。若没有其他多窗口需求，可在分屏删除后简化为单栈；在消费者迁移前不能先删。 |
| `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/WindowUtil.ets` | Ability 名到 `UIContext` 的映射、活动上下文、`getUIAbilityContext()` | 保障 toast、路由和 Ability 操作落到当前窗口。分屏移除后可评估回退为单全局上下文。 |

## 窗口尺寸、高度和方向响应

| 文件 | 当前能力 | 注意事项 |
| --- | --- | --- |
| `CaseComprehensiveMallTemplate/components/module_transition/src/main/ets/utils/WindowUtils.ets` | 初始化时读取 `windowRect.width/height`、系统避让区和导航指示器高度；监听 `windowSizeChange` 与 `avoidAreaChange`，写入 `AppStorage`。 | 支撑一镜到底转场在窗口变化和沉浸式区域下的几何计算。移除响应监听前需验证旋转、分屏合并和自由窗口中的转场。 |
| `CaseComprehensiveMallTemplate/components/module_transition/src/main/ets/constants/LongTakeTransitionConstants.ets` | 定义 `WINDOW_SIZE` 与 `ON_WINDOW_SIZE_CHANGED` 存储键。 | 与 `WindowUtils` 成组清理；当前 `ON_WINDOW_SIZE_CHANGED` 没有明确的有效观察消费。 |
| `CaseComprehensiveMallTemplate/components/module_transition/src/main/ets/utils/LoneTakeAnimationsTransition.ets` | 在两个 Ability 创建窗口内容后调用 `WindowUtils.init(windowStage)`。 | 若删除窗口监听但保留转场，需要替换其初始化依赖。 |
| `CaseComprehensiveMallTemplate/components/module_transition/src/main/ets/customtransition/ImageLongTakeDelegate.ets` | 读取当前 `windowRect.width`，据此计算图片手势边界。 | 固定宽度会破坏宽屏/旋转后的拖拽与缩放范围。 |
| `CaseComprehensiveMallTemplate/components/module_transition/src/main/ets/sessions/LongTakeAnimationProperties.ets` | 读取当前窗口沉浸模式，并依据页面新尺寸维护转场裁剪尺寸。 | 与 `ProductSwiperPage.onSizeChange` 配合；不是断点布局，但属于窗口变化兼容。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/views/ProductSwiperPage.ets` | `NavDestination.onSizeChange` 把新尺寸传入转场会话。 | 应与转场模块一起保留或一起替换。 |
| `CaseComprehensiveMallTemplate/features/product/src/main/ets/viewmodels/ProductInfoVM.ets` | 监听 `windowStatusChange`，主窗口恢复 `FULL_SCREEN` 时清除分屏状态。 | 这是窗口模式响应，不是宽度断点。 |

工程没有直接读取方向枚举，也没有独立的横/竖屏资源限定目录；方向变化主要通过宽度断点和窗口尺寸事件间接生效。

## deviceTypes 配置声明

共有 32 个当前 `module.json5` 含 `deviceTypes`：18 个生产模块配置、14 个 `ohosTest` 配置。按值组合统计为：

| 声明组合 | 文件数 |
| --- | ---: |
| 仅 `default` | 14 |
| 仅 `phone` | 10 |
| `phone` + `tablet` | 4 |
| `default` + `tablet` | 4 |

### 生产模块配置（18）

| 声明 | 文件 |
| --- | --- |
| `phone` + `tablet` | `CaseComprehensiveMallTemplate/components/module_transition/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/products/entry/src/main/module.json5` |
| `default` + `tablet` | `CaseComprehensiveMallTemplate/features/points/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/features/product/src/main/module.json5` |
| 仅 `phone` | `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_custom_service_chat/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_filter/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_search/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_shopping_cart/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/features/order/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/features/shopping/src/main/module.json5` |
| 仅 `default` | `CaseComprehensiveMallTemplate/commons/lib_network/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/commons/lib_widget/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_notice_center/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_category/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_review/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_ui_base/src/main/module.json5`<br>`CaseComprehensiveMallTemplate/features/setting/src/main/module.json5` |

生产配置存在明显不一致：入口声明平板，但它依赖的 `lib_foundation`、订单、购物、购物车等模块仍仅声明 `phone`；部分使用响应式代码的模块用 `default`。后续若剥离平板能力，必须先确定 `default` 的目标语义，不能只删除显式 `"tablet"`。

### 测试配置（14）

| 声明 | 文件 |
| --- | --- |
| `phone` + `tablet` | `CaseComprehensiveMallTemplate/components/module_shopping_cart/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_transition/src/ohosTest/module.json5` |
| `default` + `tablet` | `CaseComprehensiveMallTemplate/components/module_product_filter/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/features/product/src/ohosTest/module.json5` |
| 仅 `phone` | `CaseComprehensiveMallTemplate/commons/lib_foundation/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_custom_service_chat/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_search/src/ohosTest/module.json5` |
| 仅 `default` | `CaseComprehensiveMallTemplate/commons/lib_network/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/commons/lib_widget/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_notice_center/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_category/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_product_review/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/components/module_ui_base/src/ohosTest/module.json5`<br>`CaseComprehensiveMallTemplate/features/setting/src/ohosTest/module.json5` |

现有 `ohosTest` 测试源码没有断点、Grid、平板布局、分屏或窗口模式专项断言；当前测试侧多端信息仅停留在上述模块部署声明。剥离前应先增加至少覆盖 `SM/MD/LG` 映射、分屏启动/合并、宽屏列数和窗口恢复全屏的测试。

## 截图与说明材料

### 支持范围与变更说明（7 个 Markdown）

| 文件 | 多端相关内容 |
| --- | --- |
| `CaseComprehensiveMallTemplate/README.md` | 约束中声明支持华为手机（含双折叠、阔折叠）与华为平板，是当前产品级支持口径。 |
| `CaseComprehensiveMallTemplate/CHANGELOG.md` | 记录折叠屏/平板商品详情分屏，以及折叠屏/平板商品瀑布流手势缩放。 |
| `CaseComprehensiveMallTemplate/components/module_custom_service_chat/README.md` | 声明手机（含双折叠、阔折叠）支持范围。 |
| `CaseComprehensiveMallTemplate/components/module_product_filter/README.md` | 声明手机（含双折叠、阔折叠）支持范围。 |
| `CaseComprehensiveMallTemplate/components/module_product_review/README.md` | 声明手机（含双折叠、阔折叠）支持范围，并引用组件效果图。 |
| `CaseComprehensiveMallTemplate/components/module_product_search/README.md` | 声明手机（含双折叠、阔折叠）支持范围，并引用组件效果图。 |
| `CaseComprehensiveMallTemplate/components/module_shopping_cart/README.md` | 声明手机（含双折叠、阔折叠）支持范围，并引用普通与子路由购物车截图。 |

### 视觉基线（9 张）

| 范围 | 文件 | 现状 |
| --- | --- | --- |
| 商城主页面 | `CaseComprehensiveMallTemplate/screenshot/home.jpeg`<br>`CaseComprehensiveMallTemplate/screenshot/category.jpeg`<br>`CaseComprehensiveMallTemplate/screenshot/cart.jpeg`<br>`CaseComprehensiveMallTemplate/screenshot/profile.jpeg` | 可作为首页、分类、购物车、个人中心的现有视觉基线，但没有明确标注窗口尺寸或设备类型。 |
| 商品筛选 | `CaseComprehensiveMallTemplate/components/module_product_filter/snapshots/display.jpg` | 组件效果图，没有平板/分屏对照。 |
| 商品评价 | `CaseComprehensiveMallTemplate/components/module_product_review/snapshots/display.png` | 组件效果图，没有展示 `xs:3` 与 `md:5` 的对照。 |
| 商品搜索 | `CaseComprehensiveMallTemplate/components/module_product_search/snapshots/display.png` | 组件效果图，没有折叠展开态对照。 |
| 购物车 | `CaseComprehensiveMallTemplate/components/module_shopping_cart/screenshot/cartPage.png`<br>`CaseComprehensiveMallTemplate/components/module_shopping_cart/screenshot/childrenRoute.png` | 普通页与子路由场景截图，没有平板双列或居中弹窗对照。 |

当前没有明确的平板、折叠展开态、应用内分屏、旋转前后对比截图。若后续剥离，需要先补齐这些基线，否则难以判断移除的是冗余能力还是仍被验收的产品能力。

## 文件统计

| 分类 | 去重文件数 | 主要集中区域 |
| --- | ---: | --- |
| 断点定义/注册/导出 | 5 | `lib_foundation`、`module_ui_base`、入口根页面 |
| 断点直接消费与宽屏分支 | 19 | entry、购物车、订单、积分、商品、设置、购物 |
| 原生 Grid 响应式 | 4 | 分类、评价、商品详情（其中商品详情已计入断点消费者，去重时不重复） |
| 分屏与多 Ability | 10 | entry、product、foundation（其中 2 个文件同时属于断点/宽屏类别） |
| 窗口/显示尺寸与转场 | 7 | transition、product（其中 2 个文件同时属于分屏或断点类别） |
| ArkTS 运行时代码合计 | **38** | 上述类别并集 |
| 生产配置 | **19** | 18 个生产 `module.json5` + 1 个 SecondAbility 文案资源 |
| 测试配置 | **14** | `ohosTest/module.json5` |
| 平板限定资源 | **1** | entry 首页横幅 |
| 说明文档与截图 | **16** | 7 个 Markdown + 9 张图片 |
| 全部文件合计 | **88** | 所有分类按路径去重 |

可复现扫描入口：

```bash
rg -l "BreakpointSystem|BreakpointTypeEnum|BreakpointStorage|onBreakpointChange|GridRow|GridCol|windowSizeChange|WindowMode|WINDOW_MODE_SPLIT|isSplitScreen|splitNavStore|deviceTypes|isTablet|foldable|tablet" \
  CaseComprehensiveMallTemplate \
  --glob '*.{ets,ts,json5,json,md}' \
  --glob '!build/**' \
  --glob '!oh_modules/**' \
  | sort
```

该命令用于发现候选文件；上述统计又补充了 `windowStatusChange`、`onSizeChange`、`getDefaultDisplaySync()`、平板资源和截图，并人工排除了普通字符串 `split()` 等误报。

## 后续剥离影响与建议顺序

建议按依赖从叶子到根分阶段进行，每一阶段都保留手机主流程构建与页面回归：

1. **先锁定验收基线。** 补充手机窄屏、折叠展开态、平板、商品详情分屏/合并、旋转或窗口缩放截图与自动化断言；同时确定是否仍需支持 `README.md` 声明的折叠屏和平板。
2. **先处理无业务依赖的声明与遗留副本。** 统一生产/测试 `deviceTypes` 语义，确认无消费者后删除 `module_ui_base` 的重复断点实现；不要先动 `lib_foundation` 主断点。
3. **独立剥离应用内分屏。** 依次移除商品详情入口与 VM 操作、SecondAbility 生命周期和声明、`splitNavStore`、双栈复制/迁移及多上下文映射；保留普通商品深链与单窗口路由。该阶段不应同时改响应式布局，便于定位回归。
4. **处理局部 Grid 与资源限定。** 按产品决策把分类/评价/商品详情 Grid 改为固定手机布局或继续保留 ArkUI 原生响应式；随后处理 `resources/tablet` 横幅。Grid 与自定义断点互相独立。
5. **逐页收敛宽屏分支。** 推荐顺序为低风险列表列数（订单、秒杀、收藏、购物车）→ 首页/个人中心 → 商品瀑布流捏合 → 商品详情左右分栏与轮播样式。每步明确固定后的手机列数、边距和弹窗形态。
6. **最后移除 foundation 断点主干。** 仅当所有业务导入清零后，删除 `BreakpointSystem` 注册、存储、枚举与出口；同时确认 SecondAbility 销毁逻辑不再重注册它。
7. **窗口尺寸能力单独决策。** 一镜到底转场不应因“删除平板布局”被一并删除。即使只支持手机，旋转、分屏系统行为、自由窗口和避让区变化仍可能需要这些监听；若确实剥离，应先用固定尺寸/生命周期刷新方案替代。
8. **同步文档、截图和测试配置。** 更新产品支持范围、CHANGELOG/组件 README、`deviceTypes` 和视觉基线，避免代码已降级为手机单端但文档仍承诺折叠屏/平板。

高风险影响点是商品详情（同时连接断点、Grid、分屏、双路由栈和窗口状态）、商品瀑布流（断点加捏合列数）与 transition（窗口几何影响手势/转场）。建议三个区域分别提交和验证，不做一次性全量删除。

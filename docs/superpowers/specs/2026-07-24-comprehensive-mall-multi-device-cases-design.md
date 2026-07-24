# 综合商城一多适配双用例设计

## 1. 背景与目标

当前 `CaseComprehensiveMallTemplate` 同时包含两类一多能力：

1. 基于 `SM`、`MD`、`LG` 断点的响应式 UI 适配。
2. 商品详情页基于 `SecondAbility` 的应用内分屏购物能力。

本次将原工程改造为两个相互独立的评测用例：

| 用例目录 | 评测目标 | answer 允许包含的新增能力 |
| --- | --- | --- |
| `ComprehensiveMallTemplate/CaseUI` | 将固定手机布局改造为多断点响应式 UI | 断点系统、响应式布局、宽屏样式、瀑布流缩放 |
| `ComprehensiveMallTemplate/CaseSplitWindow` | 将单窗口商品详情改造为应用内分屏购物 | SecondAbility、分屏启停、双路由栈、多窗口上下文 |

两个用例必须从同一个剥离基线派生，且两份 `swe` 工程完全一致。`CaseUI/answer` 不得包含分屏能力，`CaseSplitWindow/answer` 不得包含响应式 UI 能力。

## 2. 已确认的设计决策

### 2.1 首页平板资源

删除：

```text
products/entry/src/main/resources/tablet/media/mock_homepage_banner1.png
```

该资源从共同 `swe` 删除后，两个 answer 均不恢复。UI answer 的首页横幅只使用基础资源，通过 `aspectRatio` 表达断点差异：

| 断点 | 横幅宽高比 |
| --- | ---: |
| SM | 4:3 |
| MD | 2.5:1 |
| LG | 5:1 |

UITest 只验证横幅容器比例，不比较或识别图片内容。

### 2.2 窗口尺寸与转场

`module_transition` 中的窗口尺寸、避让区和 `ProductSwiperPage.onSizeChange` 继续保留在共同 `swe`。这些代码还服务手机旋转、沉浸区域和一镜到底动画，不作为本次 UI 断点能力剥离对象。

只删除其中与 `SecondAbility` 生命周期直接相关的初始化和恢复调用；这些调用仅在分屏 answer 中恢复。

### 2.3 重复断点实现

`module_ui_base` 中未被当前业务消费的重复 `BreakpointSystem` 从共同 `swe` 删除，UI answer 也不恢复。UI answer 只使用 `lib_foundation` 中的一套断点系统，避免参考答案携带无效公共 API。

### 2.4 用例测试的存放方式

两个 `swe` 必须完全一致，因此不同用例的 UITest 不直接固化进初始 `swe`。每个用例使用自己的 `test_patch.patch`，评测时对对应的 swe/answer 注入相同测试和测试 ID。

## 3. 目标目录

```text
ComprehensiveMallTemplate/
├── CaseUI/
│   ├── README.md
│   ├── CHANGE_LOG.md
│   ├── metadata.json
│   ├── golden_patch.patch
│   ├── test_patch.patch
│   ├── swe/
│   └── answer/
└── CaseSplitWindow/
    ├── README.md
    ├── CHANGE_LOG.md
    ├── metadata.json
    ├── golden_patch.patch
    ├── test_patch.patch
    ├── swe/
    └── answer/
```

`golden_patch.patch` 分别表示：

- CaseUI：共同 swe → 仅 UI 适配 answer。
- CaseSplitWindow：共同 swe → 仅分屏购物 answer。

## 4. 共同 swe 工程

共同 swe 保留商城核心业务和固定手机布局，剥离全部 UI 一多适配及分屏能力。

### 4.1 保留内容

| 范围 | 保留内容 |
| --- | --- |
| 启动 | EntryAbility 直接进入 `MainEntry` |
| 首页 | 搜索、分类、活动卡片、商品列表 |
| 主 Tab | 首页、分类、购物车、我的 |
| 商品 | 商品列表、商品详情、评价、加购、购买 |
| 订单 | 订单列表、订单详情、快捷入口 |
| 路由 | 单 Ability、单 `NavPathStack` |
| 外部入口 | 商品 App Linking、订单桌面快捷入口 |
| 网络 | 现有 mock API 与 mock 数据 |
| 转场 | 一镜到底动画、窗口尺寸和避让区几何 |

### 4.2 UI 能力剥离

| 原能力 | swe 固定行为 |
| --- | --- |
| `BreakpointSystem` | 删除定义、导出、注册和监听 |
| 首页横幅 | 固定 4:3 |
| 首页搜索 | 固定为标题下方的手机搜索区 |
| 普通商品瀑布流 | 固定 2 列 |
| 瀑布流捏合 | 删除手势及列数缩放工具 |
| 分类商品 Grid | 固定 2 列 |
| 评价媒体 Grid | 固定 3 列 |
| 列表类页面 | 固定 1 列 |
| 商品详情 | 固定单列纵向滚动 |
| 商品操作按钮 | 自动平分可用宽度 |
| 购物车金额明细 | 底部全宽弹层 |
| 首页 tablet 图片 | 直接删除，任何 answer 均不恢复 |

### 4.3 分屏能力剥离

| 原能力 | swe 处理 |
| --- | --- |
| `SecondAbility` | 删除源码和 `module.json5` 声明 |
| `SecondAbility_label` | 删除 |
| 商品详情分屏按钮 | 删除 |
| `SplitNavStore` | 删除 |
| `WINDOW_MODE_SPLIT_SECONDARY` | 删除 |
| `isSplitActive` | 删除 |
| 双路由栈 Map | 收敛为单栈 |
| `cloneStackTo` / `migrateStack` | 删除 |
| 多 Ability UIContext Map | 收敛为单上下文 |
| `windowStatusChange` 分屏恢复 | 删除 |

### 4.4 一致性检查

排除 `build`、`.hvigor`、`oh_modules` 和运行日志后执行：

```bash
diff -qr \
  ComprehensiveMallTemplate/CaseUI/swe \
  ComprehensiveMallTemplate/CaseSplitWindow/swe
```

同时对两份工程生成排序后的 SHA-256 文件清单，结果必须完全一致。

## 5. UI 用例设计

### 5.1 断点定义

沿用系统 `WidthBreakpoint` 的映射：

| 用例断点 | 系统宽度档位 | 主要测试设备 |
| --- | --- | --- |
| SM | `WIDTH_XS`、`WIDTH_SM` | 直板手机、折叠屏折叠态 |
| MD | `WIDTH_MD` | 折叠屏展开态、中宽窗口 |
| LG | 其余更宽档位 | 平板、宽窗口 |

测试根据活动窗口实际 vp 宽度校验断点。若设备没有进入 metadata 指定的断点，测试应明确失败，不允许静默跳过。

### 5.2 逐页面 SM/MD/LG 展示矩阵

#### 商城根页面与首页

| 页面/区域 | SM | MD | LG |
| --- | --- | --- | --- |
| `MainEntry` 背景 | 透明 | 透明 | 灰色 |
| 首页标题区 | 标题行不放搜索框 | 同 SM | 标题行右侧放置固定 400vp 搜索框 |
| 首页滚动搜索区 | 标题下方独立搜索区；滚动时可收起 | 同 SM | 不显示独立搜索区 |
| 首页搜索区背景 | 主背景色 | 主背景色 | 灰色/透明宽屏标题背景 |
| 首页横幅 | 使用基础图片，比例 4:3 | 使用同一基础图片，比例 2.5:1 | 使用同一基础图片，比例 5:1 |
| 首页分类入口 | 横向滚动，靠左排列 | 同 SM | 在可用宽度内均匀分布 |
| 首页普通商品瀑布流 | 初始 2 列，不响应捏合 | 初始 3 列，可在 2–4 列间捏合 | 初始 5 列，可在 4–6 列间捏合 |

说明：LG 首页不再使用 `resources/tablet` 图片；三个断点始终解析同一基础资源。

#### 分类、搜索结果与商品列表

| 页面/区域 | SM | MD | LG |
| --- | --- | --- | --- |
| 分类页商品 Grid | 2 列 | 4 列 | 4 列 |
| 普通商品 WaterFlow | 2 列 | 3 列 | 5 列 |
| 商品列表模式 | 1 列 | 1 列 | 2 列 |
| 商品列表骨架屏（横向卡片） | 2 列 | 3 列 | 4 列 |
| 商品列表骨架屏（纵向卡片） | 1 列 | 1 列 | 2 列 |
| 收藏/浏览记录商品列表 | 1 列 | 1 列 | 2 列 |
| 秒杀商品列表 | 1 列 | 1 列 | 2 列 |

#### 商品详情与商品评价

| 页面/区域 | SM | MD | LG |
| --- | --- | --- | --- |
| 商品详情主体 | 单列纵向滚动 | 单列纵向滚动 | 左侧商品图、右侧详情信息两栏 |
| 商品详情背景 | 主背景色 | 主背景色 | 灰色 |
| 商品轮播最大高度 | 360vp | 360vp | 填满左栏可用高度 |
| 商品轮播图片比例 | 1:1 | 1:1 | 不强制固定比例 |
| 相邻轮播图片露出 | 0 | 120vp | 0 |
| 轮播外层横向 padding | 16vp 资源值 | 0 | 16vp 资源值 |
| 轮播图片 padding | 左右各 6vp | 左右各 6vp、上下各 8vp | 0 |
| 评价媒体缩略图 | 3 列 | 5 列 | 5 列 |
| 创建评价媒体选择器 | 3 列 | 5 列 | 5 列 |
| “加入购物车/立即购买”按钮 | 自动伸展 | 自动伸展 | 每个固定 200vp |
| 客服按钮右边距 | 普通间距 | 普通间距 | 加大间距 |
| 分屏/合并入口 | 不存在 | 不存在 | 不存在 |

UI answer 在所有断点均不得出现分屏入口。

#### 购物车

| 页面/区域 | SM | MD | LG |
| --- | --- | --- | --- |
| 购物车商品列表 | 1 列 | 1 列 | 2 列 |
| 底部控制栏 Tab 预留 | 额外预留 56vp | 额外预留 56vp | 不额外预留 |
| 金额明细弹层 | 底部、全宽、无圆角 | 同 SM | 居中、窗口宽度约 40%、32vp 圆角 |

#### “我的”、订单与积分商城

| 页面/区域 | SM | MD | LG |
| --- | --- | --- | --- |
| 用户信息/签到/主菜单 | 纵向依次排列 | 同 SM | 用户信息与“签到+主菜单”横向并排 |
| 主菜单对齐 | `SpaceBetween` | `SpaceAround` | `SpaceAround` |
| 订单状态入口对齐 | `SpaceBetween` | `SpaceAround` | `SpaceAround` |
| “我的”子菜单 | 1 列 | 1 列 | 2 列 |
| 订单列表 | 1 列 | 1 列 | 2 列 |
| 积分商品 | 2 列 | 3 列 | 4 列 |

#### 不随断点改变的页面

以下页面保留共同业务表现，不因 UI answer 引入新的页面级结构：

| 页面 | SM / MD / LG 共同表现 |
| --- | --- |
| 商品筛选 | 保留原筛选交互，布局不新增断点分支 |
| 商品搜索输入页 | 保留搜索、历史和联想交互 |
| 客服会话 | 保留消息列表和输入区 |
| 通知中心 | 保留单列表结构 |
| 订单详情、物流、提交订单 | 保留现有业务结构 |
| 设置类表单页 | 保留现有表单结构；仅其中商品列表消费者按上表变化 |

### 5.3 UI answer 代码边界

UI answer 恢复：

1. `lib_foundation` 的断点枚举、存储、模型和窗口监听。
2. 根页面断点注册。
3. 上述页面矩阵涉及的全部消费者。
4. ArkUI `GridRow/GridCol` 的响应式列数。
5. WaterFlow 的断点初始列数及 MD/LG 捏合缩放。
6. 支持 phone/tablet 的必要模块声明。

UI answer 不恢复：

1. tablet 首页专用图片。
2. `module_ui_base` 重复断点实现。
3. SecondAbility 及任何分屏逻辑。
4. 双路由栈和多 Ability 上下文。

## 6. UI 用例 UITest

### 6.1 pass-to-pass

这些测试必须在共同 swe 和 UI answer 上都通过。

| 测试名称 | 页面 | 断点/设备 | 断言 |
| --- | --- | --- | --- |
| `should_start_mall_successfully` | 首页 | 全部 | EntryAbility 启动，商城根节点和首页出现 |
| `should_show_four_main_tabs` | 主页面 | 全部 | 首页、分类、购物车、我的四个 Tab 存在 |
| `should_keep_home_content_available` | 首页 | 全部 | 搜索、分类、活动卡片、商品列表正常加载 |
| `should_keep_sm_home_banner_ratio_4_3` | 首页 | SM/phone | 横幅 bounds 接近 4:3 |
| `should_keep_sm_search_in_separate_row` | 首页 | SM/phone | 搜索框位于标题下方并占手机内容宽度 |
| `should_keep_sm_product_waterflow_two_columns` | 首页 | SM/phone | 首行商品为 2 列 |
| `should_keep_sm_category_grid_two_columns` | 分类 | SM/phone | 分类商品为 2 列 |
| `should_keep_sm_product_detail_single_column` | 商品详情 | SM/phone | 商品图和详情上下排列 |
| `should_keep_product_purchase_actions_available` | 商品详情 | 全部 | 客服、购物车、加购、购买入口存在 |
| `should_keep_split_action_absent_in_ui_case` | 商品详情 | 全部 | 不存在分屏或合并按钮 |

### 6.2 fail-to-pass

这些测试在共同 swe 上失败，在 UI answer 上通过。

| 测试名称 | 页面 | 断点/设备 | answer 断言 |
| --- | --- | --- | --- |
| `should_use_md_home_banner_ratio_2_5` | 首页 | MD/foldable | 同一基础图片的容器比例接近 2.5:1 |
| `should_show_three_product_columns_on_md` | 首页商品流 | MD/foldable | 初始 3 列 |
| `should_show_four_category_columns_on_md` | 分类 | MD/foldable | 商品 Grid 4 列 |
| `should_show_five_review_media_columns_on_md` | 商品评价 | MD/foldable | 评价媒体 5 列 |
| `should_place_400vp_search_in_home_title_on_lg` | 首页 | LG/tablet | 搜索框位于标题行，宽约 400vp |
| `should_use_lg_home_banner_ratio_5` | 首页 | LG/tablet | 同一基础图片的容器比例接近 5:1 |
| `should_show_five_product_columns_on_lg` | 首页商品流 | LG/tablet | 初始 5 列 |
| `should_show_two_cart_columns_on_lg` | 购物车 | LG/tablet | 商品卡片 2 列 |
| `should_show_two_order_columns_on_lg` | 订单列表 | LG/tablet | 订单卡片 2 列 |
| `should_show_two_seckill_columns_on_lg` | 秒杀列表 | LG/tablet | 秒杀商品 2 列 |
| `should_show_two_collection_columns_on_lg` | 收藏/浏览记录 | LG/tablet | 商品列表 2 列 |
| `should_show_four_points_products_on_lg` | 积分商城 | LG/tablet | 积分商品 4 列 |
| `should_use_lg_profile_horizontal_header` | 我的 | LG/tablet | 用户信息与签到/主菜单横向并排 |
| `should_use_lg_profile_two_column_submenu` | 我的 | LG/tablet | 子菜单 2 列 |
| `should_show_product_detail_as_two_panes_on_lg` | 商品详情 | LG/tablet | 商品图与详情左右排列 |
| `should_use_200vp_product_action_buttons_on_lg` | 商品详情 | LG/tablet | 两个操作按钮各约 200vp |
| `should_center_cart_amount_sheet_on_lg` | 购物车 | LG/tablet | 弹层居中且宽约窗口 40% |

横幅测试不得按资源名称、像素内容或截图相似度断言。

### 6.3 补充非 UITest 验证

骨架屏出现时间受异步 mock 调度影响，不作为强制 UITest。通过 ArkTS 单元测试验证：

| 测试 | 预期 |
| --- | --- |
| 横向骨架卡片列数 | SM=2、MD=3、LG=4 |
| 纵向骨架卡片列数 | SM=1、MD=1、LG=2 |
| BreakpointModel 映射 | 三个断点分别返回对应值 |
| WaterFlow 初始列数 | SM=2、MD=3、LG=5 |
| WaterFlow 捏合范围 | SM 不变、MD 2–4、LG 4–6 |

## 7. 分屏购物用例设计

### 7.1 answer 能力范围

分屏 answer 恢复：

1. `SecondAbility` 源码、声明和 label。
2. 商品详情分屏/合并入口。
3. `SplitNavStore` 商品参数中转。
4. EntryAbility 与 SecondAbility 的独立路由栈。
5. `cloneStackTo()` 和 `migrateStack()`。
6. 多 Ability `UIContext` 管理。
7. `WINDOW_MODE_SPLIT_SECONDARY` 启动。
8. SecondAbility 销毁和主窗口恢复全屏时的状态回收。
9. SecondAbility 的转场初始化。

分屏 answer 不恢复：

1. 全局 `BreakpointSystem`。
2. 首页、列表、商品详情的响应式布局。
3. WaterFlow 捏合列数。
4. tablet 首页图片。
5. 平板商品详情左右分栏。

### 7.2 分屏状态下页面表现

| 状态 | EntryAbility | SecondAbility | 路由与上下文 |
| --- | --- | --- | --- |
| 未分屏 | 全屏商品详情 | 不存在 | 单活动栈 |
| 启动分屏 | `PRIMARY` 主窗 | `SECONDARY` 从窗 | 从窗复制主窗完整栈 |
| 分屏浏览 | 保持原商品或独立浏览 | 可继续进入购物车/其他商品 | 操作路由到当前聚焦窗口 |
| 从窗点击合并 | 主窗恢复全屏 | 自身关闭 | 主窗保留原栈 |
| 主窗点击合并 | 主窗恢复全屏并接管从窗页面 | 关闭 | 从窗栈迁移到主窗 |
| 系统关闭从窗 | 主窗恢复全屏 | 销毁 | 清除分屏状态，活动上下文回主窗 |

### 7.3 分屏入口资格

分屏 answer 不引入通用 UI 断点系统。使用仅服务分屏入口的 `SplitCapability`：

- 窄手机窗口不显示启动分屏按钮。
- 支持分屏的中宽/宽窗口显示启动按钮。
- 已进入分屏后，即使单个窗口变窄，合并按钮继续显示。
- 该能力不得驱动任何页面布局或列数变化。

## 8. 分屏用例 UITest

### 8.1 pass-to-pass

| 测试名称 | 设备 | 断言 |
| --- | --- | --- |
| `should_start_mall_successfully` | 全部 | EntryAbility 与首页正常启动 |
| `should_open_product_detail_from_applink` | 全部 | App Linking 可进入指定商品详情 |
| `should_keep_purchase_actions_available` | 全部 | 客服、购物车、加购和购买入口存在 |
| `should_have_one_fullscreen_window_before_split` | 全部 | 初始只有一个 FULLSCREEN 商城窗口 |
| `should_keep_product_detail_single_column_on_wide_window` | foldable/tablet | 宽窗口仍为共同 swe 的固定单列详情 |
| `should_hide_split_action_on_sm` | phone | 窄窗口不显示分屏入口 |

### 8.2 fail-to-pass

| 测试名称 | 设备 | answer 断言 |
| --- | --- | --- |
| `should_show_split_action_on_supported_window` | foldable/tablet | 商品详情出现分屏入口 |
| `should_start_secondary_window_in_split_mode` | foldable/tablet | 主窗为 PRIMARY，从窗为 SECONDARY |
| `should_show_same_product_in_secondary_window` | foldable/tablet | 从窗加载相同商品 |
| `should_show_merge_action_in_both_windows` | foldable/tablet | 聚焦任一窗口均有合并入口 |
| `should_restore_main_window_when_secondary_is_closed` | foldable/tablet | TestKit 关闭从窗后主窗恢复 FULLSCREEN |
| `should_merge_when_action_is_clicked_in_secondary` | foldable/tablet | 从窗合并后自身关闭，主窗保留原商品 |
| `should_migrate_secondary_navigation_when_merged_from_primary` | foldable/tablet | 主窗合并后接管从窗最新路由 |

窗口通过 Ability label 区分：

| Ability | 窗口标题 |
| --- | --- |
| EntryAbility | `综合商城模板` |
| SecondAbility | `分屏-商品详情` |

使用 `UiWindow.getWindowMode()` 断言 `FULLSCREEN`、`PRIMARY` 和 `SECONDARY`，不以窗口宽度间接推断分屏成功。

## 9. UITest 工程约束

1. `test_patch.patch` 为关键页面和组件增加稳定 ID。
2. 测试 ID 同时注入 swe 和 answer，不属于 golden patch。
3. 几何断言统一转换为 vp，并使用合理容差：
   - 固定长度：建议 ±2vp。
   - 比例：建议误差不超过 0.08。
4. 列数通过同一行元素的坐标聚类判断，不使用“容器宽度 ÷ 卡片宽度”的脆弱估算。
5. 异步页面统一使用轮询等待，不使用固定长时间 sleep。
6. 分屏状态测试在 `beforeEach` 清理残留 SecondAbility，避免测试顺序依赖。
7. metadata 只在对应设备上分发套件，不在测试体内静默放行错误断点。

推荐套件：

| 用例 | 套件 | 设备 |
| --- | --- | --- |
| CaseUI | `CommonPassToPassTest` | phone、foldable、tablet |
| CaseUI | `SmPassToPassTest` | phone |
| CaseUI | `MdFailToPassTest` | foldable |
| CaseUI | `LgFailToPassTest` | tablet |
| CaseSplitWindow | `CommonPassToPassTest` | phone、foldable、tablet |
| CaseSplitWindow | `SmPassToPassTest` | phone |
| CaseSplitWindow | `SplitFailToPassTest` | foldable、tablet |

## 10. 实施顺序

1. 从当前原工程复制出一个临时基线。
2. 删除分屏完整链路并收敛单栈、单上下文。
3. 将全部 UI 消费者固定为 SM 表现。
4. 删除断点系统、响应式 Grid、捏合工具和 tablet 首页资源。
5. 验证共同 swe 的手机主流程与构建。
6. 将共同 swe 复制到两个用例目录，并验证字节一致。
7. 从共同 swe 生成 UI answer。
8. 从共同 swe 生成分屏 answer。
9. 分别编写 test patch、metadata、README 和 golden patch。
10. 在 phone、foldable、tablet 上执行对应 pass-to-pass/fail-to-pass。

## 11. 完成标准

| 项目 | 完成条件 |
| --- | --- |
| swe 一致性 | 两份 swe 源码及资源哈希完全一致 |
| UI 隔离 | UI answer 不包含 SecondAbility、分屏按钮或双栈方法 |
| 分屏隔离 | 分屏 answer 不包含全局断点、响应式列数或平板两栏布局 |
| 首页资源 | 两个 swe、两个 answer 均不存在 tablet 首页图片 |
| 首页断点 | UI answer 仅通过同一基础图片的 4:3、2.5:1、5:1 比例体现差异 |
| pass-to-pass | swe 和对应 answer 均通过 |
| fail-to-pass | swe 失败、对应 answer 通过 |
| 构建 | 两个 swe、两个 answer 均可独立编译 |
| 设备 | phone、foldable、tablet 套件按 metadata 正确执行 |

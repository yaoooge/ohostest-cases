# ComprehensiveMallTemplate 断点 UI Test 设计

## 1. 目标

本设计用于补全 `ComprehensiveMallTemplate/CaseUI` 中与 SM、MD、LG 断点直接相关的 UI Test。

测试重点是可通过组件几何信息稳定判断的响应式结果：

- 行列数；
- 上下、左右排列关系；
- 组件是否位于指定容器内；
- 双指缩放前后的商品列数。

本设计暂不扩展 `CommonPassToPassTest`，也不测试以下内容：

- 应用启动、四个主 Tab、通用入口存在性；
- 首页滚动后搜索框的显隐和收起行为；
- 背景色、圆角、阴影、字体、颜色等视觉细节；
- 弹窗、半模态页面和金额明细 Sheet；
- 新增组件宽度、高度、宽高比等尺寸断言；
- 搜索、支付、兑换等业务结果；
- 同一设备运行期间动态切换窗口断点；
- 测试代码对非目标设备的跳过或兼容逻辑。

## 2. 设备和 Suite 分配

设备分发继续完全由 `metadata.json.device_test_suites` 和 case-runner 负责：

| 设备 | 断点 | Suite | 测试文件 |
| --- | --- | --- | --- |
| `phone` | SM | `SmPassToPassTest` | `products/entry/src/ohosTest/ets/test/SmPassToPass.test.ets` |
| `foldable` | MD | `MdFailToPassTest` | `products/entry/src/ohosTest/ets/test/MdFailToPass.test.ets` |
| `tablet` | LG | `LgFailToPassTest` | `products/entry/src/ohosTest/ets/test/LgFailToPass.test.ets` |

各 Suite 保留 `beforeAll` 中的 `assertCurrentBreakpoint`，用于尽早暴露设备配置错误。不在测试代码中增加条件跳过。

测试开发期间以 `answer` 为唯一评审工程：

1. 先将当前 `test_patch.patch` 应用到 `answer`；
2. 后续新增测试和测试所需组件 ID 直接修改 `answer`；
3. 用户在 `answer` 中完成代码评审；
4. 使用 `ohostest:matrix` 直接验证 `answer`，直至三个设备上的全部用例通过；
5. 全部用例符合要求后，再将测试相关修改同步到用于制补丁的 SWE 工作副本；
6. 以干净的 `swe` 为基线重新生成 `test_patch.patch`；
7. 最后使用 `ohostest:case --run swe` 验证新补丁在 SWE 上的 fail/pass 分类。

在评审通过前，不提前修改 `swe`，也不覆盖现有 `test_patch.patch`。

## 3. 设计原则

### 3.1 一个用例验证一个响应式行为

列数和相对排列分别使用独立测试名称。某个页面打不开时允许该页面的多个用例失败，但一个布局断言不应包含其他页面的行为验证。

### 3.2 优先验证实际几何结果

断言优先读取 UITest 组件 bounds，而不是只检查表示断点的语义 ID。例如：

- 5 列商品：统计首行商品数量；
- 左右分栏：验证轮播图在信息卡左侧，并且两者存在足够的垂直重叠；
- 纵向布局：验证前一个区域位于后一个区域上方；
- 首页分类分布：验证分类项保持同一行，并覆盖内容区左右两侧。

### 3.3 只测初始首页布局

首页打开并稳定后立即测量：

- 搜索框相对标题行的位置；
- 横幅宽高比；
- 商品初始列数；
- 分类入口的初始排列。

不滚动首页，不断言搜索框收起、透明度或可见性变化。

### 3.4 几何位置断言保留容差

考虑像素取整和浮点布局误差：

- 边界位置：默认容差 `±12px`；
- 同行判断：组件 `top` 差默认不超过 `3px`；
- 相对位置判断：允许最多 `12px` 的布局误差。

当前 `test_patch.patch` 已存在的横幅宽高比和 LG 搜索框 400vp 用例保持不变；本轮不再新增任何组件宽高尺寸断言。

## 4. SM 测试矩阵

SM 用例属于 `pass_to_pass`：基础工程和应用答案都应通过。

### 4.1 已有用例

| 测试名称 | 断言 |
| --- | --- |
| `should_keep_sm_home_banner_ratio_4_3` | 首页横幅宽高比约为 4:3 |
| `should_keep_sm_product_waterflow_two_columns` | 首页普通商品首行为 2 列 |
| `should_keep_sm_category_grid_two_columns` | 分类页商品首行为 2 列 |

### 4.2 新增用例

| 测试名称 | 页面/操作 | 核心断言 |
| --- | --- | --- |
| `should_keep_search_below_title_on_sm` | 打开首页 | 搜索框位于标题行下方，不在标题行内部 |
| `should_ignore_product_pinch_on_sm` | 首页商品流依次执行双指放大和缩小 | 每次手势后首行仍为 2 列 |
| `should_keep_list_mode_single_column_on_sm` | 打开搜索结果并切换为列表模式 | 列表商品首行为 1 列 |
| `should_keep_horizontal_skeleton_two_columns_on_sm` | 打开横向商品骨架状态 | 首行为 2 个骨架卡片 |
| `should_keep_vertical_skeleton_single_column_on_sm` | 打开纵向商品骨架状态 | 首行为 1 个骨架卡片 |
| `should_show_product_detail_vertically_on_sm` | 打开商品详情 | 轮播图位于信息卡上方，两者不是左右并排 |
| `should_show_three_review_media_columns_on_sm` | 打开包含媒体的商品评价 | 评价媒体首行为 3 列 |
| `should_show_three_review_picker_columns_on_sm` | 打开创建评价页 | 媒体选择器首行为 3 列 |
| `should_keep_cart_single_column_on_sm` | 打开包含至少两件商品的购物车 | 购物车商品首行为 1 列 |
| `should_keep_profile_sections_vertical_on_sm` | 打开个人中心 | 用户信息、签到区、主菜单按从上到下排列 |
| `should_keep_profile_submenu_single_column_on_sm` | 打开个人中心 | 子菜单首行为 1 列 |
| `should_keep_order_list_single_column_on_sm` | 打开订单列表 | 订单卡首行为 1 列 |
| `should_show_two_points_products_on_sm` | 打开积分商城 | 积分商品首行为 2 列 |

SM 共设计 16 个断点用例，其中已有 3 个，新增 13 个。

## 5. MD 测试矩阵

MD 中原布局已经满足的行为属于 `pass_to_pass`，本任务新增或改变的响应式行为属于 `fail_to_pass`。

### 5.1 已有 fail-to-pass 用例

| 测试名称 | 断言 |
| --- | --- |
| `should_use_md_home_banner_ratio_2_5` | 首页横幅宽高比约为 2.5:1 |
| `should_show_three_product_columns_on_md` | 首页普通商品首行为 3 列 |
| `should_show_four_category_columns_on_md` | 分类页商品首行为 4 列 |

### 5.2 新增用例

| 测试名称 | 分类 | 页面/操作 | 核心断言 |
| --- | --- | --- | --- |
| `should_keep_search_below_title_on_md` | pass-to-pass | 打开首页 | 搜索框位于标题行下方，不在标题行内部 |
| `should_change_product_columns_between_two_and_four_on_md` | fail-to-pass | 首页初始 3 列，执行放大、恢复、缩小手势 | 列数依次为 2、3、4 |
| `should_keep_list_mode_single_column_on_md` | pass-to-pass | 搜索结果切换列表模式 | 首行为 1 列 |
| `should_show_three_horizontal_skeleton_columns_on_md` | fail-to-pass | 打开横向商品骨架状态 | 首行为 3 列 |
| `should_keep_vertical_skeleton_single_column_on_md` | pass-to-pass | 打开纵向商品骨架状态 | 首行为 1 列 |
| `should_show_product_detail_vertically_on_md` | pass-to-pass | 打开商品详情 | 轮播位于信息卡上方 |
| `should_reveal_adjacent_product_image_on_md` | fail-to-pass | 打开商品详情 | 当前图片侧边存在相邻图片可见区域 |
| `should_show_five_review_media_columns_on_md` | fail-to-pass | 打开包含媒体的商品评价 | 评价媒体首行为 5 列 |
| `should_show_five_review_picker_columns_on_md` | fail-to-pass | 打开创建评价页 | 媒体选择器首行为 5 列 |
| `should_keep_cart_single_column_on_md` | pass-to-pass | 打开购物车 | 商品首行为 1 列 |
| `should_keep_profile_sections_vertical_on_md` | pass-to-pass | 打开个人中心 | 用户信息、签到区、主菜单按从上到下排列 |
| `should_keep_profile_submenu_single_column_on_md` | pass-to-pass | 打开个人中心 | 子菜单首行为 1 列 |
| `should_keep_order_list_single_column_on_md` | pass-to-pass | 打开订单列表 | 订单卡首行为 1 列 |
| `should_show_three_points_products_on_md` | fail-to-pass | 打开积分商城 | 积分商品首行为 3 列 |

MD 共设计 17 个断点用例，其中已有 3 个，新增 14 个。

## 6. LG 测试矩阵

LG 响应式布局均属于 `fail_to_pass`。

### 6.1 已有用例

| 测试名称 | 断言 |
| --- | --- |
| `should_place_400vp_search_in_home_title_on_lg` | 搜索框位于标题行内，宽度约 400vp |
| `should_use_lg_home_banner_ratio_5` | 首页横幅宽高比约为 5:1 |
| `should_show_five_product_columns_on_lg` | 首页商品首行为 5 列 |
| `should_show_product_detail_as_two_panes_on_lg` | 商品轮播位于左侧，信息和详情位于右侧 |

### 6.2 新增用例

| 测试名称 | 页面/操作 | 核心断言 |
| --- | --- | --- |
| `should_distribute_home_categories_across_available_width_on_lg` | 打开首页 | 第一项接近内容区左侧，最后一项接近右侧，分类项保持同一行 |
| `should_show_four_category_columns_on_lg` | 打开分类页 | 商品首行为 4 列 |
| `should_change_product_columns_between_four_and_six_on_lg` | 首页初始 5 列，执行放大、恢复、缩小手势 | 列数依次为 4、5、6 |
| `should_show_two_list_mode_columns_on_lg` | 搜索结果切换列表模式 | 列表商品首行为 2 列 |
| `should_show_two_collection_columns_on_lg` | 打开收藏 | 商品首行为 2 列 |
| `should_show_two_history_columns_on_lg` | 打开浏览记录 | 商品首行为 2 列 |
| `should_show_two_seckill_columns_on_lg` | 打开秒杀列表 | 秒杀商品首行为 2 列 |
| `should_show_four_horizontal_skeleton_columns_on_lg` | 打开横向商品骨架状态 | 首行为 4 列 |
| `should_show_two_vertical_skeleton_columns_on_lg` | 打开纵向商品骨架状态 | 首行为 2 列 |
| `should_show_five_review_media_columns_on_lg` | 打开包含媒体的商品评价 | 评价媒体首行为 5 列 |
| `should_show_five_review_picker_columns_on_lg` | 打开创建评价页 | 媒体选择器首行为 5 列 |
| `should_show_two_cart_columns_on_lg` | 打开购物车 | 商品首行为 2 列 |
| `should_remove_extra_bottom_gap_from_cart_on_lg` | 打开购物车 | 底部操作区底边接近窗口可用区域底边，不额外预留手机主导航高度 |
| `should_place_profile_sections_side_by_side_on_lg` | 打开个人中心 | 用户信息区在左，签到和主菜单区在右，两区域垂直方向有重叠 |
| `should_show_two_profile_submenu_columns_on_lg` | 打开个人中心 | 子菜单首行为 2 列 |
| `should_show_two_order_columns_on_lg` | 打开订单列表 | 订单卡首行为 2 列 |
| `should_show_four_points_products_on_lg` | 打开积分商城 | 积分商品首行为 4 列 |

LG 共设计 21 个断点用例，其中已有 4 个，新增 17 个。

## 7. TestHelper 设计

### 7.1 页面导航

新增以下 helper，内部优先使用稳定组件 ID；只有没有 ID 时才临时使用文本：

```text
openSearchResults(driver)
switchToListMode(driver)
openCart(driver)
openProfile(driver)
openCollection(driver)
openHistory(driver)
openSeckill(driver)
openOrderList(driver)
openPointsMall(driver)
openReviewCreation(driver)
```

每个导航 helper 应：

1. 从 `prepareHome()` 或已知页面开始；
2. 完成点击或路由进入；
3. 等待目标页面根组件；
4. 等待至少一个待测条目；
5. 不在 helper 中执行布局断言。

### 7.2 几何断言

复用现有：

```text
getAspectRatioById()
getComponentVpWidthById()
countItemsInFirstRow()
isComponentVerticallyInside()
isProductDetailTwoPane()
```

前两个尺寸 helper 仅供当前已有用例使用，本轮新增用例不调用它们。

新增：

```text
isComponentBelow(driver, upperId, lowerId, tolerance)
isComponentLeftOf(driver, leftId, rightId, tolerance)
isComponentBottomAlignedToWindow(driver, id, bundleName, tolerance)
getFirstRowBounds(driver, itemId)
performPinch(driver, componentId, scale)
```

`performPinch` 完成手势后必须等待布局稳定，再统计首行列数。

### 7.3 建议增加的组件 ID

为避免依赖中文文本和绝对坐标，在测试 patch 中为待测组件补充稳定 ID：

```text
mall-home-category-item
mall-horizontal-skeleton-item
mall-vertical-skeleton-item
mall-review-media-item
mall-review-picker-item

mall-cart-list
mall-cart-item
mall-cart-control-panel

mall-profile-user-area
mall-profile-checkin-menu-area
mall-profile-submenu-item

mall-order-item
mall-points-product-item
mall-seckill-item
mall-collection-item
mall-history-item
```

ID 只用于定位真实组件；测试结果仍通过 bounds 和首行数量判断，不通过断点名称 ID 代替布局断言。

## 8. 测试数据要求

以下页面必须有足够数据，才能可靠判断列数：

| 页面 | 最少数据 |
| --- | ---: |
| 首页普通商品 | 6 |
| 分类商品 | 4 |
| 搜索结果 | 4 |
| 收藏 | 2 |
| 浏览记录 | 2 |
| 秒杀列表 | 2 |
| 购物车 | 2 |
| 订单列表 | 2 |
| 积分商城 | 4 |
| 商品评价媒体 | 5 张媒体 |

评价创建页必须能稳定到达并展示媒体选择器。

数据不足时测试应明确失败并记录缺失页面或条目数量，不能把空列表视为布局通过。

骨架状态不能依赖 300ms 网络延迟中的偶然截图时机。测试 patch 应将 MockAdapter 的
`delayResponse` 调整为 1500ms，骨架用例从页面首次打开开始，在响应返回前等待骨架组件；
其他用例继续等待真实列表组件出现后再断言。SWE 和 Answer 都应用同一个测试 patch，因此
这一延迟不会改变 fail-to-pass 判定，只用于提供确定的 UITest 观察窗口。

## 9. metadata.json 更新规则

每个新增测试名称必须且只能出现在以下一个数组中：

- `pass_to_pass`：SWE 和 Answer 都应通过；
- `fail_to_pass`：SWE 应失败，Answer 应通过。

本设计中的分类如下：

### 9.1 新增 pass-to-pass

```text
should_keep_search_below_title_on_sm
should_ignore_product_pinch_on_sm
should_keep_list_mode_single_column_on_sm
should_keep_horizontal_skeleton_two_columns_on_sm
should_keep_vertical_skeleton_single_column_on_sm
should_show_product_detail_vertically_on_sm
should_show_three_review_media_columns_on_sm
should_show_three_review_picker_columns_on_sm
should_keep_cart_single_column_on_sm
should_keep_profile_sections_vertical_on_sm
should_keep_profile_submenu_single_column_on_sm
should_keep_order_list_single_column_on_sm
should_show_two_points_products_on_sm

should_keep_search_below_title_on_md
should_keep_list_mode_single_column_on_md
should_keep_vertical_skeleton_single_column_on_md
should_show_product_detail_vertically_on_md
should_keep_cart_single_column_on_md
should_keep_profile_sections_vertical_on_md
should_keep_profile_submenu_single_column_on_md
should_keep_order_list_single_column_on_md
```

### 9.2 新增 fail-to-pass

```text
should_change_product_columns_between_two_and_four_on_md
should_show_three_horizontal_skeleton_columns_on_md
should_reveal_adjacent_product_image_on_md
should_show_five_review_media_columns_on_md
should_show_five_review_picker_columns_on_md
should_show_three_points_products_on_md

should_distribute_home_categories_across_available_width_on_lg
should_show_four_category_columns_on_lg
should_change_product_columns_between_four_and_six_on_lg
should_show_two_list_mode_columns_on_lg
should_show_two_collection_columns_on_lg
should_show_two_history_columns_on_lg
should_show_two_seckill_columns_on_lg
should_show_four_horizontal_skeleton_columns_on_lg
should_show_two_vertical_skeleton_columns_on_lg
should_show_five_review_media_columns_on_lg
should_show_five_review_picker_columns_on_lg
should_show_two_cart_columns_on_lg
should_remove_extra_bottom_gap_from_cart_on_lg
should_place_profile_sections_side_by_side_on_lg
should_show_two_profile_submenu_columns_on_lg
should_show_two_order_columns_on_lg
should_show_four_points_products_on_lg
```

case-runner 报告中不得出现 `unclassified` 或 `conflict`。

## 10. 验证流程

### 10.1 Answer 开发阶段：ohostest:matrix

新增测试开发期间只验证 `answer` 工程，不通过 case 模式重复合成 Answer。

可以按设备分批验证：

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner \
  run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer \
  --device phone
```

将 `phone` 分别替换为 `foldable` 或 `tablet`，依次验证三个断点。需要只运行当前断点 Suite
时，可以额外传入：

```bash
--test-class SmPassToPassTest
--test-class MdFailToPassTest
--test-class LgFailToPassTest
```

每条 matrix 命令只传入与设备对应的一个 `--test-class`。

完成分批调试后，执行一次完整 Answer 矩阵：

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner \
  run ohostest:matrix -- \
  --project /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI/answer \
  --device phone \
  --device foldable \
  --device tablet
```

Answer 阶段验收条件：

1. matrix 级 `status` 为 `completed`；
2. phone、foldable、tablet 均完成执行；
3. 三个断点 Suite 中的每一条测试均为 `passed`；
4. 没有 suite failure、用例 failure、`none parsed` 或设备 blocked；
5. 构建、安装、启动和测试解析均无诊断错误。

只有满足以上条件，才能开始构建新的 SWE 测试补丁。

### 10.2 补丁构建阶段

Answer 全量 matrix 通过后：

1. 保留一份未包含测试修改的干净 `swe` 基线；
2. 将 `answer` 中的 ohosTest 文件、测试所需组件 ID 和确定性测试支持修改同步到 SWE 工作副本；
3. 对比干净 `swe` 与该工作副本，生成新的 `test_patch.patch`；
4. 检查 patch 中只包含测试及测试可观测性修改，不包含 golden 响应式实现；
5. 使用 `git apply --check` 确认新 patch 能应用到干净 `swe`。

case 目录中最终保留的 `swe` 必须仍是未应用 `test_patch.patch` 的基线，否则 case-runner 会重复应用补丁并失败。

### 10.3 SWE 验证阶段：ohostest:case

新 `test_patch.patch` 和 `metadata.json` 准备完成后，仅执行 SWE：

```bash
npm --prefix /Users/guoyutong/codeRepo/01-mine/harmonyos-ohostest/harmonyos-ohostest-runner \
  run ohostest:case -- \
  --case /Users/guoyutong/codeRepo/01-mine/ohostest-cases/ComprehensiveMallTemplate/CaseUI \
  --run swe
```

需要定位单设备问题时，可以附加一个 `--device phone`、`--device foldable` 或
`--device tablet`；最终验收必须执行不带 `--device` 的完整 SWE 矩阵。

### 10.4 最终验收条件

SWE case 验证必须满足：

1. case 级 `status` 为 `completed`；
2. phone、foldable、tablet 均完成执行；
3. 所有 `pass_to_pass` 在 SWE 中通过；
4. 所有 `fail_to_pass` 在 SWE 中失败；
5. 每台设备的 `Incorrect` 为 0；
6. 报告中没有 `unclassified`、`conflict`、`none parsed`；
7. 构建、安装、启动和测试解析均无诊断错误。

若数据依赖页面因预置数据不足而失败，应先补齐确定性测试数据，再调整布局断言；不得通过放宽为“零条数据也通过”规避失败。

## 11. 实施顺序

建议按以下顺序实现和验证：

1. 首页、分类和普通商品流；
2. 双指缩放与列表模式；
3. 商品详情、轮播和评价；
4. 购物车；
5. 个人中心、订单和积分商城；
6. 收藏、浏览记录、秒杀和骨架状态；
7. 更新 `metadata.json`，运行完整 case-runner 双轮验证。

每完成一组页面，先使用 `ohostest:matrix --device <id>` 验证对应 Answer Suite。所有 Answer
用例通过后，才生成新测试补丁；最终使用 `ohostest:case --run swe` 完成 SWE 分类验证。

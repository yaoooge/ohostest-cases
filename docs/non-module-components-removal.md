# Mall 非 module_ 组件删除清单

## 范围与结论

本次以 `8c02f47` 为改造前基线，核对 `8c02f47..1f029d3` 的提交差异及当前工作树。删除范围是
`CaseComprehensiveMallTemplate/components/` 下全部 10 个名称不以 `module_` 开头的组件目录；同时删除只为会员组件提供页面封装的
`CaseComprehensiveMallTemplate/features/member/`。

删除后，商城首页、分类、商品浏览、收藏、购物车、下单、订单列表/详情、积分兑换和商品评价仍保留。登录、支付和收货地址由现有基础层或
feature 层提供确定性兜底；分享、设置、个人资料编辑、优惠券选择、意见反馈、会员订阅和图片大图预览等次要入口按要求直接移除，不保留兼容壳。

## 删除组件与原功能

| 删除组件 | 原功能 | 原消费位置（改造前） | 最终处理 |
| --- | --- | --- | --- |
| `address_management` | 地址列表与新增、编辑、删除；默认地址查询；地图选址和地址识别 | `features/order/` 的订单提交与订单地址修改；`features/points/` 的兑换提交与兑换地址修改；`products/entry/src/main/ets/utils/ProfileUtil.ets` 的“地址管理”入口；`features/shopping/oh-package.json5` 的本地依赖声明 | 删除组件和所有地址选择/编辑入口；订单与积分兑换改用固定默认地址；订单信息与兑换记录中的修改地址动作、页面和路由删除 |
| `aggregated_login` | 华为账号一键登录及微信、手机号等其他登录方式 | `features/setting/src/main/ets/views/LoginPage.ets`、`features/setting/src/main/ets/viewmodels/LoginVM.ets`；首页、购物车、商品、秒杀和“我的”中的登录守卫通过登录路由间接消费 | 删除登录页、登录 VM、路由和所有登录入口/守卫；应用主入口初始化时设置默认已登录用户 |
| `aggregated_payment` | `CashierPicker` 收银台及支付宝、华为支付、微信支付聚合服务 | `features/order/src/main/ets/utils/OrderUtil.ets`、`features/order/src/main/ets/views/OrderSubmitPage.ets` | 删除收银台、支付类型选择、支付服务调用和回调注册/注销；创建订单或点击立即支付后直接更新为支付成功后的订单状态 |
| `aggregated_share` | 微信、朋友圈、QQ、微博、碰一碰、海报及系统分享 | `products/entry/src/main/ets/entryability/EntryAbility.ets` 的分享服务初始化；`features/product/src/main/ets/viewmodels/ProductInfoVM.ets`、`features/product/src/main/ets/views/ProductSwiperPage.ets` 和已删除的 `features/product/src/main/ets/utils/ShareUtil.ets` | 删除分享服务初始化、分享数据模型、商品详情/推荐商品分享按钮与分享工具；不提供替代入口 |
| `app_setting` | 设置项分组、开关、选择项、页面跳转、字体/深浅色/关于/隐私等应用内设置 UI | 已删除的 `features/setting/src/main/ets/views/SettingPage.ets` 和 `features/setting/src/main/ets/views/SettingPrivacyPage.ets`；“我的”页设置入口 | 删除设置与隐私设置页面、路由及“我的”页入口；保留与该组件无关的协议页面 |
| `collect_personal_info` | 编辑头像、昵称、姓名、性别、手机号、生日和个人简介等资料表单 | 已删除的 `features/setting/src/main/ets/views/EditProfilePage.ets`、`features/setting/src/main/ets/viewmodels/EditProfileVM.ets`；“我的”页用户信息区域点击入口 | 删除个人资料编辑页面、VM、路由和点击入口；用户信息区域保留为只读展示 |
| `coupons` | 优惠券列表、优惠券卡片、可用券计算与下单选券 | `features/order/src/main/ets/views/OrderSubmitPage.ets` 的 `CouponsController`；已删除的 `features/setting/src/main/ets/views/CouponPage.ets`；“我的”页优惠券入口 | 删除优惠券页和选券交互；订单价格明细仍显示后端/模拟数据中的“优惠券”项，但该行只读、不可选择 |
| `feedback` | 提交问题反馈与查看反馈记录 | `products/entry/src/main/ets/utils/ProfileUtil.ets` 的“意见反馈”入口 | 删除“意见反馈”菜单、路由跳转和组件；不提供替代入口 |
| `image_preview` | 图片和动态照片的大图预览、缩放、长图及画中画等能力 | `features/product/src/main/ets/components/ProductReviewCard.ets`、`components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`；`features/order/oh-package.json5` 曾有未直接导入的依赖声明 | 评价图片/动态照片缩略图及动态照片标识继续展示，点击预览、预览状态和模型转换删除 |
| `membership` | 自动续期/非续期会员开通、会员商品与购买状态查询 | 已删除的 `features/member/`；`products/entry/src/main/ets/viewmodels/MainEntryVM.ets`、`products/entry/src/main/ets/tabviews/ProfilePage.ets`、`features/product/src/main/ets/viewmodels/ProductInfoVM.ets`、`features/setting/src/main/ets/viewmodels/LoginVM.ets` | 删除会员中心、会员订阅 feature、商品会员推广入口和购买状态查询；默认用户的 `isMember` 为 `false` |

上述“原消费位置”来自基线提交中的实际 import、路由或本地包依赖，而不是按组件名称推断。

## 消费位置及处理方式

- 订单：`CaseComprehensiveMallTemplate/features/order/` 移除了地址管理、聚合支付、优惠券选择和图片预览依赖。
  `src/main/ets/views/UpdateAddressSheet.ets` 被删除，`OrderActionMap.UPDATE_ADDRESS` 及其详情页/列表页分支被清理；订单提交仍保留地址展示、
  价格明细、创建订单和订单状态流转。
- 积分兑换：`CaseComprehensiveMallTemplate/features/points/` 移除了地址管理依赖，删除
  `src/main/ets/utils/PointsAddressUtil.ets`，并移除兑换提交、兑换详情和兑换列表中的地址编辑动作；兑换下单及地址展示保留。
- 商品：`CaseComprehensiveMallTemplate/features/product/` 删除 `src/main/ets/utils/ShareUtil.ets`，移除商品详情和推荐商品页分享入口；
  商品评价缩略图继续渲染，但不再打开 `image_preview`。
- 商品评价组件：`CaseComprehensiveMallTemplate/components/module_product_review/src/main/ets/views/ProductReviewCreation.ets`
  保留评价星级、文字、图片选择、缩略图和删除图片能力，仅移除预览打开逻辑。
- “我的”页：`CaseComprehensiveMallTemplate/products/entry/src/main/ets/utils/ProfileUtil.ets` 的菜单缩减为收藏、消息、浏览历史和客服；
  `products/entry/src/main/ets/tabviews/ProfilePage.ets` 删除登录、编辑资料和会员中心入口，用户信息改为只读展示。
- 设置 feature：删除 `LoginPage.ets`、`SettingPage.ets`、`SettingPrivacyPage.ets`、`EditProfilePage.ets`、`CouponPage.ets`
  及对应 `LoginVM.ets`、`EditProfileVM.ets`；`AgreementPage.ets`、收藏页和浏览历史页保留。
- 应用入口：`CaseComprehensiveMallTemplate/products/entry/src/main/ets/entryability/EntryAbility.ets` 不再创建或处理分享服务；
  `products/entry/src/main/ets/components/HomePageContent.ets`、`tabviews/CartPage.ets`、
  `features/product/src/main/ets/components/ProductOperationButton.ets` 和
  `features/shopping/src/main/ets/viewmodel/SeckillListVM.ets` 不再跳转登录页。

## 主流程兜底

### 默认登录

- `CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/utils/IData.ets` 新增
  `ensureDefaultUserState()`：强制 `isLogin = true`；当手机号为空时写入昵称“华为用户”、手机号 `12345678900`、
  脱敏手机号 `123****8900`、空头像及 `isMember = false`。
- `CaseComprehensiveMallTemplate/commons/lib_foundation/Index.ets` 导出该函数。
- `CaseComprehensiveMallTemplate/products/entry/src/main/ets/viewmodels/MainEntryVM.ets` 在 `initData()` 开始处调用该函数，
  因此首页、收藏、购物车、下单、订单和积分入口不再被登录页阻断。

### 默认支付成功

- `CaseComprehensiveMallTemplate/features/order/src/main/ets/viewmodels/OrderSubmitVM.ets` 创建订单成功后直接调用
  `OrderUtil.handleImmediatePayment()`。
- `CaseComprehensiveMallTemplate/features/order/src/main/ets/utils/OrderUtil.ets` 不再打开 `CashierPicker`：到店自提订单更新为
  `PENDING_PICKUP`，快递订单更新为 `PENDING_SHIPMENT`；接口成功后提示“订单支付成功！”，随后进入订单详情。
- 支付方式选择、支付宝/华为支付/微信支付拉起逻辑和聚合支付回调生命周期均已删除。

### 默认地址

- `CaseComprehensiveMallTemplate/features/order/src/main/ets/viewmodels/OrderSubmitVM.ets` 默认写入收件人“华为用户”、
  手机号 `12300000000`、地址“广东省深圳市南山区科技园”、城市“深圳市”及坐标
  `22.5405, 113.9345`，快递下单不再依赖地址组件。
- `CaseComprehensiveMallTemplate/features/points/src/main/ets/viewmodels/RedemptionSubmitVM.ets` 使用相同收件人、手机号和地址，
  积分兑换提交不再依赖地址组件。
- 订单提交页与积分兑换提交页保留地址文本展示，但移除了点击选择/修改行为；到店自提仍使用订单接口返回的默认门店信息。

## 配置、路由与依赖清理

- 根模块：`CaseComprehensiveMallTemplate/build-profile.json5` 删除 10 个组件模块注册，并删除只服务会员订阅的
  `features/member` 模块注册。
- 本地包依赖：
  - `products/entry/oh-package.json5` 删除 `feedback`、`aggregated_login`、`address_management`、`aggregated_share`、
    `membership` 和 `member`。
  - `features/setting/oh-package.json5` 删除 `coupons`、`app_setting`、`aggregated_login`、
    `collect_personal_info` 和 `membership`。
  - `features/order/oh-package.json5` 删除 `address_management`、`aggregated_payment`、`coupons` 和 `image_preview`。
  - `features/points/oh-package.json5` 删除 `address_management`。
  - `features/product/oh-package.json5` 删除 `aggregated_share` 和 `image_preview`。
  - `features/shopping/oh-package.json5` 删除 `address_management` 和 `aggregated_share`。
  - `components/module_product_review/oh-package.json5` 删除 `image_preview`。
- 路由常量：`CaseComprehensiveMallTemplate/commons/lib_foundation/src/main/ets/constants/RouterMap.ets` 删除
  `SETTING`、`SETTING_PRIVACY`、`USER_LOGIN`、`USER_OTHER_LOGIN`、`USER_PROFILE_EDIT`、`USER_COUPON_PAGE`、
  `USER_MEMBER_SUBSCRIPTION`、`UPDATE_ADDRESS` 和 `ORDER_UPDATE_ADDRESS`。
- 路由表：
  - `features/setting/src/main/resources/base/profile/route_map.json` 删除设置、登录、隐私设置、编辑资料和优惠券页面项。
  - `features/order/src/main/resources/base/profile/route_map.json` 删除 `UpdateAddressSheet`。
  - `features/points/src/main/resources/base/profile/route_map.json` 删除 `UpdateAddressPage`。
  - `features/member/src/main/resources/base/profile/route_map.json` 随整个会员 feature 删除。
- 元数据：`CaseComprehensiveMallTemplate/AppScope/resources/base/element/string.json` 的 `agcitkid_huawei_comprehensive_mall`
  删除 10 个通用组件标识；`CaseComprehensiveMallTemplate/README.md` 删除对应组件目录与能力说明。

## 明确保留的 module_ 组件

当前 `CaseComprehensiveMallTemplate/components/` 下保留以下 12 个目录，均已通过实际目录扫描确认：

1. `module_advertisement`
2. `module_custom_service_chat`
3. `module_notice_center`
4. `module_privacy_agreement`
5. `module_product_category`
6. `module_product_filter`
7. `module_product_review`
8. `module_product_scan`
9. `module_product_search`
10. `module_shopping_cart`
11. `module_transition`
12. `module_ui_base`

## 验证结果

验证基于当前实现，结果如下：

- `git diff 8c02f47 --name-status -- CaseComprehensiveMallTemplate`：确认 10 个目标组件树均为删除状态，消费、配置和路由文件均在改造差异中。
- 目录完整性：10 个目标路径均不存在；`find CaseComprehensiveMallTemplate/components -mindepth 1 -maxdepth 1 -type d -name 'module_*'`
  统计为 12。
- 静态删除契约：`node --test CaseComprehensiveMallTemplate/tests/non-module-components-removal.test.mjs` 通过，
  共 3 项测试、3 项通过、0 项失败。
- 残留引用扫描：源码和 `oh-package.json5` 中没有指向 10 个删除包的 import 或 `file:` 依赖。
- AGC 元数据扫描：`AppScope/resources/base/element/string.json` 中没有对应
  `agcit_huawei_common_(address_management|login|payment|share|app_setting|collect_personal_info|coupons|feedback|imagepreview|membership)`
  标识。
- 主流程证据扫描：`ensureDefaultUserState`、支付成功提示和 `12300000000` 默认地址手机号分别存在于上述登录、订单和地址兜底文件中。
- 完整工程构建：
  `hvigorw --mode project -p product=default assembleApp --analyze=normal --parallel --incremental --no-daemon`
  退出码为 0，输出 `BUILD SUCCESSFUL`；生成未签名 APP 与 entry HAP。构建仅包含工程既有的未配置签名及依赖混淆提示，无编译错误。

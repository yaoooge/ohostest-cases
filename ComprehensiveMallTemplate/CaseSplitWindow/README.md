# 综合商城分屏购物评测用例

## 用例标识

- **case_id**：`comprehensive-mall-split-shopping`
- **模式**：`derive_base`
- **适配领域**：HarmonyOS 应用内分屏购物

## 用例概述

本用例要求在固定手机布局的综合商城中增加分屏购物能力。用户可从商品详情创建分屏窗口，在两个窗口中独立浏览和购物，并从任一窗口结束分屏。

本用例只评测分屏购物，不包含首页、列表、商品详情等页面的响应式 UI 改造，也不包含平板专用首页图片。

## 工程结构

```text
CaseSplitWindow/
├── PROMPT.md
├── README.md
├── CHANGE_LOG.md
├── metadata.json
├── golden_patch.patch
├── test_patch.patch
├── swe/
└── answer/
```

## 测试分类

`test_patch.patch` 可同时应用于 `swe` 和 `answer`，只为自动化测试补充稳定组件标识和 `ohosTest` 代码，不引入业务能力。

| 套件 | 类型 | 运行设备 | 验证重点 |
|---|---|---|---|
| `CommonPassToPass` | pass-to-pass | 手机、折叠屏、平板 | 应用启动、商品链接直达、购买入口、分屏前单窗口，以及宽屏仍保持固定单列商品详情 |
| `SmPassToPass` | pass-to-pass | 手机 | sm 窗口不展示分屏入口 |
| `SplitFailToPass` | fail-to-pass | 折叠屏、平板 | 分屏入口、PRIMARY/SECONDARY 窗口模式、双窗同商品、双端合并、关闭从窗恢复，以及合并时迁移从窗最新页面 |

测试定位优先使用组件稳定标识；窗口级断言使用应用窗口标题和 `UiWindow.getWindowMode()`，不依赖坐标点击或截图像素。

## 能力隔离

- answer 不得包含通用断点系统、响应式多列、宽屏商品详情分栏或商品流缩放。
- 两个 answer 均不得包含平板专用首页图片。
- `CaseUI/swe` 与 `CaseSplitWindow/swe` 必须完全一致。

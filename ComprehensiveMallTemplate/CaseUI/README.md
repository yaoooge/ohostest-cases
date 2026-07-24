# 综合商城多设备 UI 适配评测用例

## 用例标识

- **case_id**：`comprehensive-mall-responsive-ui`
- **模式**：`derive_base`
- **适配领域**：HarmonyOS 一多响应式 UI

## 用例概述

本用例要求将固定手机布局的综合商城改造为支持手机、折叠屏和平板的响应式商城。适配范围覆盖首页、分类、商品流、商品详情、评价、购物车、个人中心、订单、秒杀、收藏和积分商城。

首页在三个断点下始终使用同一张基础横幅图片，只改变显示比例：

| 断点 | 比例 |
| --- | --- |
| SM | 4:3 |
| MD | 2.5:1 |
| LG | 5:1 |

本用例不包含应用内分屏购物能力，也不包含平板专用首页图片。

## 工程结构

```text
CaseUI/
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

### pass-to-pass

验证应用启动、四个主 Tab、首页基础内容、SM 首页横幅、SM 商品两列、SM 分类两列、SM 商品详情单列以及商品购买入口。

### fail-to-pass

验证 MD 首页 2.5:1 横幅、3 列商品、4 列分类和 5 列评价媒体；验证 LG 首页标题搜索、5:1 横幅、5 列商品、宽屏双列列表、个人中心宽屏布局以及商品详情左右分栏。

## 能力隔离

- answer 不得包含第二购物窗口、分屏/合并入口或双窗口路由。
- 两个 answer 均不得包含平板专用首页图片。
- `CaseUI/swe` 与 `CaseSplitWindow/swe` 必须完全一致。

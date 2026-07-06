# 响应式布局Grid重复布局评测用例

## 用例标识

- **case_id**： `responsive-repeat-grid-layout`
- **模式**： `derive_base` (基于基础工程派生)
- **适配领域**：鸿蒙一多（多设备）响应式布局Grid重复布局

## 用例概述

本用例评测Agent将仅适配手机竖屏的商品分类页改造为支持多设备（手机、折叠屏、平板）响应式重复Grid布局的能力。原始工程工程的商品网格固定为 2 列、8vp 间距、58vp 商品图，未做断点适配；目标工程需引入断点监听体系，并在Grid的列数、间距以及图片尺寸上实现断点驱动的响应式布局。

目录结构：

```
CaseResponsiveRepeatGridLayout/
├── CHANGE_LOG.md          # 版本记录
├── README.md              # 说明文档
├── golden_patch.patch     # 参考实现布丁
├── metadata.json          # 用例元数据（测试定义等）
├── test_patch.patch       # 测试代码补丁
└── task/                  # 任务工程代码（待适配的基础工程）
```

### 提示词

请完成以下内容的一多适配：

1. **引入断点改造体系**：需适配手机、折叠屏、平板。
2. **改造 Grid 列数**：商品分类页中，Grid列数随断点切换（SM=2列，MD=3列，LG=5列）。
3. **调整 Grid 边距**：商品卡片的横向和竖向间距随断点切换（SM=8vp，MD=12vp，LG=16vp）。
4. **调整商品图片尺寸**：商品卡片中的图片尺寸随断点切换（SM=58vp，MD=68vp，LG=76vp）。

## 单元测试用例

### fail_to_pass (修复后应通过)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_show_grid_as_three_columns_on_medium_breakpoint` | md 断点下商品 `Grid` 应展示为 3 列。 |
| `should_use_12vp_grid_gap_on_medium_breakpoint` | md 断点下相邻商品网格项的水平间距应为 12vp。 |
| `should_use_68vp_product_image_on_medium_breakpoint` | md 断点下商品图片宽高应为 68vp。 |
| `should_show_grid_as_five_columns_on_large_breakpoint` | lg 断点下商品 `Grid` 应展示为 5 列。 |
| `should_use_16vp_grid_gap_on_large_breakpoint` | lg 断点下相邻商品网格项的水平间距应为 16vp。 |
| `should_use_76vp_product_image_on_large_breakpoint` | lg 断点下商品图片宽高应为 76vp。 |

### pass_to_pass (原有功能不受影响)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_start_ability_successfully` | 应用 Ability 应能正常启动并展示商品分类页面。 |
| `should_show_grid_page_content` | 页面应展示头部区域和“商品分类”标题。 |
| `should_show_grid_items` | 页面应展示商品网格容器和至少一个商品网格项。 |
| `should_show_product_category_content` | 页面应保留一级分类、二级分类和商品内容展示。 |
| `should_keep_grid_items_without_horizontal_overflow` | 商品网格项不应相对网格容器发生横向溢出。 |
| `should_show_grid_as_two_columns_on_small_breakpoint` | sm 断点下商品 `Grid` 应保持 2 列。 |
| `should_use_58vp_product_image_on_small_breakpoint` | sm 断点下商品图片宽高应保持 58vp。 |

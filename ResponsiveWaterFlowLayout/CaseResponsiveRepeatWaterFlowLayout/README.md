# 响应式布局WaterFlow重复布局评测用例

## 用例标识

- **case_id**： `responsive-repeat-waterflow-layout`
- **模式**： `derive_base` (基于基础工程派生)
- **适配领域**：鸿蒙一多（多设备）响应式布局WaterFlow重复布局

## 用例概述

本用例评测Agent将仅适配手机竖屏的商品瀑布流页改造为支持多设备（手机、折叠屏、平板）响应式重复WaterFlow布局的能力。原始工程的瀑布流固定为 2 列、8vp 间距、16vp 横向边距，未做断点适配；目标工程需引入断点监听体系，并在WaterFlow的列数、行列间距以及横向边距上实现断点驱动的响应式布局。

目录结构：

```
CaseResponsiveRepeatWaterFlowLayout/
├── CHANGE_LOG.md          # 版本记录
├── README.md              # 说明文档
├── golden_patch.patch     # 参考实现补丁
├── metadata.json          # 用例元数据（测试定义等）
├── test_patch.patch       # 测试代码补丁
└── task/                  # 任务工程代码（待适配的基础工程）
```

### 提示词

请完成以下内容的一多适配：

1. **引入断点改造体系**：需适配手机、折叠屏、平板。
2. **改造 WaterFlow 列数**：商品瀑布流页中，WaterFlow列数随断点切换（SM=2列，MD=3列，LG=4列）。
3. **调整 WaterFlow 间距**：商品瀑布流的横向和纵向间距随断点切换（SM=8vp，MD=12vp，LG=12vp）。
4. **调整内容横向边距**：瀑布流内容区横向边距随断点切换（SM=16vp，MD=24vp，LG=32vp）。

## 单元测试用例

### fail_to_pass (修复后应通过)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_show_waterflow_as_three_columns_on_medium_breakpoint` | md 断点下商品 `WaterFlow` 应展示为 3 列。 |
| `should_show_waterflow_as_four_columns_on_large_breakpoint` | lg 断点下商品 `WaterFlow` 应展示为 4 列。 |

### pass_to_pass (原有功能不受影响)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_start_ability_successfully` | 应用 Ability 应能正常启动并展示商品瀑布流页面。 |
| `should_show_waterflow_page_content` | 页面应展示头部区域和商品瀑布流内容。 |
| `should_show_waterflow_items` | 页面应展示商品瀑布流容器和至少一个瀑布流项。 |
| `should_keep_waterflow_items_without_horizontal_overflow` | 商品瀑布流项不应相对瀑布流容器发生横向溢出。 |
| `should_show_waterflow_as_two_columns_on_small_breakpoint` | sm 断点下商品 `WaterFlow` 应保持 2 列。 |

# 响应式布局List重复布局评测用例

## 用例标识

- **case_id**： `responsive-repeat-list-layout`
- **模式**： `derive_base` (基于基础工程派生)
- **适配领域**：鸿蒙一多（多设备）响应式布局List重复布局

## 用例概述

本用例评测Agent将仅适配手机竖屏的订单列表页改造为支持多设备（手机、折叠屏、平板）响应式重复List布局的能力。原始工程的订单列表固定为单列、8vp 行间距，未做断点适配；目标工程需引入断点监听体系，并在List的 lanes、行间距以及列间距上实现断点驱动的响应式布局。

目录结构：

```
CaseResponsiveRepeatListLayout/
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
2. **改造 List lanes**：订单列表页中，List列数随断点切换（SM=1列，MD=1列，LG=2列）。
3. **调整 List 行间距**：订单列表项的纵向间距随断点切换（SM=8vp，MD=12vp，LG=12vp）。
4. **调整 List 列间距**：大屏双列布局下相邻列表项的横向间距应保持 12vp。

## 单元测试用例

### fail_to_pass (修复后应通过)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_keep_order_list_row_space_12_on_medium_breakpoint` | md 断点下订单列表项的纵向间距应为 12vp。 |
| `should_show_list_as_two_lanes_on_large_breakpoint` | lg 断点下订单 `List` 应展示为 2 列。 |
| `should_keep_order_list_column_space_12_on_large_breakpoint` | lg 断点下相邻订单列表项的横向间距应为 12vp。 |
| `should_keep_order_list_row_space_12_on_large_breakpoint` | lg 断点下订单列表项的纵向间距应为 12vp。 |

### pass_to_pass (原有功能不受影响)

| 测试用例名称 | 验证内容 |
| --- | --- |
| `should_start_ability_successfully` | 应用 Ability 应能正常启动并展示订单列表页面。 |
| `should_show_list_page_content` | 页面应展示头部区域和订单列表内容。 |
| `should_show_list_items` | 页面应展示订单列表容器和至少一个订单列表项。 |
| `should_keep_list_items_without_horizontal_overflow` | 订单列表项不应相对列表容器发生横向溢出。 |
| `should_show_list_as_one_lane_on_small_breakpoint` | sm 断点下订单 `List` 应保持 1 列。 |
| `should_keep_order_list_row_space_8_on_small_breakpoint` | sm 断点下订单列表项的纵向间距应保持 8vp。 |
| `should_show_list_as_one_lane_on_medium_breakpoint` | md 断点下订单 `List` 应保持 1 列。 |

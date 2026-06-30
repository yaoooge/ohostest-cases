# ResponsiveListLayout 多设备 UI 测试计划

## 测试矩阵

- passtopass: `SmPassToPass.test.ets`
  - `it('should_show_list_as_one_lane_on_small_breakpoint')`
  - `it('should_keep_order_list_row_space_8_on_small_breakpoint')`
- passtopass: `MdPassToPass.test.ets`
  - `it('should_show_list_as_one_lane_on_medium_breakpoint')`
- failtopass: `MdFailToPass.test.ets`
  - `it('should_keep_order_list_row_space_12_on_medium_breakpoint')`
- failtopass: `LgFailToPass.test.ets`
  - `it('should_show_list_as_two_lanes_on_large_breakpoint')`
  - `it('should_keep_order_list_column_space_12_on_large_breakpoint')`
  - `it('should_keep_order_list_row_space_12_on_large_breakpoint')`

## Checklist

- [x] 计划确认: 根据需求直板机单列行距 8，折叠屏单列行距 12，平板及更大屏双列列距 12 行距 12
- [x] 测试文件编写
- [x] 编译验证
- [x] 直板机验证
- [x] 折叠屏验证
- [x] 平板验证
- [x] 最终全量通过

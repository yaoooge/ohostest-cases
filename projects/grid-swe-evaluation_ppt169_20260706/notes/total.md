# 01_grid_case_overview

这一页的结论是，这个 Grid case 不是一个普通示例工程，而是一道完整的 SWE 评测题。左侧列出了题目的核心资产：task 是基础工程，README 提供给 Agent 的提示词，golden patch 是参考实现，test patch 是评测测试，metadata 则定义 fail to pass 和 pass to pass 的测试分组。右侧是 Agent 必须实现的断点目标：小屏保持两列和原始尺寸，中屏扩展到三列，大屏扩展到五列，并同步调整间距和商品图片尺寸。底部强调测试设计的关键：fail to pass 负责暴露多设备适配缺口，pass to pass 负责保护已有页面行为不被破坏。

# 02_evaluation_loop

这一页的结论是，完整评测闭环同时验证题目可信度和 Agent 产物质量。第一步把 task、golden patch 和 test patch 合在一起跑，确认参考实现可以通过全部测试。第二步只合入 task 和 test patch，确认基线工程确实会暴露 fail to pass，同时 pass to pass 仍然成功。第三步把 task 作为基础工程，把 README 里的提示词交给 Agent 生成 implement patch。第四步把 implement patch 和 test patch 合入 task，使用同一套测试判断 Agent 是否修好。最后一步比较 implement patch 和 golden patch，重点看是否真的引入断点体系、是否用断点驱动 Grid 列数、间距和图片尺寸，以及有没有绕过测试或破坏原功能。

# Grid SWE Evaluation - Design Spec

## I. Project Information

| Item | Value |
| ---- | ----- |
| **Project Name** | Grid SWE Evaluation |
| **Canvas Format** | PPT 16:9 (1280x720) |
| **Page Count** | 2 |
| **Design Style** | General Consulting + Huawei light technical briefing |
| **Target Audience** | 内部研发、评测平台、SWE case 设计评审人员 |
| **Use Case** | 说明 ResponsiveGridLayout/CaseResponsiveRepeatGridLayout 作为完整 SWE 测试题目的构成与执行闭环 |
| **Created Date** | 2026-07-06 |

---

## II. Canvas Specification

| Property | Value |
| -------- | ----- |
| **Format** | PPT 16:9 |
| **Dimensions** | 1280x720 |
| **viewBox** | `0 0 1280 720` |
| **Margins** | left/right 54px, top 42px, bottom 34px |
| **Content Area** | 1172x644 |

---

## III. Visual Theme

### Theme Style

- **Style**: General Consulting + Huawei light technical briefing
- **Theme**: Light theme
- **Tone**: 清晰、研发评审、流程可信、红色品牌强调

### Color Scheme

| Role | HEX | Purpose |
| ---- | --- | ------- |
| **Background** | `#FFFFFF` | 主背景 |
| **Secondary bg** | `#F7F7F7` | 浅色页面底块 |
| **Card bg** | `#FFFFFF` | 内容模块 |
| **Primary** | `#C7000A` | 华为主红、标题强调、关键路径 |
| **Accent** | `#E9002F` | fail_to_pass、差异审查、风险强调 |
| **Secondary accent** | `#F26B43` | 流程节点、提示信息 |
| **Warm accent** | `#FBAE40` | 断点矩阵辅助强调 |
| **Body text** | `#1D1D1A` | 主文本 |
| **Strong text** | `#232323` | 标题与重要标签 |
| **Secondary text** | `#666666` | 注释、说明 |
| **Tertiary text** | `#898989` | 页脚、来源 |
| **Border/divider** | `#B5B5B5` | 分割线 |
| **Subtle border** | `#EBEBEB` | 卡片边界、表格线 |
| **Success** | `#2E7D32` | 通过、验证成功 |
| **Warning** | `#C62828` | 失败、需修复 |

---

## IV. Typography System

### Font Plan

**Typography direction**: CJK-primary technical briefing with code-safe monospace labels.

| Role | Chinese | English | Fallback tail |
| ---- | ------- | ------- | ------------- |
| **Title** | `"Microsoft YaHei", "PingFang SC"` | `Arial` | `sans-serif` |
| **Body** | `"Microsoft YaHei", "PingFang SC"` | `Arial` | `sans-serif` |
| **Emphasis** | `"Microsoft YaHei", "PingFang SC"` | `Arial` | `sans-serif` |
| **Code** | -- | `Consolas, "Courier New"` | `monospace` |

**Per-role font stacks**

- Title: `"Microsoft YaHei", "PingFang SC", Arial, sans-serif`
- Body: `"Microsoft YaHei", "PingFang SC", Arial, sans-serif`
- Emphasis: `"Microsoft YaHei", "PingFang SC", Arial, sans-serif`
- Code: `Consolas, "Courier New", monospace`

### Font Size Hierarchy

**Baseline**: Body font size = 20px.

| Purpose | Ratio to body | Current Project | Weight |
| ------- | ------------- | --------------- | ------ |
| Cover title / page headline | 2.0-2.4x | 40-48px | Heavy |
| Page title | 1.7-2.0x | 34-40px | Bold |
| Subtitle / takeaway | 1.1-1.3x | 22-26px | Semibold |
| Body content | 1x | 20px | Regular |
| Annotation / caption | 0.65-0.8x | 13-16px | Regular |
| Code label | 0.65-0.85x | 13-17px | Medium |

---

## V. Layout Principles

### Page Structure

- **Header area**: 40-112px, assertion title + compact source/context tag.
- **Content area**: 120-650px, structured matrix or pipeline.
- **Footer area**: 676-700px, case path and source note.

### Spacing Specification

| Element | Current Project |
| ------- | --------------- |
| Safe margin from canvas edge | 54px |
| Content block gap | 22-32px |
| Icon-text gap | 8-12px |
| Card gap | 18-24px |
| Card padding | 18-24px |
| Card border radius | 8px |

---

## VI. Icon Usage Specification

### Source

- **Built-in icon library**: `tabler-outline`
- **Stroke width**: 2
- **Usage method**: SVG placeholder `<use data-icon="tabler-outline/name" .../>`

### Recommended Icon List

| Purpose | Icon Path | Page |
| ------- | --------- | ---- |
| Grid/layout | `tabler-outline/layout-grid` | P01 |
| File/artifact | `tabler-outline/file-code` | P01 |
| Test/check | `tabler-outline/check` | P01-P02 |
| Warning/fail | `tabler-outline/alert-triangle` | P01-P02 |
| Pipeline direction | `tabler-outline/arrow-right` | P02 |
| Code comparison | `tabler-outline/git-compare` | P02 |

---

## VII. Visualization Reference List

Catalog read: 71 templates

| Page | Template | Path | Summary-quote (verbatim from `charts_index.json`) | Usage |
| ---- | -------- | ---- | ------------------------------------------------- | ----- |
| P01 | basic_table | `templates/charts/basic_table.svg` | "Pick for plain tabular text/number grid, 3-8 columns. Skip if cells need visual bars (use consulting_table) or qualitative scores (use harvey_balls_table)." | 断点目标矩阵与 case 资产清单的表格式组织参考 |
| P02 | pipeline_with_stages | `templates/charts/pipeline_with_stages.svg` | "Pick for 3-5 horizontal pipeline stages, each = title + 1-line description + output artifact, connected by arrows (data pipelines, ETL, build pipelines)." | 五阶段 SWE 评测闭环：验证 Golden、验证 Baseline、Agent 生成、测试判定、Patch 审查 |

**Runners-up considered**

- `process_flow` | rejected for P02: it fits general workflow, but this page has named output artifacts at every stage, so `pipeline_with_stages` is more specific.
- `comparison_table` | rejected for P01: the page compares SM/MD/LG breakpoints, but rows are simple target values rather than many feature rows across plans.
- `numbered_steps` | rejected for P02: the sequence is artifact-driven and benefits from explicit stage outputs, not only numbered step cards.

---

## VIII. Image Resource List

No external images, AI images, web images, or formula PNG assets are used. The deck relies on native SVG shapes, editable text, and icon placeholders only.

---

## IX. Content Outline

### Part 1: Case Overview

#### Slide 01 - Grid case 把多设备适配压缩成一道可验证 SWE 题

- **Layout**: Header + left case asset stack + right breakpoint target matrix + bottom test coverage strip.
- **Title**: Grid case 把多设备适配压缩成一道可验证 SWE 题
- **Core message**: 这个目录不是普通 demo，而是由基础工程、题目 prompt、参考实现和测试补丁组成的一道完整评测题。
- **Visualization**: `basic_table`
- **Content**:
  - Case: `ResponsiveGridLayout/CaseResponsiveRepeatGridLayout`
  - 输入资产：`task/` 基础工程、`README.md` 题目提示词、`golden_patch.patch` 参考答案、`test_patch.patch` 测试补丁、`metadata.json` 测试定义。
  - 适配目标：SM 保持手机体验；MD/LG 引入断点驱动的 Grid 列数、间距和图片尺寸。
  - 断点矩阵：SM = 2 列 / 8vp / 58vp；MD = 3 列 / 12vp / 68vp；LG = 5 列 / 16vp / 76vp。
  - 测试覆盖：`fail_to_pass` 验证 MD/LG 修复点；`pass_to_pass` 验证页面启动、内容展示、SM 行为和无横向溢出。

### Part 2: Evaluation Loop

#### Slide 02 - 评测闭环同时回答“题是否可信”和“Agent 是否真修好”

- **Layout**: Five-stage horizontal pipeline with a side takeaway panel.
- **Title**: 评测闭环同时回答“题是否可信”和“Agent 是否真修好”
- **Core message**: 完整执行链路先证明题目与测试自身可靠，再用同一测试集验证 Agent 产物，最后通过 patch 对比审查实现方式。
- **Visualization**: `pipeline_with_stages`
- **Content**:
  - Stage 1: `task + golden_patch + test_patch`，全部单测通过，证明参考实现与测试集匹配。
  - Stage 2: `task + test_patch`，`fail_to_pass` 暴露问题，`pass_to_pass` 保持成功，证明题目不是空修复。
  - Stage 3: 以 `task/` 为基础工程，把 README 提示词交给 Agent，产出 `implement_patch`。
  - Stage 4: `task + implement_patch + test_patch`，执行同一套测试，判断是否全部通过。
  - Stage 5: 对比 `implement_patch` 与 `golden_patch`，审查断点体系、Grid 属性驱动方式、原功能保持和是否绕过测试。

---

## X. Speaker Notes Requirements

- **Total duration**: 2-3 minutes.
- **Notes style**: conclusion-first, concise technical briefing.
- **Purpose**: explain the case structure and the evaluation method so reviewers can quickly understand how this SWE test is judged.
- **Files**: notes generated from `notes/total.md`, one section per slide.

---

## XI. Technical Constraints Reminder

1. viewBox: `0 0 1280 720`
2. Background uses `<rect>` elements.
3. Text wrapping uses `<tspan>`; `<foreignObject>` is forbidden.
4. Transparency uses `fill-opacity` / `stroke-opacity`; `rgba()` is forbidden.
5. Forbidden: `mask`, `<style>`, `class`, `textPath`, `animate*`, `script`, `iframe`, `foreignObject`.
6. Top-level content must be grouped with semantic `<g id="...">` groups.
7. Colors, fonts, icons, page rhythm, and chart references must follow `spec_lock.md`.

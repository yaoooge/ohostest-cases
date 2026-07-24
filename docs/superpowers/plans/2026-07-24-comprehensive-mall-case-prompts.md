# Comprehensive Mall Case Prompts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为综合商城 UI 一多适配和分屏购物两个用例分别提供一份面向产品结果的 Agent 任务提示词。

**Architecture:** 两份提示词分别放在对应用例根目录，与 swe/answer 同级。提示词只说明用户场景、不同设备下的产品体验、能力边界和验收结果，不暴露参考答案的代码组织、文件位置或具体实现步骤。

**Tech Stack:** Markdown、HarmonyOS 商城产品需求、phone/foldable/tablet 多设备验收。

---

### Task 1: 编写 UI 一多适配提示词

**Files:**
- Create: `ComprehensiveMallTemplate/CaseUI/PROMPT.md`
- Reference: `docs/superpowers/specs/2026-07-24-comprehensive-mall-multi-device-cases-design.md`

- [ ] **Step 1: 写入产品背景和任务目标**

说明商城当前只具有固定手机布局，目标是在不破坏购物主流程的前提下，让首页、商品列表、分类、购物车、个人中心、订单、积分商城和商品详情适配 phone、foldable、tablet。

- [ ] **Step 2: 写入逐断点产品表现**

以 SM、MD、LG 三档描述用户实际看到的列数、排列方式、横幅比例、搜索框位置、弹层形态和商品详情结构。明确首页始终使用同一基础图片，仅改变显示比例。

- [ ] **Step 3: 写入能力边界**

明确不得增加应用内分屏购物能力，不要求恢复专用 tablet 首页图片，不改变现有业务、数据、路由和交互语义。

- [ ] **Step 4: 写入验收标准**

覆盖启动、核心购物流程、三个断点的页面表现、无横向溢出、窗口变化后重新布局以及分屏入口不存在。

### Task 2: 编写分屏购物提示词

**Files:**
- Create: `ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md`
- Reference: `docs/superpowers/specs/2026-07-24-comprehensive-mall-multi-device-cases-design.md`

- [ ] **Step 1: 写入产品背景和任务目标**

说明用户希望在支持分屏的折叠屏和平板上，从商品详情创建第二个购物窗口，并在两个窗口中连续浏览和购物。

- [ ] **Step 2: 写入完整用户旅程**

描述入口展示、启动分屏、两窗口显示相同商品、从窗独立导航、主窗/从窗合并、系统关闭从窗和主窗恢复等用户可观察行为。

- [ ] **Step 3: 写入能力边界**

明确不得引入首页、列表、商品详情等响应式 UI 改造；宽窗口仍使用基础工程的固定单列布局；不恢复专用 tablet 首页图片。

- [ ] **Step 4: 写入验收标准**

覆盖分屏前单窗口、分屏后的主从窗口模式、商品一致性、当前窗口路由、合并后的页面接管和异常关闭恢复。

### Task 3: 验证提示词视角和隔离性

**Files:**
- Verify: `ComprehensiveMallTemplate/CaseUI/PROMPT.md`
- Verify: `ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md`

- [ ] **Step 1: 检查文件存在且非空**

Run:

```bash
test -s ComprehensiveMallTemplate/CaseUI/PROMPT.md
test -s ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md
```

Expected: 两条命令退出码均为 0。

- [ ] **Step 2: 检查没有代码级定位**

Run:

```bash
rg -n '\.(ets|ts|json5)|src/|module\.json5|BreakpointSystem|SecondAbility|NavPathStack|WindowUtil|修改.*文件|在.*代码' \
  ComprehensiveMallTemplate/CaseUI/PROMPT.md \
  ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md
```

Expected: 无输出。产品名词使用“主窗口”“分屏窗口”，不使用实现类或代码符号。

- [ ] **Step 3: 检查关键边界**

Run:

```bash
rg -n '同一.*图片|4:3|2.5:1|5:1|不包含.*分屏' ComprehensiveMallTemplate/CaseUI/PROMPT.md
rg -n '主窗口|分屏窗口|合并|固定单列|不.*响应式' ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md
```

Expected: 两份提示词分别完整覆盖 UI 图片比例和分屏能力隔离。

- [ ] **Step 4: 检查 Markdown 和提交**

Run:

```bash
git diff --check
git status --short
```

Expected: 无空白错误，仅出现计划和两份 PROMPT.md 的预期变更。

Commit:

```bash
git add \
  docs/superpowers/plans/2026-07-24-comprehensive-mall-case-prompts.md \
  ComprehensiveMallTemplate/CaseUI/PROMPT.md \
  ComprehensiveMallTemplate/CaseSplitWindow/PROMPT.md
git commit -m "docs: add mall adaptation case prompts"
```

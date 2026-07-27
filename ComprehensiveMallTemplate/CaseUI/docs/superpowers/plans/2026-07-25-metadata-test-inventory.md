# Metadata Test Inventory Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `metadata.json` exactly enumerate all 59 tests in the latest Common, SM, MD, and LG suites.

**Architecture:** Test names are sourced directly from ordered `it(...)` declarations. Common and SM form `pass_to_pass`; MD and LG form `fail_to_pass`; device suite mappings remain unchanged.

**Tech Stack:** JSON, ArkTS test sources, Node.js validation

---

### Task 1: Establish the Mismatch

**Files:**

- Test: `ComprehensiveMallTemplate/CaseUI/metadata.json`
- Source: `ComprehensiveMallTemplate/CaseUI/answer/products/entry/src/ohosTest/ets/test/*.test.ets`

- [ ] Extract the four ordered suite inventories and compare them to metadata.
- [ ] Verify the current metadata fails with 8 pass-to-pass and 7 fail-to-pass entries instead of 21 and 38.

### Task 2: Update the Inventories

**Files:**

- Modify: `ComprehensiveMallTemplate/CaseUI/metadata.json`

- [ ] Replace `fail_to_pass` with all 17 MD names followed by all 21 LG names.
- [ ] Replace `pass_to_pass` with all 5 Common names followed by all 16 SM names.
- [ ] Preserve `case_id`, patch names, base project, and `device_test_suites`.

### Task 3: Verify Exact Coverage

- [ ] Parse `metadata.json` as JSON.
- [ ] Assert ordered equality between metadata arrays and their source suite inventories.
- [ ] Assert 59 total names, 59 unique names, and no overlap.
- [ ] Assert every `device_test_suites` file exists.
- [ ] Run `git diff --check -- ComprehensiveMallTemplate/CaseUI/metadata.json`.

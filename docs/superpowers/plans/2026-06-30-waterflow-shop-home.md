# Waterflow Shop Home Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rework `ResponsiveWaterFlowLayout/answer` into a shop-style home waterflow that matches the provided reference image and reuses list product information and images.

**Architecture:** Keep the existing responsive WaterFlow and breakpoint utilities. Move product image/title/price data into the waterflow demo model, then render each product as a white rounded merchandise card with a real image, selling point, price, and optional original price.

**Tech Stack:** HarmonyOS ArkTS, ArkUI `WaterFlow`, local media resources.

---

### Task 1: Extend Product Data

**Files:**
- Modify: `ResponsiveWaterFlowLayout/answer/products/entry/src/main/ets/model/Types.ets`
- Modify: `ResponsiveWaterFlowLayout/answer/products/entry/src/main/ets/model/DemoData.ets`

- [ ] **Step 1: Add fields to `ProductCard`**

```ts
export interface ProductCard {
  title: string;
  description: string;
  price: string;
  originalPrice: string;
  tag: string;
  image: ResourceStr;
  ratio: number;
}
```

- [ ] **Step 2: Replace placeholder color data with reusable shop product data**

Use image resources already present in `ResponsiveWaterFlowLayout/answer/products/entry/src/main/resources/base/media`, including repeated use of banner resources where needed to fill a long page.

### Task 2: Redesign Product Card UI

**Files:**
- Modify: `ResponsiveWaterFlowLayout/answer/products/entry/src/main/ets/components/ProductWaterFlow.ets`

- [ ] **Step 1: Replace the color placeholder with `Image(item.image)`**
- [ ] **Step 2: Style cards as reference-like white rounded merchandise cards**
- [ ] **Step 3: Preserve responsive columns with `BreakpointModel<number>(2, 3, 4)`**

### Task 3: Redesign Header Copy

**Files:**
- Modify: `ResponsiveWaterFlowLayout/answer/products/entry/src/main/ets/components/PageHeader.ets`
- Modify: `ResponsiveWaterFlowLayout/answer/products/entry/src/main/ets/views/Index.ets`

- [ ] **Step 1: Make the header read `首页` and `精选好物`**
- [ ] **Step 2: Add a circular search icon button on the right**
- [ ] **Step 3: Keep the page background and waterflow spacing close to the reference**

### Task 4: Verify

**Files:**
- Check: `ResponsiveWaterFlowLayout/answer`

- [ ] **Step 1: Run a local build check**

```bash
cd ResponsiveWaterFlowLayout/answer
hvigorw --mode project -p product=default assembleHap
```

- [ ] **Step 2: Confirm no TypeScript/ArkTS compile errors**

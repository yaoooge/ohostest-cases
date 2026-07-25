import { Want } from '@kit.AbilityKit';
import { abilityDelegatorRegistry, Driver, ON, PointerMatrix, Rect, UiWindow } from '@kit.TestKit';
import { expect } from '@ohos/hypium';
import { ProductSearchResultsPageParam, RouterMap, routerStack } from 'lib_foundation';

export const delegator: abilityDelegatorRegistry.AbilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

const BREAKPOINT_SM_MAX = 600;
const BREAKPOINT_MD_MAX = 840;
const HOME_ID = 'mall-home-page';
const PRODUCT_DETAIL_URI =
  'https://linking.xiaobingtang.cn/comprehensive-mall?productId=product_10001';

export type TestBreakpoint = 'sm' | 'md' | 'lg';

let sharedDriver: Driver | undefined = undefined;
let sharedBundleName: string = '';
let hasStartedEntryAbility: boolean = false;

export function getDriver(): Driver {
  if (sharedDriver === undefined) {
    sharedDriver = Driver.create();
  }
  return sharedDriver;
}

export async function prepareHome(): Promise<string> {
  const driver = getDriver();
  if (!hasStartedEntryAbility) {
    sharedBundleName = abilityDelegatorRegistry.getArguments().bundleName;
    const want: Want = {
      bundleName: sharedBundleName,
      abilityName: 'EntryAbility',
    };
    await delegator.startAbility(want);
    hasStartedEntryAbility = true;
  }
  await returnToHome(driver);
  return sharedBundleName;
}

export async function returnToHome(driver: Driver): Promise<void> {
  for (let index = 0; index < 8; index++) {
    const isSearchPage = await componentExistsById(driver, 'search_bar');
    const isSearchResults = await componentExistsById(driver, 'mall-display-mode-toggle');
    const isProductDetail = await componentExistsById(driver, 'mall-product-info-page');
    if (!isSearchPage && !isSearchResults && !isProductDetail &&
      await componentExistsById(driver, HOME_ID)) {
      break;
    }
    try {
      if (!isSearchPage && !isSearchResults && !isProductDetail &&
        await componentExistsById(driver, 'mall-tab-0')) {
        const homeTab = await driver.findComponent(ON.id('mall-tab-0'));
        await homeTab.click();
      } else if ((isSearchPage || isSearchResults) &&
        await componentExistsById(driver, 'mall-search-back')) {
        const searchBack = await driver.findComponent(ON.id('mall-search-back'));
        await searchBack.click();
      } else {
        await driver.pressBack();
      }
      await driver.waitForIdle(300, 1000);
    } catch (e) {
      console.error('returnToHome pressBack failed: ' + JSON.stringify(e));
    }
  }
  await waitForComponentById(driver, HOME_ID, 12);
  if (await componentExistsById(driver, 'mall-tab-0')) {
    const homeTab = await driver.findComponent(ON.id('mall-tab-0'));
    await homeTab.click();
    await driver.waitForIdle(300, 1000);
  }
  await waitForComponentById(driver, 'mall-home-content', 12);
  await waitForComponentById(driver, 'mall-product-item', 20);
  await driver.delayMs(500);
}

export async function openCategory(driver: Driver): Promise<void> {
  await prepareHome();
  const categoryTab = await driver.findComponent(ON.id('mall-tab-1'));
  await categoryTab.click();
  await waitForComponentById(driver, 'mall-category-products', 20);
  await waitForComponentById(driver, 'mall-category-item', 20);
}

export async function submitProductSearch(driver: Driver): Promise<void> {
  await prepareHome();
  routerStack.pushPath({
    name: RouterMap.PRODUCT_SEARCH_RESULTS,
    param: {
      keywords: '针织',
    } as ProductSearchResultsPageParam,
  }, false);
  await waitForComponentById(driver, 'mall-display-mode-toggle', 12);
}

export async function openSearchResults(driver: Driver): Promise<void> {
  await submitProductSearch(driver);
  await waitForComponentById(driver, 'mall-display-mode-toggle', 12);
  await waitForComponentById(driver, 'mall-product-waterflow', 20);
  await waitForComponentById(driver, 'mall-product-item', 20);
}

export async function switchToListMode(driver: Driver): Promise<void> {
  const toggle = await driver.findComponent(ON.id('mall-display-mode-toggle'));
  await toggle.click();
  const salesSort = await driver.findComponent(ON.id('mall-sort-sales'));
  await salesSort.click();
  await waitForComponentById(driver, 'mall-vertical-skeleton-item', 12);
  await waitForComponentById(driver, 'mall-list-product-item', 20);
}

export async function openSearchSkeleton(driver: Driver, listMode: boolean): Promise<void> {
  await submitProductSearch(driver);
  if (listMode) {
    await waitForComponentById(driver, 'mall-display-mode-toggle', 8);
    const toggle = await driver.findComponent(ON.id('mall-display-mode-toggle'));
    await toggle.click();
    await waitForComponentById(driver, 'mall-vertical-skeleton-item', 12);
    return;
  }
  await waitForComponentById(driver, 'mall-horizontal-skeleton-item', 12);
}

export async function openProductDetail(driver: Driver): Promise<void> {
  await prepareHome();
  const want: Want = {
    bundleName: sharedBundleName,
    abilityName: 'EntryAbility',
    uri: PRODUCT_DETAIL_URI,
  };
  await delegator.startAbility(want);
  await waitForComponentById(driver, 'mall-product-info-page', 12);
  await waitForComponentById(driver, 'mall-product-info-card', 20);
}

export async function getWindowVpWidth(driver: Driver, bundleName: string): Promise<number> {
  const uiWindow: UiWindow = await driver.findWindow({ bundleName: bundleName, active: true });
  const bounds = await uiWindow.getBounds();
  return px2vp(bounds.right - bounds.left);
}

export function getBreakpointName(vpWidth: number): TestBreakpoint {
  if (vpWidth < BREAKPOINT_SM_MAX) {
    return 'sm';
  }
  if (vpWidth < BREAKPOINT_MD_MAX) {
    return 'md';
  }
  return 'lg';
}

export async function assertCurrentBreakpoint(
  driver: Driver,
  bundleName: string,
  expected: TestBreakpoint,
): Promise<void> {
  const actual = getBreakpointName(await getWindowVpWidth(driver, bundleName));
  expect(actual).assertEqual(expected);
}

export async function componentExistsById(driver: Driver, id: string): Promise<boolean> {
  try {
    const component = await driver.findComponent(ON.id(id));
    return component !== null && component !== undefined;
  } catch (e) {
    return false;
  }
}

export async function waitForComponentById(driver: Driver, id: string, retries: number = 8): Promise<void> {
  for (let index = 0; index < retries; index++) {
    if (await componentExistsById(driver, id)) {
      expect(true).assertTrue();
      return;
    }
    await driver.delayMs(300);
  }
  console.error('component not found: ' + id);
  expect('component found: ' + id).assertEqual('component not found: ' + id);
}

export async function waitForComponentByText(driver: Driver, text: string, retries: number = 8): Promise<void> {
  for (let index = 0; index < retries; index++) {
    try {
      const component = await driver.findComponent(ON.text(text));
      if (component !== null && component !== undefined) {
        expect(true).assertTrue();
        return;
      }
    } catch (e) {
    }
    await driver.delayMs(300);
  }
  console.error('component text not found: ' + text);
  expect('component text found: ' + text).assertEqual('component text not found: ' + text);
}

export async function getAspectRatioById(driver: Driver, id: string): Promise<number> {
  const component = await driver.findComponent(ON.id(id));
  const bounds = await component.getBounds();
  const width = bounds.right - bounds.left;
  const height = bounds.bottom - bounds.top;
  if (height <= 0) {
    return -1;
  }
  return width / height;
}

export async function getComponentVpWidthById(driver: Driver, id: string): Promise<number> {
  const component = await driver.findComponent(ON.id(id));
  const bounds = await component.getBounds();
  return px2vp(bounds.right - bounds.left);
}

export async function countItemsInFirstRow(driver: Driver, itemId: string): Promise<number> {
  for (let attempt = 0; attempt < 12; attempt++) {
    try {
      const items = await driver.findComponents(ON.id(itemId));
      if (items !== null && items !== undefined && items.length > 0) {
        const boundsList: Rect[] = [];
        let firstTop = Number.MAX_VALUE;
        for (let index = 0; index < items.length; index++) {
          const bounds = await items[index].getBounds();
          boundsList.push(bounds);
          firstTop = Math.min(firstTop, bounds.top);
        }
        let count = 0;
        for (let index = 0; index < boundsList.length; index++) {
          if (Math.abs(boundsList[index].top - firstTop) <= 3) {
            count++;
          }
        }
        return count;
      }
    } catch (e) {
    }
    await driver.delayMs(300);
  }
  return 0;
}

export async function isComponentBelow(
  driver: Driver,
  upperId: string,
  lowerId: string,
  tolerance: number = 12,
): Promise<boolean> {
  const upper = await driver.findComponent(ON.id(upperId));
  const lower = await driver.findComponent(ON.id(lowerId));
  const upperBounds = await upper.getBounds();
  const lowerBounds = await lower.getBounds();
  return lowerBounds.top >= upperBounds.bottom - tolerance;
}

export async function isComponentLeftOf(
  driver: Driver,
  leftId: string,
  rightId: string,
  tolerance: number = 12,
): Promise<boolean> {
  const left = await driver.findComponent(ON.id(leftId));
  const right = await driver.findComponent(ON.id(rightId));
  const leftBounds = await left.getBounds();
  const rightBounds = await right.getBounds();
  return leftBounds.right <= rightBounds.left + tolerance;
}

export async function areComponentsOnSameRow(
  driver: Driver,
  firstId: string,
  secondId: string,
  tolerance: number = 3,
): Promise<boolean> {
  const first = await driver.findComponent(ON.id(firstId));
  const second = await driver.findComponent(ON.id(secondId));
  const firstBounds = await first.getBounds();
  const secondBounds = await second.getBounds();
  return Math.abs(firstBounds.top - secondBounds.top) <= tolerance;
}

export async function areItemsSpreadAcrossContainer(
  driver: Driver,
  itemId: string,
  containerId: string,
): Promise<boolean> {
  const items = await driver.findComponents(ON.id(itemId));
  if (items === null || items === undefined || items.length < 2) {
    return false;
  }
  const container = await driver.findComponent(ON.id(containerId));
  const containerBounds = await container.getBounds();
  let firstTop = Number.MAX_VALUE;
  for (let index = 0; index < items.length; index++) {
    const bounds = await items[index].getBounds();
    firstTop = Math.min(firstTop, bounds.top);
  }
  const firstRowBounds: Rect[] = [];
  for (let index = 0; index < items.length; index++) {
    const bounds = await items[index].getBounds();
    if (Math.abs(bounds.top - firstTop) <= 3) {
      firstRowBounds.push(bounds);
    }
  }
  if (firstRowBounds.length < 2) {
    return false;
  }
  const first = firstRowBounds[0];
  const last = firstRowBounds[firstRowBounds.length - 1];
  const containerWidth = containerBounds.right - containerBounds.left;
  const firstCenter = (first.left + first.right) / 2;
  const lastCenter = (last.left + last.right) / 2;
  return firstCenter <= containerBounds.left + containerWidth * 0.25 &&
    lastCenter >= containerBounds.left + containerWidth * 0.75;
}

export async function pinchOutById(driver: Driver, id: string, scale: number = 2): Promise<void> {
  const uiWindow = await driver.findWindow({ bundleName: sharedBundleName, active: true });
  const windowBounds = await uiWindow.getBounds();
  if (await componentExistsById(driver, 'mall-home-scroll')) {
    const windowCenterX = Math.round((windowBounds.left + windowBounds.right) / 2);
    const windowHeight = windowBounds.bottom - windowBounds.top;
    await driver.swipe(
      windowCenterX,
      Math.round(windowBounds.top + windowHeight * 0.75),
      windowCenterX,
      Math.round(windowBounds.top + windowHeight * 0.3),
      600,
    );
    await driver.waitForIdle(300, 1500);
  }
  const component = await driver.findComponent(ON.id(id));
  const bounds = await component.getBounds();
  const items = await driver.findComponents(ON.id('mall-product-item'));
  const firstItemBounds = await items[0].getBounds();
  const secondItemBounds = await items[1].getBounds();
  const centerX = Math.round((firstItemBounds.right + secondItemBounds.left) / 2);
  const visibleTop = Math.max(bounds.top, windowBounds.top);
  const visibleBottom = Math.min(bounds.bottom, windowBounds.bottom);
  const centerY = Math.round((visibleTop + visibleBottom) / 2);
  const endRadius = Math.round(Math.min((visibleBottom - visibleTop) / 4, 180));
  const startRadius = Math.max(12, Math.round(endRadius / scale));
  const steps = 8;
  const pointers = PointerMatrix.create(2, steps);
  for (let step = 0; step < steps; step++) {
    const progress = step / (steps - 1);
    const radius = Math.round(startRadius + (endRadius - startRadius) * progress);
    pointers.setPoint(0, step, { x: centerX, y: centerY - radius });
    pointers.setPoint(1, step, { x: centerX, y: centerY + radius });
  }
  await driver.injectMultiPointerAction(pointers, 600);
  await driver.waitForIdle(300, 1500);
}

export async function pinchInById(driver: Driver, id: string, scale: number = 0.5): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchIn(scale);
  await driver.waitForIdle(300, 1500);
}

export async function resetPinchById(driver: Driver, id: string): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchOut(1.01);
  await driver.waitForIdle(300, 1500);
}

export async function isComponentVerticallyInside(
  driver: Driver,
  childId: string,
  containerId: string,
): Promise<boolean> {
  const child = await driver.findComponent(ON.id(childId));
  const container = await driver.findComponent(ON.id(containerId));
  const childBounds = await child.getBounds();
  const containerBounds = await container.getBounds();
  const childCenterY = (childBounds.top + childBounds.bottom) / 2;
  return childCenterY >= containerBounds.top - 3 && childCenterY <= containerBounds.bottom + 3;
}

export async function isProductDetailTwoPane(driver: Driver): Promise<boolean> {
  const swiper = await driver.findComponent(ON.id('mall-product-swiper'));
  const info = await driver.findComponent(ON.id('mall-product-info-card'));
  const swiperBounds = await swiper.getBounds();
  const infoBounds = await info.getBounds();
  const verticalOverlap =
    Math.min(swiperBounds.bottom, infoBounds.bottom) - Math.max(swiperBounds.top, infoBounds.top);
  return swiperBounds.right <= infoBounds.left + 12 && verticalOverlap > 20;
}

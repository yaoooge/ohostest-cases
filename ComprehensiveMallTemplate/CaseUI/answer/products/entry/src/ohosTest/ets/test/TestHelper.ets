import { Want } from '@kit.AbilityKit';
import { abilityDelegatorRegistry, Driver, ON, UiWindow } from '@kit.TestKit';
import { expect } from '@ohos/hypium';

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
  for (let index = 0; index < 4; index++) {
    if (await componentExistsById(driver, HOME_ID)) {
      break;
    }
    try {
      await driver.pressBack();
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
}

export async function openCategory(driver: Driver): Promise<void> {
  await prepareHome();
  const categoryTab = await driver.findComponent(ON.id('mall-tab-1'));
  await categoryTab.click();
  await waitForComponentById(driver, 'mall-category-products', 12);
  await waitForComponentById(driver, 'mall-category-item', 12);
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
  await waitForComponentById(driver, 'mall-product-info-card', 12);
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
  expect(false).assertTrue();
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
  expect(false).assertTrue();
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
  const items = await driver.findComponents(ON.id(itemId));
  if (items === null || items === undefined || items.length === 0) {
    return 0;
  }
  let firstTop = Number.MAX_VALUE;
  for (let index = 0; index < items.length; index++) {
    const bounds = await items[index].getBounds();
    firstTop = Math.min(firstTop, bounds.top);
  }
  let count = 0;
  for (let index = 0; index < items.length; index++) {
    const bounds = await items[index].getBounds();
    if (Math.abs(bounds.top - firstTop) <= 3) {
      count++;
    }
  }
  return count;
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

export async function pinchOutById(driver: Driver, id: string, scale: number = 2): Promise<void> {
  const component = await driver.findComponent(ON.id(id));
  await component.pinchOut(scale);
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

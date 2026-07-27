import { Want } from '@kit.AbilityKit';
import {
  abilityDelegatorRegistry,
  Component,
  Driver,
  ON,
  UiWindow,
  WindowMode,
} from '@kit.TestKit';
import { expect } from '@ohos/hypium';

export const ENTRY_WINDOW_TITLE: string = '综合商城模板';
export const SECOND_WINDOW_TITLE: string = '分屏-商品详情';
export const PRODUCT_TITLE: string = '时尚轻商务系列针织打底纯羊毛内搭';

const PRODUCT_URI: string =
  'https://linking.xiaobingtang.cn/comprehensive-mall?productId=product_10001';
const delegator: abilityDelegatorRegistry.AbilityDelegator =
  abilityDelegatorRegistry.getAbilityDelegator();

let sharedDriver: Driver | undefined = undefined;
let sharedBundleName: string = '';

export interface SplitSession {
  main: UiWindow;
  secondary: UiWindow;
}

export function getDriver(): Driver {
  if (sharedDriver === undefined) {
    try {
      sharedDriver = Driver.create();
    } catch (error) {
      console.error('Driver.create failed: ' + JSON.stringify(error));
      expect(false).assertTrue();
      throw new Error('Driver.create failed');
    }
  }
  return sharedDriver;
}

export function getBundleName(): string {
  if (sharedBundleName.length === 0) {
    sharedBundleName = abilityDelegatorRegistry.getArguments().bundleName;
  }
  return sharedBundleName;
}

async function waitForUiChange(driver: Driver): Promise<void> {
  try {
    await driver.waitForIdle(200, 800);
  } catch (error) {
    console.info('waitForIdle ignored: ' + JSON.stringify(error));
  }
}

export async function startMall(): Promise<string> {
  const driver = getDriver();
  const bundleName = getBundleName();
  const want: Want = {
    bundleName: bundleName,
    abilityName: 'EntryAbility',
  };
  await delegator.startAbility(want);
  await waitForComponentById(driver, 'mall-root', 12);
  return bundleName;
}

export async function openProductDetail(): Promise<string> {
  const driver = getDriver();
  const bundleName = getBundleName();
  await closeSecondaryWindowIfPresent();
  const want: Want = {
    bundleName: bundleName,
    abilityName: 'EntryAbility',
    uri: PRODUCT_URI,
  };
  await delegator.startAbility(want);
  await waitForComponentById(driver, 'product-info-page', 16);
  await waitForComponentByText(driver, PRODUCT_TITLE, 16);
  return bundleName;
}

export async function componentExistsById(driver: Driver, id: string): Promise<boolean> {
  try {
    const component = await driver.findComponent(ON.id(id));
    return component !== null && component !== undefined;
  } catch (error) {
    return false;
  }
}

export async function componentExistsByText(driver: Driver, text: string): Promise<boolean> {
  try {
    const component = await driver.findComponent(ON.text(text));
    return component !== null && component !== undefined;
  } catch (error) {
    return false;
  }
}

export async function waitForComponentById(driver: Driver, id: string, retries: number = 10): Promise<void> {
  for (let index = 0; index < retries; index++) {
    if (await componentExistsById(driver, id)) {
      return;
    }
    await waitForUiChange(driver);
  }
  console.error('component id not found: ' + id);
  expect(false).assertTrue();
}

export async function waitForComponentByText(driver: Driver, text: string, retries: number = 10): Promise<void> {
  for (let index = 0; index < retries; index++) {
    if (await componentExistsByText(driver, text)) {
      return;
    }
    await waitForUiChange(driver);
  }
  console.error('component text not found: ' + text);
  expect(false).assertTrue();
}

export async function clickComponentById(driver: Driver, id: string): Promise<void> {
  await waitForComponentById(driver, id);
  const component = await driver.findComponent(ON.id(id));
  await component.click();
  await waitForUiChange(driver);
}

async function findWindowByRole(title: string): Promise<UiWindow | undefined> {
  try {
    const titledWindow = await getDriver().findWindow({
      bundleName: getBundleName(),
      title: title,
    });
    if (titledWindow !== null && titledWindow !== undefined) {
      return titledWindow;
    }
  } catch (error) {
  }

  const activeStates: boolean[] = [true, false];
  for (let index = 0; index < activeStates.length; index++) {
    try {
      const uiWindow = await getDriver().findWindow({
        bundleName: getBundleName(),
        active: activeStates[index],
      });
      if (uiWindow === null || uiWindow === undefined) {
        continue;
      }
      const mode = await uiWindow.getWindowMode();
      if (title === SECOND_WINDOW_TITLE && mode === WindowMode.SECONDARY) {
        return uiWindow;
      }
      if (title === ENTRY_WINDOW_TITLE &&
        (mode === WindowMode.FULLSCREEN || mode === WindowMode.PRIMARY)) {
        return uiWindow;
      }
    } catch (error) {
    }
  }
  return undefined;
}

export async function windowExists(title: string): Promise<boolean> {
  return await findWindowByRole(title) !== undefined;
}

export async function waitForWindow(title: string, retries: number = 12): Promise<UiWindow> {
  for (let index = 0; index < retries; index++) {
    const uiWindow = await findWindowByRole(title);
    if (uiWindow !== undefined) {
      return uiWindow;
    }
    await waitForUiChange(getDriver());
  }
  console.error('window not found: ' + title);
  expect(false).assertTrue();
  throw new Error('window not found: ' + title);
}

export async function waitForWindowAbsent(title: string, retries: number = 12): Promise<void> {
  for (let index = 0; index < retries; index++) {
    if (!await windowExists(title)) {
      return;
    }
    await waitForUiChange(getDriver());
  }
  console.error('window still exists: ' + title);
  expect(false).assertTrue();
}

export async function waitForWindowMode(
  uiWindow: UiWindow,
  expectedMode: WindowMode,
  retries: number = 12,
): Promise<void> {
  for (let index = 0; index < retries; index++) {
    if (await uiWindow.getWindowMode() === expectedMode) {
      return;
    }
    await waitForUiChange(getDriver());
  }
  expect(await uiWindow.getWindowMode()).assertEqual(expectedMode);
}

export async function closeSecondaryWindowIfPresent(): Promise<void> {
  try {
    const secondWindow = await findWindowByRole(SECOND_WINDOW_TITLE);
    if (secondWindow !== undefined) {
      await secondWindow.close();
      await waitForWindowAbsent(SECOND_WINDOW_TITLE);
    }
  } catch (error) {
  }
}

async function getHeaderActions(driver: Driver): Promise<Component[]> {
  await waitForComponentById(driver, 'product-info-header-actions');
  const header = await driver.findComponent(ON.id('product-info-header-actions'));
  const headerBounds = await header.getBounds();
  const symbols = await driver.findComponents(ON.id('common-symbol'));
  const actions: Component[] = [];
  for (let index = 0; index < symbols.length; index++) {
    const bounds = await symbols[index].getBounds();
    const centerX = (bounds.left + bounds.right) / 2;
    const centerY = (bounds.top + bounds.bottom) / 2;
    if (centerX >= headerBounds.left && centerX <= headerBounds.right &&
      centerY >= headerBounds.top && centerY <= headerBounds.bottom) {
      actions.push(symbols[index]);
    }
  }
  return actions;
}

export async function getHeaderActionCount(driver: Driver): Promise<number> {
  return (await getHeaderActions(driver)).length;
}

export async function clickSplitOrMergeAction(driver: Driver): Promise<void> {
  const actions = await getHeaderActions(driver);
  expect(actions.length >= 2).assertTrue();
  let rightmost = actions[0];
  let rightmostBounds = await rightmost.getBounds();
  for (let index = 1; index < actions.length; index++) {
    const bounds = await actions[index].getBounds();
    if (bounds.right > rightmostBounds.right) {
      rightmost = actions[index];
      rightmostBounds = bounds;
    }
  }
  await rightmost.click();
  await waitForUiChange(driver);
}

export async function startSplitSession(): Promise<SplitSession> {
  const driver = getDriver();
  await openProductDetail();
  expect(await getHeaderActionCount(driver)).assertEqual(2);
  await clickSplitOrMergeAction(driver);
  const main = await waitForWindow(ENTRY_WINDOW_TITLE);
  const secondary = await waitForWindow(SECOND_WINDOW_TITLE);
  await waitForWindowMode(main, WindowMode.PRIMARY);
  await waitForWindowMode(secondary, WindowMode.SECONDARY);
  return { main, secondary };
}

export async function assertProductDetailIsSingleColumn(driver: Driver): Promise<void> {
  for (let index = 0; index < 16; index++) {
    let isSingleColumn: boolean | undefined = undefined;
    try {
      const swiper = await driver.findComponent(ON.id('product-swiper'));
      const infoCard = await driver.findComponent(ON.id('product-info-card'));
      if (swiper === null || swiper === undefined || infoCard === null || infoCard === undefined) {
        await waitForUiChange(driver);
        continue;
      }
      const swiperBounds = await swiper.getBounds();
      const infoBounds = await infoCard.getBounds();
      isSingleColumn = infoBounds.top >= swiperBounds.bottom - vp2px(2);
    } catch (error) {
      await waitForUiChange(driver);
    }
    if (isSingleColumn !== undefined) {
      expect(isSingleColumn).assertTrue();
      return;
    }
  }
  console.error('stable product detail bounds not found');
  expect(false).assertTrue();
}

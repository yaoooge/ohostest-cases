import { describe, it, expect, Level } from '@ohos/hypium';
import { Driver, WindowMode } from '@kit.TestKit';
import {
  assertProductDetailIsSingleColumn,
  closeSecondaryWindowIfPresent,
  componentExistsByText,
  ENTRY_WINDOW_TITLE,
  getDriver,
  openProductDetail,
  PRODUCT_TITLE,
  SECOND_WINDOW_TITLE,
  startMall,
  waitForComponentById,
  waitForComponentByText,
  waitForWindow,
  waitForWindowMode,
  windowExists,
} from './TestHelper';

export default function commonPassToPassTest() {
  describe('CommonPassToPassTest', () => {
    const driver: Driver = getDriver();

    it('should_start_mall_successfully', Level.LEVEL2, async (done: Function) => {
      await startMall();
      await waitForComponentById(driver, 'mall-root');
      done();
    });

    it('should_open_product_detail_from_applink', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      await waitForComponentById(driver, 'product-info-page');
      await waitForComponentByText(driver, PRODUCT_TITLE);
      done();
    });

    it('should_keep_purchase_actions_available', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      await waitForComponentById(driver, 'product-purchase-actions');
      expect(await componentExistsByText(driver, '客服')).assertTrue();
      expect(await componentExistsByText(driver, '购物车')).assertTrue();
      expect(await componentExistsByText(driver, '加入购物车')).assertTrue();
      expect(await componentExistsByText(driver, '立即购买')).assertTrue();
      done();
    });

    it('should_have_one_fullscreen_window_before_split', Level.LEVEL2, async (done: Function) => {
      await closeSecondaryWindowIfPresent();
      await openProductDetail();
      const main = await waitForWindow(ENTRY_WINDOW_TITLE);
      await waitForWindowMode(main, WindowMode.FULLSCREEN);
      expect(await windowExists(SECOND_WINDOW_TITLE)).assertFalse();
      done();
    });

    it('should_keep_product_detail_single_column_on_wide_window', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      await assertProductDetailIsSingleColumn(driver);
      done();
    });
  });
}

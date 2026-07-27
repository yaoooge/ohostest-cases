import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  componentExistsById,
  getDriver,
  openProductDetail,
  prepareHome,
  waitForComponentById,
} from './TestHelper';

export default function commonPassToPassTest() {
  describe('CommonPassToPassTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = getDriver();
    });

    it('should_start_mall_successfully', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      await waitForComponentById(driver, 'mall-main-entry');
      await waitForComponentById(driver, 'mall-home-page');
      done();
    });

    it('should_show_four_main_tabs', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      for (let index = 0; index < 4; index++) {
        await waitForComponentById(driver, 'mall-tab-' + index);
      }
      done();
    });

    it('should_keep_home_content_available', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      await waitForComponentById(driver, 'mall-home-search');
      await waitForComponentById(driver, 'mall-home-banner');
      done();
    });

    it('should_keep_product_purchase_actions_available', Level.LEVEL2, async (done: Function) => {
      await openProductDetail(driver);
      await waitForComponentById(driver, 'mall-customer-service', 20);
      await waitForComponentById(driver, 'mall-shopping-cart', 20);
      await waitForComponentById(driver, 'mall-add-to-cart', 20);
      await waitForComponentById(driver, 'mall-buy-now', 20);
      done();
    });

    it('should_keep_split_action_absent_in_ui_case', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await componentExistsById(driver, 'mall-split-action')).assertFalse();
      done();
    });
  });
}

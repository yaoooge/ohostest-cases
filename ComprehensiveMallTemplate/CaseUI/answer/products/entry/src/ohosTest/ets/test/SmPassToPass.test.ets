import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  assertCurrentBreakpoint,
  countItemsInFirstRow,
  getAspectRatioById,
  getDriver,
  isComponentBelow,
  openCategory,
  pinchInById,
  pinchOutById,
  prepareHome,
} from './TestHelper';

export default function smPassToPassTest() {
  describe('SmPassToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareHome();
      await assertCurrentBreakpoint(driver, bundleName, 'sm');
    });

    it('should_keep_sm_home_banner_ratio_4_3', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      const ratio = await getAspectRatioById(driver, 'mall-home-banner');
      expect(Math.abs(ratio - 4 / 3) <= 0.12).assertTrue();
      done();
    });

    it('should_keep_sm_product_waterflow_two_columns', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
      done();
    });

    it('should_keep_search_below_title_on_sm', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await isComponentBelow(driver, 'mall-home-title-row', 'mall-home-search')).assertTrue();
      done();
    });

    it('should_ignore_product_pinch_on_sm', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      await pinchOutById(driver, 'mall-product-waterflow');
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
      await pinchInById(driver, 'mall-product-waterflow');
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
      done();
    });

    it('should_keep_sm_category_grid_two_columns', Level.LEVEL2, async (done: Function) => {
      await openCategory(driver);
      expect(await countItemsInFirstRow(driver, 'mall-category-item')).assertEqual(2);
      done();
    });
  });
}

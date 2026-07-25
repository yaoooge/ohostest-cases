import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  assertCurrentBreakpoint,
  countItemsInFirstRow,
  getAspectRatioById,
  getDriver,
  openCategory,
  prepareHome,
} from './TestHelper';

export default function mdFailToPassTest() {
  describe('MdFailToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareHome();
      await assertCurrentBreakpoint(driver, bundleName, 'md');
    });

    it('should_use_md_home_banner_ratio_2_5', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      const ratio = await getAspectRatioById(driver, 'mall-home-banner');
      expect(Math.abs(ratio - 2.5) <= 0.15).assertTrue();
      done();
    });

    it('should_show_three_product_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(3);
      done();
    });

    it('should_show_four_category_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await openCategory(driver);
      expect(await countItemsInFirstRow(driver, 'mall-category-item')).assertEqual(4);
      done();
    });
  });
}

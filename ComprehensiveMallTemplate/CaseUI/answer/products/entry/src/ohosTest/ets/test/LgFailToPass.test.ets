import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  areItemsSpreadAcrossContainer,
  assertCurrentBreakpoint,
  countItemsInFirstRow,
  getAspectRatioById,
  getComponentVpWidthById,
  getDriver,
  isComponentVerticallyInside,
  isProductDetailTwoPane,
  openCategory,
  openProductDetail,
  openSearchResults,
  openSearchSkeleton,
  pinchInById,
  pinchOutById,
  prepareHome,
  switchToListMode,
} from './TestHelper';

export default function lgFailToPassTest() {
  describe('LgFailToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareHome();
      await assertCurrentBreakpoint(driver, bundleName, 'lg');
    });

    it('should_place_400vp_search_in_home_title_on_lg', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      const width = await getComponentVpWidthById(driver, 'mall-home-search');
      expect(Math.abs(width - 400) <= 12).assertTrue();
      expect(await isComponentVerticallyInside(driver, 'mall-home-search', 'mall-home-title-row')).assertTrue();
      done();
    });

    it('should_use_lg_home_banner_ratio_5', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      const ratio = await getAspectRatioById(driver, 'mall-home-banner');
      expect(Math.abs(ratio - 5) <= 0.2).assertTrue();
      done();
    });

    it('should_show_five_product_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(5);
      done();
    });

    it('should_show_product_detail_as_two_panes_on_lg', Level.LEVEL2, async (done: Function) => {
      await openProductDetail(driver);
      expect(await isProductDetailTwoPane(driver)).assertTrue();
      done();
    });

    it('should_distribute_home_categories_across_available_width_on_lg', Level.LEVEL2,
      async (done: Function) => {
        await prepareHome();
        expect(await areItemsSpreadAcrossContainer(
          driver,
          'mall-home-category-item',
          'mall-home-category-row',
        )).assertTrue();
        done();
      });

    it('should_change_product_columns_between_four_and_six_on_lg', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      await pinchOutById(driver, 'mall-product-waterflow', 2);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(4);
      await pinchInById(driver, 'mall-product-waterflow', 0.5);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(6);
      done();
    });

    it('should_show_four_category_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openCategory(driver);
      expect(await countItemsInFirstRow(driver, 'mall-category-item')).assertEqual(4);
      done();
    });

    it('should_show_two_list_mode_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openSearchResults(driver);
      await switchToListMode(driver);
      expect(await countItemsInFirstRow(driver, 'mall-list-product-item')).assertEqual(2);
      done();
    });

    it('should_show_four_horizontal_skeleton_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, false);
      expect(await countItemsInFirstRow(driver, 'mall-horizontal-skeleton-item')).assertEqual(4);
      done();
    });

    it('should_show_two_vertical_skeleton_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, true);
      expect(await countItemsInFirstRow(driver, 'mall-vertical-skeleton-item')).assertEqual(2);
      done();
    });

  });
}

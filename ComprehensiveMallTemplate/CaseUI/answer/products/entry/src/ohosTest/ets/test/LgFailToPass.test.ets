import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  areItemsSpreadAcrossContainer,
  assertCurrentBreakpoint,
  countItemsInFirstRow,
  getAspectRatioById,
  getCategoryGridColumnCount,
  getComponentVpWidthById,
  getDriver,
  haveVerticalOverlap,
  isComponentBottomNearWindow,
  isComponentLeftOf,
  isComponentVerticallyInside,
  isProductDetailTwoPane,
  openCart,
  openProductDetail,
  openProductReviewMedia,
  openReviewCreation,
  openProfile,
  openOrderList,
  openPointsMall,
  openCollection,
  openHistory,
  openSeckill,
  openSearchResults,
  openSearchSkeleton,
  pinchInById,
  pinchOutById,
  prepareHome,
  revealHomeProducts,
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
      await revealHomeProducts(driver);
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
      await revealHomeProducts(driver);
      await pinchOutById(driver, 'mall-product-waterflow', 2);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(4);
      await pinchInById(driver, 'mall-product-waterflow', 0.5);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(6);
      done();
    });

    it('should_show_four_category_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      expect(await getCategoryGridColumnCount(driver)).assertEqual(4);
      done();
    });

    it('should_show_two_list_mode_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openSearchResults(driver);
      await switchToListMode(driver);
      expect(await countItemsInFirstRow(driver, 'mall-list-product-item')).assertEqual(2);
      done();
    });

    it('should_show_four_horizontal_skeleton_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      expect(await openSearchSkeleton(driver, false)).assertEqual(4);
      done();
    });

    it('should_show_two_vertical_skeleton_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      expect(await openSearchSkeleton(driver, true)).assertEqual(2);
      done();
    });

    it('should_show_five_review_media_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openProductReviewMedia(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-media-item')).assertEqual(5);
      done();
    });

    it('should_show_five_review_picker_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openReviewCreation(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-picker-item')).assertEqual(5);
      done();
    });

    it('should_show_two_cart_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openCart(driver);
      expect(await countItemsInFirstRow(driver, 'mall-cart-item')).assertEqual(2);
      done();
    });

    it('should_remove_extra_bottom_gap_from_cart_on_lg', Level.LEVEL2, async (done: Function) => {
      await openCart(driver);
      expect(await isComponentBottomNearWindow(
        driver,
        'mall-cart-control-panel',
        bundleName,
      )).assertTrue();
      done();
    });

    it('should_place_profile_sections_side_by_side_on_lg', Level.LEVEL2, async (done: Function) => {
      await openProfile(driver);
      expect(await isComponentLeftOf(
        driver,
        'mall-profile-user-area',
        'mall-profile-checkin-menu-area',
      )).assertTrue();
      expect(await haveVerticalOverlap(
        driver,
        'mall-profile-user-area',
        'mall-profile-checkin-menu-area',
      )).assertTrue();
      done();
    });

    it('should_show_two_profile_submenu_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openProfile(driver);
      expect(await countItemsInFirstRow(driver, 'mall-profile-submenu-item')).assertEqual(2);
      done();
    });

    it('should_show_two_order_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openOrderList(driver);
      expect(await countItemsInFirstRow(driver, 'mall-order-item')).assertEqual(2);
      done();
    });

    it('should_show_four_points_products_on_lg', Level.LEVEL2, async (done: Function) => {
      await openPointsMall(driver);
      expect(await countItemsInFirstRow(driver, 'mall-points-product-item')).assertEqual(4);
      done();
    });

    it('should_show_two_collection_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openCollection(driver);
      expect(await countItemsInFirstRow(driver, 'mall-setting-product-item')).assertEqual(2);
      done();
    });

    it('should_show_two_history_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openHistory(driver);
      expect(await countItemsInFirstRow(driver, 'mall-setting-product-item')).assertEqual(2);
      done();
    });

    it('should_show_two_seckill_columns_on_lg', Level.LEVEL2, async (done: Function) => {
      await openSeckill(driver);
      expect(await countItemsInFirstRow(driver, 'mall-seckill-item')).assertEqual(2);
      done();
    });

  });
}

import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  assertCurrentBreakpoint,
  countItemsInFirstRow,
  getAspectRatioById,
  getDriver,
  isComponentBelow,
  openCart,
  openCategory,
  openProductDetail,
  openProductReviewMedia,
  openReviewCreation,
  openProfile,
  openSearchResults,
  openSearchSkeleton,
  pinchInById,
  pinchOutById,
  prepareHome,
  switchToListMode,
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

    it('should_keep_list_mode_single_column_on_sm', Level.LEVEL2, async (done: Function) => {
      await openSearchResults(driver);
      await switchToListMode(driver);
      expect(await countItemsInFirstRow(driver, 'mall-list-product-item')).assertEqual(1);
      done();
    });

    it('should_keep_horizontal_skeleton_two_columns_on_sm', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, false);
      expect(await countItemsInFirstRow(driver, 'mall-horizontal-skeleton-item')).assertEqual(2);
      done();
    });

    it('should_keep_vertical_skeleton_single_column_on_sm', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, true);
      expect(await countItemsInFirstRow(driver, 'mall-vertical-skeleton-item')).assertEqual(1);
      done();
    });

    it('should_show_product_detail_vertically_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProductDetail(driver);
      expect(await isComponentBelow(driver, 'mall-product-swiper', 'mall-product-info-card')).assertTrue();
      done();
    });

    it('should_show_three_review_media_columns_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProductReviewMedia(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-media-item')).assertEqual(3);
      done();
    });

    it('should_show_three_review_picker_columns_on_sm', Level.LEVEL2, async (done: Function) => {
      await openReviewCreation(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-picker-item')).assertEqual(3);
      done();
    });

    it('should_keep_cart_single_column_on_sm', Level.LEVEL2, async (done: Function) => {
      await openCart(driver);
      expect(await countItemsInFirstRow(driver, 'mall-cart-item')).assertEqual(1);
      done();
    });

    it('should_keep_profile_sections_vertical_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProfile(driver);
      expect(await isComponentBelow(
        driver,
        'mall-profile-user-area',
        'mall-profile-checkin-area',
      )).assertTrue();
      expect(await isComponentBelow(
        driver,
        'mall-profile-checkin-area',
        'mall-profile-main-menu-area',
      )).assertTrue();
      done();
    });

    it('should_keep_profile_submenu_single_column_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProfile(driver);
      expect(await countItemsInFirstRow(driver, 'mall-profile-submenu-item')).assertEqual(1);
      done();
    });

  });
}

import { beforeAll, describe, expect, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  assertCurrentBreakpoint,
  countVisibleItemsInside,
  countItemsInFirstRow,
  getAspectRatioById,
  getDriver,
  isComponentBelow,
  openCategory,
  openProductDetail,
  openProductReviewMedia,
  openReviewCreation,
  openSearchResults,
  openSearchSkeleton,
  pinchInById,
  pinchOutById,
  prepareHome,
  switchToListMode,
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

    it('should_keep_search_below_title_on_md', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      expect(await isComponentBelow(driver, 'mall-home-title-row', 'mall-home-search')).assertTrue();
      done();
    });

    it('should_change_product_columns_between_two_and_four_on_md', Level.LEVEL2, async (done: Function) => {
      await prepareHome();
      await pinchOutById(driver, 'mall-product-waterflow', 2);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(2);
      await pinchInById(driver, 'mall-product-waterflow', 0.5);
      expect(await countItemsInFirstRow(driver, 'mall-product-item')).assertEqual(4);
      done();
    });

    it('should_show_four_category_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await openCategory(driver);
      expect(await countItemsInFirstRow(driver, 'mall-category-item')).assertEqual(4);
      done();
    });

    it('should_keep_list_mode_single_column_on_md', Level.LEVEL2, async (done: Function) => {
      await openSearchResults(driver);
      await switchToListMode(driver);
      expect(await countItemsInFirstRow(driver, 'mall-list-product-item')).assertEqual(1);
      done();
    });

    it('should_show_three_horizontal_skeleton_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, false);
      expect(await countItemsInFirstRow(driver, 'mall-horizontal-skeleton-item')).assertEqual(3);
      done();
    });

    it('should_keep_vertical_skeleton_single_column_on_md', Level.LEVEL2, async (done: Function) => {
      await openSearchSkeleton(driver, true);
      expect(await countItemsInFirstRow(driver, 'mall-vertical-skeleton-item')).assertEqual(1);
      done();
    });

    it('should_show_product_detail_vertically_on_md', Level.LEVEL2, async (done: Function) => {
      await openProductDetail(driver);
      expect(await isComponentBelow(driver, 'mall-product-swiper', 'mall-product-info-card')).assertTrue();
      done();
    });

    it('should_show_five_review_media_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await openProductReviewMedia(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-media-item')).assertEqual(5);
      done();
    });

    it('should_reveal_adjacent_product_image_on_md', Level.LEVEL2, async (done: Function) => {
      await openProductDetail(driver);
      expect(await countVisibleItemsInside(
        driver,
        'mall-product-swiper-image',
        'mall-product-swiper',
      ) >= 2).assertTrue();
      done();
    });

    it('should_show_five_review_picker_columns_on_md', Level.LEVEL2, async (done: Function) => {
      await openReviewCreation(driver);
      expect(await countItemsInFirstRow(driver, 'mall-review-picker-item')).assertEqual(5);
      done();
    });

  });
}

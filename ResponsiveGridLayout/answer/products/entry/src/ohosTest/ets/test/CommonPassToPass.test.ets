import { describe, beforeAll, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  assertComponentById,
  assertComponentByText,
  assertNoHorizontalOverflow,
  getDriver,
  prepareEntryAbility,
} from './TestHelper';

export default function commonPassToPassTest() {
  describe('CommonPassToPassTest', () => {
    let driver: Driver;

    beforeAll(async () => {
      driver = getDriver();
      await prepareEntryAbility();
    });

    it('should_start_ability_successfully', Level.LEVEL2, async (done: Function) => {
      await assertComponentById(driver, 'grid-page');
      done();
    });

    it('should_show_grid_page_content', Level.LEVEL2, async (done: Function) => {
      await assertComponentById(driver, 'grid-header');
      await assertComponentByText(driver, '分类');
      done();
    });

    it('should_show_grid_items', Level.LEVEL2, async (done: Function) => {
      await assertComponentById(driver, 'category-grid');
      await assertComponentById(driver, 'category-grid-item0');
      done();
    });

    it('should_show_product_category_content', Level.LEVEL2, async (done: Function) => {
      await assertComponentById(driver, 'primary-category-list');
      await assertComponentByText(driver, '配件中心');
      await assertComponentByText(driver, '通用配件');
      await assertComponentByText(driver, '华为 6A 数据线');
      done();
    });

    it('should_keep_grid_items_without_horizontal_overflow', Level.LEVEL2, async (done: Function) => {
      await assertNoHorizontalOverflow(driver, 'category-grid', 'category-grid-item0');
      done();
    });
  });
}

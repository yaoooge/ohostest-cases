import { describe, beforeAll, it, expect, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  estimateComponentVpHeightById,
  estimateComponentVpWidthById,
  estimateHorizontalGapByIds,
  estimateLanesById,
  getCurrentBreakpoint,
  getDriver,
  prepareEntryAbility,
} from './TestHelper';

export default function mdFailToPassTest() {
  describe('MdFailToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareEntryAbility();
    });

    it('should_show_grid_as_three_columns_on_medium_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'md') {
        const lanes = await estimateLanesById(driver, 'category-grid', 'category-grid-item0');
        expect(lanes).assertEqual(3);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_use_12vp_grid_gap_on_medium_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'md') {
        const gap = await estimateHorizontalGapByIds(driver, 'category-grid-item0', 'category-grid-item1');
        expect(gap).assertEqual(12);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_use_68vp_product_image_on_medium_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'md') {
        const width = await estimateComponentVpWidthById(driver, 'category-grid-image0');
        const height = await estimateComponentVpHeightById(driver, 'category-grid-image0');
        expect(width).assertEqual(68);
        expect(height).assertEqual(68);
      } else {
        expect(true).assertTrue();
      }
      done();
    });
  });
}

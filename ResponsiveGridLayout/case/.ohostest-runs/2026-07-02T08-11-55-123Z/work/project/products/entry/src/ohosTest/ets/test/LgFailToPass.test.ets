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

export default function lgFailToPassTest() {
  describe('LgFailToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareEntryAbility();
    });

    it('should_show_grid_as_five_columns_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const lanes = await estimateLanesById(driver, 'category-grid', 'category-grid-item0');
        expect(lanes).assertEqual(5);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_use_16vp_grid_gap_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const gap = await estimateHorizontalGapByIds(driver, 'category-grid-item0', 'category-grid-item1');
        expect(gap).assertEqual(16);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_use_76vp_product_image_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const width = await estimateComponentVpWidthById(driver, 'category-grid-image0');
        const height = await estimateComponentVpHeightById(driver, 'category-grid-image0');
        expect(width).assertEqual(76);
        expect(height).assertEqual(76);
      } else {
        expect(true).assertTrue();
      }
      done();
    });
  });
}

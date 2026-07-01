import { describe, beforeAll, it, expect, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  estimateComponentVpHeightById,
  estimateComponentVpWidthById,
  estimateLanesById,
  getCurrentBreakpoint,
  getDriver,
  prepareEntryAbility,
} from './TestHelper';

export default function smPassToPassTest() {
  describe('SmPassToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareEntryAbility();
    });

    it('should_show_grid_as_two_columns_on_small_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'sm') {
        const lanes = await estimateLanesById(driver, 'category-grid', 'category-grid-item0');
        expect(lanes).assertEqual(2);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_use_58vp_product_image_on_small_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'sm') {
        const width = await estimateComponentVpWidthById(driver, 'category-grid-image0');
        const height = await estimateComponentVpHeightById(driver, 'category-grid-image0');
        expect(width).assertEqual(58);
        expect(height).assertEqual(58);
      } else {
        expect(true).assertTrue();
      }
      done();
    });
  });
}

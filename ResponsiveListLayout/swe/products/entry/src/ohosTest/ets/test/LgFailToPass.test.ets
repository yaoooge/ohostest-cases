import { describe, beforeAll, it, expect, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import {
  estimateLanesById,
  getCurrentBreakpoint,
  getDriver,
  getHorizontalGapVp,
  getVerticalGapVp,
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

    it('should_show_list_as_two_lanes_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const lanes = await estimateLanesById(driver, 'order-list', 'order-list-item0');
        expect(lanes).assertEqual(2);
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_keep_order_list_column_space_12_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const gap = await getHorizontalGapVp(driver, 'order-list-item0', 'order-list-item1');
        expect(gap >= 10 && gap <= 14).assertTrue();
      } else {
        expect(true).assertTrue();
      }
      done();
    });

    it('should_keep_order_list_row_space_12_on_large_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'lg') {
        const gap = await getVerticalGapVp(driver, 'order-list-item0', 'order-list-item2');
        expect(gap >= 10 && gap <= 14).assertTrue();
      } else {
        expect(true).assertTrue();
      }
      done();
    });
  });
}

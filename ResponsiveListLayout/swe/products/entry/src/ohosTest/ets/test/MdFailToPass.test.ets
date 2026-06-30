import { describe, beforeAll, it, expect, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { getCurrentBreakpoint, getDriver, getVerticalGapVp, prepareEntryAbility } from './TestHelper';

export default function mdFailToPassTest() {
  describe('MdFailToPassTest', () => {
    let driver: Driver;
    let bundleName: string;

    beforeAll(async () => {
      driver = getDriver();
      bundleName = await prepareEntryAbility();
    });

    it('should_keep_order_list_row_space_12_on_medium_breakpoint', Level.LEVEL2, async (done: Function) => {
      const breakpoint = await getCurrentBreakpoint(driver, bundleName);
      if (breakpoint === 'md') {
        const gap = await getVerticalGapVp(driver, 'order-list-item0', 'order-list-item1');
        expect(gap >= 10 && gap <= 14).assertTrue();
      } else {
        expect(true).assertTrue();
      }
      done();
    });
  });
}

import { describe, it, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { getDriver, openProductDetail, waitForHeaderActionCount } from './TestHelper';

export default function smPassToPassTest() {
  describe('SmPassToPassTest', () => {
    const driver: Driver = getDriver();

    it('should_hide_split_action_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      await waitForHeaderActionCount(driver, 1);
      done();
    });
  });
}

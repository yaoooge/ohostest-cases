import { describe, it, expect, Level } from '@ohos/hypium';
import { Driver } from '@kit.TestKit';
import { getDriver, getHeaderActionCount, openProductDetail } from './TestHelper';

export default function smPassToPassTest() {
  describe('SmPassToPassTest', () => {
    const driver: Driver = getDriver();

    it('should_hide_split_action_on_sm', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      expect(await getHeaderActionCount(driver)).assertEqual(1);
      done();
    });
  });
}

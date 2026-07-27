import { describe, it, expect, Level } from '@ohos/hypium';
import { Driver, WindowMode } from '@kit.TestKit';
import {
  clickComponentById,
  clickSplitOrMergeAction,
  ENTRY_WINDOW_TITLE,
  getDriver,
  getHeaderActionCount,
  openProductDetail,
  PRODUCT_TITLE,
  SECOND_WINDOW_TITLE,
  startSplitSession,
  waitForComponentById,
  waitForComponentByText,
  waitForWindowAbsent,
  waitForWindowMode,
  windowExists,
} from './TestHelper';

export default function splitFailToPassTest() {
  describe('SplitFailToPassTest', () => {
    const driver: Driver = getDriver();

    it('should_show_split_action_on_supported_window', Level.LEVEL2, async (done: Function) => {
      await openProductDetail();
      expect(await getHeaderActionCount(driver)).assertEqual(2);
      done();
    });

    it('should_start_secondary_window_in_split_mode', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      expect(await windows.main.getWindowMode()).assertEqual(WindowMode.PRIMARY);
      expect(await windows.secondary.getWindowMode()).assertEqual(WindowMode.SECONDARY);
      done();
    });

    it('should_show_same_product_in_secondary_window', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      await windows.secondary.focus();
      await waitForComponentByText(driver, PRODUCT_TITLE, 16);
      done();
    });

    it('should_show_merge_action_in_both_windows', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      await windows.main.focus();
      expect(await getHeaderActionCount(driver)).assertEqual(2);
      await windows.secondary.focus();
      expect(await getHeaderActionCount(driver)).assertEqual(2);
      done();
    });

    it('should_restore_main_window_when_secondary_is_closed', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      await windows.secondary.close();
      await waitForWindowAbsent(SECOND_WINDOW_TITLE);
      await waitForWindowMode(windows.main, WindowMode.FULLSCREEN);
      expect(await windowExists(SECOND_WINDOW_TITLE)).assertFalse();
      done();
    });

    it('should_merge_when_action_is_clicked_in_secondary', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      await windows.secondary.focus();
      await clickSplitOrMergeAction(driver);
      await waitForWindowAbsent(SECOND_WINDOW_TITLE);
      await waitForWindowMode(windows.main, WindowMode.FULLSCREEN);
      await windows.main.focus();
      await waitForComponentByText(driver, PRODUCT_TITLE, 16);
      done();
    });

    it('should_migrate_secondary_navigation_when_merged_from_primary', Level.LEVEL2, async (done: Function) => {
      const windows = await startSplitSession();
      await windows.secondary.focus();
      await clickComponentById(driver, 'product-cart-action');
      await waitForComponentById(driver, 'cart-page', 16);

      await windows.main.focus();
      await clickSplitOrMergeAction(driver);
      await waitForWindowAbsent(SECOND_WINDOW_TITLE);
      await waitForWindowMode(windows.main, WindowMode.FULLSCREEN);
      await windows.main.focus();
      await waitForComponentById(driver, 'cart-page', 16);
      expect(await windowExists(ENTRY_WINDOW_TITLE)).assertTrue();
      done();
    });
  });
}

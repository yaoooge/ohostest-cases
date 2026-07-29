import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { UtilLog } from '@hw-agconnect/util-log';
import { routerStack, WindowUtil } from 'lib_foundation';

const TAG: string = '[SecondAbility]';

export default class SecondAbility extends UIAbility {
  onWindowStageActive(windowStage: window.WindowStage): void {
    routerStack.setActive('SecondAbility');
    WindowUtil.setActiveContext('SecondAbility');
  }

  onDestroy(): void {
    routerStack.isSplitActive = false;
    routerStack.setActive('EntryAbility');
    WindowUtil.setActiveContext('EntryAbility');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    try {
      windowStage.loadContent('views/Index', (): void => {
        try {
          windowStage
            .getMainWindowSync()
            .getUIContext()
            .setKeyboardAvoidMode(KeyboardAvoidMode.OFFSET_WITH_CARET);
          LoneTakeAnimationsTransition.init(windowStage);
        } catch (err) {
          UtilLog.error(TAG, JSON.stringify(err));
        }
      });
    } catch (err) {
      UtilLog.error(TAG, 'loadContent failed: ' + JSON.stringify(err));
    }
  }
}

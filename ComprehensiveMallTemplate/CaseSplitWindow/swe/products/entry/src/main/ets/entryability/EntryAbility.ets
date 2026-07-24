import { Want } from '@kit.AbilityKit';
import ConfigurationConstant from '@ohos.app.ability.ConfigurationConstant';
import UIAbility from '@ohos.app.ability.UIAbility';
import { KeyboardAvoidMode } from '@ohos.arkui.UIContext';
import window from '@ohos.window';
import { ColorModeUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { UtilLog } from '@hw-agconnect/util-log';
import { SetupUtil } from '../utils/SetupUtil';

const TAG: string = '[EntryAbility]';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want): void {
    UtilLog.setGlobalConfig({
      tag: 'ComprehensiveMall',
      domain: 0xff00,
      open: true,
      showStack: false,
    });
    UtilLog.info(TAG, 'set global log config success.');
    ColorModeUtil.applySavedColorMode(this.context);
    SetupUtil.handleWant(want);
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

  onNewWant(want: Want): void {
    SetupUtil.handleWant(want);
    SetupUtil.jumpToTarget();
  }
}

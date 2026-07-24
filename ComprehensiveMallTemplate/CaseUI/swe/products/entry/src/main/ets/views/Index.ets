import { RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { SetupUtil } from '../utils/SetupUtil';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  isEnabled: boolean = true

  aboutToAppear(): void {
    const uiContext = this.getUIContext()
    WindowUtil.setUIContext(uiContext)
    routerStack.registerStack(this.stack)
    this.stack.pushPath({
      name: RouterMap.MAIN_ENTRY,
    }, false)
    SetupUtil.jumpToTarget()
  }

  build() {
    Navigation(this.stack) {
    }
    .backgroundColor($r('app.color.background_color_grey'))
    .hideBackButton(true)
    .hideNavBar(true)
    .mode(NavigationMode.Stack)
    .customNavContentTransition((from: NavContentInfo, to: NavContentInfo, operation: NavigationOperation) => {
      return LoneTakeAnimationsTransition.customNavContentTransition(from, to, operation, {
        // 自定义转场过程中禁用手势，避免出现体验问题
        onTransitionStart: () => {
          this.isEnabled = false;
        },
        onTransitionEnd: () => {
          this.isEnabled = true;
        },
      });
    })
  }
}

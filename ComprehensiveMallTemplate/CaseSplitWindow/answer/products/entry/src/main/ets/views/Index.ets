import { common } from '@kit.AbilityKit';
import { ProductInfoPageParam, RouterMap, routerStack, WindowUtil } from 'lib_foundation';
import { LoneTakeAnimationsTransition } from 'module_transition';
import { splitNavStore } from '../utils/SplitNavStore';

@Entry
@ComponentV2
struct EmptyPage {
  @Local
  stack: NavPathStack = new NavPathStack()
  @Local
  isEnabled: boolean = true

  aboutToAppear(): void {
    const uiContext = this.getUIContext()
    const abilityContext = uiContext.getHostContext() as common.UIAbilityContext;
    const abilityName: string = abilityContext.abilityInfo.name;
    WindowUtil.setUIContext(abilityName, uiContext)
    routerStack.registerStack(abilityName, this.stack)
    if (abilityName === 'SecondAbility') {
      routerStack.cloneStackTo('EntryAbility', this.stack);
      splitNavStore.productId = undefined;
      splitNavStore.slotId = undefined;
    } else if (splitNavStore.productId) {
      const navParam: ProductInfoPageParam = {
        productId: splitNavStore.productId,
        slotId: splitNavStore.slotId,
      };
      splitNavStore.productId = undefined;
      splitNavStore.slotId = undefined;
      this.stack.pushPath({
        name: RouterMap.PRODUCT_INFO,
        param: navParam,
      }, false);
    } else {
      this.stack.pushPath({
        name: RouterMap.MAIN_ENTRY,
      }, false)
    }
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

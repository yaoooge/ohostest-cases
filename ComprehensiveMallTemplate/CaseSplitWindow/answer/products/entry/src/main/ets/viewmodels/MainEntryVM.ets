import { ensureDefaultUserState, iData, routerStack } from 'lib_foundation';
import { ShoppingCartApis } from 'lib_network';
import { SetupUtil } from '../utils/SetupUtil';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = routerStack.getActiveStack();
  // 当前页签
  @Trace curIndex: number = 0;
  @Trace firstBackTime: number = 0;

  public initData() {
    ensureDefaultUserState();
    ShoppingCartApis.getCartData().then((res) => {
      if (res.code === 0) {
        iData.global.cartVersion = res.data.version;
        iData.global.cartTotal = res.data.total;
      }
    });
    SetupUtil.jumpToTarget();
  }
}

import { Want } from '@kit.AbilityKit';
import { ProductInfoPageParam, RouterMap, routerStack } from 'lib_foundation';

export class SetupUtil {
  public static navInfo?: NavPathInfo;

  public static handleWant(want: Want) {
    // AppLinking解析
    let uri = want?.uri;
    if (uri) {
      const productId = uri.split('productId=')[1] || null;
      if (productId) {
        SetupUtil.navInfo = {
          name: RouterMap.PRODUCT_INFO,
          param: { productId } as ProductInfoPageParam,
        };
        return;
      }
    }
    // 参数解析
    let params = want?.parameters;
    if (params?.shortCutKey) {
      switch (params.shortCutKey) {
        case 'OrderPage':
          SetupUtil.navInfo = {
            name: RouterMap.ORDER_LIST, param: 3,
          };
      }
    }
  }

  public static jumpToTarget() {
    console.log(JSON.stringify(SetupUtil.navInfo));
    if (!SetupUtil.navInfo) {
      return;
    }
    routerStack.pushPath(SetupUtil.navInfo);
    SetupUtil.navInfo = undefined;
  }
}

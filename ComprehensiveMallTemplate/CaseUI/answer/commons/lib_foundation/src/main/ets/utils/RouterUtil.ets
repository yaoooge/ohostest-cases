import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[RouterUtil]';

/**
 * 单窗口路由管理工具。
 */
@ObservedV2
class RouterUtil {
  private stack?: NavPathStack;

  public registerStack(stack: NavPathStack): void {
    this.stack = stack;
    UtilLog.info(TAG, 'registerStack');
  }

  public getStack(): NavPathStack | undefined {
    if (this.stack === undefined) {
      UtilLog.warn(TAG, 'getStack: stack not registered');
    }
    return this.stack;
  }

  /**
   * 入栈新页面。
   * @param pathInfo 页面路由信息（name + param）
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则路由到当前激活窗口
   */
  public push(pathInfo: NavPathInfo, animated: boolean = true): void {
    this.getStack()?.pushPath(pathInfo, animated);
  }

  /**
   * 出栈当前页面。
   * @param result 可选，传递给上一个页面的返回值
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public pop(result?: Object, animated: boolean = true): void {
    this.getStack()?.pop(result, animated);
  }

  /**
   * 替换栈顶页面（出栈当前页，入栈新页，无回退记录）。
   * @param pathInfo 新页面路由信息
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public replace(pathInfo: NavPathInfo, animated: boolean = true): void {
    this.getStack()?.replacePath(pathInfo, animated);
  }

  /**
   * 退栈至指定页面名（保留该页面，弹出其上所有页面）。
   * @param name 目标页面的路由名称
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public popToName(name: string, animated: boolean = true): void {
    this.getStack()?.popToName(name, animated);
  }

  /**
   * 清空指定 Ability 的路由栈（退回根页面）。
   * @param animated 是否启用转场动画，默认 true
   * @param abilityName 可选，指定目标 Ability；不传则操作当前激活窗口
   */
  public clear(animated: boolean = true): void {
    this.getStack()?.clear(animated);
  }

  /**
   * 获取当前激活 Ability 的 NavPathStack，始终返回有效实例。
   * 供需要显式传入 NavPathStack 参数的组件使用。
   */
  public getActiveStack(): NavPathStack {
    const stack: NavPathStack | undefined = this.getStack();
    if (stack === undefined) {
      UtilLog.warn(TAG, 'getActiveStack: no active stack registered, returning empty stack');
      return new NavPathStack();
    }
    return stack;
  }

  /** 返回当前激活路由栈的深度（NavPathStack 同名代理） */
  public size(): number {
    return this.getStack()?.size() ?? 0;
  }

  // ── NavPathStack 同名代理方法 ──────────────────────────────────────────────
  // 以下方法与 NavPathStack 保持相同签名，使消费方无需修改调用代码。

  /** 入栈新页面（NavPathStack 同名代理） */
  public pushPath(info: NavPathInfo, animated?: boolean): void {
    this.getStack()?.pushPath(info, animated);
  }

  /** 按名称入栈（NavPathStack 同名代理） */
  public pushPathByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.pushPathByName(name, param, animated);
  }

  /** 替换栈顶页面（NavPathStack 同名代理） */
  public replacePath(info: NavPathInfo, animated?: boolean): void {
    this.getStack()?.replacePath(info, animated);
  }

  /** 按名称替换栈顶（NavPathStack 同名代理） */
  public replacePathByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.replacePathByName(name, param, animated);
  }

  /** 按名称入栈（pushPathByName 别名，供统一风格调用） */
  public pushByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.pushPathByName(name, param, animated);
  }

  /** 按名称替换栈顶（replacePathByName 别名，供统一风格调用） */
  public replaceByName(name: string, param?: Object, animated?: boolean): void {
    this.getStack()?.replacePathByName(name, param, animated);
  }
}

/** 全局路由工具单例 */
export const routerUtil: RouterUtil = new RouterUtil();

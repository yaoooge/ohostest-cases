import { UtilLog } from '@hw-agconnect/util-log';

const TAG: string = '[RouterUtil]';

/**
 * 单窗口路由管理工具。
 */
class RouterUtil {
  private stack?: NavPathStack;

  /**
   * 注册应用的唯一根路由栈。
   */
  public registerStack(stack: NavPathStack): void {
    this.stack = stack;
    UtilLog.info(TAG, 'registerStack');
  }

  /**
   * 获取应用根路由栈。
   * @returns NavPathStack 实例，找不到时返回 undefined
   */
  public getStack(): NavPathStack | undefined {
    if (this.stack === undefined) {
      UtilLog.warn(TAG, 'getStack: root stack is not registered');
    }
    return this.stack;
  }

  /**
   * 入栈新页面。
   * @param pathInfo 页面路由信息（name + param）
   * @param animated 是否启用转场动画，默认 true
   */
  public push(pathInfo: NavPathInfo, animated: boolean = true): void {
    this.stack?.pushPath(pathInfo, animated);
  }

  /**
   * 出栈当前页面。
   * @param result 可选，传递给上一个页面的返回值
   * @param animated 是否启用转场动画，默认 true
   */
  public pop(result?: Object, animated: boolean = true): void {
    this.stack?.pop(result, animated);
  }

  /**
   * 替换栈顶页面（出栈当前页，入栈新页，无回退记录）。
   * @param pathInfo 新页面路由信息
   * @param animated 是否启用转场动画，默认 true
   */
  public replace(pathInfo: NavPathInfo, animated: boolean = true): void {
    this.stack?.replacePath(pathInfo, animated);
  }

  /**
   * 退栈至指定页面名（保留该页面，弹出其上所有页面）。
   * @param name 目标页面的路由名称
   * @param animated 是否启用转场动画，默认 true
   */
  public popToName(name: string, animated: boolean = true): void {
    this.stack?.popToName(name, animated);
  }

  /**
   * 清空指定 Ability 的路由栈（退回根页面）。
   * @param animated 是否启用转场动画，默认 true
   */
  public clear(animated: boolean = true): void {
    this.stack?.clear(animated);
  }

  /**
   * 获取当前激活 Ability 的 NavPathStack，始终返回有效实例。
   * 供需要显式传入 NavPathStack 参数的组件使用。
   */
  public getActiveStack(): NavPathStack {
    if (this.stack === undefined) {
      UtilLog.warn(TAG, 'getActiveStack: root stack is not registered, returning empty stack');
      return new NavPathStack();
    }
    return this.stack;
  }

  /** 返回根路由栈深度（NavPathStack 同名代理） */
  public size(): number {
    return this.stack?.size() ?? 0;
  }

  // ── NavPathStack 同名代理方法 ──────────────────────────────────────────────
  // 以下方法与 NavPathStack 保持相同签名，使消费方无需修改调用代码。

  /** 入栈新页面（NavPathStack 同名代理） */
  public pushPath(info: NavPathInfo, animated?: boolean): void {
    this.stack?.pushPath(info, animated);
  }

  /** 按名称入栈（NavPathStack 同名代理） */
  public pushPathByName(name: string, param?: Object, animated?: boolean): void {
    this.stack?.pushPathByName(name, param, animated);
  }

  /** 替换栈顶页面（NavPathStack 同名代理） */
  public replacePath(info: NavPathInfo, animated?: boolean): void {
    this.stack?.replacePath(info, animated);
  }

  /** 按名称替换栈顶（NavPathStack 同名代理） */
  public replacePathByName(name: string, param?: Object, animated?: boolean): void {
    this.stack?.replacePathByName(name, param, animated);
  }

  /** 按名称入栈（pushPathByName 别名，供统一风格调用） */
  public pushByName(name: string, param?: Object, animated?: boolean): void {
    this.stack?.pushPathByName(name, param, animated);
  }

  /** 按名称替换栈顶（replacePathByName 别名，供统一风格调用） */
  public replaceByName(name: string, param?: Object, animated?: boolean): void {
    this.stack?.replacePathByName(name, param, animated);
  }
}

/** 全局路由工具单例 */
export const routerUtil: RouterUtil = new RouterUtil();

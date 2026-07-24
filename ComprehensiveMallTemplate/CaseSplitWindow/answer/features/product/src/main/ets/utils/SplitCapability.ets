const MIN_SPLIT_WINDOW_WIDTH: number = 600;

/**
 * 仅用于判断当前商品详情窗口是否适合启动应用内分屏。
 * 页面布局不消费该状态；进入分屏后始终保留合并入口。
 */
export class SplitCapability {
  public static shouldShowAction(windowWidth: number, isSplitActive: boolean): boolean {
    return isSplitActive || windowWidth >= MIN_SPLIT_WINDOW_WIDTH;
  }
}

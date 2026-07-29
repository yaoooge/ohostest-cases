const MIN_SPLIT_WINDOW_WIDTH: number = 600;

export class SplitCapability {
  public static shouldShowAction(windowWidth: number, isSplitActive: boolean): boolean {
    return isSplitActive || windowWidth >= MIN_SPLIT_WINDOW_WIDTH;
  }
}

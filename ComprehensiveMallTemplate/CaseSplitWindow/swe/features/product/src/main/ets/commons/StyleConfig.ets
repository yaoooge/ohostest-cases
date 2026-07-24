@ObservedV2
export class ProductSwiperStyleConfig {
  @Computed
  public static get imageMaxHeight() {
    return 360;
  }

  @Computed
  public static get imageAspectRatio() {
    return 1.0;
  }

  @Computed
  public static get outImageDisplayWidth() {
    return 0;
  }

  @Computed
  public static get swiperPadding() {
    return $r('app.float.space_l');
  }

  @Computed
  public static get imagePadding() {
    return {
      left: 6,
      right: 6,
    } as Padding
  }
}

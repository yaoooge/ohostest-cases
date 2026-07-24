import { webview } from '@kit.ArkWeb';

@ComponentV2
export struct AgreementPage {

  @Local
  private label: string = '';

  @Local
  private url: string = '';

  private controller: webview.WebviewController = new webview.WebviewController();

  public build(): void {
    NavDestination() {
      Column() {
        Web({
          src: this.url,
          controller: this.controller,
        })
          .width('100%')
          .layoutWeight(1)
          .fileAccess(false)
          .geolocationAccess(false)
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backgroundColor(Color.White)
    }
    .title(this.label)
    .onReady((ctx: NavDestinationContext) => {
      if (ctx.pathInfo.param) {
        const param: Record<string, string> = ctx.pathInfo.param as Record<string, string>;
        this.label = param.label ?? '';
        this.url = param.url ?? '';
      }
    })
  }
}

@Builder
export function buildAgreementPage(): void {
  AgreementPage()
}

import { routerStack, RouterMap, WindowUtil } from 'lib_foundation'
import { AdvertisementComponent } from 'module_advertisement';

@Builder
export function buildSplashPage() {
  SplashPage()
}

@ComponentV2
export struct SplashPage {
  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.app_icon'))
          .width('512px')
          .height('512px')

        AdvertisementComponent({
          adType: 1,
          testAd: 'testd7c5cewoj6',
          skipAd: () => {
            routerStack.replacePath({
              name: RouterMap.MAIN_ENTRY,
            })
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .onShown(() => {
      WindowUtil.setWindowScreen(true)
    })
    .onHidden(()=>{
      WindowUtil.setWindowScreen(false)
    })
  }
}
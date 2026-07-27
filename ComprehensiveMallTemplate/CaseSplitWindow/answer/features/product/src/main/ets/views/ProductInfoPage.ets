import { common } from '@kit.AbilityKit';
import { ProductInfoPageParam } from 'lib_foundation';
import { CommonSymbol, NavTitleBar } from 'lib_widget';
import { ProductInfoVM } from '../viewmodels/ProductInfoVM';
import {
  buildDivider,
  buildEmptySearch,
  buildLoadingPlaceholder,
  buildProductDesc,
  buildProductInfoCard,
  buildProductSwiper,
  buildReviewOverview,
} from '../components/ProductInfoCards';
import { ProductOperationButton } from '../components/ProductOperationButton';
import { SeckillStatus } from 'lib_network';
import { SplitCapability } from '../utils/SplitCapability';

@Builder
export function buildProductInfoPage() {
  ProductInfoPage();
}

@ComponentV2
export struct ProductInfoPage {
  vm: ProductInfoVM = new ProductInfoVM()
  @Local
  windowWidth: number = 0

  build() {
    NavDestination() {
      this.buildHeader()
      Column() {
        if (this.vm.isLoading) {
          buildLoadingPlaceholder()
        } else if (!this.vm.productInfo) {
          buildEmptySearch()
        } else {
          this.buildPhoneDisplay()
        }
      }
      .layoutWeight(1)

      // 底部操作栏
      this.buildBottomOperation();
    }
    .id('product-info-page')
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_primary'))
    .onReady((context) => {
      const params = context.pathInfo.param as ProductInfoPageParam | undefined;
      if (params) {
        const abilityName: string =
          (this.getUIContext().getHostContext() as common.UIAbilityContext)?.abilityInfo?.name ??
            'EntryAbility';
        this.vm.initData(params, abilityName);
      }
      this.vm.registerWindowActiveListener()
    })
    .onShown(async () => {
      this.vm.getProductInfo()
      this.vm.countdown?.startCountdownTimer()
    })
    .onHidden(() => {
      this.vm.countdown?.stopCountdownTimer()
    })
    .onSizeChange((_oldValue: SizeOptions, newValue: SizeOptions) => {
      this.windowWidth = newValue.width as number;
    })
    .onDisAppear(() => {
      this.vm.unregisterWindowActiveListener()
    })
  }

  @Builder
  buildHeader() {
    NavTitleBar({
      title: '商品详情',
    }) {
      Row({ space: 16 }) {
        if (this.vm.productInfo) {
          CommonSymbol({
            src: this.vm.collectedStatus ? $r('sys.symbol.star_fill') : $r('sys.symbol.star'),
            color: this.vm.collectedStatus ? $r('app.color.theme_color') : $r('sys.color.font_primary'),
          })
            .onClick(() => {
              this.vm.changeCollectStatus()
            })

          if (SplitCapability.shouldShowAction(this.windowWidth, this.vm.isSplitScreen)) {
            CommonSymbol({
              src: this.vm.isSplitScreen
                ? $r('sys.symbol.arrow_down_right_and_arrow_up_left')
                : $r('sys.symbol.rectangle_split_2x1'),
            })
              .onClick(() => {
                if (this.vm.isSplitScreen) {
                  this.vm.mergeSplitScreen();
                } else {
                  this.vm.startSplitScreen();
                }
              })
          }
        }
      }
      .id('product-info-header-actions')
      .justifyContent(FlexAlign.End)
      .layoutWeight(1)
    };
  }

  @Builder
  buildPhoneDisplay() {
    Scroll() {
      Column() {
        buildProductSwiper(this.vm.productInfo?.productDetail?.banners ?? [])
        buildProductInfoCard(this.vm.productInfo?.productDetail!, this.vm.productInfo?.seckillInfo)
        buildDivider()
        buildReviewOverview(this.vm)
        buildDivider()
        buildProductDesc(this.vm.productInfo?.productDetail!)
      };
    }
    .id('product-info-scroll')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.Off)
    .layoutWeight(1);
  }

  @Builder
  buildBottomOperation() {
    Row() {
      // 待开售的秒杀商品只展示预约按钮
      if (this.vm.productInfo?.timeSlot?.status === SeckillStatus.WAITING) {
        Row() {
          SymbolGlyph($r('sys.symbol.bell_fill'))
            .fontSize(24)
            .fontColor([$r('app.color.font_color_level1_invert')])
            .margin({ right: $r('app.float.space_s') })
          Text(this.vm.reserveButtonLabel)
            .fontColor($r('app.color.font_color_level1_invert'))
            .fontSize($r('app.float.font_size_14'))
            .fontWeight(FontWeight.Medium)

          if (this.vm.isReserved && this.vm.countdown?.countdownLabel) {
            Text(`剩余${this.vm.countdown.countdownLabel}开抢`)
              .fontColor($r('app.color.font_color_level1_invert'))
              .fontSize($r('app.float.font_size_14'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: $r('app.float.space_s') })
          }
        }
        .height(40)
        .borderRadius(20)
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .backgroundColor($r('app.color.theme_color_second'))
        .opacity(this.vm.isReserved ? 0.6 : 1)
        .onClick(() => {
          this.vm.handleClickReserveButton()
        })
      } else {
        Column() {
          SymbolGlyph($r('sys.symbol.service'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_primary')])
            .margin({ bottom: 2 });

          Text('客服')
            .fontSize(12)
            .fontColor($r('app.color.font_color_level1'));
        }
        .onClick(() => {
          this.vm.handleClickCustomService()
        })
        .margin({ right: $r('app.float.space_l') })

        Badge({
          count: this.vm.isLogin ? this.vm.cartNum : 0,
          style: {
            badgeSize: 16,
            badgeColor: $r('app.color.theme_color'),
            fontWeight: FontWeight.Medium,
            fontSize: 10,
          },
          position: BadgePosition.RightTop,
        }) {
          Column() {
            SymbolGlyph($r('sys.symbol.cart'))
              .fontSize(24)
              .fontColor([$r('sys.color.icon_primary')])
              .margin({ bottom: 2 });
            Text('购物车')
              .fontSize(12)
              .fontColor($r('app.color.font_color_level1'));
          }
          .padding(4);
        }
        .id('product-cart-action')
        .onClick(() => {
          this.vm.handleClickCart()
        });

        Blank();
        ProductOperationButton({
          productInfo: this.vm.productInfo,
        })
          .layoutWeight(1)
      }
    }
    .id('product-purchase-actions')
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
    })
    .backgroundColor($r('app.color.background_color_primary'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

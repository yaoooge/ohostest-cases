import {
  routerStack, RouterMap, ProductInfoPageParam, ProductSearchResultsPageParam,
} from 'lib_foundation';
import { CommonSymbol, NavTitleBar } from 'lib_widget';
import { FilterSelectionItem, ProductFilter } from 'module_product_filter';
import { SearchBar } from 'module_product_search';
import { ProductWaterFlow } from 'product';
import { SortTypeMap } from '../commons/Enums';
import { SortBar } from '../components/SortBar';

@ComponentV2
struct ProductSearchResultsPage {
  @Local
  keywords?: string;
  @Local
  searchImg?: PixelMap
  @Local
  slotId?: string
  @Local
  isGrid: boolean = false
  @Local
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Local
  filterList: FilterSelectionItem[] = []

  build() {
    NavDestination() {
      this.buildHeader()

      Row() {
        SortBar({
          handleSortTypeChange: (type) => {
            this.sortType = type
          },
        })
        Blank()
        Row() {
          Text('筛选')
            .fontSize($r('app.float.font_size_14'))
            .fontColor($r('app.color.font_color_level2'))
            .margin({ right: $r('app.float.space_s') })
          SymbolGlyph($r('sys.symbol.funnel'))
            .fontSize(16)
            .fontColor([$r('sys.color.icon_secondary')])
        }
        .margin({
          right: $r('app.float.space_l'),
        })
        .onClick(() => {
          ProductFilter.show({
            initFilter: this.filterList,
            handleConfirm: (res) => {
              this.filterList = res
            },
          }, this.getUIContext())
        })
      }
      .width($r('app.string.size_percent_full'))
      .padding({
        bottom: $r('app.float.space_m'),
        left: $r('app.float.space_m'),
      })
      .backgroundColor($r('app.color.background_color_primary'))

      Column() {
        ProductWaterFlow({
          keyword: this.keywords,
          slotId: this.slotId,
          sortType: this.sortType,
          filterList: this.filterList,
          isGrid: this.isGrid,
          handleProductClick: (id) => {
            routerStack.pushPath({
              name: RouterMap.PRODUCT_INFO,
              param: {
                productId: id,
                slotId: this.slotId,
              } as ProductInfoPageParam,
            });
          },
        })
          .layoutWeight(1)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);

      }
      .padding({
        left: $r('app.float.space_l'),
        right: $r('app.float.space_l'),
        top: $r('app.float.space_l'),
      })
      .layoutWeight(1)
      .backgroundColor($r('app.color.background_color_grey'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.background_color_grey'))
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .onReady((context) => {
      const param = context.pathInfo.param as ProductSearchResultsPageParam
      this.keywords = param.keywords;
      this.searchImg = param.searchImg
      this.slotId = param.slotId
    })
  }

  @Builder
  buildHeader() {
    if (this.searchImg) {
      NavTitleBar({ title: '相关商品', bgColor: $r('app.color.background_color_primary') })
      Row() {
        Image(this.searchImg)
          .width(40)
          .height(40)
          .borderRadius($r('app.float.border_radius_s'))
          .margin({ right: $r('app.float.space_m') })
          .backgroundColor($r('app.color.background_color_grey'))
        Text('以下是扫描实物识别出的相关商品')
          .fontSize($r('app.float.font_size_14'))
          .fontColor($r('app.color.font_color_level2'))
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.background_color_primary'))
      .padding($r('app.float.space_l'))
    } else {
      Row() {
        SearchBar({
          searchWords: this.keywords,
          disabled: true,
          clickBack: () => {
            routerStack.pop(false);
          },
        })
          .layoutWeight(1)

        CommonSymbol({ src: this.isGrid ? $r('sys.symbol.list_bullet') : $r('sys.symbol.grid') })
          .onClick(() => {
            this.isGrid = !this.isGrid;
          })
          .margin({ right: $r('app.float.space_l') })
      }
      .backgroundColor($r('app.color.background_color_primary'))
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .padding({ bottom: $r('app.float.space_l') })

    }
  }
}

@Builder
export function buildProductSearchResultsPage() {
  ProductSearchResultsPage();
}

import { PRODUCT_CARDS } from '../model/DemoData';
import { ProductCard } from '../model/Types';
import { BreakpointModel, BreakpointStorage, BreakpointSystem } from '../utils/BreakpointSystem';

@Extend(Text)
function productSingleLineText() {
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text)
function productDoubleLineText() {
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@ComponentV2
export struct ProductWaterFlow {
  @Local
  currentBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint;

  @Computed
  get columns(): number {
    return new BreakpointModel<number>(2, 3, 4).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get gap(): number {
    return new BreakpointModel<number>(8, 12, 12).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get horizontalPadding(): number {
    return new BreakpointModel<number>(16, 24, 32).getValue(this.currentBreakpoint.value);
  }

  build() {
    WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
      ForEach(PRODUCT_CARDS, (item: ProductCard, index: number) => {
        FlowItem() {
          this.productCard(item, index)
        }
        .width('100%')
      }, (item: ProductCard, index: number) => item.title + index.toString())
    }
    .columnsTemplate(`repeat(${this.columns}, 1fr)`)
    .columnsGap(this.gap)
    .rowsGap(this.gap)
    .width('100%')
    .layoutWeight(1)
    .padding({ left: this.horizontalPadding, right: this.horizontalPadding, bottom: 20 })
    .scrollBar(BarState.Off)
    .id('product-waterflow')
  }

  @Builder
  productCard(item: ProductCard, index: number) {
    Column() {
      Stack() {
        Image(item.image)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
          .draggable(false)
      }
      .width('100%')
      .aspectRatio(item.ratio)
      .padding(12)
      .backgroundColor(Color.White)

      Column() {
        Row() {
          Text(item.title)
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .productSingleLineText()
            .layoutWeight(1)
          Text(item.tag)
            .fontSize(11)
            .fontColor('#C51636')
            .backgroundColor('#FFF1F3')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .margin({ left: 8 })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)

        Text(item.description)
          .fontSize(14)
          .fontColor('#6B7280')
          .margin({ top: 6 })
          .productDoubleLineText()

        Row() {
          Text(item.price)
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .productSingleLineText()
          if (item.originalPrice) {
            Text(item.originalPrice)
              .fontSize(14)
              .fontColor('#9CA3AF')
              .decoration({ type: TextDecorationType.LineThrough, color: '#9CA3AF' })
              .margin({ left: 8, top: 4 })
              .productSingleLineText()
          }
        }
        .width('100%')
        .alignItems(VerticalAlign.Bottom)
        .margin({ top: 16 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 14, right: 14, bottom: 16 })
    }
    .clip(true)
    .borderRadius(12)
    .backgroundColor(Color.White)
    .id('product-waterflow-item' + index)
  }
}

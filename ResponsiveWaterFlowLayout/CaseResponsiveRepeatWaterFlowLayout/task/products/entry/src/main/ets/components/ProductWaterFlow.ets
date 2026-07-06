import { PRODUCT_CARDS } from '../model/DemoData';
import { ProductCard } from '../model/Types';

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
  build() {
    WaterFlow({ layoutMode: WaterFlowLayoutMode.SLIDING_WINDOW }) {
      ForEach(PRODUCT_CARDS, (item: ProductCard, index: number) => {
        FlowItem() {
          this.productCard(item, index)
        }
        .width('100%')
      }, (item: ProductCard, index: number) => item.title + index.toString())
    }
    .columnsTemplate('repeat(2, 1fr)')
    .columnsGap(8)
    .rowsGap(8)
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 16, right: 16, bottom: 16 })
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

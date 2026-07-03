@ComponentV2
export struct PageHeader {
  @Param title: string = '';
  @Param testId: string = 'page-header';

  build() {
    Column() {
      Row() {
        Text(this.title)
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2933')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        Button() {
          Image($r('app.media.ic_search'))
            .width(28)
            .height(28)
            .objectFit(ImageFit.Contain)
            .draggable(false)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor('#E9EEF3')
        .margin({ left: 16 })
        .id('waterflow-search-button')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 16, right: 16, top: 24, bottom: 18 })
    .id(this.testId)
  }
}

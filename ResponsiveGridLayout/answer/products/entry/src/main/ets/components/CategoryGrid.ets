import { PRIMARY_CATEGORIES } from '../model/DemoData';
import { CategoryProduct, PrimaryCategory, SecondaryCategory } from '../model/Types';
import { BreakpointModel, BreakpointStorage, BreakpointSystem } from '../utils/BreakpointSystem';

@Extend(Text)
function categorySingleLineText() {
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text)
function categoryDoubleLineText() {
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Image)
function categoryProductImageStyle(size: number) {
  .width(size)
  .height(size)
  .objectFit(ImageFit.Contain)
  .draggable(false)
}

@ComponentV2
export struct CategoryGrid {
  @Local
  currentBreakpoint: BreakpointStorage = BreakpointSystem.currentBreakpoint;
  @Local
  activePrimaryIndex: number = 3;
  @Local
  activeSecondaryIndex: number = 0;

  @Computed
  get columns(): number {
    return new BreakpointModel<number>(2, 3, 5).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get gap(): number {
    return new BreakpointModel<number>(8, 12, 16).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get sideWidth(): number {
    return new BreakpointModel<number>(96, 120, 148).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get imageSize(): number {
    return new BreakpointModel<number>(58, 68, 76).getValue(this.currentBreakpoint.value);
  }

  @Computed
  get activePrimary(): PrimaryCategory {
    if (this.activePrimaryIndex < 0 || this.activePrimaryIndex >= PRIMARY_CATEGORIES.length) {
      return PRIMARY_CATEGORIES[0];
    }
    return PRIMARY_CATEGORIES[this.activePrimaryIndex];
  }

  @Computed
  get activeSection(): SecondaryCategory {
    const sections = this.activePrimary.sections;
    if (this.activeSecondaryIndex < 0 || this.activeSecondaryIndex >= sections.length) {
      return sections[0];
    }
    return sections[this.activeSecondaryIndex];
  }

  build() {
    Row() {
      this.primaryCategoryList()
      Column() {
        this.secondaryTabs()
        Column() {
          Text(this.activeSection.title)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
            .categorySingleLineText()
            .margin({ bottom: 14 })

          Grid() {
            ForEach(this.activeSection.products, (item: CategoryProduct, index: number) => {
              GridItem() {
                Column() {
                  Image(item.image)
                    .categoryProductImageStyle(this.imageSize)
                    .id('category-grid-image' + index)
                  Text(item.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#111827')
                    .textAlign(TextAlign.Center)
                    .categoryDoubleLineText()
                    .margin({ top: 10 })
                  Text(item.detail)
                    .fontSize(11)
                    .fontColor('#8A9099')
                    .textAlign(TextAlign.Center)
                    .categoryDoubleLineText()
                    .margin({ top: 4 })
                }
                .width('100%')
                .height(148)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .id('category-grid-item' + index)
            }, (item: CategoryProduct) => item.name)
          }
          .columnsTemplate(`repeat(${this.columns}, 1fr)`)
          .columnsGap(this.gap)
          .rowsGap(this.gap)
          .width('100%')
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .id('category-grid')
        }
        .width('100%')
        .layoutWeight(1)
        .padding(20)
        .borderRadius(16)
        .backgroundColor(Color.White)
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .height('100%')
      .padding({ right: 12, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  primaryCategoryList() {
    Scroll() {
      Column() {
        ForEach(PRIMARY_CATEGORIES, (item: PrimaryCategory, index: number) => {
          Text(item.label)
            .width('100%')
            .height(54)
            .padding({ left: 10, right: 8 })
            .fontSize(15)
            .fontWeight(index === this.activePrimaryIndex ? FontWeight.Bold : FontWeight.Regular)
            .fontColor(index === this.activePrimaryIndex ? '#111827' : '#626B78')
            .backgroundColor('#F4F6F8')
            .categorySingleLineText()
            .onClick(() => {
              this.activePrimaryIndex = index;
              this.activeSecondaryIndex = 0;
            })
            .id('primary-category-item' + index)
        }, (item: PrimaryCategory) => item.label)
      }
      .width('100%')
      .padding({ top: 4, bottom: 12 })
    }
    .width(this.sideWidth)
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor('#EEF2F5')
    .scrollBar(BarState.Off)
    .id('primary-category-list')
  }

  @Builder
  secondaryTabs() {
    Scroll() {
      Row({ space: 10 }) {
        ForEach(this.activePrimary.sections, (item: SecondaryCategory, index: number) => {
          Text(item.label)
            .height(38)
            .padding({ left: 16, right: 16 })
            .fontSize(15)
            .fontWeight(index === this.activeSecondaryIndex ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(index === this.activeSecondaryIndex ? Color.White : '#4B5563')
            .backgroundColor(index === this.activeSecondaryIndex ? '#22242A' : Color.White)
            .borderRadius(19)
            .categorySingleLineText()
            .onClick(() => {
              this.activeSecondaryIndex = index;
            })
            .id('secondary-category-item' + index)
        }, (item: SecondaryCategory) => item.label)
      }
      .padding({ left: 12, right: 12 })
    }
    .width('100%')
    .height(48)
    .margin({ bottom: 12 })
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Start)
    .id('secondary-category-tabs')
  }
}

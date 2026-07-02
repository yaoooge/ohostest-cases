import { PageHeader } from '../components/PageHeader';
import { CategoryGrid } from '../components/CategoryGrid';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      PageHeader({
        title: '商品分类',
        testId: 'grid-header',
      })
      CategoryGrid()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6F8')
    .id('grid-page')
  }
}

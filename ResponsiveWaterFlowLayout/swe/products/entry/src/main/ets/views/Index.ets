import { PageHeader } from '../components/PageHeader';
import { ProductWaterFlow } from '../components/ProductWaterFlow';

@Entry
@ComponentV2
struct Index {
  build() {
    Column() {
      PageHeader({
        title: '精选好物',
        testId: 'waterflow-header',
      })
      ProductWaterFlow()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F4F6F8')
    .id('waterflow-page')
  }
}

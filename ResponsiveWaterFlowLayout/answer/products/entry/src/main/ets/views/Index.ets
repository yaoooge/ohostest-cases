import { common } from '@kit.AbilityKit';
import { PageHeader } from '../components/PageHeader';
import { ProductWaterFlow } from '../components/ProductWaterFlow';
import { BreakpointSystem } from '../utils/BreakpointSystem';

@Entry
@ComponentV2
struct Index {
  aboutToAppear(): void {
    const uiContext = this.getUIContext();
    uiContext.getHostContext() as common.UIAbilityContext;
    BreakpointSystem.register(uiContext);
  }

  aboutToDisappear(): void {
    BreakpointSystem.unregister();
  }

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

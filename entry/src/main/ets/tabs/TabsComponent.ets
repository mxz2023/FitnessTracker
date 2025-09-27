/**
 * 健康监测应用Tab组件
 */

import { WeightTab } from './subs/WeightTab';
import { BloodPressureTab } from './subs/BloodPressureTab';
import { BloodSugarTab } from './subs/BloodSugarTab';
import { UricAcidTab } from './subs/UricAcidTab';
import { BloodLipidTab } from './subs/BloodLipidTab';

// 定义Tab项的接口
interface TabItem {
  title: string;
  symbolName: string;
  component: string; // 组件名称，用于动态创建组件
}

@ComponentV2
export struct TabsComponent {
  @Local currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  
  // 定义Tab项数组，包含标题、图标和对应的组件
  private tabItems: TabItem[] = [
    { title: '体重', symbolName: 'weight_unit', component: 'WeightTab' },
    { title: '血压', symbolName: 'blood_pressure', component: 'BloodPressureTab' },
    { title: '血糖', symbolName: 'drop', component: 'BloodSugarTab' },
    { title: '尿酸', symbolName: 'blood_oxygen_meter', component: 'UricAcidTab' },
    { title: '血脂', symbolName: 'leaf', component: 'BloodLipidTab' }
  ];

  @Builder
  TabBuilder(tabItem: TabItem, index: number) {
    Column() {
      SymbolGlyph($r(`sys.symbol.${tabItem.symbolName}`))
        .fontSize(24)
        .fontColor(this.currentIndex === index ? [$r('app.color.icon_primary')] : [$r('app.color.icon_secondary')])

      Text(tabItem.title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#2196F3' : '#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  // 根据组件名称返回对应的组件实例
  @Builder
  TabContentBuilder(componentName: string) {
    if (componentName === 'WeightTab') {
      WeightTab()
    } else if (componentName === 'BloodPressureTab') {
      BloodPressureTab()
    } else if (componentName === 'BloodSugarTab') {
      BloodSugarTab()
    } else if (componentName === 'UricAcidTab') {
      UricAcidTab()
    } else if (componentName === 'BloodLipidTab') {
      BloodLipidTab()
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      ForEach(this.tabItems, (tabItem: TabItem, index: number) => {
        TabContent() {
          this.TabContentBuilder(tabItem.component)
        }
        .tabBar(this.TabBuilder(tabItem, index))
      })
    }
    .barHeight(56)
    .barMode(BarMode.Fixed)
    .barWidth('100%')
    .onChange((index: number) => {
      this.currentIndex = index;
    })
    .height('100%')
    .width('100%')
  }
}
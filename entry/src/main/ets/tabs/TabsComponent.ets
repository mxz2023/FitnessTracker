/**
 * 健康监测应用Tab组件
 */

import { WeightTab } from './subs/WeightTab';
import { BloodPressureTab } from './subs/BloodPressureTab';
import { BloodSugarTab } from './subs/BloodSugarTab';
import { UricAcidTab } from './subs/UricAcidTab';
import { BloodLipidTab } from './subs/BloodLipidTab';

@ComponentV2
export struct TabsComponent {
  @Local currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  // 定义Tab标题
  private tabTitles: string[] = ['体重', '血压', '血糖', '尿酸', '血脂'];
  // 定义每个Tab对应的系统符号名称（请根据需要替换为合适的sys.symbol名称）
  private tabSymbolNames: string[] = ['weight_unit', 'blood_pressure', 'drop', 'blood_oxygen_meter', 'leaf'];

  @Builder
  TabBuilder(title: string, index: number) {
    Column() {
      SymbolGlyph($r(`sys.symbol.${this.tabSymbolNames[index]}`))
        .fontSize(24)
        .fontColor(this.currentIndex === index ? [$r('app.color.icon_primary')] : [$r('app.color.icon_secondary')])

      Text(title)
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

  build() {
    Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
      TabContent() {
        WeightTab()
      }
      .tabBar(this.TabBuilder(this.tabTitles[0], 0))

      TabContent() {
        BloodPressureTab()
      }
      .tabBar(this.TabBuilder(this.tabTitles[1], 1))

      TabContent() {
        BloodSugarTab()
      }
      .tabBar(this.TabBuilder(this.tabTitles[2], 2))

      TabContent() {
        UricAcidTab()
      }
      .tabBar(this.TabBuilder(this.tabTitles[3], 3))

      TabContent() {
        BloodLipidTab()
      }
      .tabBar(this.TabBuilder(this.tabTitles[4], 4))
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
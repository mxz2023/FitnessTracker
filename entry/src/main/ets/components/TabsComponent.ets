/**
 * 健康监测应用Tab组件
 */

import { WeightTab } from './WeightTab';
import { BloodPressureTab } from './BloodPressureTab';
import { BloodSugarTab } from './BloodSugarTab';
import { UricAcidTab } from './UricAcidTab';
import { BloodLipidTab } from './BloodLipidTab';

@Component
export struct TabsComponent {
  @State currentIndex: number = 0;
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
    Column() {
      Text('健康监测')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 16 })
      
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
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
/**
 * 健康监测应用主页面
 */

import { TabsComponent } from '../components/TabsComponent';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';

@Entry
@Component
struct Index {
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl();

  build() {
    Column() {
      TabsComponent()
    }
    .width('100%')
    .height('100%')
  }
}
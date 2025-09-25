/**
 * 健康监测应用主页面
 */

import { CommonDefine } from '../common/CommonDefine';
import { TabsComponent } from '../tabs/TabsComponent';


@Entry
@Component
struct Index {
  private pathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    AppStorage.setOrCreate(CommonDefine.globalPathStackName, this.pathStack);
  }

  build() {
    Navigation(this.pathStack) {
      TabsComponent()
    }
    .title('健康监测')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .width('100%')
    .height('100%')
  }
}
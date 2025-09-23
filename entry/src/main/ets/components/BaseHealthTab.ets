/**
 * 基础健康Tab组件
 */

import { HealthData, HealthStatus } from '../model/HealthDataModel';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { formatDate } from '../utils/HealthUtils';

@Component
export struct BaseHealthTab {
  @State title: string = '';
  @State icon: Resource = $r('app.media.icon');
  @State latestData: HealthData | null = null;
  @State healthStatus: HealthStatus = HealthStatus.EXCELLENT;
  @State showAddDataDialog: boolean = false;
  @State showHistoryData: boolean = false;

  // 子类需要实现的方法
  onAddData() {
    this.showAddDataDialog = true;
  }

  onViewHistory() {
    this.showHistoryData = true;
  }

  build() {
    Column() {
      // 顶部信息区域
      Row() {
        Column() {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          if (this.latestData) {
            Row() {
              Text('最近记录: ')
                .fontSize(14)
                .fontColor('#666666')

              Text(formatDate(this.latestData.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(14)
                .fontColor('#666666')
            }
            .margin({ bottom: 4 })

            Row() {
              Text('健康状态: ')
                .fontSize(14)
                .fontColor('#666666')

              HealthStatusIndicator({ status: this.healthStatus, indicatorSize: 16 })
            }
          } else {
            Text('暂无记录')
              .fontSize(14)
              .fontColor('#999999')
          }
        }
        .layoutWeight(1)

        Image(this.icon)
          .width(40)
          .height(40)
          .objectFit(ImageFit.Contain)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#f5f5f5')
      .borderRadius(12)

      // 内容区域 - 由子类实现
      Column() {
        this.buildContent()
      }
      .width('100%')
      .layoutWeight(1)
      .margin({ top: 16 })

      // 底部按钮区域
      Row({ space: 16 }) {
        Button('添加记录')
          .onClick(() => this.onAddData())
          .backgroundColor('#4CAF50')
          .width('45%')

        Button('查看历史')
          .onClick(() => this.onViewHistory())
          .backgroundColor('#2196F3')
          .width('45%')
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .padding(16)
  }

  // 子类需要实现的内容构建方法
  @Builder
  buildContent() {
    // 默认实现，子类应该覆盖此方法
    Text('请在子类中实现此方法')
      .fontSize(16)
      .fontColor('#999999')
      .width('100%')
      .textAlign(TextAlign.Center)
  }
}
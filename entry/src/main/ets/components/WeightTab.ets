/**
 * 体重Tab组件
 */

import { WeightData, HealthStatus } from '../model/HealthDataModel';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';
import { evaluateWeightStatus, formatDate } from '../utils/HealthUtils';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { promptAction } from '@kit.ArkUI';

@Component
export struct WeightTab {
  @State weightValue: number = 0;
  @State nHeight: number = 1.70; // 默认身高，单位m
  @State historyData: WeightData[] = [];
  @State isLoading: boolean = false;
  @State latestData: WeightData | null = null;
  @State healthStatus: HealthStatus = HealthStatus.EXCELLENT;

  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());

  async loadLatestData() {
    this.isLoading = true;
    try {
      const data = await this.dataService.getDataByType('weight');
      const list = data as WeightData[];
      if (list.length > 0) {
        const latest = list[0];
        this.latestData = latest;
        this.weightValue = latest.value;
        this.healthStatus = evaluateWeightStatus(latest.value, this.nHeight);
      }
    } finally {
      this.isLoading = false;
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('weight');
    this.historyData = data as WeightData[];
  }

  async saveWeightData() {
    if (this.weightValue <= 0) {
      promptAction.showToast({ message: '请输入有效的体重值' });
      return;
    }
    const now = Date.now();
    const record = new WeightData();
    record.id = `weight_${now}`;
    record.timestamp = now;
    record.value = this.weightValue;
    record.note = '';

    const ok = await this.dataService.saveData(record);
    if (ok) {
      this.latestData = record;
      this.healthStatus = evaluateWeightStatus(this.weightValue, this.nHeight);
      await this.loadHistoryData();
      promptAction.showToast({ message: '保存成功' });
    } else {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  build() {
    Column() {
      // 输入区
      Column() {
        Row({ space: 12 }) {
          Text('体重(kg)')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.weightValue.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.weightValue = parseFloat(v); })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('身高(m)')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.nHeight.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.nHeight = parseFloat(v); })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('保存记录')
          .onClick(() => { this.saveWeightData(); })
          .backgroundColor('#4CAF50')
          .width('45%')
        Button('刷新历史')
          .onClick(() => { this.loadHistoryData(); })
          .backgroundColor('#2196F3')
          .width('45%')
      }
      .width('100%')
      .margin({ top: 12, bottom: 12 })

      // 最新数据与状态
      if (this.latestData) {
        Row() {
          Text('当前体重:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.value} kg`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Row() {
          Text('BMI指数:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${(this.latestData.value / (this.nHeight * this.nHeight)).toFixed(1)}`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Row() {
          Text('健康状态:')
            .fontSize(16)
            .fontColor('#666666')
          HealthStatusIndicator({ status: this.healthStatus })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 12 })
      } else {
        Text('暂无体重记录，先输入体重并保存')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
      }

      // 历史列表
      List() {
        ForEach(this.historyData, (item: WeightData) => {
          ListItem() {
            Row() {
              Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(13)
                .fontColor('#666666')
              Text(`${item.value} kg`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 6, bottom: 6 })
          }
        })
      }
      .width('100%')
      .height(220)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .onAppear(() => {
      this.loadLatestData();
      this.loadHistoryData();
    })
  }
}
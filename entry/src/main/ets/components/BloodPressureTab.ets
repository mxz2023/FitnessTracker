/**
 * 血压Tab组件
 */

import { BloodPressureData, HealthStatus } from '../model/HealthDataModel';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';
import { evaluateBloodPressureStatus, formatDate } from '../utils/HealthUtils';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { promptAction } from '@kit.ArkUI';

@Component
export struct BloodPressureTab {
  @State systolicValue: number = 120;
  @State diastolicValue: number = 80;
  @State historyData: BloodPressureData[] = [];
  @State latestData: BloodPressureData | null = null;
  @State healthStatus: HealthStatus = HealthStatus.EXCELLENT;

  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());

  async loadLatestData() {
    const data = await this.dataService.getDataByType('bloodPressure');
    const list = data as BloodPressureData[];
    if (list.length > 0) {
      const latest = list[0];
      this.latestData = latest;
      this.systolicValue = latest.systolic;
      this.diastolicValue = latest.diastolic;
      this.healthStatus = evaluateBloodPressureStatus(latest);
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('bloodPressure');
    this.historyData = data as BloodPressureData[];
  }

  async saveBloodPressureData() {
    if (this.systolicValue <= 0 || this.diastolicValue <= 0) {
      promptAction.showToast({ message: '请输入有效的血压值' });
      return;
    }
    const now = Date.now();
    const record = new BloodPressureData();
    record.id = `bloodPressure_${now}`;
    record.timestamp = now;
    record.systolic = this.systolicValue;
    record.diastolic = this.diastolicValue;
    record.note = '';
    const ok = await this.dataService.saveData(record);
    if (ok) {
      this.latestData = record;
      this.healthStatus = evaluateBloodPressureStatus(record);
      await this.loadHistoryData();
      promptAction.showToast({ message: '保存成功' });
    } else {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  build() {
    Column() {
      Column() {
        Row({ space: 12 }) {
          Text('收缩压(mmHg)')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.systolicValue.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.systolicValue = parseFloat(v); })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('舒张压(mmHg)')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.diastolicValue.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.diastolicValue = parseFloat(v); })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('保存记录')
          .onClick(() => { this.saveBloodPressureData(); })
          .backgroundColor('#4CAF50')
          .width('45%')
        Button('刷新历史')
          .onClick(() => { this.loadHistoryData(); })
          .backgroundColor('#2196F3')
          .width('45%')
      }
      .width('100%')
      .margin({ top: 12, bottom: 12 })

      if (this.latestData) {
        Row() {
          Text('当前血压:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.systolic}/${this.latestData.diastolic} mmHg`)
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
        Text('暂无血压记录，先输入数值并保存')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
      }

      List() {
        ForEach(this.historyData, (item: BloodPressureData) => {
          ListItem() {
            Row() {
              Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(13)
                .fontColor('#666666')
              Text(`${item.systolic}/${item.diastolic} mmHg`)
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
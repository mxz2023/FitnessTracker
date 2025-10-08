/**
 * 血压Tab组件
 */

import { BloodPressureData, HealthStatus } from '../../models/HealthDataModel';
import { HealthDataServiceImpl } from '../../models/HealthDataServiceImpl';
import { evaluateBloodPressureStatus } from '../../utils/HealthUtils';
import { HealthStatusIndicator } from '../../commonents/HealthStatusIndicator';
import { MTextInput } from '../../commonui/MTextInput';
import { MButton } from '../../commonui/MButton';
import { getAppPathStack } from '../../utils/PathStackUtils';
import { showToast } from '../../utils/ToastUtils';

@ComponentV2
export struct BloodPressureTab {
  @Local systolicValue: number = 120;
  @Local diastolicValue: number = 80;
  @Local historyData: BloodPressureData[] = [];
  @Local latestData: BloodPressureData | null = null;
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT;

  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());
  private navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.navPathStack = getAppPathStack()
  }

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
      showToast(this.getUIContext(), "请输入有效的血压值");
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
      showToast(this.getUIContext(), "保存成功");
    } else {
      showToast(this.getUIContext(), "保存失败");
    }
  }

  build() {
    Column() {
      Column() {
        Row({ space: 12 }) {
          Text('收缩压')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({ 
            text: this.systolicValue.toString(),
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.systolicValue = parseFloat(v || '0');
            }
          })
            .layoutWeight(1)
          Text('mmHg')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('舒张压')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({ 
            text: this.diastolicValue.toString(),
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.diastolicValue = parseFloat(v || '0');
            }
          })
            .layoutWeight(1)
          Text('mmHg')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row() {
        MButton({
          text: '保存记录',
          bgColor: '#4CAF50',
          onClickBlock: () => { this.saveBloodPressureData(); }
        })
          .layoutWeight(1)
          .margin({ right: 6 })
        MButton({
          text: '查看历史',
          bgColor: '#2196F3',
          onClickBlock: () => {
            const data: Record<string, string> = {
              "data": "bloodPressure"
            }
            this.navPathStack.pushPathByName("history", data)
          }
        })
          .layoutWeight(1)
          .margin({ left: 6 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
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
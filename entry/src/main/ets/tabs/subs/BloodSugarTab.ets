/**
 * 血糖Tab组件
 */
import { promptAction } from '@kit.ArkUI';

import { BloodSugarData, HealthStatus, MeasurementType } from '../../model/HealthDataModel';
import { HealthDataServiceImpl } from '../../model/HealthDataServiceImpl';
import { evaluateBloodSugarStatus, formatDate } from '../../utils/HealthUtils';
import { HealthStatusIndicator } from '../../commonents/HealthStatusIndicator';
import { MTextInput } from '../../commonui/MTextInput';
import { MButton } from '../../commonui/MButton';
import { getAppPathStack } from '../../utils/PathStackUtils';

@ComponentV2
export struct BloodSugarTab {
  @Local latestData: BloodSugarData | null = null;
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT;
  @Local bloodSugarValue: number = 5.0;
  @Local measurementType: MeasurementType = MeasurementType.FASTING;
  @Local historyData: BloodSugarData[] = [];
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());
  private navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.navPathStack = getAppPathStack()
  }

  async loadLatestData() {
    const data = await this.dataService.getDataByType('bloodSugar');
    const list = data as BloodSugarData[];
    if (list.length > 0) {
      const latest = list[0];
      this.latestData = latest;
      this.bloodSugarValue = latest.value;
      this.measurementType = latest.measurementType;
      this.healthStatus = evaluateBloodSugarStatus(latest.value, latest.measurementType);
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('bloodSugar');
    this.historyData = data as BloodSugarData[];
  }

  async saveBloodSugarData() {
    if (this.bloodSugarValue <= 0) {
      promptAction.showToast({ message: '请输入有效的血糖值' });
      return;
    }
    const now = Date.now();
    const record: BloodSugarData = {
      id: `bloodSugar_${now}`,
      timestamp: now,
      value: this.bloodSugarValue,
      measurementType: this.measurementType,
      note: ''
    };
    const ok = await this.dataService.saveData(record);
    if (ok) {
      this.latestData = record;
      this.healthStatus = evaluateBloodSugarStatus(this.bloodSugarValue, this.measurementType);
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
          Text('血糖')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.bloodSugarValue.toString(),
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.bloodSugarValue = parseFloat(v || '0');
            }
          })
            .layoutWeight(1)
          Text('mmol/L')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 12 })

        Column() {
          Text('测量类型')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          Row({ space: 8 }) {
            Radio({ value: 'FASTING', group: 'bsType' })
              .checked(this.measurementType === MeasurementType.FASTING)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.FASTING;
                }
              })
            Text('空腹')
            Radio({ value: 'AFTER_MEAL', group: 'bsType' })
              .checked(this.measurementType === MeasurementType.AFTER_MEAL)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.AFTER_MEAL;
                }
              })
            Text('餐后')
            Radio({ value: 'RANDOM', group: 'bsType' })
              .checked(this.measurementType === MeasurementType.RANDOM)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.RANDOM;
                }
              })
            Text('随机')
          }
          .width('100%')
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row() {
        MButton({
          text: '保存记录',
          bgColor: '#4CAF50',
          onClickBlock: () => {
            this.saveBloodSugarData();
          }
        })
          .layoutWeight(1)
          .margin({ right: 6 })
        MButton({
          text: '查看历史',
          bgColor: '#2196F3',
          onClickBlock: () => {
            const data: Record<string, string> = {
              "data": "bloodSugar"
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
          Text('当前血糖:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.value} mmol/L`)
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
        Text('暂无血糖记录，先输入并保存')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
      }

      List() {
        ForEach(this.historyData, (item: BloodSugarData) => {
          ListItem() {
            Row() {
              Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(13)
                .fontColor('#666666')
              Text(`${item.value} mmol/L`)
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
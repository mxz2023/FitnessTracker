/**
 * 通用健康历史记录页面
 */

import {
  WeightData,
  BloodLipidData,
  BloodSugarData,
  UricAcidData,
  HealthData,
  BloodPressureData
} from '../model/HealthDataModel';
import { formatDate } from '../utils/HealthUtils';

type HealthDataType = 'weight' | 'bloodPressure' | 'bloodLipid' | 'bloodSugar' | 'uricAcid';


@ComponentV2
struct HealthHistoryPage {
  @Param @Require dataType: HealthDataType
  @Local private historyData: Array<WeightData | BloodLipidData | BloodSugarData | UricAcidData> = []

  private pathInfos?: NavPathStack

  aboutToAppear() {

  }

  @Builder
  renderWeightItem(item: WeightData) {
    Column() {
      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }

      Row() {
        Text(`${item.value} kg`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width('100%')
    .padding(8)
  }

  @Builder
  renderBloodLipidItem(item: BloodLipidData) {
    Column() {
      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }

      Row({ space: 8 }) {
        Text(`TC: ${item.totalCholesterol}`)
          .fontSize(14)
        Text(`TG: ${item.triglycerides}`)
          .fontSize(14)
      }

      Row({ space: 8 }) {
        Text(`HDL: ${item.hdlCholesterol}`)
          .fontSize(14)
        Text(`LDL: ${item.ldlCholesterol}`)
          .fontSize(14)
      }

      Text('单位: mmol/L')
        .fontSize(12)
        .fontColor('#999999')
    }
    .width('100%')
    .padding(8)
  }

  @Builder
  renderBloodSugarItem(item: BloodSugarData) {
    Column() {
      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }

      Row() {
        Text(`${item.value} mmol/L`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(`(${this.getMeasurementTypeText(item.measurementType)})`)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .padding(8)
  }

  @Builder
  renderUricAcidItem(item: UricAcidData) {
    Column() {
      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }

      Row() {
        Text(`${item.value} μmol/L`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }

      if (item.note) {
        Row() {
          Text(`备注: ${item.note}`)
            .fontSize(14)
            .fontColor('#666666')
        }
      }
    }
    .width('100%')
    .padding(8)
  }

  @Builder
  renderBloodPressureItem(item: BloodPressureData) {
    Row() {
      Column() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
        Text(`血压: ${item.systolic}/${item.diastolic} mmHg`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .margin({ top: 4 })
      }
      .layoutWeight(1)

      if (item.note && item.note !== '') {
        Text(item.note)
          .fontSize(12)
          .fontColor('#999999')
      }
    }
    .width('100%')
    .padding(12)
    .borderRadius(4)
    .backgroundColor('#FFFFFF')
    .margin({ bottom: 8 })
  }

  private getMeasurementTypeText(type: string): string {
    switch (type) {
      case 'FASTING':
        return '空腹';
      case 'AFTER_MEAL':
        return '餐后';
      case 'RANDOM':
        return '随机';
      default:
        return type;
    }
  }

  private getTitle(): string {
    switch (this.dataType) {
      case 'weight':
        return '体重';
      case 'bloodLipid':
        return '血脂';
      case 'bloodSugar':
        return '血糖';
      case 'bloodPressure':
        return '血压';
      case 'uricAcid':
        return '尿酸';
      default:
        return '健康';
    }
  }

  build() {
    NavDestination() {
      List() {
        ForEach(this.historyData, (item: HealthData) => {
          ListItem() {
            if (this.dataType == 'weight') {
              this.renderWeightItem(item as WeightData);
            } else if (this.dataType == 'bloodLipid') {
              this.renderBloodLipidItem(item as BloodLipidData);
            } else if (this.dataType == 'bloodSugar') {
              this.renderBloodSugarItem(item as BloodSugarData);
            } else if (this.dataType == 'uricAcid') {
              this.renderUricAcidItem(item as UricAcidData);
            } else if (this.dataType == 'bloodPressure') {
              this.renderBloodPressureItem(item as BloodPressureData);
            }
          }
          .borderRadius(4)
          .backgroundColor('#FFFFFF')
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .height('100%')
    }
    .title({
      main: "历史记录",
      sub: this.getTitle()
    })
    .width('100%')
    .height('100%')
    .onReady((ctx: NavDestinationContext) => {
      // NavDestinationContext获取当前所在的导航控制器
      this.pathInfos = ctx.pathStack;
    })
  }
}

@Builder
export function PageBuilder(_: string, param: Record<string, Object>) {
  HealthHistoryPage({
    dataType: param.data as HealthDataType
  });
}
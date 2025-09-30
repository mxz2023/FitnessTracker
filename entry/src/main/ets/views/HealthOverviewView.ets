/**
 * 健康数据概览页面
 * 基于 Figma 设计实现的健康指标卡片式布局
 */

import {
  HealthStatus,
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData,
  MeasurementType,
  Gender
} from '../model/HealthDataModel';
import { HealthStatusIndicator } from '../commonents/HealthStatusIndicator';
import {
  formatDate,
  evaluateWeightStatus,
  evaluateBloodPressureStatus,
  evaluateBloodSugarStatus,
  evaluateUricAcidStatus,
  evaluateBloodLipidStatus
} from '../utils/HealthUtils';

// 健康指标卡片数据接口
interface HealthCardData {
  title: string;
  value: string;
  status: HealthStatus;
  unit?: string;
  date?: string;
}

@ComponentV2
export struct HealthOverviewView {
  @Local private nHeight: number = 175; // 身高，单位cm
  @Local private weight: number = 70; // 体重，单位kg
  @Local private bloodSugar: number = 5.2; // 血糖，单位mmol/L
  @Local private bloodPressureSystolic: number = 120; // 收缩压
  @Local private bloodPressureDiastolic: number = 80; // 舒张压
  @Local private uricAcid: number = 350; // 尿酸，单位μmol/L
  @Local private totalCholesterol: number = 4.5; // 总胆固醇，单位mmol/L

  // 获取健康卡片数据
  private getHealthCardData(): HealthCardData[] {
    const currentDate = formatDate(Date.now(), 'MM-DD');

    return [
      {
        title: '体重',
        value: this.weight.toString(),
        unit: 'kg',
        status: evaluateWeightStatus(this.weight, this.nHeight / 100),
        date: currentDate
      },
      {
        title: '血糖',
        value: this.bloodSugar.toString(),
        unit: 'mmol/L',
        status: evaluateBloodSugarStatus(this.bloodSugar, MeasurementType.FASTING), // 0 表示空腹
        date: currentDate
      },
      {
        title: '血脂',
        value: this.totalCholesterol.toString(),
        unit: 'mmol/L',
        status: this.totalCholesterol <= 5.2 ? HealthStatus.EXCELLENT :
          this.totalCholesterol <= 5.7 ? HealthStatus.GOOD :
            this.totalCholesterol <= 6.5 ? HealthStatus.MODERATE : HealthStatus.POOR,
        date: currentDate
      },
      {
        title: '尿酸',
        value: this.uricAcid.toString(),
        unit: 'μmol/L',
        status: evaluateUricAcidStatus(this.uricAcid, Gender.MALE), // 0 表示男性
        date: currentDate
      },
      {
        title: '血压',
        value: `${this.bloodPressureSystolic}/${this.bloodPressureDiastolic}`,
        unit: 'mmHg',
        status: this.bloodPressureSystolic <= 120 && this.bloodPressureDiastolic <= 80 ? HealthStatus.EXCELLENT :
          this.bloodPressureSystolic <= 130 && this.bloodPressureDiastolic <= 85 ? HealthStatus.GOOD :
            this.bloodPressureSystolic <= 140 && this.bloodPressureDiastolic <= 90 ? HealthStatus.MODERATE :
              HealthStatus.POOR,
        date: currentDate
      }
    ];
  }

  // 健康指标卡片组件
  @Builder
  HealthCard(cardData: HealthCardData) {
    Column() {
      // 卡片头部 - 标题和状态指示器
      Row() {
        Text(cardData.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        Blank()

        HealthStatusIndicator({
          status: cardData.status,
          showText: true,
          indicatorSize: 16
        })
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 数值显示
      Row({ space: 4 }) {
        Text(cardData.value)
          .lineHeight(30)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1a1a1a')
          .alignSelf(ItemAlign.End)

        if (cardData.unit) {
          Text(cardData.unit)
            .lineHeight(30)
            .fontSize(14)
            .fontColor('#666666')
            .alignSelf(ItemAlign.End)
            .margin({ bottom: 2 })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: 8 })

      Row() {
        // 日期信息
        if (cardData.date) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.time_inerval'))
              .fontSize(12)
              .fontColor(['#999999'])

            Text(`${cardData.date}`)
              .fontSize(12)
              .fontColor('#999999')
              .alignSelf(ItemAlign.Start)
          }
        }

        SymbolGlyph($r('sys.symbol.plus_circle_fill'))
          .fontSize(18)
          .fontColor(['#f6685d'])
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

    }
    .width('100%')
    .height(120)
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 身高体重信息卡片
  @Builder
  BasicInfoCard() {
    Column() {
      Row() {
        Text('叶记健康')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')

        SymbolGlyph($r('sys.symbol.doc_plaintext_and_pencil'))
          .fontSize(24)
          .fontColor([$r('app.color.icon_secondary')])
      }
      .width('100%')
      .margin({ bottom: 16 })
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Row({ space: 12 }) {
            Text('男')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')

            Text('40岁')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
          }
          .layoutWeight(2)

          Row({ space: 4 }) {
            Text(this.nHeight.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1a1a1a')

            Text('cm')
              .fontSize(12)
              .fontColor('#666666')
              .alignSelf(ItemAlign.End)
              .margin({ bottom: 2 })
          }
          .layoutWeight(1)
          .alignItems(VerticalAlign.Bottom)

          Blank().layoutWeight(1)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  build() {
    Column() {
      // 滚动容器
      Scroll() {
        Column({ space: 16 }) {
          // 基本信息卡片
          this.BasicInfoCard()

          // 健康指标网格
          Grid() {
            ForEach(this.getHealthCardData(), (cardData: HealthCardData, index: number) => {
              GridItem() {
                this.HealthCard(cardData)
              }
            })
          }
          .columnsTemplate('1fr 1fr')
          .rowsGap(16)
          .columnsGap(16)
          .width('100%')
        }
        .height('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
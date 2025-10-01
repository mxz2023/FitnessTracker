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
  evaluateBloodLipidStatus,
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
  @Local private nAge: number = 0; // 年龄
  @Local private nGender: Gender = Gender.UNKNOWN;
  @Local private nHeight: number = 0; // 身高，单位:cm
  @Local private nWeight: number = 0; // 体重，单位:g
  @Local private nBloodSugar: number = 0; // 血糖，单位:mmol/L
  @Local private nBloodPressureSystolic: number = 0; // 收缩压
  @Local private nBloodPressureDiastolic: number = 0; // 舒张压
  @Local private nUricAcid: number = 0; // 尿酸，单位:μmol/L
  @Local private nTotalCholesterol: number = 0; // 总胆固醇，单位:mmol/L

  aboutToAppear(): void {


  }

  // 将数值转换为显示字符串，0 则显示 N/A
  private toDisplay(value: number): string {
    return value !== 0 ? `${value}` : 'N/A';
  }

  // 判断数值是否有效（非 0）
  private isValid(value: number): boolean {
    return value !== 0;
  }

  // 血压专用显示与校验
  private isValidBP(systolic: number, diastolic: number): boolean {
    return systolic !== 0 && diastolic !== 0;
  }

  private toDisplayBP(systolic: number, diastolic: number): string {
    return this.isValidBP(systolic, diastolic) ? `${systolic}/${diastolic}` : 'N/A';
  }

  // 获取健康卡片数据
  private getHealthCardData(): HealthCardData[] {
    const currentDate = formatDate(Date.now(), 'MM-DD');

    return [
      {
        title: '体重',
        value: this.toDisplay(this.nWeight),
        unit: 'kg',
        status: this.isValid(this.nWeight) ? evaluateWeightStatus(this.nWeight, this.nHeight / 100) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血糖',
        value: this.toDisplay(this.nBloodSugar),
        unit: 'mmol/L',
        status: this.isValid(this.nBloodSugar) ? evaluateBloodSugarStatus(this.nBloodSugar, MeasurementType.FASTING) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血脂',
        value: this.toDisplay(this.nTotalCholesterol),
        unit: 'mmol/L',
        status: this.isValid(this.nTotalCholesterol) ? this.nTotalCholesterol <= 5.2 ? HealthStatus.EXCELLENT :
          this.nTotalCholesterol <= 5.7 ? HealthStatus.GOOD :
            this.nTotalCholesterol <= 6.5 ? HealthStatus.MODERATE : HealthStatus.POOR : HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '尿酸',
        value: this.toDisplay(this.nUricAcid),
        unit: 'μmol/L',
        status: this.isValid(this.nUricAcid) ? evaluateUricAcidStatus(this.nUricAcid, Gender.MALE) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血压',
        value: this.toDisplayBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic),
        unit: 'mmHg',
        status: this.isValidBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic) ?
          this.nBloodPressureSystolic <= 120 && this.nBloodPressureDiastolic <= 80 ? HealthStatus.EXCELLENT :
            this.nBloodPressureSystolic <= 130 && this.nBloodPressureDiastolic <= 85 ? HealthStatus.GOOD :
              this.nBloodPressureSystolic <= 140 && this.nBloodPressureDiastolic <= 90 ? HealthStatus.MODERATE :
                HealthStatus.POOR : HealthStatus.UNKNOWN,
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
          .fontSize($r('app.float.font_size_medium'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        Blank()

        HealthStatusIndicator({
          status: cardData.status,
          showText: true,
        })
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })

      // 数值显示
      Row({ space: 4 }) {
        Text(cardData.value)
          .lineHeight(30)
          .fontSize($r('app.float.font_size_nav_title'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_333'))
          .alignSelf(ItemAlign.End)

        if (cardData.unit) {
          Text(cardData.unit)
            .lineHeight(30)
            .fontSize($r('app.float.font_size_normal'))
            .fontColor($r('app.color.text_666'))
            .alignSelf(ItemAlign.End)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .margin({ bottom: $r('app.integer.view_margin') })

      Row() {
        // 日期信息
        if (cardData.date) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.time_inerval'))
              .fontSize($r('app.float.font_size_normal'))
              .fontColor([$r('app.color.text_999')])

            Text(`${cardData.date}`)
              .fontSize($r('app.float.font_size_normal'))
              .fontColor($r('app.color.text_999'))
              .alignSelf(ItemAlign.Start)
          }
        }

        Column() {
          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize(18)
            .fontColor([$r('app.color.red')])
        }
        // .backgroundColor("#00FF00")
        .width(30)
        .height(30)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(120)
    .alignItems(HorizontalAlign.Start)
    .padding($r('app.integer.view_padding'))
    .backgroundColor($r('app.color.white'))
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
          .fontSize($r('app.float.font_size_large_title'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        SymbolGlyph($r('sys.symbol.doc_plaintext_and_pencil'))
          .fontSize(24)
          .fontColor([$r('app.color.text_666')])
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin')  })
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Row({ space: $r('app.integer.view_space') }) {
            Text(this.nGender)
              .fontSize($r('app.float.font_size_large'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_333'))

            Text(this.isValid(this.nAge) ? `${this.nAge}` : 'N/A')
              .fontSize($r('app.float.font_size_large'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_333'))
          }
          .layoutWeight(2)

          Row({ space: $r('app.integer.view_space') }) {
            Text(this.isValid(this.nHeight) ? `${this.nHeight}` : 'N/A')
              .fontSize($r('app.float.font_size_large'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_333'))

            Text('cm')
              .fontSize($r('app.float.font_size_normal'))
              .fontColor($r('app.color.text_666'))
              .alignSelf(ItemAlign.End)
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
    .padding($r('app.integer.view_padding'))
    .backgroundColor($r('app.color.white'))
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
        Column({ space: $r('app.integer.view_space') }) {
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
          .rowsGap($r('app.integer.view_space'))
          .columnsGap($r('app.integer.view_space'))
          .width('100%')
        }
        .height('100%')
        .padding($r('app.integer.view_padding'))
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.view_background_color'))
  }
}
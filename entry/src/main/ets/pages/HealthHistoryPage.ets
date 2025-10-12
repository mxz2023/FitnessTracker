/**
 * 通用健康历史记录页面
 */

import { MNavigationTitle, NavigationTitleBuilder } from '../components/MNavigationTitle';
import {
  WeightData,
  BloodLipidData,
  BloodSugarData,
  UricAcidData,
  HealthData,
  BloodPressureData
} from '../models/HealthDataModel';
import { ChartOptions, XAxis, YAxis } from '../thirds/EChart/EChartOption';
import { MChart } from '../thirds/MChart';
import { formatDate } from '../utils/HealthUtils';
import { getAppPathStack } from '../utils/PathStackUtils';
import { StorageUtils } from '../utils/StorageUtils';

interface ChartDataItem {
  x: string;
  y: number;
  y2?: number;
  y3?: number;
}

type HealthDataType = 'weight' | 'bloodPressure' | 'bloodLipid' | 'bloodSugar' | 'uricAcid';


@ComponentV2
struct HealthHistoryPage {
  @Param @Require dataType: HealthDataType
  @Local private historyData: Array<WeightData | BloodLipidData | BloodSugarData | UricAcidData | BloodPressureData> =
    []
  @Local private isLoading: boolean = true;
  private storageUtils: StorageUtils = StorageUtils.getInstance(this.getUIContext().getHostContext());
  private pathInfos?: NavPathStack
  @Local options: ChartOptions = {};

  aboutToAppear() {
    this.loadHistoryData();
  }

  /**
   * 加载历史数据
   */
  async loadHistoryData() {
    this.isLoading = true;
    try {
      const data = await this.storageUtils.getHealthDataByType(this.dataType);

      // 根据数据类型进行类型转换
      switch (this.dataType) {
        case 'weight':
          this.historyData = data as WeightData[];
          break;
        case 'bloodPressure':
          this.historyData = data as BloodPressureData[];
          break;
        case 'bloodSugar':
          this.historyData = data as BloodSugarData[];
          break;
        case 'uricAcid':
          this.historyData = data as UricAcidData[];
          break;
        case 'bloodLipid':
          this.historyData = data as BloodLipidData[];
          break;
      }

      // 按时间降序排序，最新的记录显示在前面
      this.historyData.sort((a, b) => b.timestamp - a.timestamp);

      // 生成图表数据
      this.generateChartData();
    } catch (error) {
      console.error(`加载${this.getTitle()}历史数据失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 生成图表数据
   */
  generateChartData() {
    if (this.dataType === 'weight' || this.dataType === 'bloodSugar' || this.dataType === 'uricAcid') {
      this.options = {
        xAxis: {
          data: ['A', 'B', 'C', 'D', 'E']
        } as XAxis,
        yAxis: {} as YAxis,
        series: [
          {
            data: this.historyData.map(item => (item as WeightData | BloodSugarData | UricAcidData).value),
            type: 'line',
            smooth: true
          }
        ]
      };
    } else if (this.dataType === 'bloodLipid') {
      this.options = {
        xAxis: {
          data: ['A', 'B', 'C', 'D', 'E']
        } as XAxis,
        yAxis: {} as YAxis,
        series: [
          {
            data: this.historyData.map(item => (item as BloodLipidData).totalCholesterol),
            type: 'line',
            smooth: true,
            stack: 'x'
          },
          {
            data: this.historyData.map(item => (item as BloodLipidData).hdlCholesterol),
            type: 'line',
            smooth: true,
            stack: 'x'
          },
          {
            data: this.historyData.map(item => (item as BloodLipidData).ldlCholesterol),
            type: 'line',
            smooth: true,
            stack: 'x'
          }
        ]
      };
    } else if (this.dataType === 'bloodPressure') {
      this.options = {
        xAxis: {
          data: ['A', 'B', 'C', 'D', 'E']
        } as XAxis,
        yAxis: {} as YAxis,
        series: [
          {
            data: this.historyData.map(item => (item as BloodPressureData).systolic),
            type: 'line',
            smooth: true,
            stack: 'x'
          },
          {
            data: this.historyData.map(item => (item as BloodPressureData).diastolic),
            type: 'line',
            smooth: true,
            stack: 'x'
          }
        ]
      };
    }
  }

  @Builder
  renderWeightItem(item: WeightData) {
    Column({ space: $r('app.integer.view_space') }) {
      Row() {
        Text(`${item.value} kg`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        if (item.note && item.note !== '') {
          Text(`备注: ${item.note}`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }

      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  renderBloodSugarItem(item: BloodSugarData) {
    Column({ space: $r('app.integer.view_space') }) {
      Row() {
        Text(`${item.value} mmol/L`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        Text(`(${this.getMeasurementTypeText(item.measurementType)})`)
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8 })

        if (item.note && item.note !== '') {
          Text(`备注: ${item.note}`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }

      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  renderUricAcidItem(item: UricAcidData) {
    Column({ space: $r('app.integer.view_space') }) {
      Row() {
        Text(`${item.value} μmol/L`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        if (item.note && item.note !== '') {
          Text(`备注: ${item.note}`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }

      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  renderBloodPressureItem(item: BloodPressureData) {
    Column({ space: $r('app.integer.view_space') }) {
      Row() {
        Text(`${item.systolic}/${item.diastolic} mmHg`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)

        if (item.note && item.note !== '') {
          Row() {
            Text(`备注: ${item.note}`)
              .fontSize(12)
              .fontColor('#999999')
          }
        }
      }

      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  renderBloodLipidItem(item: BloodLipidData) {
    Column({ space: $r('app.integer.view_space') }) {
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

      if (item.note && item.note !== '') {
        Row() {
          Text(`备注: ${item.note}`)
            .fontSize(12)
            .fontColor('#999999')
        }
      }

      Row() {
        Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
          .fontSize(14)
          .fontColor('#666666')
      }
    }
    .width('100%')
    .padding(8)
    .alignItems(HorizontalAlign.Start)
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
      case 'bloodSugar':
        return '血糖';
      case 'uricAcid':
        return '尿酸';
      case 'bloodPressure':
        return '血压';
      case 'bloodLipid':
        return '血脂';
      default:
        return '健康';
    }
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#2196F3')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else if (this.historyData.length === 0) {
          Column() {
            Text(`暂无${this.getTitle()}历史记录`)
              .fontSize(16)
              .fontColor('#999999')
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column() {
            MChart({
              options: this.options
            })
          }
          .width('100%')
          .height('200')

          List() {
            ForEach(this.historyData, (item: HealthData) => {
              ListItem() {
                if (this.dataType === 'weight') {
                  this.renderWeightItem(item as WeightData);
                } else if (this.dataType === 'bloodLipid') {
                  this.renderBloodLipidItem(item as BloodLipidData);
                } else if (this.dataType === 'bloodSugar') {
                  this.renderBloodSugarItem(item as BloodSugarData);
                } else if (this.dataType === 'uricAcid') {
                  this.renderUricAcidItem(item as UricAcidData);
                } else if (this.dataType === 'bloodPressure') {
                  this.renderBloodPressureItem(item as BloodPressureData);
                }
              }
              .borderRadius(4)
              .backgroundColor('#FFFFFF')
              .margin({ bottom: 8 })
            })
          }
          .width('100%')
          .layoutWeight(1)
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8
          })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    // .title({
    //   main: "历史记录",
    //   sub: this.getTitle()
    // })
    .title({
      builder: NavigationTitleBuilder(getAppPathStack(), {
        title: {
          text: "历史记录"
        },
        subTitle: {
          text: this.getTitle()
        },
        height: 45
      }),
      height: 58
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
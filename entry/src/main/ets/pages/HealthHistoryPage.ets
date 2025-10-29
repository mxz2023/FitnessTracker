/**
 * 通用健康历史记录页面
 */

import { it } from '@ohos/hypium';
import { AppConstants, ColorConstants, HealthDataType } from '../common/CommonDefine';
import { MButton } from '../components/MButton';
import { MIcon } from '../components/MIcon';
import { NavigationTitleBuilder } from '../components/MNavigationTitle';
import {
  WeightData,
  BloodLipidData,
  BloodSugarData,
  UricAcidData,
  HealthData,
  BloodPressureData,
} from '../models/HealthDataModel';
import { ChartOptions, XAxis, YAxis } from '../thirds/EChart/EChartOption';
import { MChart } from '../thirds/MChart';
import { formatDate, getHealthStatusColor } from '../utils/HealthUtils';
import { getAppPathStack } from '../utils/PathStackUtils';
import { StorageUtils } from '../utils/StorageUtils';

interface ChartDataItem {
  x: string;
  y: number;
  y2?: number;
  y3?: number;
}

@ComponentV2
struct HealthHistoryPage {
  @Param @Require dataType: HealthDataType
  @Local private historyData: Array<WeightData | BloodLipidData | BloodSugarData | UricAcidData | BloodPressureData> =
    []
  @Local private isLoading: boolean = true;
  @Local options: ChartOptions = {};
  private storageUtils: StorageUtils = StorageUtils.getInstance(this.getUIContext().getHostContext());

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
   * 生成图表数据（图表用时间升序；列表维持降序）
   */
  generateChartData() {
    const asc = [...this.historyData].sort((a, b) => a.timestamp - b.timestamp);
    const x = asc.map(i => formatDate(i.timestamp, 'MM-DD HH:mm'));

    if (this.dataType === 'weight') {
      this.options = {
        xAxis: { type: 'category', data: x } as XAxis,
        yAxis: { type: 'value', name: 'kg' } as YAxis,
        tooltip: { trigger: 'axis' },
        legend: { data: ['体重'] },
        series: [
          {
            name: '体重',
            data: asc.map(i => (i as WeightData).value),
            type: 'line',
            smooth: true
          }
        ]
      };
    } else if (this.dataType === 'bloodSugar') {
      this.options = {
        xAxis: { type: 'category', data: x } as XAxis,
        yAxis: { type: 'value', name: 'mmol/L' } as YAxis,
        tooltip: { trigger: 'axis' },
        legend: { data: ['血糖'] },
        series: [
          {
            name: '血糖',
            data: asc.map(i => (i as BloodSugarData).value),
            type: 'line',
            smooth: true
          }
        ]
      };
    } else if (this.dataType === 'uricAcid') {
      this.options = {
        xAxis: { type: 'category', data: x } as XAxis,
        yAxis: { type: 'value', name: 'μmol/L' } as YAxis,
        tooltip: { trigger: 'axis' },
        legend: { data: ['尿酸'] },
        series: [
          {
            name: '尿酸',
            data: asc.map(i => (i as UricAcidData).value),
            type: 'line',
            smooth: true
          }
        ]
      };
    } else if (this.dataType === 'bloodPressure') {
      this.options = {
        xAxis: { type: 'category', data: x } as XAxis,
        yAxis: { type: 'value', name: 'mmHg' } as YAxis,
        tooltip: { trigger: 'axis' },
        legend: { data: ['收缩压', '舒张压'] },
        series: [
          {
            name: '收缩压',
            data: asc.map(i => (i as BloodPressureData).systolic),
            type: 'line',
            smooth: true
          },
          {
            name: '舒张压',
            data: asc.map(i => (i as BloodPressureData).diastolic),
            type: 'line',
            smooth: true
          }
        ]
      };
    } else if (this.dataType === 'bloodLipid') {
      const d = asc as BloodLipidData[];
      this.options = {
        xAxis: { type: 'category', data: x } as XAxis,
        yAxis: { type: 'value', name: 'mmol/L' } as YAxis,
        tooltip: { trigger: 'axis' },
        legend: { data: ['TC', 'HDL', 'LDL', 'TG'] },
        series: [
          {
            name: 'TC',
            data: d.map(i => i.totalCholesterol),
            type: 'line',
            smooth: true
          },
          {
            name: 'HDL',
            data: d.map(i => i.hdlCholesterol),
            type: 'line',
            smooth: true
          },
          {
            name: 'LDL',
            data: d.map(i => i.ldlCholesterol),
            type: 'line',
            smooth: true
          },
          {
            name: 'TG',
            data: d.map(i => i.triglycerides),
            type: 'line',
            smooth: true
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
      RelativeContainer() {
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#2196F3')
          }
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Bottom },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .justifyContent(FlexAlign.Center)
        } else if (this.historyData.length === 0) {
          Column() {
            Image($r('app.media.no_data'))
              .width('80%')
              .constraintSize({
                maxWidth: 300
              })
              .aspectRatio(1)
            MButton({
              text: "去添加一条记录",
              onClickBlock: () => {
                getAppPathStack().pop(this.dataType, true)
              }
            }).width('50%')
          }
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .justifyContent(FlexAlign.Center)
        } else {
          Row() {
            Text("常识").onClick(() => {
              const data: Record<string, string> = {
                "data": this.dataType
              }
              getAppPathStack().pushPathByName("knowledge", data, () => {

              })
            })
            MIcon({
              iconName: "about",
              iconSize: 16
            }).margin({
              left: 4
            })
          }
          .padding(AppConstants.VIEW_PADDING)
          .id("__top__")
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .justifyContent(FlexAlign.End)

          Column() {
            MChart({
              options: this.options
            })
          }
          .height(300)
          .id("__Chart__")
          .alignRules({
            top: { anchor: '__top__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })

          List() {
            ForEach(this.historyData, (item: HealthData) => {
              ListItem() {
                Row() {
                  Image($r('app.media.bgImg')).margin({
                    right: 8
                  }).width(48).height(48)
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
                }.padding({
                  left: 16,
                })
              }
              .borderRadius(4)
              .backgroundColor('#FFFFFF')
              .margin({ bottom: 8 })
            })
          }
          .id("__List__")
          .alignRules({
            top: { anchor: '__Chart__', align: VerticalAlign.Bottom },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
          })
          .padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8
          })

          MButton({
            text: "去添加一条记录",
            onClickBlock: () => {
              getAppPathStack().pop(this.dataType, true)
            }
          })
            .margin({
              bottom: 16
            })
            .width('50%')
            .alignRules({
              bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
    .title({
      builder: NavigationTitleBuilder(getAppPathStack(), {
        title: {
          text: "历史记录",
          fontColor: "#000000"
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

    })
  }
}

@Builder
export function PageBuilder(_: string, param: Record<string, Object>) {
  HealthHistoryPage({
    dataType: param.data as HealthDataType
  });
}
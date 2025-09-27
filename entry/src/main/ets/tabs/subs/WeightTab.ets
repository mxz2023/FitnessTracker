/**
 * 体重Tab组件
 */
import { promptAction } from '@kit.ArkUI';

import { WeightData, HealthStatus } from '../../model/HealthDataModel';
import { HealthDataServiceImpl } from '../../model/HealthDataServiceImpl';
import { evaluateWeightStatus } from '../../utils/HealthUtils';
import { HealthStatusIndicator } from '../../commonents/HealthStatusIndicator';
import { MTextInput } from '../../commonui/MTextInput';
import { MButton } from '../../commonui/MButton';
import { getAppPathStack } from '../../utils/PathStackUtils';
import { showToast } from '../../utils/ToastUtils';

@ComponentV2
export struct WeightTab {
  @Local weightInputText: string = '80';
  @Local heightInputText: string = '1.85';
  @Local historyData: WeightData[] = [];
  @Local isLoading: boolean = false;
  @Local latestData: WeightData | null = null;
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT;
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());
  private navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.navPathStack = getAppPathStack()
  }

  async loadLatestData() {
    this.isLoading = true;
    try {
      const data = await this.dataService.getDataByType('weight');
      const list = data as WeightData[];
      if (list.length > 0) {
        const latest = list[0];
        this.latestData = latest;
        this.weightInputText = latest.value.toFixed(2);
        this.healthStatus = evaluateWeightStatus(latest.value, Number(this.weightInputText));
      }
    } finally {
      this.isLoading = false;
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('weight');
    // 时间升序，便于渲染与滚动定位
    this.historyData = (data as WeightData[]).sort((a, b) => a.timestamp - b.timestamp);
  }

  async saveWeightData() {
    if (Number(this.weightInputText) <= 0) {
      promptAction.showToast({ message: '请输入有效的体重值' });
      return;
    }
    const ok = await this.saveAveragedToday();
    if (ok) {
      this.healthStatus = evaluateWeightStatus(Number(this.weightInputText), Number(this.heightInputText));
      await this.loadHistoryData();
      showToast(this.getUIContext(), "保存成功")
    } else {
      showToast(this.getUIContext(), "保存失败")
    }
  }

  // 当天多次记录时，做平均并只保留一条记录
  private async saveAveragedToday(): Promise<boolean> {
    const now = Date.now();
    // 计算本地当天起止时间戳
    const d = new Date(now);
    const dayStart = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0).getTime();
    const dayEnd = dayStart + 24 * 60 * 60 * 1000 - 1;

    const all = await this.dataService.getDataByType('weight');
    const todayList = (all as WeightData[]).filter(item => item.timestamp >= dayStart && item.timestamp <= dayEnd);

    let sum = Number(this.weightInputText);
    let count = 1;
    for (const it of todayList) {
      sum += it.value;
      count += 1;
    }
    const avg = sum / count;

    // 删除当天已有记录
    for (const it of todayList) {
      await this.dataService.deleteData(it.id);
    }

    // 保存一条平均值记录
    const record = new WeightData();
    record.id = `weight_${now}`;
    record.timestamp = now;
    record.value = avg;
    record.note = '';

    const ok = await this.dataService.saveData(record);
    if (ok) {
      this.latestData = record;
    }
    return ok;
  }

  build() {
    Column() {
      // 输入区
      Column() {
        Row({ space: 12 }) {
          Text('身高')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.heightInputText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.heightInputText = v
            }
          })
            .layoutWeight(1)
          Text('m')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('体重')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.weightInputText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.weightInputText = v
            }
          })
            .layoutWeight(1)
          Text('kg')
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
          onClickBlock: () => {
            this.saveWeightData();
          }
        })
          .layoutWeight(1)
          .margin({ right: 6 })
        MButton({
          text: '查看历史',
          bgColor: '#2196F3',
          onClickBlock: () => {
            const data: Record<string, string> = {
              "data": "weight"
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
          Text(`${(this.latestData.value / (Number(this.heightInputText) * Number(this.heightInputText))).toFixed(1)}`)
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
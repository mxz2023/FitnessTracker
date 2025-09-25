/**
 * 血脂Tab组件（简化版）
 */
import { promptAction } from '@kit.ArkUI';

import { BloodLipidData, HealthStatus } from '../../model/HealthDataModel';
import { HealthDataServiceImpl } from '../../model/HealthDataServiceImpl';
import { evaluateBloodLipidStatus, formatDate } from '../../utils/HealthUtils';
import { HealthStatusIndicator } from '../../commonents/HealthStatusIndicator';
import { MTextInput } from '../../commonui/MTextInput';
import { MButton } from '../../commonui/MButton';
import { getAppPathStack } from '../../utils/PathStackUtils';

@ComponentV2
export struct BloodLipidTab {
  @Local private totalCholesterolText: string = ''
  @Local private triglyceridesText: string = ''
  @Local private hdlCholesterolText: string = ''
  @Local private ldlCholesterolText: string = ''
  @Local private historyData: BloodLipidData[] = []
  @Local private latestData: BloodLipidData | null = null
  @Local private healthStatus: HealthStatus = HealthStatus.EXCELLENT
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext())
  private navPathStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    this.navPathStack = getAppPathStack()
  }

  async loadLatestData() {
    const data = await this.dataService.getDataByType('bloodLipid')
    const list = data as BloodLipidData[]
    if (list.length > 0) {
      const latest = list[0]
      this.latestData = latest
      this.healthStatus = evaluateBloodLipidStatus(latest)
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('bloodLipid')
    this.historyData = data as BloodLipidData[]
  }

  async saveBloodLipidData() {
    if (
      this.totalCholesterolText.length <= 0 ||
        this.triglyceridesText.length <= 0 ||
        this.hdlCholesterolText.length <= 0 ||
        this.ldlCholesterolText.length <= 0
    ) {
      promptAction.showToast({ message: '请输入有效的血脂值' })
      return
    }
    const now = Date.now()
    const record: BloodLipidData = {
      id: `bloodLipid_${now}`,
      timestamp: now,
      totalCholesterol: Number(this.totalCholesterolText),
      triglycerides: Number(this.triglyceridesText),
      hdlCholesterol: Number(this.hdlCholesterolText),
      ldlCholesterol: Number(this.ldlCholesterolText),
      note: ''
    }
    const ok = await this.dataService.saveData(record)
    if (ok) {
      this.latestData = record
      this.healthStatus = evaluateBloodLipidStatus(record)
      await this.loadHistoryData()
      promptAction.showToast({ message: '保存成功' })
    } else {
      promptAction.showToast({ message: '保存失败' })
    }
  }

  build() {
    Column() {
      // 输入区
      Column() {
        Row({ space: 12 }) {
          Text('TC')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.totalCholesterolText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.totalCholesterolText = v;
            }
          })
            .layoutWeight(1)
          Text('mmol/L')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('TG')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.triglyceridesText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.triglyceridesText = v;
            }
          })
            .layoutWeight(1)
          Text('mmol/L')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 8 })

        Row({ space: 12 }) {
          Text('HDL-C')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.hdlCholesterolText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.hdlCholesterolText = v;
            }
          })
            .layoutWeight(1)
          Text('mmol/L')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 8 })

        Row({ space: 12 }) {
          Text('LDL-C')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.ldlCholesterolText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.ldlCholesterolText = v;
            }
          })
            .layoutWeight(1)
          Text('mmol/L')
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
            this.saveBloodLipidData();
          }
        })
          .layoutWeight(1)
          .margin({ right: 6 })
        MButton({
          text: '查看历史',
          bgColor: '#2196F3',
          onClickBlock: () => {
            const data: Record<string, string> = {
              "data": "bloodLipid"
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

      // 最新与状态
      if (this.latestData) {
        Row() {
          Text('TC:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.totalCholesterol} mmol/L`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Row() {
          Text('TG:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.triglycerides} mmol/L`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Row() {
          Text('HDL-C:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.hdlCholesterol} mmol/L`)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })

        Row() {
          Text('LDL-C:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestData.ldlCholesterol} mmol/L`)
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
        Text('暂无血脂记录，先输入并保存')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
      }

      // 历史列表
      List() {
        ForEach(this.historyData, (item: BloodLipidData) => {
          ListItem() {
            Row() {
              Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(13)
                .fontColor('#666666')
              Text(`TC:${item.totalCholesterol}  TG:${item.triglycerides}  HDL:${item.hdlCholesterol}  LDL:${item.ldlCholesterol}`)
                .fontSize(14)
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
      this.loadLatestData()
      this.loadHistoryData()
    })
  }
}
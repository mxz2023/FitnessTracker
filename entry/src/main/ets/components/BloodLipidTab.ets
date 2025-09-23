/**
 * 血脂Tab组件（简化版）
 */

import { BloodLipidData, HealthStatus } from '../model/HealthDataModel';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';
import { evaluateBloodLipidStatus, formatDate } from '../utils/HealthUtils';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { promptAction } from '@kit.ArkUI';

@Component
export struct BloodLipidTab {
  @State private totalCholesterol: number = 0
  @State private triglycerides: number = 0
  @State private hdlCholesterol: number = 0
  @State private ldlCholesterol: number = 0
  @State private historyData: BloodLipidData[] = []
  @State private latestData: BloodLipidData | null = null
  @State private healthStatus: HealthStatus = HealthStatus.EXCELLENT

  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext())

  async loadLatestData() {
    const data = await this.dataService.getDataByType('bloodLipid')
    const list = data as BloodLipidData[]
    if (list.length > 0) {
      const latest = list[0]
      this.latestData = latest
      this.totalCholesterol = latest.totalCholesterol
      this.triglycerides = latest.triglycerides
      this.hdlCholesterol = latest.hdlCholesterol
      this.ldlCholesterol = latest.ldlCholesterol
      this.healthStatus = evaluateBloodLipidStatus(latest)
    }
  }

  async loadHistoryData() {
    const data = await this.dataService.getDataByType('bloodLipid')
    this.historyData = data as BloodLipidData[]
  }

  async saveBloodLipidData() {
    if (
      this.totalCholesterol <= 0 ||
      this.triglycerides <= 0 ||
      this.hdlCholesterol <= 0 ||
      this.ldlCholesterol <= 0
    ) {
      promptAction.showToast({ message: '请输入有效的血脂值' })
      return
    }
    const now = Date.now()
    const record: BloodLipidData = {
      id: `bloodLipid_${now}`,
      timestamp: now,
      totalCholesterol: this.totalCholesterol,
      triglycerides: this.triglycerides,
      hdlCholesterol: this.hdlCholesterol,
      ldlCholesterol: this.ldlCholesterol,
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
          TextInput({ text: this.totalCholesterol.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.totalCholesterol = parseFloat(v) })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('TG')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.triglycerides.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.triglycerides = parseFloat(v) })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })

        Row({ space: 12 }) {
          Text('HDL-C')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.hdlCholesterol.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.hdlCholesterol = parseFloat(v) })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })

        Row({ space: 12 }) {
          Text('LDL-C')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.ldlCholesterol.toString() })
            .type(InputType.Number)
            .onChange((v: string) => { this.ldlCholesterol = parseFloat(v) })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('保存记录')
          .onClick(() => { this.saveBloodLipidData() })
          .backgroundColor('#4CAF50')
          .width('45%')
        Button('刷新历史')
          .onClick(() => { this.loadHistoryData() })
          .backgroundColor('#2196F3')
          .width('45%')
      }
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
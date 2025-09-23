/**
 * 尿酸指标Tab组件
 */

import { UricAcidData, HealthStatus, Gender } from '../model/HealthDataModel';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';
import { evaluateUricAcidStatus, formatDate } from '../utils/HealthUtils';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { promptAction } from '@kit.ArkUI';
// 移除不存在的 LineChart 依赖与重复类型声明

@Component
export struct UricAcidTab {
  @State private records: UricAcidData[] = []
  @State private latestRecord: UricAcidData | null = null
  @State private healthStatus: HealthStatus = HealthStatus.EXCELLENT
  @State private inputValue: string = ''
  @State private inputNote: string = ''

  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext())

  async loadData() {
    const data = await this.dataService.getDataByType('uricAcid')
    this.records = data as UricAcidData[]
    if (this.records.length > 0) {
      this.latestRecord = this.records[0]
      this.healthStatus = evaluateUricAcidStatus(this.latestRecord.value)
    }
  }

  async saveData() {
    const value = parseFloat(this.inputValue)
    if (isNaN(value) || value <= 0) {
      promptAction.showToast({ message: '请输入有效的尿酸值' })
      return
    }
    const record: UricAcidData = {
      id: `uricAcid_${Date.now()}`,
      timestamp: Date.now(),
      value: value,
      gender: Gender.MALE,
      note: this.inputNote || ''
    }
    const ok = await this.dataService.saveData(record)
    if (ok) {
      this.inputValue = ''
      this.inputNote = ''
      await this.loadData()
      promptAction.showToast({ message: '保存成功' })
    } else {
      promptAction.showToast({ message: '保存失败' })
    }
  }

  build() {
    Column() {
      Column() {
        Row({ space: 12 }) {
          Text('尿酸(μmol/L)')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.inputValue })
            .type(InputType.Number)
            .onChange((v: string) => { this.inputValue = v })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('备注')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          TextInput({ text: this.inputNote })
            .onChange((v: string) => { this.inputNote = v })
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')

      Row({ space: 12 }) {
        Button('保存记录')
          .onClick(() => { this.saveData() })
          .backgroundColor('#4CAF50')
          .width('45%')
        Button('刷新历史')
          .onClick(() => { this.loadData() })
          .backgroundColor('#2196F3')
          .width('45%')
      }
      .width('100%')
      .margin({ top: 12, bottom: 12 })

      if (this.latestRecord) {
        Row() {
          Text('当前尿酸:')
            .fontSize(16)
            .fontColor('#666666')
          Text(`${this.latestRecord.value} μmol/L`)
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
        Text('暂无尿酸记录，先输入并保存')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 12 })
      }

      List() {
        ForEach(this.records, (item: UricAcidData) => {
          ListItem() {
            Row() {
              Text(formatDate(item.timestamp, 'YYYY-MM-DD HH:mm'))
                .fontSize(13)
                .fontColor('#666666')
              Text(`${item.value} μmol/L`)
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
      this.loadData()
    })
  }
}
/**
 * 尿酸指标Tab组件
 */

import { UricAcidData, HealthStatus, Gender } from '../model/HealthDataModel';
import { HealthDataServiceImpl } from '../model/HealthDataServiceImpl';
import { evaluateUricAcidStatus } from '../utils/HealthUtils';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import { promptAction, router } from '@kit.ArkUI';
import { MTextInput } from '../common/MTextInput';
import { MButton } from '../common/MButton';

@ComponentV2
export struct UricAcidTab {
  @Local records: UricAcidData[] = []
  @Local latestRecord: UricAcidData | null = null
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT
  @Local inputValue: number = 3
  @Local inputNote: string = ''
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
    const value = this.inputValue
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
          Text('尿酸')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.inputValue.toString(),
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.inputValue = parseFloat(v || '0');
            }
          })
            .layoutWeight(1)
          Text('μmol/L')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .margin({ top: 12 })

        Row({ space: 12 }) {
          Text('备注')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            text: this.inputNote,
            type: InputType.Normal,
            onChangeBlock: (v: string) => {
              this.inputNote = v;
            }
          })
            .layoutWeight(1)
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
            this.saveData();
          }
        })
          .layoutWeight(1)
          .margin({ right: 6 })
        MButton({
          text: '查看历史',
          bgColor: '#2196F3',
          onClickBlock: () => {
            router.pushUrl({
              url: 'pages/HealthHistoryPage',
              params: { type: 'uricAcid' }
            });
          }
        })
          .layoutWeight(1)
          .margin({ left: 6 })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
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
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .onAppear(() => {
      this.loadData()
    })
  }
}
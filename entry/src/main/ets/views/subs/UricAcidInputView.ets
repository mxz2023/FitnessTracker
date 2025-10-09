/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file UricAcidInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../components/MButton"
import { MLable } from "../../components/MLable"
import { MTextInput } from "../../components/MTextInput"
import { HealthStatus, UricAcidData } from "../../models/HealthDataModel"
import { HealthDataServiceImpl } from "../../models/HealthDataServiceImpl"
import { Gender } from "../../models/UserDataModel"

import { getAppPathStack } from "../../utils/PathStackUtils"
import { showToast } from "../../utils/ToastUtils"


const TAG = 'UricAcidInputView.ets'

@ComponentV2
export struct UricAcidInputView {
  @Local records: UricAcidData[] = []
  @Local latestRecord: UricAcidData | null = null
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT
  @Local inputValue: number = 3
  @Local inputNote: string = ''
  private navPathStack: NavPathStack = new NavPathStack()
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext())

  aboutToAppear(): void {
    this.navPathStack = getAppPathStack()
  }

  async loadData() {

  }

  async saveData() {
    const value = this.inputValue
    if (isNaN(value) || value <= 0) {
      showToast(this.getUIContext(), "请输入有效的尿酸值");
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
      showToast(this.getUIContext(), "保存成功");
    } else {
      showToast(this.getUIContext(), "保存失败");
    }
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "尿酸:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.inputValue.toString(),
            onText: (v: string) => {
              this.inputValue = parseFloat(v || '0');
            }
          }).layoutWeight(1)

          MLable({ lable: "μmol/L" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "备注:" })

          MTextInput({
            type: InputType.Normal,
            text: this.inputNote,
            onText: (v: string) => {
              this.inputNote = v;
            }
          }).layoutWeight(1)
        }
      }

      Row() {
        MButton({
          text: '保存记录',
          bgColor: '#4CAF50',
          onClickBlock: () => {
            this.saveData();
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .onAppear(() => {
      this.loadData();
    })
    .width('100%')
    .height('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
    .alignSelf(ItemAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
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
import { UricAcidData } from "../../models/HealthDataModel"
import { Gender } from "../../models/UserDataModel"


@ComponentV2
export struct UricAcidInputView {
  @Event onSubmit: (data?: UricAcidData) => void;
  @Param @Require inputValue: number;
  @Param @Require gender: Gender;
  @Local inputNote: string = '';
  // 本地状态
  @Local private inputText: string = "";

  aboutToAppear(): void {
    this.inputText = `${this.inputValue}`
  }

  async saveData() {
    const value = parseInt(this.inputText)
    if (isNaN(value) || value <= 0) {
      return
    }
    const record: UricAcidData = {
      id: `uricAcid_${Date.now()}`,
      timestamp: Date.now(),
      value: value,
      gender: this.gender ?? Gender.UNKNOWN,
      note: this.inputNote || ''
    }
    this.onSubmit(record)
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "尿酸:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.inputText,
            onText: (v: string) => {
              this.inputText = v;
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
    .width('100%')
    .height('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
    .alignSelf(ItemAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
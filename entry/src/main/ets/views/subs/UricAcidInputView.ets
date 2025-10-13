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
import { MTitleBar } from "../../components/MTitleBar"
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
    const value = parseFloat(this.inputText)
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

  @Builder
  contentBuilder() {
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
  }

  build() {
    RelativeContainer() {
      MTitleBar({
        title: "尿酸信息",
        handleBack: () => {
          this.onSubmit()
        }
      }).alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      }).id('__nav_title_bar__')

      Row() {
        this.contentBuilder()
      }.alignRules({
        top: { anchor: '__nav_title_bar__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      }).margin({
        top: $r('app.integer.view_space')
      })

      // 底部
      Row({ space: $r('app.integer.view_space') }) {
        MButton({
          text: '保存记录',
          bgColor: $r('app.color.green'),
          onClickBlock: () => {
            this.saveData()
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignRules({
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End },
      })
    }
    .width('100%')
    .height('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
  }
}
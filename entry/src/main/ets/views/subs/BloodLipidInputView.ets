/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file BloodLipidInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../components/MButton"
import { MLable } from "../../components/MLable"
import { MTextInput } from "../../components/MTextInput"
import { MTitleBar } from "../../components/MTitleBar";
import { BloodLipidData } from "../../models/HealthDataModel"


@ComponentV2
export struct BloodLipidInputView {
  @Event onSubmit: (data?: BloodLipidData) => void;
  @Param @Require totalCholesterol: number;
  @Param @Require triglycerides: number;
  @Param @Require hdlCholesterol: number;
  @Param @Require ldlCholesterol: number;
  // 本地状态
  @Local private totalCholesterolText: string = "";
  @Local private triglyceridesText: string = "";
  @Local private hdlCholesterolText: string = "";
  @Local private ldlCholesterolText: string = "";

  aboutToAppear(): void {
    this.totalCholesterolText = `${this.totalCholesterol}`;
    this.triglyceridesText = `${this.triglycerides}`;
    this.hdlCholesterolText = `${this.hdlCholesterol}`;
    this.ldlCholesterolText = `${this.ldlCholesterol}`;
  }

  private async saveData() {
    if (
      this.totalCholesterolText.length <= 0 ||
      this.triglyceridesText.length <= 0 ||
      this.hdlCholesterolText.length <= 0 ||
      this.ldlCholesterolText.length <= 0
    ) {
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
    this.onSubmit(record)
  }

  @Builder
  contentBuilder() {
    Column({ space: $r('app.integer.view_content_space') }) {
      Row({ space: $r('app.integer.view_content_space') }) {
        MLable({ lable: "TC:" })

        MTextInput({
          type: InputType.NUMBER_DECIMAL,
          text: this.totalCholesterolText,
          onText: (v: string) => {
            this.totalCholesterolText = v;
          }
        }).layoutWeight(1)

        MLable({ lable: "mmol/L" })
      }

      Row({ space: $r('app.integer.view_content_space') }) {
        MLable({ lable: "TG:" })

        MTextInput({
          type: InputType.NUMBER_DECIMAL,
          text: this.triglyceridesText,
          onText: (v: string) => {
            this.triglyceridesText = v;
          }
        }).layoutWeight(1)

        MLable({ lable: "mmol/L" })
      }

      Row({ space: $r('app.integer.view_content_space') }) {
        MLable({ lable: "HDL-C:" })

        MTextInput({
          text: this.hdlCholesterolText,
          type: InputType.NUMBER_DECIMAL,
          onText: (v: string) => {
            this.hdlCholesterolText = v;
          }
        }).layoutWeight(1)

        MLable({ lable: "mmol/L" })
      }

      Row({ space: $r('app.integer.view_content_space') }) {
        MLable({ lable: "LDL-C:" })

        MTextInput({
          type: InputType.NUMBER_DECIMAL,
          text: this.ldlCholesterolText,
          onText: (v: string) => {
            this.ldlCholesterolText = v;
          }
        }).layoutWeight(1)

        MLable({ lable: "mmol/L" })
      }
    }
  }

  build() {
    RelativeContainer() {
      MTitleBar({
        title: "血脂信息",
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
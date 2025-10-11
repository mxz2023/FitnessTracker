/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file BloodPressureInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../components/MButton";
import { MLable } from "../../components/MLable";
import { MTextInput } from "../../components/MTextInput";
import { BloodPressureData } from "../../models/HealthDataModel";


@ComponentV2
export struct BloodPressureInputView {
  @Event onSubmit: (data?: BloodPressureData) => void;
  @Param @Require systolicValue: number;
  @Param @Require diastolicValue: number;
  // 本地状态
  @Local private systolicText: string = "";
  @Local private diastolicText: string = "";

  aboutToAppear(): void {
    this.systolicText = `${this.systolicValue}`;
    this.diastolicText = `${this.diastolicValue}`;
  }

  private async saveData() {
    const systolicValue = parseInt(this.systolicText)
    const diastolicValue = parseInt(this.diastolicText)
    if (isNaN(systolicValue) || systolicValue <= 0 || isNaN(diastolicValue) || diastolicValue <= 0) {
      return
    }

    const now = Date.now();
    const record = new BloodPressureData();
    record.id = `bloodPressure_${now}`;
    record.timestamp = now;
    record.systolic = systolicValue;
    record.diastolic = diastolicValue;
    record.note = '';
    this.onSubmit(record);
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "收缩压:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.systolicText,
            onText: (v: string) => {
              this.systolicText = v
            }
          }).layoutWeight(1)

          MLable({ lable: "mmHg:" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "舒张压:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.diastolicText,
            onText: (v: string) => {
              this.diastolicText = v
            }
          }).layoutWeight(1)

          MLable({ lable: "mmHg" })
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
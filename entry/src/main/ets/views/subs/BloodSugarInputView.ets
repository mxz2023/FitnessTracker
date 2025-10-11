/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file BloodSugarInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../components/MButton";
import { MTextInput } from "../../components/MTextInput";
import { BloodSugarData, MeasurementType } from "../../models/HealthDataModel";


@ComponentV2
export struct BloodSugarInputView {
  @Event onSubmit: (data?: BloodSugarData) => void;
  @Param @Require bloodSugarValue: number;
  @Param @Require measurementType: MeasurementType;
  // 本地状态
  @Local private bloodSugarText: string = "";
  @Local private measurementText: MeasurementType = MeasurementType.RANDOM;

  aboutToAppear(): void {
    this.bloodSugarText = `${this.bloodSugarValue}`;
    this.measurementText = this.measurementType;
  }

  private async saveData() {
    const value = parseInt(this.bloodSugarText)
    if (isNaN(value) || value <= 0 ) {
      return
    }

    const now = Date.now();
    const record: BloodSugarData = {
      id: `bloodSugar_${now}`,
      timestamp: now,
      value: value,
      measurementType: this.measurementType,
      note: ''
    };
    this.onSubmit(record);
  }

  build() {
    Column() {
      Column() {
        Row({ space: $r('app.integer.view_content_space') }) {
          Text('血糖')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.bloodSugarText,
            onText: (v: string) => {
              this.bloodSugarText = v;
            }
          }).layoutWeight(1)

          Text('mmol/L').fontSize(14).fontColor('#666666')
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          Text('测量类型')
            .fontSize(14)
            .fontColor('#666666')
            .maxLines(1)
          Row({ space: 8 }) {
            Radio({ value: 'FASTING', group: 'bsType' })
              .checked(this.measurementText === MeasurementType.FASTING)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementText = MeasurementType.FASTING;
                }
              })
            Text('空腹')
            Radio({ value: 'AFTER_MEAL', group: 'bsType' })
              .checked(this.measurementText === MeasurementType.AFTER_MEAL)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementText = MeasurementType.AFTER_MEAL;
                }
              })
            Text('餐后')
            Radio({ value: 'RANDOM', group: 'bsType' })
              .checked(this.measurementText === MeasurementType.RANDOM)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementText = MeasurementType.RANDOM;
                }
              })
            Text('随机')
          }
          .width('100%')
        }
        .width('100%')
        .margin({ top: 8 })
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
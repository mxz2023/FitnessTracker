/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file WeightInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../components/MButton"
import { MLable } from "../../components/MLable";
import { MTextInput } from "../../components/MTextInput"
import { MTitleBar } from "../../components/MTitleBar";
import { WeightData } from "../../models/HealthDataModel";


@ComponentV2
export struct WeightInputView {
  @Event onSubmit: (data?: WeightData) => void
  @Param @Require weightKg: number;
  // 本地状态
  @Local weightInputText: string = "";

  aboutToAppear(): void {
    // 使用外部传入的 weightKg 初始化输入框文本
    this.weightInputText = `${this.weightKg}`;
  }

  private async saveData() {
    const value = parseFloat(this.weightInputText)
    if (isNaN(value) || value <= 0 ) {
      return
    }

    const now = Date.now();
    const record = new WeightData();
    record.id = `weight_${now}`;
    record.timestamp = now;
    record.value = Number(this.weightInputText) || 0;
    record.note = '';
    this.onSubmit(record);
  }

  @Builder
  contentBuilder() {
    Column({ space: $r('app.integer.view_content_space') }) {

      Row({ space: $r('app.integer.view_content_space') }) {
        MLable({ lable: "体重:" })

        MTextInput({
          type: InputType.NUMBER_DECIMAL,
          text: this.weightInputText,
          onText: (v: string) => {
            // 数字与小数点输入校验，最多两位小数
            let res: string = v ?? '';
            if (!/^\d*\.?\d*$/.test(res)) {
              return;
            }
            const parts: string[] = res.split('.');
            if (parts.length > 1 && parts[1].length > 2) {
              res = `${parts[0]}.${parts[1].substring(0, 2)}`;
            }
            this.weightInputText = res;
          }
        }).layoutWeight(1)

        MLable({ lable: "kg" })
      }
    }
  }

  build() {
    RelativeContainer() {
      MTitleBar({
        style: 1,
        title: "体重信息",
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
    .constraintSize({
      maxWidth: 500
    })
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
  }
}
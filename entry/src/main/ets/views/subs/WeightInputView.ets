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
    // 构造体重数据并通过事件提交，持久化由主页面处理
    const now = Date.now();
    const record = new WeightData();
    record.id = `weight_${now}`;
    record.timestamp = now;
    record.value = Number(this.weightInputText) || 0;
    record.note = '';
    this.onSubmit(record);
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
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

      Row({ space: $r('app.integer.view_space') }) {
        MButton({
          text: '保存记录',
          bgColor: $r('app.color.green'),
          onClickBlock: () => {
            this.saveData();
          }
        }).layoutWeight(1)

        MButton({
          text: '取消',
          bgColor: $r('app.color.gray'),
          onClickBlock: () => {
            const res = new WeightData()
            res.value = Number(this.weightInputText)
            this.onSubmit(res);
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
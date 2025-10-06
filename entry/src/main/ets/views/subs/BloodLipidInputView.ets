/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file BloodLipidInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

import { MButton } from "../../commonui/MButton"
import { MLable } from "../../commonui/MLable"
import { MTextInput } from "../../commonui/MTextInput"
import { BloodLipidData } from "../../model/HealthDataModel"
import { HealthDataServiceImpl } from "../../model/HealthDataServiceImpl"
import { showToast } from "../../utils/ToastUtils"

// system

// module

// inner

const TAG = 'BloodLipidInputView.ets'


@ComponentV2
export struct BloodLipidInputView {
  @Local private totalCholesterolText: string = ''
  @Local private triglyceridesText: string = ''
  @Local private hdlCholesterolText: string = ''
  @Local private ldlCholesterolText: string = ''
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext())

  async loadData() {

  }

  async saveData() {
    if (
      this.totalCholesterolText.length <= 0 ||
        this.triglyceridesText.length <= 0 ||
        this.hdlCholesterolText.length <= 0 ||
        this.ldlCholesterolText.length <= 0
    ) {
      showToast(this.getUIContext(), '请输入有效的血脂值')
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
    const ok = await this.dataService.saveData(record)
    if (ok) {
      showToast(this.getUIContext(), '保存成功')
    } else {
      showToast(this.getUIContext(), '保存失败')
    }
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "TC:" })

          MTextInput({
            text: this.totalCholesterolText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.totalCholesterolText = v;
            }
          }).layoutWeight(1)

          MLable({ lable: "mmol/L" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "TG:" })

          MTextInput({
            text: this.triglyceridesText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
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
            onChangeBlock: (v: string) => {
              this.hdlCholesterolText = v;
            }
          }).layoutWeight(1)

          MLable({ lable: "mmol/L" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "LDL-C:" })

          MTextInput({
            text: this.ldlCholesterolText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.ldlCholesterolText = v;
            }
          }).layoutWeight(1)

          MLable({ lable: "mmol/L" })
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
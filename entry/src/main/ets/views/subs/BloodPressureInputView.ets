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
import { HealthDataServiceImpl } from "../../models/HealthDataServiceImpl";
import { showToast } from "../../utils/ToastUtils";


const TAG = 'BloodPressureInputView.ets'

@ComponentV2
export struct BloodPressureInputView {
  @Local systolicValue: number = 120;
  @Local diastolicValue: number = 80;
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());

  async loadData() {

  }

  async saveData() {
    if (this.systolicValue <= 0 || this.diastolicValue <= 0) {
      showToast(this.getUIContext(), "请输入有效的血压值");
      return;
    }
    const now = Date.now();
    const record = new BloodPressureData();
    record.id = `bloodPressure_${now}`;
    record.timestamp = now;
    record.systolic = this.systolicValue;
    record.diastolic = this.diastolicValue;
    record.note = '';
    const ok = await this.dataService.saveData(record);
    if (ok) {
      showToast(this.getUIContext(), "保存成功");
    } else {
      showToast(this.getUIContext(), "保存失败");
    }
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "收缩压:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.systolicValue.toString(),
            onText: (v: string) => {
              this.systolicValue = parseFloat(v || '0');
            }
          }).layoutWeight(1)

          MLable({ lable: "mmHg:" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "舒张压:" })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: this.diastolicValue.toString(),
            onText: (v: string) => {
              this.diastolicValue = parseFloat(v || '0');
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
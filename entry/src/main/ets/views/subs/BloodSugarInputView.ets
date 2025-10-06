/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file BloodSugarInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

// system

// module

// inner
import { MButton } from "../../commonui/MButton";
import { MTextInput } from "../../commonui/MTextInput";
import { BloodSugarData, MeasurementType } from "../../model/HealthDataModel";
import { HealthDataServiceImpl } from "../../model/HealthDataServiceImpl";
import { showToast } from "../../utils/ToastUtils";


const TAG = 'BloodSugarInputView.ets'


@ComponentV2
export struct BloodSugarInputView {
  @Local bloodSugarValue: number = 5.0;
  @Local measurementType: MeasurementType = MeasurementType.FASTING;
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());

  async loadData() {

  }

  async saveData() {
    if (this.bloodSugarValue <= 0) {
      showToast(this.getUIContext(), "请输入有效的血糖值");
      return;
    }
    const now = Date.now();
    const record: BloodSugarData = {
      id: `bloodSugar_${now}`,
      timestamp: now,
      value: this.bloodSugarValue,
      measurementType: this.measurementType,
      note: ''
    };
    const ok = await this.dataService.saveData(record);
    if (ok) {
      showToast(this.getUIContext(), "保存成功");
    } else {
      showToast(this.getUIContext(), "保存失败");
    }
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
            text: this.bloodSugarValue.toString(),
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.bloodSugarValue = parseFloat(v || '0');
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
              .checked(this.measurementType === MeasurementType.FASTING)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.FASTING;
                }
              })
            Text('空腹')
            Radio({ value: 'AFTER_MEAL', group: 'bsType' })
              .checked(this.measurementType === MeasurementType.AFTER_MEAL)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.AFTER_MEAL;
                }
              })
            Text('餐后')
            Radio({ value: 'RANDOM', group: 'bsType' })
              .checked(this.measurementType === MeasurementType.RANDOM)
              .onChange((c: boolean) => {
                if (c) {
                  this.measurementType = MeasurementType.RANDOM;
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
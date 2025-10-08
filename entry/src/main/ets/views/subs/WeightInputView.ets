/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file WeightInputView.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */

// system

// module

// inner
import { MButton } from "../../commonui/MButton"
import { MLable } from "../../commonui/MLable";
import { MTextInput } from "../../commonui/MTextInput"
import { HealthStatus, WeightData } from "../../models/HealthDataModel";
import { HealthDataServiceImpl } from "../../models/HealthDataServiceImpl";

import { evaluateWeightStatus } from "../../utils/HealthUtils";
import { showToast } from "../../utils/ToastUtils";


const TAG = 'WeightInputView.ets'

@ComponentV2
export struct WeightInputView {
  @Local weightInputText: string = '80';
  @Local heightInputText: string = '1.85';
  @Local isLoading: boolean = false;
  @Local latestData: WeightData | null = null;
  @Local healthStatus: HealthStatus = HealthStatus.EXCELLENT;
  private dataService: HealthDataServiceImpl = new HealthDataServiceImpl(this.getUIContext().getHostContext());

  aboutToAppear(): void {

  }

  private async loadData() {

  }

  private async saveData() {
    if (Number(this.weightInputText) <= 0) {
      showToast(this.getUIContext(), "请输入有效的体重值");
      return;
    }
    const ok = await this.saveAveragedToday();
    if (ok) {
      this.healthStatus = evaluateWeightStatus(Number(this.weightInputText), Number(this.heightInputText));
      showToast(this.getUIContext(), "保存成功");
    } else {
      showToast(this.getUIContext(), "保存失败");
    }
  }

  // 当天多次记录时，做平均并只保留一条记录
  private async saveAveragedToday(): Promise<boolean> {
    const now = Date.now();
    // 计算本地当天起止时间戳
    const d = new Date(now);
    const dayStart = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0).getTime();
    const dayEnd = dayStart + 24 * 60 * 60 * 1000 - 1;

    const all = await this.dataService.getDataByType('weight');
    const todayList = (all as WeightData[]).filter(item => item.timestamp >= dayStart && item.timestamp <= dayEnd);

    let sum = Number(this.weightInputText);
    let count = 1;
    for (const it of todayList) {
      sum += it.value;
      count += 1;
    }

    const avg = sum / count;

    // 删除当天已有记录
    for (const it of todayList) {
      await this.dataService.deleteData(it.id);
    }

    // 保存一条平均值记录
    const record = new WeightData();
    record.id = `weight_${now}`;
    record.timestamp = now;
    record.value = avg;
    record.note = '';

    const ok = await this.dataService.saveData(record);
    if (ok) {
      this.latestData = record;
    }
    return ok;
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "身高:" })

          MTextInput({
            text: this.heightInputText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.heightInputText = v
            }
          }).layoutWeight(1)

          MLable({ lable: "m" })
        }

        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: "体重:" })

          MTextInput({
            text: this.weightInputText,
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.weightInputText = v
            }
          }).layoutWeight(1)

          MLable({ lable: "kg" })
        }
      }

      Row() {
        MButton({
          text: '保存记录',
          bgColor: $r('app.color.green'),
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
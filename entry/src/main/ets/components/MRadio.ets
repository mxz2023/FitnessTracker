/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MRadio.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-04
 * @desc
 */


@ComponentV2
export struct MRadio {
  @Param titles: string = ''
  @Param isChecked: boolean = false
  @Param value : string = ''
  @Param groupName: string = ""
  @Event onChange: (isChecked: boolean) => void = () => { }

  build() {
    Row() {
      Text(this.titles).fontSize($r('app.float.font_size_normal'))
      Radio({ value: this.value, group: this.groupName,
        indicatorType:RadioIndicatorType.TICK
      }).checked(this.isChecked)
        .height(20)
        .onChange((isChecked: boolean) => {
          this.onChange(isChecked)
        })
    }
  }
}
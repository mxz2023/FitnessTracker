/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MLable.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-06
 * @desc
 */

// system

// module

// inner

const TAG = 'MLable.ets'


@ComponentV2
export struct MLable {
  @Param lable: string = ''

  build() {
    Text(`${this.lable}`)
      .fontSize($r('app.float.font_size_normal'))
      .fontColor($r('app.color.text_666'))
  }
}
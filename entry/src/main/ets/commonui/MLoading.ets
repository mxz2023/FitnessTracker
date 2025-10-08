/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MLoading.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-17
 * @desc
 */


@ComponentV2
export struct MLoading {
  build() {
    Column() {
      Column() {
        LoadingProgress()
          .color($r('app.color.white'))
          .width(80)
          .height(80)

        Text('努力加载中..')
          .fontSize($r('app.float.font_size_medium'))
          .fontColor($r('app.color.white'))
      }
      .width(120)
      .height(120)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.black'))
      .borderRadius($r('app.integer.view_radius'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#90000000')
    .justifyContent(FlexAlign.Center)
  }
}

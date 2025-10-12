/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MTitleBar.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-12
 * @desc
 */
import { MIcon } from "./MIcon"
import { MTitle } from "./MLable"


@ComponentV2
export struct MTitleBar {
  @Param title: string = ""
  @Event handleBack: () => void

  build() {
    Row() {
      MIcon({
        iconName: "back"
      }).onClick(() => {
        this.handleBack()
      })

      MTitle({
        data: {
          text: this.title,
          size: 20
        }
      }).margin({
        left: $r('app.integer.view_space')
      })
    }
    .width('100%')
    .height($r('app.integer.nav_bar_height'))
  }
}
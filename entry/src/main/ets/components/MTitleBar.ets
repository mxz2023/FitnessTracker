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
  @Param style: number = 0
  @Event handleBack: () => void

  getJustifyContent() {
    switch (this.style) {
      case 0: {
        return FlexAlign.Start
      }
      case 1: {
        return FlexAlign.SpaceBetween
      }
      default: {
        return FlexAlign.Start
      }
    }
  }

  build() {
    Row() {
      if (this.style == 0) {
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
      } else if (this.style == 1) {
        MTitle({
          data: {
            text: this.title,
            size: 20
          }
        })

        MIcon({
          iconName: "close",
          iconSize: 24
        }).onClick(() => {
          this.handleBack()
        })
      }
    }
    .width('100%')
    .height($r('app.integer.nav_bar_height'))
    .justifyContent(this.getJustifyContent())
  }
}
/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MDashBoard.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-08
 * @desc
 */

import { TitleData } from "./MLable"
import { TypeUtils } from "../utils/TypeUtils"
import { Range } from "../models/HealthDataModel"


@ComponentV2
export struct MDashBoard {
  @Param @Require title: TitleData
  @Param @Require subTitle: TitleData
  @Param @Require note: TitleData
  @Param @Require colors: Array<[ResourceColor | LinearGradient, number]>
  @Param @Require range: Range
  @Param @Require value: number

  @Builder
  descriptionBuilder(data?: TitleData) {
    Column() {
      Text(data?.text)
        .maxFontSize($r('app.float.font_size_normal'))
        .minFontSize($r('app.float.font_size_small'))
        .fontColor(data?.color)
        .fontWeight(FontWeight.Regular)
        .textAlign(TextAlign.Center)
    }
  }

  build() {
    Gauge({ value: this.range.min, min: this.range.min, max: this.range.max }) {
      RelativeContainer() {
        // 数值显示
        Text(`${this.title.text}`)
          .maxLines(1)
          .fontSize($r('app.float.font_size_nav_title'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_333'))
          .id('__text_value__')
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center },
          })
          .margin({
            top: -20
          })

        if (!TypeUtils.isEmptyString(this.subTitle.text)) {
          Text(this.subTitle.text)
            .fontSize($r('app.float.font_size_normal'))
            .fontColor($r('app.color.text_666'))
            .id('__text_unit__')
            .alignRules({
              top: { anchor: '__text_value__', align: VerticalAlign.Bottom },
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
            })
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .strokeWidth(18)
    .trackShadow({
      radius: 7,
      offsetX: 7,
      offsetY: 7
    })
    .value(this.value)
    .startAngle(240)
    .endAngle(120)
    .colors(this.colors)
    .description(this.descriptionBuilder(this.note))
  }
}
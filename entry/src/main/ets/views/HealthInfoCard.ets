/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file HealthInfoCard.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-12
 * @desc
 */

import { MDashBoard } from "../components/MDashBoard"
import { MStatusLable } from "../components/MLable"
import { HealthCardData, HealthCardDataType } from "../models/HealthDataModel"
import {
  getHealthStatusColor,
  getHealthStatusColors,
  getHealthStatusRang,
  getHealthStatusText
} from "../utils/HealthUtils"
import { TypeUtils } from "../utils/TypeUtils"

@ComponentV2
export struct HealthInfoCard {
  @Param @Require data: HealthCardData
  @Event handleClick: (type: HealthCardDataType) => void

  build() {
    Column() {
      // 卡片头部 - 标题和状态指示器
      Row() {
        Text(this.data.title)
          .fontSize($r('app.float.font_size_medium'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        Blank()

        MStatusLable({
          title: {
            text: getHealthStatusText(this.data.status),
            color: getHealthStatusColor(this.data.status)
          },
          status: true,
        })
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })

      // 仪表盘视图
      if (this.data.type === HealthCardDataType.WeightInfo || this.data.type === HealthCardDataType.BloodSugarInfo ||
        this.data.type === HealthCardDataType.UricAcidInfo) {
        // 单值圆形仪表
        MDashBoard({
          value: Number(this.data.value),
          colors: getHealthStatusColors(this.data.type),
          range: getHealthStatusRang(this.data.type),
          title: {
            text: `${this.data.value}`,
            color: getHealthStatusColor(this.data.status)
          },
          subTitle: {
            text: this.data.unit,
            color: getHealthStatusColor(this.data.status)
          },
          note: {
            text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) : this.data.other,
            color: getHealthStatusColor(this.data.status)
          },
        })
      } else if (this.data.type === HealthCardDataType.BloodPressureInfo ||
        this.data.type === HealthCardDataType.BloodLipidInfo) {
        // 多值线条仪表
      } else {
        // 默认仪表
      }

      Row() {
        // 日期信息
        if (this.data.date) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.time_inerval'))
              .fontSize($r('app.float.font_size_normal'))
              .fontColor([$r('app.color.text_999')])

            Text(`${this.data.date}`)
              .fontSize($r('app.float.font_size_normal'))
              .fontColor($r('app.color.text_999'))
              .alignSelf(ItemAlign.Start)
          }
        }

        Column() {
          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize(18)
            .fontColor([$r('app.color.red')])
        }
        .onClick(() => {
          this.handleClick(this.data.type)
        })
        // .backgroundColor("#00FF00")
        .width(30)
        .height(30)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(230)
    .padding($r('app.integer.view_padding'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.integer.view_radius'))
    .shadow({
      radius: $r('app.integer.view_radius'),
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
  }
}
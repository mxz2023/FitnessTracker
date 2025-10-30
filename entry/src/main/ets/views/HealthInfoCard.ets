/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file HealthInfoCard.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-12
 * @desc
 */

import { FontSizeConstants } from "../common/CommonDefine"
import { MDashBoardStyle, MDashBoardV1, MDashBoardV2, MDashBoardV3 } from "../components/MDashBoard"
import { MStatusLable } from "../components/MLable"
import { HealthCardData, HealthCardDataType } from "../models/HealthDataModel"
import {
  getHealthStatusColor,
  getHealthStatusRang,
  getHealthStatusText,
  getHealthColors,
} from "../func/HealthUtils"
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
        MDashBoardV1({
          data: {
            value: Number(this.data.value1),
            colors: getHealthColors(this.data.type),
            range: getHealthStatusRang(this.data.type)[0],
            title: {
              text: `${this.data.value1}`,
              color: $r('app.color.text_333')
            },
            subTitle: {
              text: this.data.unit,
              color: $r('app.color.text_999')
            },
            note: {
              text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) : this.data.other,
              color: $r('app.color.text_666')
            },
          }
        })
      } else if (this.data.type === HealthCardDataType.BloodPressureInfo) {
        // 双线条仪表
        MDashBoardV2({
          dataList: [
            {
              value: Number(this.data.value1),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[0],
              title: {
                text: `${this.data.value1}`,
                color: $r('app.color.text_333'),
                size: FontSizeConstants.NavTitle
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: "收缩压",
                color: $r('app.color.text_666'),
                size: FontSizeConstants.Small
              },
            },
            {
              value: Number(this.data.value2),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[1],
              title: {
                text: `${this.data.value2}`,
                color: $r('app.color.text_333'),
                size: FontSizeConstants.NavTitle
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: "舒张压",
                color: $r('app.color.text_666'),
                size: FontSizeConstants.Small
              },
            }
          ],
        })
      } else if (this.data.type === HealthCardDataType.BloodLipidInfo) {
        // 多值圆形仪表
        MDashBoardV3({
          dataList: [
            {
              value: Number(this.data.value1),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[0],
              title: {
                text: `${this.data.value1}`,
                color: $r('app.color.text_333')
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) :
                  this.data.other,
                color: $r('app.color.text_666')
              },
            },
            {
              value: Number(this.data.value2),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[1],
              title: {
                text: `${this.data.value2}`,
                color: $r('app.color.text_333')
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) :
                  this.data.other,
                color: $r('app.color.text_666')
              },
            },
            {
              value: Number(this.data.value3),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[2],
              title: {
                text: `${this.data.value3}`,
                color: $r('app.color.text_333')
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) :
                  this.data.other,
                color: $r('app.color.text_666')
              },
            },
            {
              value: Number(this.data.value4),
              colors: getHealthColors(this.data.type),
              range: getHealthStatusRang(this.data.type)[3],
              title: {
                text: `${this.data.value4}`,
                color: $r('app.color.text_333')
              },
              subTitle: {
                text: this.data.unit,
                color: $r('app.color.text_999'),
                size: FontSizeConstants.Small
              },
              note: {
                text: TypeUtils.isEmptyString(this.data.other) ? getHealthStatusText(this.data.status) :
                  this.data.other,
                color: $r('app.color.text_666')
              },
            }]
        })
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
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
import { MIcon } from "./MIcon"
import { AppConstants, ColorConstants } from "../common/CommonDefine"

interface MDashBoardData {
  title: TitleData
  subTitle?: TitleData
  note?: TitleData
  colors: Array<[ResourceColor, number]>
  range: Range
  value: number
}

const kStrokeWidth = 15

@ComponentV2
export struct MDashBoardV1 {
  @Param @Require data: MDashBoardData

  getColors() {
    const colorStop: ColorStop[] = this.data.colors.map((item: [ResourceColor, number]) => {
      return {
        color: item[0],
        offset: item[1]
      } as ColorStop
    })
    return new LinearGradient(colorStop)
  }

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
    Gauge({ value: this.data.range.min, min: this.data.range.min, max: this.data.range.max }) {
      RelativeContainer() {
        // 数值显示
        Text(`${this.data.title.text}`)
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

        if (this.data.subTitle && !TypeUtils.isEmptyString(this.data.subTitle.text)) {
          Text(this.data.subTitle.text)
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
    .aspectRatio(1)
    .trackShadow({
      radius: 7,
      offsetX: 7,
      offsetY: 7
    })
    .strokeWidth(kStrokeWidth) // 圆环宽度
    .indicator({
      space: kStrokeWidth      // 指示器样式
    })
    .value(this.data.value)
    .startAngle(240)
    .endAngle(120)
    .colors(this.getColors())
    .description(this.descriptionBuilder(this.data.note))
  }
}


@ComponentV2
export struct MDashBoardV2 {
  @Param @Require dataList: MDashBoardData[]
  @Local private pos: number[] = []

  aboutToAppear(): void {
    const len = this.dataList.length
    for (let i = 0; i < len; i++) {
      this.pos[i] = 0
    }
  }

  getTop(value: number, index: number): Percentage {
    return `${(1 - value / (this.dataList[index].range.max - this.dataList[index].range.min)) * 100}%`
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      ForEach(this.dataList, (item: MDashBoardData, index: number) => {
        RelativeContainer() {
          Row() {
            Row() {
              Text(item.title.text)
                .fontColor(item.title.color)
                .fontSize(item.title.size)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
              if (item.subTitle && !TypeUtils.isEmptyString(item.subTitle.text)) {
                Text(item.subTitle.text)
                  .fontColor(item.subTitle.color)
                  .fontSize(item.subTitle.size)
                  .maxLines(1)
                  .margin({
                    left: 2
                  })
              }
            }

            if (item.note && !TypeUtils.isEmptyString(item.note.text)) {
              Text(item.note.text)
                .fontColor(item.note.color)
                .fontSize(item.note.size)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
            }
          }.alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End },
            top: { anchor: '__container__', align: VerticalAlign.Top },
          }).id("__title__").justifyContent(FlexAlign.SpaceBetween)

          Row() {
            MIcon({
              iconName: "^",
              iconColor: [ColorConstants.Black],
              iconSize: 16
            })
              .width(18)
              .height(18)
              .margin({
                left: this.pos[index],
                top: 15 + kStrokeWidth
              })
          }
          .justifyContent(FlexAlign.Start)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            const a = Math.max(this.dataList[index].value - this.dataList[index].range.min, 1)
            const b = this.dataList[index].range.max - this.dataList[index].range.min
            this.pos[index] = Number(newValue.width) / b * a
          })
          .width('100%')
          .height(kStrokeWidth)
          .margin({
            top: 4,
            bottom: 4
          })
          .borderRadius(10)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: item.colors
          })
          .alignRules({
            top: { anchor: '__title__', align: VerticalAlign.Bottom },
            bottom: { anchor: '__note__', align: VerticalAlign.Top },
            middle: { anchor: '__note__', align: HorizontalAlign.Center }
          })
        }.layoutWeight(1)
      })
    }
    .padding({
      bottom: 20
    })
    .width('100%')
    .aspectRatio(1)
  }
}

@ComponentV2
export struct MDashBoardV3 {
  @Param @Require dataList: MDashBoardData[]

  build() {
    Grid() {
      ForEach(this.dataList, (item: MDashBoardData) => {
        GridItem() {
          MDashBoardV1({
            data: item
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap($r('app.integer.view_space'))
    .columnsGap($r('app.integer.view_space'))
  }
}

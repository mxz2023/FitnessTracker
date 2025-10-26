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
import { ColorConstants, FontSizeConstants } from "../common/CommonDefine"


const TAG = "MDashBoard"

export interface MDashBoardData {
  title: TitleData
  subTitle?: TitleData
  note?: TitleData
  colors: Array<[ResourceColor, number]>
  range: Range
  value: number
}

/**
 * 仪表盘大小
 */
export enum MDashBoardStyle {
  DashBoardSmall,
  DashBoardNormal,
  DashBoardBig,
}

// 环形仪表盘
@ComponentV2
export struct MDashBoardV1 {
  @Param @Require data: MDashBoardData
  @Param isGridItem: boolean = false
  @Consumer("DashBoardStyle") style: MDashBoardStyle = MDashBoardStyle.DashBoardNormal
  @Local private strokeWidth: number = 15
  @Local private titleFontSize: number = FontSizeConstants.LargeTitle
  @Local private subTitleFontSize: number = FontSizeConstants.Normal
  @Local private descriptionFontSize: number = FontSizeConstants.Normal

  @Monitor('style')
  onStyleChange(monitor: IMonitor) {
    this.updateContent()
  }

  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext()
    if (context == undefined) {
      return
    }

    // try {
    //   this.normalFontSize = context.resourceManager.getNumberByName('font_size_normal');
    //   this.smallFontSize = context.resourceManager.getNumberByName('font_size_small');
    //   this.navTitleFontSize = context.resourceManager.getNumberByName('font_size_nav_title');
    // } catch (error) {
    //   // TODO: Implement error handling.
    // }

    this.updateContent()
  }

  private updateContent() {
    if (this.isGridItem) {
      switch (this.style) {
        case MDashBoardStyle.DashBoardSmall: {
          this.strokeWidth = 8
          this.titleFontSize = FontSizeConstants.Medium
          this.subTitleFontSize = FontSizeConstants.Normal
          this.descriptionFontSize = FontSizeConstants.Normal
          break;
        }
        case MDashBoardStyle.DashBoardNormal: {
          this.strokeWidth = 12
          this.titleFontSize = FontSizeConstants.Medium
          this.subTitleFontSize = FontSizeConstants.Normal
          this.descriptionFontSize = FontSizeConstants.Normal
          break;
        }
        case MDashBoardStyle.DashBoardBig: {
          this.strokeWidth = 16
          this.titleFontSize = FontSizeConstants.Large
          this.subTitleFontSize = FontSizeConstants.Normal
          this.descriptionFontSize = FontSizeConstants.Normal
          break;
        }
        default: {
          break;
        }
      }
    } else {
      switch (this.style) {
        case MDashBoardStyle.DashBoardSmall: {
          this.strokeWidth = 10
          this.titleFontSize = FontSizeConstants.Small
          this.subTitleFontSize = FontSizeConstants.Small
          this.descriptionFontSize = FontSizeConstants.Small
          break;
        }
        case MDashBoardStyle.DashBoardNormal: {
          this.strokeWidth = 15
          this.titleFontSize = FontSizeConstants.LargeTitle
          this.subTitleFontSize = FontSizeConstants.Normal
          this.descriptionFontSize = FontSizeConstants.Normal
          break;
        }
        case MDashBoardStyle.DashBoardBig: {
          this.strokeWidth = 25
          this.titleFontSize = 40
          this.subTitleFontSize = 20
          this.descriptionFontSize = 20
          break;
        }
        default: {
          break;
        }
      }
    }
  }

  getColors() {
    const colorStop: ColorStop[] = this.data.colors.map((item: [ResourceColor, number]) => {
      return {
        color: item[0],
        offset: item[1]
      } as ColorStop
    })
    return new LinearGradient(colorStop)
  }

  getTitleText(): string {
    return this.data.title.text ?? ""
  }

  getTitleTextColor(): ResourceColor {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return ""
    } else {
      return this.data.title.color ?? $r('app.color.text_333')
    }
  }

  getTitleFontWeight(): FontWeight {
    if (this.isGridItem) {
      if (this.style != MDashBoardStyle.DashBoardBig) {
        return FontWeight.Normal
      }
      return FontWeight.Bold
    }
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return FontWeight.Normal
    }
    return FontWeight.Bold
  }

  getSubTitleText(): string {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return ""
    } else {
      return this.data.subTitle?.text ?? ""
    }
  }

  getSubTitleFontWeight(): FontWeight {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return FontWeight.Lighter
    } else {
      return FontWeight.Normal
    }
  }

  getSubTitleTextColor(): ResourceColor {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return ""
    } else {
      return this.data.title.color ?? $r('app.color.text_666')
    }
  }

  getDescriptionText(): string {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return `${this.data.subTitle?.text ?? ""}`
    } else {
      return this.data.note?.text ?? ""
    }
  }

  getDescriptionTextColor(): ResourceColor {
    return this.data.note?.color ?? $r('app.color.text_666')
  }

  getDescriptionFontWeight(): FontWeight {
    if (this.style == MDashBoardStyle.DashBoardSmall) {
      return FontWeight.Lighter
    } else {
      return FontWeight.Medium
    }
  }

  @Builder
  descriptionBuilder() {
    Column() {
      Text(this.getDescriptionText())
        .maxFontSize(this.descriptionFontSize)
        .minFontSize(8)
        .fontColor(this.getDescriptionTextColor())
        .fontWeight(this.getDescriptionFontWeight())
        .textAlign(TextAlign.Center)
    }
  }

  build() {
    Gauge({ value: this.data.range.min, min: this.data.range.min, max: this.data.range.max }) {
      RelativeContainer() {
        // 数值显示
        Text(this.getTitleText())
          .maxLines(1)
          .fontSize(this.titleFontSize)
          .fontWeight(this.getTitleFontWeight())
          .fontColor(this.getTitleTextColor())
          .id('__text_value__')
          .alignRules({
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
            center: { anchor: '__container__', align: VerticalAlign.Center },
          })
          .margin({
            top: (this.isGridItem || this.style == MDashBoardStyle.DashBoardSmall) ? 0 : -20
          })

        if (!this.isGridItem && this.style != MDashBoardStyle.DashBoardSmall) {
          Text(this.getSubTitleText())
            .fontSize(this.subTitleFontSize)
            .fontColor(this.getSubTitleTextColor())
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
    .strokeWidth(this.strokeWidth) // 圆环宽度
    .indicator({
      space: this.strokeWidth      // 指示器样式
    })
    .value(this.data.value)
    .startAngle(240)
    .endAngle(120)
    .colors(this.getColors())
    .description(this.descriptionBuilder())
  }
}

// 2条线
@ComponentV2
export struct MDashBoardV2 {
  @Param @Require dataList: MDashBoardData[]
  @Consumer("DashBoardStyle") style: MDashBoardStyle = MDashBoardStyle.DashBoardNormal
  @Local private strokeWidth: number = 15
  @Local private titleFontSize: number = FontSizeConstants.LargeTitle
  @Local private subTitleFontSize: number = FontSizeConstants.Normal
  @Local private descriptionFontSize: number = FontSizeConstants.Normal
  @Local private pos: number[] = [0, 0]

  @Monitor('style')
  onStyleChange(monitor: IMonitor) {
    this.updateContent()
  }

  aboutToAppear(): void {
    let context = this.getUIContext().getHostContext()
    if (context == undefined) {
      return
    }

    this.updateContent()
  }

  private updateContent() {
    switch (this.style) {
      case MDashBoardStyle.DashBoardSmall: {
        this.strokeWidth = 10
        this.titleFontSize = FontSizeConstants.Small
        this.subTitleFontSize = FontSizeConstants.Small
        this.descriptionFontSize = FontSizeConstants.Small
        break;
      }
      case MDashBoardStyle.DashBoardNormal: {
        this.strokeWidth = 12
        this.titleFontSize = FontSizeConstants.Large
        this.subTitleFontSize = FontSizeConstants.Normal
        this.descriptionFontSize = FontSizeConstants.Normal
        break;
      }
      case MDashBoardStyle.DashBoardBig: {
        this.strokeWidth = 18
        this.titleFontSize = FontSizeConstants.NavTitle
        this.subTitleFontSize = FontSizeConstants.Medium
        this.descriptionFontSize = FontSizeConstants.Medium
        break;
      }
      default: {
        break;
      }
    }
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      ForEach(this.dataList, (item: MDashBoardData, index: number) => {
        RelativeContainer() {
          Row() {
            Row() {
              Text(item.title.text)
                .fontColor(item.title.color)
                .fontSize(this.titleFontSize)
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
              if (item.subTitle && !TypeUtils.isEmptyString(item.subTitle.text)) {
                Text(item.subTitle.text)
                  .fontColor(item.subTitle.color)
                  .fontSize(this.subTitleFontSize)
                  .maxLines(1)
                  .margin({
                    left: 2
                  })
              }
            }

            if (item.note && !TypeUtils.isEmptyString(item.note.text)) {
              Text(item.note.text)
                .fontColor(item.note.color)
                .fontSize(this.descriptionFontSize)
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
                top: 15 + this.strokeWidth
              })
          }
          .justifyContent(FlexAlign.Start)
          .onAreaChange((oldValue: Area, newValue: Area) => {
            const a = Math.max(this.dataList[index].value - this.dataList[index].range.min, 1)
            const b = this.dataList[index].range.max - this.dataList[index].range.min
            this.pos[index] = Number(newValue.width) / b * a
          })
          .width('100%')
          .height(this.strokeWidth)
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
  @Param strokeWidth: number = 10

  build() {
    Grid() {
      ForEach(this.dataList, (item: MDashBoardData) => {
        GridItem() {
          MDashBoardV1({
            data: item,
            isGridItem: true
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap($r('app.integer.view_space'))
    .columnsGap($r('app.integer.view_space'))
  }
}

/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file HealthValueDashBoard.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-08
 * @desc
 */

import { HealthCardData, HealthCardDataType } from "../models/HealthDataModel"
import { getHealthStatusColor, getHealthStatusText } from "../utils/HealthUtils"


const TAG = 'HealthValueDashBoard.ets'

@ComponentV2
export struct HealthValueDashBoard {
  @Param @Require data: HealthCardData

  getColors(type: HealthCardDataType): Array<[ResourceColor | LinearGradient, number]> {
    let colors: Array<[ResourceColor | LinearGradient, number]> = []
    switch (type) {
      case HealthCardDataType.WeightInfo: {
        colors = [
          [new LinearGradient([{ color: "#0978ab", offset: 0 }, { color: "#439b9b", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#54baea", offset: 0 }, { color: "#b4e79c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#dbefa5", offset: 0 }, { color: "#9ec827", offset: 1 }]), 2],
          [new LinearGradient([{ color: "#b7ec7c", offset: 0 }, { color: "#f8db4c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#f1e707", offset: 0 }, { color: "#e64566", offset: 1 }]), 1],
        ]
        break;
      }

      case HealthCardDataType.BloodSugarInfo: {
        colors = [
          [new LinearGradient([{ color: "#0978ab", offset: 0 }, { color: "#439b9b", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#54baea", offset: 0 }, { color: "#b4e79c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#dbefa5", offset: 0 }, { color: "#9ec827", offset: 1 }]), 2],
          [new LinearGradient([{ color: "#b7ec7c", offset: 0 }, { color: "#f8db4c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#f1e707", offset: 0 }, { color: "#e64566", offset: 1 }]), 1],
        ]
        break;
      }

      case HealthCardDataType.UricAcidInfo: {
        colors = [
          [new LinearGradient([{ color: "#0978ab", offset: 0 }, { color: "#439b9b", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#54baea", offset: 0 }, { color: "#b4e79c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#dbefa5", offset: 0 }, { color: "#9ec827", offset: 1 }]), 2],
          [new LinearGradient([{ color: "#b7ec7c", offset: 0 }, { color: "#f8db4c", offset: 1 }]), 1],
          [new LinearGradient([{ color: "#f1e707", offset: 0 }, { color: "#e64566", offset: 1 }]), 1],
        ]
        break;
      }

      default: {
        break;
      }
    }

    return colors
  }

  @Builder
  descriptionBuilder(cardData: HealthCardData) {
    Text(cardData.other)
      .maxFontSize(12)
      .minFontSize(12)
      .fontColor("#fffa2a2d")
      .fontWeight(FontWeight.Medium)
      .width('100%')
      .height("100%")
      .textAlign(TextAlign.Center)
  }

  build() {
    Gauge({ value: 50, min: 1, max: 100 }) {
      RelativeContainer() {
        // 数值显示
        Text(`${this.data.value}`)
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


        if (this.data.unit) {
          Text(this.data.unit)
            .maxLines(1)
            .fontSize($r('app.float.font_size_normal'))
            .fontColor($r('app.color.text_666'))
            .id('__text_unit__')
            .alignRules({
              top: { anchor: '__text_value__', align: VerticalAlign.Bottom },
              middle: { anchor: '__container__', align: HorizontalAlign.Center },
            })
        }
        Text(getHealthStatusText(this.data.status))
          .maxLines(1)
          .maxFontSize(16)
          .minFontSize(12)
          .fontColor(getHealthStatusColor(this.data.status))
          .fontWeight(FontWeight.Regular)
          .id('__text_status__')
          .alignRules({
            top: { anchor: '__text_value__', align: VerticalAlign.Bottom },
            middle: { anchor: '__container__', align: HorizontalAlign.Center },
          })
          .margin({
            top: this.data.unit ? 30 : 5
          })
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
    .value(10)
    .startAngle(240)
    .endAngle(120)
    .colors(this.getColors(this.data.type))
    .description(this.descriptionBuilder(this.data))
  }
}
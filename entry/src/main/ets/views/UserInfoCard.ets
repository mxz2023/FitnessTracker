/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file UserInfoCard.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-12
 * @desc
 */

import { MLable } from "../components/MLable"
import { HealthCardDataType } from "../models/HealthDataModel";
import { Gender } from "../models/UserDataModel";
import { TypeUtils } from "../utils/TypeUtils";


@ComponentV2
export struct UserInfoCard {
  @Param nickName: string = ""
  @Param nAge: number = 0; // 年龄
  @Param nGender: Gender = Gender.UNKNOWN;
  @Param nHeight: number = 0; // 身高，单位:cm
  @Event handleClick: (type: HealthCardDataType) => void

  build() {
    Column({ space: $r('app.integer.view_content_space') }) {
      Row() {
        Text(this.nickName.length > 0 ? this.nickName : "请设置基本信息")
          .fontSize($r('app.float.font_size_large_title'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        SymbolGlyph($r('sys.symbol.doc_plaintext_and_pencil'))
          .fontSize(24)
          .fontColor([$r('app.color.text_666')])
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Row({ space: $r('app.integer.view_space') }) {
            Row() {
              MLable({ lable: "性别:" })

              Text(`${this.nGender}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))
            }.alignItems(VerticalAlign.Bottom)

            Row() {
              MLable({ lable: "年龄:" })

              Text(`${this.nAge}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))

              if (!TypeUtils.isEmptyNumber(this.nAge)) {
                MLable({ lable: " 岁" })
              }
            }.alignItems(VerticalAlign.Bottom)

            Row() {
              MLable({ lable: "身高:" })

              Text(`${this.nHeight}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))

              if (!TypeUtils.isEmptyNumber(this.nHeight)) {
                MLable({ lable: " cm" })
              }
            }.alignItems(VerticalAlign.Bottom)
          }.alignItems(VerticalAlign.Bottom)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.integer.view_radius'))
    .shadow({
      radius: $r('app.integer.view_radius'),
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.handleClick(HealthCardDataType.BaseInfo)
    })
  }
}
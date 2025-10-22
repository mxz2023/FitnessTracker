/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MNavigationTitle.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-17
 * @desc
 */

import { MIcon } from "./MIcon"
import { MMenu, MMenuItem } from "./MMenu"


export interface NavOption {
  canBack?: boolean // 是否可以返回
  height?: Length
  bgColor?: string | Color
  title?: NavTitleData
  subTitle?: NavTitleData
  more?: MMenuItem[]
}

export interface NavTitleData {
  text?: ResourceStr
  fontColor?: string
  fontSize?: number
  fontWeight?: number
}

@Builder
export function NavigationTitleBuilder(nav: NavPathStack, opt?: NavOption) {
  Column() {
    Row() {
      Row() {
        if (opt?.canBack) {
          MIcon({
            iconName: 'back',
            iconColor: [$r('app.color.black')],
            iconSize: $r('app.float.font_size_large_title'),
          }).margin({
            right: 4
          }).onClick(() => {
            nav.pop()
          })
        }
        Row() {
          Text(opt?.title?.text)
            .fontColor(opt?.title?.fontColor ?? $r('app.color.black'))
            .fontSize(opt?.title?.fontSize ?? $r('app.float.font_size_nav_title'))
            .fontWeight(opt?.title?.fontWeight ?? FontWeight.Bold)
          if (opt?.subTitle?.text) {
            Text(opt?.subTitle?.text)
              .fontColor(opt?.subTitle?.fontColor ?? $r('app.color.black'))
              .fontSize(opt?.subTitle?.fontSize ?? $r('app.float.font_size_normal'))
              .fontWeight(opt?.subTitle?.fontWeight ?? FontWeight.Normal)
              .margin({
                left: 6,
                bottom: 1
              })
          }
        }
        .height($r('app.integer.nav_bar_height'))
        .alignItems(VerticalAlign.Bottom)
        .justifyContent(FlexAlign.Start)
      }
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.Start)

      if (opt?.more && opt.more.length > 0) {
        MMenu({
          menuItems: opt?.more
        })
      }
    }
    .padding({
      left: opt?.canBack ? 4 : $r('app.integer.view_padding'),
      right: $r('app.integer.view_padding')
    })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Bottom)
  }
  .height(opt?.height ?? $r('app.integer.nav_height'))
  .justifyContent(FlexAlign.End)
}


@ComponentV2
export struct MNavigationTitle {
  declare nav: NavPathStack
  declare opt: NavOption

  build() {
    NavigationTitleBuilder(this.nav, this.opt)
  }
}
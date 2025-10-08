/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MMenu.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2025-01-17
 * @desc
 */

import { MIcon } from "./MIcon"


export interface MMenuItem {
  title: string
  icon?: string
  router?: string
  callBack?: Function
}

@ComponentV2
export struct MMenu {
  @Param menuItems: Array<MMenuItem> = []
  @Param showMenu: boolean = false
  @Event changeState: (state: boolean) => void;

  @Builder
  MenuContent() {
    List() {
      ForEach(this.menuItems, (item: MMenuItem, index: number) => {
        ListItem() {
          Text(item.title)
            .fontSize(16)
            .height(40)
            .padding({ left: 12, right: 12 })
            .onClick(() => {
              this.changeState(false)
              if (item.router) {

              } else if (item.callBack) {
                item.callBack()
              }
            })
        }
        .width('100%')
      })
    }
    .width(120)
    .borderRadius(8)
    .backgroundColor($r('app.color.white'))
    .divider({
      strokeWidth: 1,
      color: '#E3E3E3'
    })
  }

  build() {
    Column() {
      MIcon({
        iconName: 'more'
      }).bindPopup(
        this.showMenu,
        {
          builder: this.MenuContent,
          placement: Placement.Bottom, // 在按钮下方显示
          showInSubWindow: false, // 在当前窗口显示
          maskColor: '#00000000', // 透明遮罩
          popupColor: '#00000000', // 透明背景
          enableArrow: false, // 不显示箭头
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.changeState(false)
            }
          }
        }
      ).onClick(() => {
        this.changeState(true)
      })
    }
  }
}
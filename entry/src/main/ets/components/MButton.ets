/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MButton.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-28
 * @desc
 */
import { ColorConstants } from "../common/CommonDefine";
import { MIcon } from "./MIcon";

@ComponentV2
export struct MButton {
  @Param leftIcon: string = "";
  @Param rightIcon: string = "";
  @Param iconColor: string = ColorConstants.Red;
  @Param iconSize: number = 32;
  @Param text: string = '';
  @Param type: ButtonType = ButtonType.Normal;
  @Param enable: boolean = true;
  @Param textColor: ResourceColor = $r('app.color.white');
  @Param bgColor: ResourceColor = $r('app.color.primary');
  @Event onClickBlock: () => void

  build() {
    Row() {
      if (this.leftIcon) {
        MIconButton({
          iconName: this.leftIcon,
          iconSize: this.iconSize,
          iconColor: this.iconColor,
        }).margin({
          top: 4,
          bottom: 4,
          left: 8,
        })
      }

      Text(this.text)
        .fontColor(this.textColor)
        .textAlign(TextAlign.Center)
        .fontWeight(FontWeight.Medium)
        .margin({
          top: 4,
          bottom: 4,
          left: this.leftIcon ? 4:8,
          right: this.rightIcon ? 4:8,
        })
        .layoutWeight(1)

      if (this.rightIcon) {
        MIconButton({
          iconName: this.rightIcon,
          iconSize: this.iconSize,
          iconColor: this.iconColor
        }).margin({
          top: 4,
          bottom: 4,
          right: 8
        })
      }
    }
    .enabled(this.enable)
    .height($r('app.integer.view_row_height'))
    .width('100%')
    .borderRadius($r('app.integer.view_radius')) // 设置圆角为3
    .backgroundColor(this.bgColor)
    .clickEffect({
      level: ClickEffectLevel.HEAVY,
      scale: 0.8
    })
    .onClick(() => {
      // 收起键盘
      this.getUIContext().getFocusController().clearFocus();

      this.onClickBlock();
    })
  }
}


@ComponentV2
export struct MIconButton {
  @Param @Require iconName: string;
  @Param srcName: ResourceStr = "";
  @Param iconSize: number = 48;
  @Param iconColor: string = ColorConstants.Red;
  @Event handleClick: () => void;

  build() {
    Column() {
      if (this.srcName) {
        Column() {
          Image(this.srcName)
        }.padding(8).backgroundColor(ColorConstants.Red)
      } else {
        MIcon({
          iconName: this.iconName,
          iconSize: this.iconSize,
          iconColor: [this.iconColor]
        }).backgroundColor(ColorConstants.White)
      }
    }
    .clickEffect({
      level: ClickEffectLevel.HEAVY,
      scale: 0.8
    })
    .onClick(() => {
      this.handleClick()
    })
    .height(this.iconSize)
    .width(this.iconSize)
    .borderRadius(this.iconSize / 2.0)
    .clip(true)
  }
}
/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MButton.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-28
 * @desc
 */

@ComponentV2
export struct MButton {
  @Param text: string = '';
  @Param type: ButtonType = ButtonType.Normal;
  @Param enable: boolean = true;
  @Param textColor: ResourceColor = $r('app.color.white');
  @Param bgColor: ResourceColor = $r('app.color.primary');
  @Event onClickBlock: () => void

  build() {
    Button(this.text, {
      type: ButtonType.Normal
    })
      .enabled(this.enable)
      .width('100%')
      .height($r('app.integer.view_row_height'))
      .borderRadius($r('app.integer.view_radius')) // 设置圆角为3
      .backgroundColor(this.bgColor)
      .fontColor(this.textColor)
      .onClick(() => {
        // 收起键盘
        this.getUIContext().getFocusController().clearFocus();

        this.onClickBlock();
      })
  }
}
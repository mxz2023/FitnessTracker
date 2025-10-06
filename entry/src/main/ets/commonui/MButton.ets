/**
 * 自定义按钮组件
 * 提供统一的样式和行为
 */

@ComponentV2
export struct MButton {
  @Param text: string = '';
  @Param type: ButtonType = ButtonType.Normal;
  @Param bgColor: ResourceColor = $r('app.color.primary');
  @Param textColor: ResourceColor = $r('app.color.white');
  @Event onClickBlock: () => void = () => {};
  
  build() {
    Button(this.text)
      .type(this.type)
      .borderRadius($r('app.integer.view_radius')) // 设置圆角为3
      .backgroundColor(this.bgColor)
      .fontColor(this.textColor)
      .height($r('app.integer.view_row_height'))
      .width('100%')
      .onClick(() => {
        this.onClickBlock();
      })
  }
}
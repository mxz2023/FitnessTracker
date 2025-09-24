/**
 * 自定义按钮组件
 * 提供统一的样式和行为
 */

@ComponentV2
export struct MButton {
  @Param text: string = '';
  @Param type: ButtonType = ButtonType.Normal;
  @Param bgColor: string = '#4CAF50';
  @Param textColor: string = '#FFFFFF';
  @Event onClickBlock: () => void = () => {};
  
  build() {
    Button(this.text)
      .type(this.type)
      .borderRadius(3) // 设置圆角为3
      .backgroundColor(this.bgColor)
      .fontColor(this.textColor)
      .height(40)
      .width('100%')
      .onClick(() => {
        this.onClickBlock();
      })
  }
}
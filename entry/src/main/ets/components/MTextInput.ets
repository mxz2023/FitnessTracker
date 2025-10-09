/**
 * 自定义文本输入组件
 * 提供统一的样式和行为
 */


@ComponentV2
export struct MTextInput {
  @Param @Require text: string;
  @Event onText: (text: string) => void
  @Param controller: TextInputController = new TextInputController()
  @Param type: InputType = InputType.Normal;
  @Param placeholder: ResourceStr = '';
  @Param maxLength: number = 0;
  @Param passwordState: boolean = false
  @Event onPasswordState: (state: boolean) => void


  build() {
    TextInput({
      text: this.text,
      placeholder: this.placeholder,
      controller: this.controller
    })
      .type(this.type)
      .width('100%')
      .height($r('app.integer.input_height'))
      .borderRadius($r('app.integer.view_radius'))
      .placeholderColor(Color.Grey)
      .placeholderFont({
        size: $r('app.float.font_size_normal'),
        weight: FontWeight.Regular
      })
      .caretColor(Color.Blue)
      .showPasswordIcon(true)
      .showPassword(this.passwordState)
      .onSecurityStateChange((isShowPassword: boolean) => {
        // 更新密码显示状态
        this.onPasswordState(isShowPassword)
      })
      .onChange((value: string) => {
        this.onText(value)
      })
  }
}
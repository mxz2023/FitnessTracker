/**
 * 自定义文本输入组件
 * 提供统一的样式和行为
 */

@ComponentV2
export struct MTextInput {
  @Require @Param text: string | number;
  @Param type: InputType = InputType.Normal;
  @Param placeholder: string = '';
  @Param maxLength: number = 0;
  @Event onChangeBlock: (value: string) => void = (value: string) => {

  };

  build() {
    TextInput({
      text: `${this.text}`,
      placeholder: this.placeholder
    })
      .type(this.type)
      .borderRadius($r('app.integer.view_radius')) // 设置圆角为3
      .backgroundColor('#F5F5F5')
      .height($r('app.integer.view_row_height'))
      .padding({ left: 8, right: 8 })
      .onChange((value: string) => {
        let res = value
        // 限制小数点后两位
        // 检查是否是有效数字格式
        if (!/^\d*\.?\d*$/.test(res)) {
          return;
        }

        // 处理小数点后超过两位的情况
        const parts = value.split('.');
        if (parts.length > 1 && parts[1].length > 2) {
          // 截断到小数点后两位
          res = `${parts[0]}.${parts[1].substring(0, 2)}`;
        }
        this.onChangeBlock(res)
      })
      .maxLength(this.maxLength > 0 ? this.maxLength : undefined)
  }
}
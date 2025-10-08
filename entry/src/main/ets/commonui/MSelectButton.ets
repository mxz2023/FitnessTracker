/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MSelectButton.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-23
 * @desc
 */


export class MSelectItem implements SelectOption {
  value: ResourceStr = ""
  icon?: ResourceStr
  symbolIcon?: SymbolGlyphModifier

  constructor(data?:Record<string, Object>) {
    if (data?.value) {
      this.value = data.value as ResourceStr
    }
    if (data?.icon) {
      this.icon = data.icon as ResourceStr
    }
    if (data?.symbolIcon) {
      this.symbolIcon = data.symbolIcon as SymbolGlyphModifier
    }
  }
}

@ComponentV2
export struct MSelectButton {
  @Param values: Array<MSelectItem> = []
  @Param index: number = 0
  @Event onIndex: (index:number) => void
  @Param optionWidth: number = 0
  @Event onOptionWidth: (index:number) => void
  @Local private text: ResourceStr = ""
  @Local private arrowPosition: ArrowPosition = ArrowPosition.END
  @Local private space: number = 8


  aboutToAppear(): void {
    if (this.index < this.values.length) {
      this.text = this.values[this.index].value
    }
    if (this.optionWidth == 0) {
      let utils = this.getUIContext().getMeasureUtils()
      let maxWidth = 0
      this.values.forEach((item:MSelectItem)=>{
        let width = utils.measureText({
          textContent: item.value,
          fontSize:$r('app.float.font_size_normal'),
          fontWeight: FontWeight.Medium
        })
        maxWidth = Math.max(width, maxWidth)
      })
      const resWidth = this.getUIContext().px2vp(maxWidth) + 65
      this.onOptionWidth(resWidth)
    }
  }

  build() {
    Column() {
      Select(this.values)
        .backgroundColor($r('app.color.blue'))
        .borderRadius($r('app.integer.view_radius'))
        .selected(this.index)
        .value(this.text)
        .font({
          size: $r('app.float.font_size_normal'),
          weight: FontWeight.Medium
        })
        .fontColor($r('app.color.white'))
        .optionFont({
          size: $r('app.float.font_size_normal'),
          weight: FontWeight.Normal
        })
        .optionFontColor($r('app.color.black'))
        .selectedOptionFont({
          size: $r('app.float.font_size_normal'),
          weight: FontWeight.Bold
        })
        .selectedOptionFontColor($r('app.color.blue'))
        .space(this.space)
        .optionWidth(OptionWidthMode.FIT_TRIGGER)
        .arrowPosition(this.arrowPosition)
        .menuAlign(MenuAlignType.START)
        .onSelect((index: number, text?: string | undefined) => {
          this.onIndex(index)
          if (text) {
            this.text = text;
          }
        })
        .width(this.optionWidth)
        .height($r('app.integer.btn_height'))
    }
  }
}
/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MLable.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-06
 * @desc
 */

@ComponentV2
export struct MLable {
  @Param lable: string = ''

  build() {
    Text(`${this.lable}`)
      .fontSize($r('app.float.font_size_normal'))
      .fontColor($r('app.color.text_666'))
  }
}

/******************************* MTitle Begin *********************************/
export interface TitleData {
  text?: string
  color?: ResourceColor
  size?: number
}

@ComponentV2
export struct MTitle {
  @Param @Require data: TitleData

  build() {
    Text(`${this.data.text}`)
      .fontColor(this.data.color)
      .fontSize(this.data.size)
  }
}

/******************************* MTitle End *********************************/
@ComponentV2
export struct MStatusLable {
  @Param @Require title: TitleData
  @Param @Require status: boolean | undefined = undefined

  build() {
    Row({ space: 4 }) {
      if (this.title.text) {
        Text(this.title.text)
          .fontSize($r('app.float.font_size_small'))
          .fontColor(this.title.color)
      }
      SymbolGlyph($r('sys.symbol.circle_inset_filled'))
        .fontSize($r('app.float.font_size_normal'))
        .fontColor([this.title.color])
    }
  }
}
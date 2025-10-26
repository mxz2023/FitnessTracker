/**
 * Copyright (c) 2023-2024 Mxz Co., Ltd.
 *
 * @file MIcon.ets
 * @project TimeImprint
 * @author vincent_gemini
 * @crateTime 2024-12-28
 * @desc
 */


@ComponentV2
export struct MIcon {
  @Param iconName: string = ""
  @Param iconSize: Length = 32
  @Param iconColor: ResourceColor[] = [$r('app.color.black')]
  @Param renderingStrategy: SymbolRenderingStrategy = SymbolRenderingStrategy.SINGLE
  @Local private symbolName?: Resource

  @Monitor('iconName')
  onIconChange(monitor: IMonitor) {
    this.updateIcon()
  }

  private updateIcon() {
    let mapData: Record<string, Resource> = {
      "home": $r('sys.symbol.house_fill'), // 首页
      "plaza": $r('sys.symbol.square_fill_grid_2x2'), // 成长
      "record": $r('sys.symbol.square_stack_3d_fill'), // 成长
      "mine": $r('sys.symbol.person_fill'), // 我的

      "smile": $r('sys.symbol.face_smiling_fill'), // 情绪快捷
      "time": $r('sys.symbol.alarm_fill'), // 时间快捷
      "run": $r('sys.symbol.figure_running'), // 运动快捷
      "account": $r('sys.symbol.bookmark_notepad_fill'), // 记账快捷
      "book": $r('sys.symbol.book_pages_fill'), // 书库快捷
      "leaf": $r('sys.symbol.mapleleave_fill'), // 叶子

      'setting': $r('sys.symbol.gearshape'), // 设置
      'agreement': $r('sys.symbol.doc_text'), // 协议
      'contact': $r('sys.symbol.message_on_message'), // 联系
      'service': $r('sys.symbol.service_fill'), // 客服
      'about': $r('sys.symbol.info_circle'), //关于

      "back": $r('sys.symbol.chevron_left'), // 返回按钮
      "more": $r('sys.symbol.more'), // 更多
      "more_arrow": $r('sys.symbol.chevron_right'), // 更多（箭头样式）
      "label": $r('sys.symbol.label'), // 标签
      "share": $r('sys.symbol.share'), // 分享
      "check_circle": $r('sys.symbol.checkmark_circle_fill'), // 圆形样式
      "check_square": $r('sys.symbol.checkmark_square_fill'), // 方形样式
      "hand": $r('sys.symbol.hand_thumbsup_fill'), // 点赞
      "hear": $r('sys.symbol.heart_fill'), // 收藏(心形样式)
      "star": $r('sys.symbol.star_fill'), // 收藏(星星样式)

      "close": $r('sys.symbol.xmark'), // 关闭x(线型)
      "+": $r('sys.symbol.plus_circle_fill'), // 填充加号(圆形)
      "-": $r('sys.symbol.minus_circle_fill'), // 填充减号(圆形)
      "x": $r('sys.symbol.xmark_circle_fill'), // 填充乘号(圆形)
      ">": $r('sys.symbol.play_fill'), // 填充大于号(右箭头)
      "^":$r('sys.symbol.triangleshape_fill') // 填充尖号(上箭头)
    }

    this.symbolName = mapData[this.iconName]
  }

  aboutToAppear(): void {
    this.updateIcon()
  }

  build() {
    if (this.symbolName) {
      SymbolGlyph(this.symbolName)
        .fontSize(this.iconSize)
        .fontColor(this.iconColor)
        .renderingStrategy(this.renderingStrategy)
    }
  }
}
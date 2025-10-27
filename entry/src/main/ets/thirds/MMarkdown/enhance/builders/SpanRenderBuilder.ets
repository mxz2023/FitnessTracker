import { TextImpl } from '../impl/TextImpl'
import { TextNode, TreeNode } from '../model/TreeNode'

/**
 * ParagraphRender need use
 * @param data
 */
@Builder
export function SpanRenderBuilder(markdownUnion: string, data: ESObject) {
  if (data?.type == "text" || data?.type == "inlineCode" || data?.type == "footnoteRef") {
    BaseSpanRenderBuilder(markdownUnion, data)
  } else {
    ForEach(data?.children, (item: TreeNode) => {
      if (item.type == "text") {
        BaseSpanRenderBuilder(markdownUnion, {
          text: item.text, type: data?.type,
          url: data?.type == "link" ? data?.url : undefined
        }, data)
      } else {
        if (item?.type == "inlineCode") {
          BaseSpanRenderBuilder(markdownUnion, item, data)
        } else {
          // 被其他语法包裹的文本
          ForEach(item.children, (item2: TextNode) => {
            BaseSpanRenderBuilder(markdownUnion, {
              text: item2.text,
              type: item.type,
              url: item.type == "link" ? item.url : undefined
            }, data)
          })
        }
      }
    })
  }
}

/**
 * 根文本渲染
 * @param data 节点数据
 * @param baseType 根节点类型
 */
@Builder
export function BaseSpanRenderBuilder(markdownUnion: string, data: ESObject, base?: TreeNode) {
  if (TextImpl.handleText(data)) {
    Span(TextImpl.handleText(data))
      .fontWeight(TextImpl.handleFontWeight(data, base?.type))
      .fontStyle(TextImpl.handleFontStyle(data, base?.type))
      .fontColor(TextImpl.handleFontColor(markdownUnion, data))
      .textBackgroundStyle({ color: TextImpl.handleBackgroundColor(markdownUnion, data), radius: 5 })
      .decoration(TextImpl.handleDecoration(markdownUnion, data))
      .lineHeight(TextImpl.handleLineHeight(markdownUnion, base))
      .fontSize(TextImpl.handleFontSize(markdownUnion, data, base))
      .onClick(() => {
        TextImpl.handleClick(markdownUnion, data)
      })
  }
}


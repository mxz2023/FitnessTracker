import { ImageBuilder } from '../builders/ImageBuilder'
import { TreeNode } from '../model/TreeNode'
import { SpanRenderBuilder } from '../builders/SpanRenderBuilder'
import { TextImpl } from '../impl/TextImpl'

@Component
export struct ParagraphRender {
  @Consume markdownUnion: string
  @State base: TreeNode | undefined = undefined

  build() {
    Column({ space: 10 }) {
      // Flex({
      //   wrap: FlexWrap.Wrap,
      //   direction: FlexDirection.Row
      // }) {
      //   ForEach(this.base?.children, (item: TreeNode) => {
      //     // Text(JSON.stringify(item))
      //     if (item.type == "image") {
      //       ImageRender({ image: item })
      //     } else {
      //       TextRender({ base: item })
      //     }
      //   })
      // }


      Text() {
        ForEach(this.base?.children, (item: TreeNode) => {
          if (item.type == "image") {
            ImageBuilder(this.markdownUnion, item)
          } else {
            SpanRenderBuilder(this.markdownUnion, item)
          }
        })
      }
      .lineHeight(TextImpl.handleLineHeight(this.markdownUnion))
      .fontSize(TextImpl.handleFontSize(this.markdownUnion))
    }
    .alignItems(HorizontalAlign.Start)
  }
}
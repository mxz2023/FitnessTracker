import { BaseSpanRenderBuilder } from '../builders/SpanRenderBuilder';
import { TextNode, TreeNode } from '../model/TreeNode';

@Component
export struct TextRender {
  @Consume markdownUnion: string
  @State base: TreeNode | undefined = undefined

  build() {
    Text() {
      ContainerSpan() {
        if (this.base?.type == "text" || this.base?.type == "inlineCode" || this.base?.type == "footnoteRef") {
          BaseSpanRenderBuilder(this.markdownUnion, this.base)
        } else {
          ForEach(this.base?.children, (item: TreeNode) => {
            if (item.type == "text") {
              // 传递根节点类型
              BaseSpanRenderBuilder(this.markdownUnion, {
                text: item.text,
                type: this.base?.type,
                url: this.base?.type == "link" ? this.base?.url : undefined
              }, this.base)
            } else {
              if (item?.type == "inlineCode") {
                BaseSpanRenderBuilder(this.markdownUnion, item, this.base)
              } else {
                // 被其他语法包裹的文本
                ForEach(item.children, (item2: TextNode) => {
                  BaseSpanRenderBuilder(this.markdownUnion, {
                    text: item2.text,
                    type: item.type,
                    url: item.type == "link" ? item.url : undefined
                  }, this.base)
                })
              }
            }
          })
        }
      }
    }
    .copyOption(CopyOptions.LocalDevice)
    .margin({
      top: (this.base?.type == "heading") ? 6 : null,
      bottom: (this.base?.type == "heading") ? 6 : null
    })
  }
}
import { TreeNode } from '../model/TreeNode'
import { BlockquoteRender } from './BlockquoteRender'
import { CodeRender } from './CodeRender'
import { FootnotesRender } from './FootnotesRender'
import { LineRender } from './LineRender'
import { OlRender } from './OlRender'
import { ParagraphRender } from './ParagraphRender'
import { TableRender } from './TableRender'
import { TextRender } from './TextRender'
import { UlRender } from './UlRender'

@Component
export struct IntactRender {
  @Prop children: TreeNode[] = []

  build() {
    Column({ space: 12 }) {
      ForEach(this.children, (item: TreeNode) => {
        if (item.type == "hr") {
          LineRender()
        }
        if (item.type == "paragraph") {
          ParagraphRender({ base: item })
        }
        if (item.type == "heading") {
          TextRender({ base: item })
        }
        if (item.type == "blockquote") {
          BlockquoteRender({ base: item })
        }
        if (item.type == "ul") {
          UlRender({ base: item })
        }
        if (item.type == "ol") {
          OlRender({ base: item })
        }
        if (item.type == "table") {
          TableRender({ base: item })
        }
        if (item.type == "codeBlock") {
          CodeRender({ base: item })
        }
        if (item.type == "footnotes") {
          FootnotesRender({ base: item })
        }
      })
    }
    .alignItems(HorizontalAlign.Start)
  }
}
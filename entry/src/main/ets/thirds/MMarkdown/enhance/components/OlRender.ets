import { TextImpl } from '../impl/TextImpl'
import { TreeNode } from '../model/TreeNode'
import { generateRandomString } from '../utils/RandomString'
import { BlockquoteRender } from './BlockquoteRender'
import { ParagraphRender } from './ParagraphRender'
import { UlRender } from './UlRender'

const TAG = "OlRender"

@Component
export struct OlRender {
  @Consume markdownUnion: string
  @State base: TreeNode | undefined = undefined
  @State idxWidth: Length[] = []

  aboutToAppear(): void {
    // 提前设置列表宽度，避免快速渲染时闪屏
    if (this.base?.children) {
      for (let i: number = 0; i < this.base?.children.length || 0; i++) {
        if (i < 10) {
          this.idxWidth.push(29)
        } else {
          this.idxWidth.push(34)
        }
      }
    }
  }

  build() {
    if (this.base) {
      Column() {
        ForEach(this.base?.children, (item: TreeNode, fIdx: number) => {
          if (item.type == "listItem") {
            Row() {
              Column() {
                Text(fIdx + 1 + ". ")
                  .fontSize(TextImpl.handleFontSize(this.markdownUnion))
                  .fontColor(TextImpl.handleFontColor(this.markdownUnion, item))
                  .lineHeight(TextImpl.handleLineHeight(this.markdownUnion))
              }
              .padding({ left: 12 })
              .height(TextImpl.handleLineHeight(this.markdownUnion))
              .justifyContent(FlexAlign.Center)
              .width(this.idxWidth[fIdx])

              Column() {
                ForEach(item?.children, (item2: TreeNode, idx: number) => {
                  if (item2.type == "paragraph") {
                    ParagraphRender({ base: item2 })
                  }
                  if (item2.type == "ol") {
                    OlRender({ base: item2 })
                  }
                  if (item2.type == "ul") {
                    UlRender({ base: item2 })
                  }
                  if (item2.type == "blockquote") {
                    BlockquoteRender({ base: item2 })
                  }
                })
              }
              .width(`calc(100% - ${this.idxWidth[fIdx]}vp)`)
              .alignItems(HorizontalAlign.Start)
            }
            .alignItems(VerticalAlign.Top)
          }
        })
      }
      .margin({ top: 4 })
      .width("100%")
      .alignItems(HorizontalAlign.Start)
      .clip(true)
    }
  }
}
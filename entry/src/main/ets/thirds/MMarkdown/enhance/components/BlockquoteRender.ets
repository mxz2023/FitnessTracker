import { QuoteImpl } from '../impl/QuoteImpl';
import { TreeNode } from '../model/TreeNode';
import { IntactRender } from './IntactRender';

@Component
export struct BlockquoteRender {
  @Consume markdownUnion: string
  @State base: TreeNode | undefined = undefined

  build() {
    if (this.base && this.base.children) {
      Column() {
        IntactRender({ children: this.base.children as TreeNode[] })
      }
      .margin({ top: 5, bottom: 5 })
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .backgroundColor(QuoteImpl.handleBackgroundColor(this.markdownUnion))
      .padding({
        left: 12,
        top: 10,
        right: 10,
        bottom: 14
      })
      .border({
        color: {
          left: QuoteImpl.handleBorderColor(this.markdownUnion)
        },
        style: {
          left: BorderStyle.Solid
        },
        width: {
          left: '6',
          right: '0',
          top: '0',
          bottom: '0'
        }
      })
    }
  }
}
import { TableImpl } from '../impl/TableImpl';
import { TableCellNode, TableNode, TableRowNode, TreeNode } from '../model/TreeNode';
import { TextRender } from './TextRender';

@Component
export struct TableRender {
  @Consume markdownUnion: string
  @State base: TableNode | undefined = undefined
  @State cellWidthArrayIndexed: number[] = []

  build() {
    Row() {
      List() {
        ListItem() {
          Column() {
            TableCellRender({ base: this.base, cellWidthArrayIndexed: this.cellWidthArrayIndexed })
            TableRowRender({
              base: this.base,
              cellWidthArrayIndexed: this.cellWidthArrayIndexed
            })
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .borderRadius(14)
      .clip(true)
      .backgroundColor(TableImpl.handleTableBackgroundColor(this.markdownUnion))
      .listDirection(Axis.Horizontal)
    }
    .margin({ bottom: 6 })
    .constraintSize({ maxWidth: "100%" })
  }
}

@Component
struct TableCellRender {
  @Consume markdownUnion: string
  @State base: TableNode | undefined = undefined
  @Link cellWidthArrayIndexed: number[]

  build() {
    Row() {
      ForEach(this.base?.header, (item: TableCellNode, index: number) => {
        if (item.type == "tableCell") {
          ForEach(item.children, (paragraph: TreeNode) => {
            ForEach(paragraph.children, (head: TreeNode) => {
              Column() {
                TextRender({ base: head })
              }
              .alignItems(TableImpl.handleTextAlign(this.base?.align?.[index]))
              .padding({
                top: 8,
                bottom: 8,
                left: 12,
                right: 12
              })
              .width(this.cellWidthArrayIndexed[index] ? this.cellWidthArrayIndexed[index] : 140)
              .clip(true)
            })
          })
        }
      })
    }
    .backgroundColor(TableImpl.handleTableTitleBackgroundColor(this.markdownUnion))
  }
}

@Component
struct TableRowRender {
  @Consume markdownUnion: string
  @State base: TableNode | undefined = undefined
  @Link cellWidthArrayIndexed: number[]

  build() {
    Column() {
      ForEach(this.base?.rows, (item: TableRowNode, index: number) => {
        Row() {
          if (item.type == "tableRow") {
            ForEach(item.children, (paragraph: TreeNode, colIdx: number) => {
              ForEach(paragraph.children, (row: TreeNode) => {
                Column() {
                  TextRender({ base: row })
                }
                .alignItems(TableImpl.handleTextAlign(this.base?.align?.[colIdx]))
                .padding({
                  top: 8,
                  bottom: 8,
                  left: 12,
                  right: 12
                })
                // .border({
                //   width: {
                //     left: colIdx == 0 ? 0 : (colIdx % 2 === 0 ? 0 : 1),
                //     right: colIdx == (item.children.length - 1) ? 0 : (colIdx % 2 === 0 ? 0 : 1),
                //     top: index == 0 ? 0 : (index % 2 === 0 ? 0 : 1),
                //     bottom: index == ((this.base?.rows?.length) || 0 - 1) ? 0 : (index % 2 === 0 ? 0 : 1),
                //   },
                //   color: "#F5F7FA"
                // })
                // .width(this.cellWidthArrayIndexed[index] ? this.cellWidthArrayIndexed[index] : 140)
                .constraintSize({
                  minWidth: this.cellWidthArrayIndexed[colIdx] || 140,
                  maxWidth: 260
                })
                .onAreaChange((oldValue: Area, newValue: Area) => {
                  let oldWidth: number = Math.ceil(oldValue.width as number)
                  let newWidth: number = Math.ceil(newValue.width as number)
                  // 表格渲染时，如果有一行的列宽度为最大限制，则直接停止，无序再计算
                  if (this.cellWidthArrayIndexed[colIdx] == 260) {
                    return
                  }
                  if (oldWidth != newWidth && newWidth != 140 && newWidth <= 260) {
                    // 新行的列宽大于上一次赋值则使用新值
                    if (!this.cellWidthArrayIndexed[colIdx] || newWidth > this.cellWidthArrayIndexed[colIdx]) {
                      this.cellWidthArrayIndexed[colIdx] = newWidth
                    }
                  }
                })
                .clip(true)
              })
            })
          }
        }
        .backgroundColor(index % 2 === 0 ? TableImpl.handleTableBackgroundColor(this.markdownUnion) :
        TableImpl.handleTableInterleaveBackgroundColor(this.markdownUnion))
      })
    }
    .alignItems(HorizontalAlign.Start)
  }
}
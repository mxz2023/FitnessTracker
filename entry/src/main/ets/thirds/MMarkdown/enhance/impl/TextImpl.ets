import { MDBaseController } from '../controller/BaseController';
// import { WebDialogController } from '../controller/WebDialogController';
import { BaseNode, FootnoteRefNode, TextNode, TreeNode } from '../model/TreeNode';

export namespace TextImpl {
  export function handleFontColor(markdownUnion: string, data: ESObject): ResourceColor {
    // 行内代码
    if ((data as TreeNode)?.type == "inlineCode") {
      return MDBaseController.getMarkdownController(markdownUnion).getInlineCodeColor()
    }
    // 超链接
    // if ((data as TreeNode)?.type == "link") {
    //   return MDBaseController.getMarkdownController(markdownUnion).getHyperlinkTextColor()
    // }
    // 超链接
    if ((data as TreeNode)?.type == "heading") {
      return MDBaseController.getMarkdownController(markdownUnion).getTitleColor()
    }
    // 脚注
    if ((data as TreeNode)?.type == "footnoteRef") {
      return MDBaseController.getMarkdownController(markdownUnion).getFootnoteTextColor()
    }
    // 默认颜色
    return MDBaseController.getMarkdownController(markdownUnion).getTextColor()
  }

  export function handleBackgroundColor(markdownUnion: string, data: ESObject) {
    // 行内代码背景色
    if ((data as TreeNode)?.type == "inlineCode") {
      return MDBaseController.getMarkdownController(markdownUnion).getInlineCodeBackgroundColor()
    }
    // 默认背景颜色
    return null
  }

  export function handleDecoration(markdownUnion: string, data: ESObject): DecorationStyleInterface {
    // 删除线
    if ((data as TreeNode)?.type == "strikethrough") {
      return {
        type: TextDecorationType.LineThrough,
        color: MDBaseController.getMarkdownController(markdownUnion).getTextColor()
      }
    }
    // 下划线
    if ((data as TreeNode)?.type == "link") {
      if (MDBaseController.getMarkdownController(markdownUnion).getHyperlinkUnderlineState()) {
        return {
          type: TextDecorationType.Underline,
          color: MDBaseController.getMarkdownController(markdownUnion).getHyperlinkTextColor(),
          style: TextDecorationStyle.SOLID
        }
      } else {
        return { type: TextDecorationType.None }
      }
    }
    // 默认背景颜色
    return { type: TextDecorationType.None }
  }

  export function handleText(data: TreeNode | TextNode | FootnoteRefNode) {
    // 行内代码增加左右空格，美观
    if (data?.type == "inlineCode") {
      return ` ${data?.text} `
    }
    // 脚注
    if (data?.type == "footnoteRef") {
      return `[${data.id}]`
    }
    return (data as TextNode)?.text.replace("<br>", "\n")
  }

  export function handleFontWeight(data: ESObject, baseType?: string) {
    if (baseType == "heading" || baseType == "bolditalic") {
      return FontWeight.Bold
    }
    return (data?.type == "bold" || data?.type == "heading") ? FontWeight.Bold : null
  }

  export function handleFontStyle(data: ESObject, baseType?: string) {
    if (baseType == "bolditalic") {
      return FontStyle.Italic
    }
    return data?.type == "italic" ? FontStyle.Italic : FontStyle.Normal
  }

  export function handleLineHeight(markdownUnion: string, base?: TreeNode): ResourceStr | number {
    let r: ResourceStr | number = MDBaseController.getMarkdownController(markdownUnion).getTextLineHeight()
    if (base?.type == "heading") {
      switch (base?.level) {
        case 1:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[0]
          break;
        case 2:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[1]
          break;
        case 3:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[2]
          break;
        case 4:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[3]
          break;
        case 5:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[4]
          break;
        case 6:
          r = MDBaseController.getMarkdownController(markdownUnion).getTitleLineHeight()[5]
          break;
      }
    }
    return r
  }

  export function handleFontSize(markdownUnion: string, data?: BaseNode | undefined, base?: TreeNode | undefined) {
    let r: ResourceStr | number = MDBaseController.getMarkdownController(markdownUnion).getTextSize()
    // 脚注
    if (data?.type == "footnoteRef") {
      return 13
    } else {
      if (base?.type == "heading") {
        switch (base.level) {
          case 1:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[0]
            break;
          case 2:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[1]
            break;
          case 3:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[2]
            break;
          case 4:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[3]
            break;
          case 5:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[4]
            break;
          case 6:
            r = MDBaseController.getMarkdownController(markdownUnion).getTitleSize()[5]
            break;
        }
      }
    }
    return r
  }

  export function handleClick(markdownUnion: string, data: ESObject) {
    // if (data && data.type == "link") {
    //   let title: string = data?.text || ""
    //   let url: string = data?.url || ""
    //   let h = MDBaseController.getMarkdownController(markdownUnion).getHyperlinkClickListener()
    //   if (!h(title, url)) {
    //     WebDialogController.getInstance().openBindSheet(title, url)
    //   }
    // }
  }
}
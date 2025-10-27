import { MDBaseController } from '../controller/BaseController';

export namespace TableImpl {
  export function handleTableBackgroundColor(markdownUnion: string): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getTableBackgroundColor()
  }

  export function handleTableTitleBackgroundColor(markdownUnion: string,): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getTableTitleBackgroundColor()
  }

  export function handleTableInterleaveBackgroundColor(markdownUnion: string,): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getTableInterleaveBackgroundColor()
  }

  export function handleTextAlign(type: "none" | "left" | "center" | "right" | string | undefined) {
    if (type == "left") {
      return HorizontalAlign.Start
    }
    if (type == "center") {
      return HorizontalAlign.Center
    }
    if (type == "right") {
      return HorizontalAlign.End
    }
    return HorizontalAlign.Start
  }
}
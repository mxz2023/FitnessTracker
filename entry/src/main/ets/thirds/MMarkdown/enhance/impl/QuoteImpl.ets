import { MDBaseController } from '../controller/BaseController';

export namespace QuoteImpl {
  export function handleBorderColor(markdownUnion: string): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getQuoteBorderColor()
  }

  export function handleBackgroundColor(markdownUnion: string): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getQuoteBackgroundColor()
  }
}
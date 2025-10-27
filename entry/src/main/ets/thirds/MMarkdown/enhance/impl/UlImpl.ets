import { MDBaseController } from '../controller/BaseController';

export namespace UlImpl {
  export function handleTodoSelectedColor(markdownUnion: string): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getTodoSelectedColor()
  }

  export function handleTodoSelectedSize(markdownUnion: string): ResourceColor {
    return MDBaseController.getMarkdownController(markdownUnion).getTodoSelectSize()
  }
}
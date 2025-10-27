import { CodeTheme, markdownCodeThemeChangeEventName } from '../constant/CodeTheme';
import { MDBaseController } from '../controller/BaseController';
import { CodeHighlight } from '../model/CodeHighlight';
import { BusinessError, pasteboard } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { Logger } from '../utils/Logger';

export namespace CodeBlockImpl {
  export function handleBackgroundColor(them: CodeTheme) {
    if (them == "dark") {
      return "#181A1F"
    } else {
      return "#F9FAFB"
    }
  }

  export function handleThemeChange(markdownUnion: string, them: CodeTheme) {
    Logger.info("markdownUnion > " + markdownUnion)
    handleCodeHighlight(markdownUnion, them)
    getContext().eventHub.emit(markdownCodeThemeChangeEventName)
  }

  // export async function copyText(text: string) {
  //   let pasteData = pasteboard.createPlainTextData(text);
  //   let systemPasteboard = pasteboard.getSystemPasteboard();
  //   await systemPasteboard.setData(pasteData).then((data) => {
  //     promptAction.showToast({
  //       message: '复制成功'
  //     });
  //   }).catch((err: BusinessError) => {
  //     // 此处不知道是不是真机有bug实际是复制成功了，模拟器中复制进入then
  //     promptAction.showToast({
  //       message: '复制成功'
  //       // message: '复制失败' + err.message
  //     });
  //   });
  // }

  export function handleCodeHighlight(markdownUnion: string, them: CodeTheme) {
    if (them == "dark") {
      MDBaseController.getMarkdownController(markdownUnion).setCodeHighlight({
        keyword: '#E2DA85', // 关键字
        method: '#65CCDC', // 方法名
        type: '#CC7830', // 类型
        modifier: '#4169e1', // 修饰符
        constant: '#FFFFF6', // 常量
        variable: '#FFFFF6', // 变量
        operator: '#E2DA90', // 运算符
        punctuation: '#E2DA90', // 标点
        brace: '#ffea78a3', // 括号
        bigBrace: '#FAA23D', //大括号
        string: '#AA7DFC', // 字符串
        number: '#B3E54C', // 数字 |
        boolean: '#E2DA90', // 布尔值
        nullish: '#E2DA90', // 空值
        promise: '#CC6B32', // Promise
        tag: '#008b8b', // HTML标签
        attrName: '#CC6B32', // 属性名
        attrValue: '#ff50641c', // 属性值
        doctype: '#ff8c00', // 文档声明
        comment: '#80807C', // 注释
        decorator: '#ffe559a0', // ArkTS 装饰器
        component: '#20b2aa', // ArkTS UI组件
        normal: '#ffe5e5de'         // 普通文本
      })
    }
    if (them == "light") {
      MDBaseController.getMarkdownController(markdownUnion).setCodeHighlight(new CodeHighlight())
    }
  }
}
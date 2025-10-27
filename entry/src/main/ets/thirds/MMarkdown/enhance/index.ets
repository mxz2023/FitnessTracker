import { MDBaseController } from './controller/BaseController';
import { MarkdownController } from './controller/MarkdonwController';
import { TreeNode } from './model/TreeNode';
import { parseMarkdown } from './utils/ast';

import { buffer } from '@kit.ArkTS';
import { fileIo as fs, ReadTextOptions } from '@kit.CoreFileKit';
import { IntactRender } from './components/IntactRender';
import { MdCallback } from './model/MdCallback';
import { htmlToMarkdown } from './utils/html2md';
import { Logger } from './utils/Logger';

const TAG = "LV-MARKDOWN-IN"

/**
 * 承载 Markdown 内容渲染的组件。
 *
 * @controller 通过 MarkdownController 可以控制 Markdown 组件各种行为，如：自定义样式、设置图片点击拦截、设置超链接点击拦截等。
 * @text markdown 文本内容。
 * @mode Markdown 组件加载模式，支持纯文本加载、沙箱文件加载、资源文件加载，不填默认为 "text"。
 * @context mode 字段设置为 rawfile 时， context 为必填项。
 * @rawfilePath mode 字段设置为 rawfile 时， rawfilePath 为必填项，需传入 resources/rawfile 目录下对应的 rawfile 文件路径。
 * @sandboxPath mode 字段设置为 sandbox 时， sandboxPath 为必填项，需传入沙箱 text/md 文件的完整沙箱路径。例：getContext().getApplicationContext().filesDir + "/t2/text.md"。
 * @call callback回调方法，Markdown 组件加载状态结果告知。用于组件加载完成时，组件加载失败时回调，并返回错误码 code，错误信息 message，可用于问题分析。
 */
@Component
export struct Markdown {
  controller: MarkdownController = new MarkdownController()
  @Provide markdownUnion: string = ""
  /** 纯文本数据，mode：text */
  @Prop @Watch("_readText") text: string = "";
  /** 加载模式：
   * text：纯文本模式
   * rawfile：rawfile资源文件模式
   * sandbox：本地沙箱路径文件模式
   */
  @Prop mode: "text" | "rawfile" | "sandbox" = "text";
  /**
   * 资源文件path
   */
  @Prop rawfilePath: string
  /**
   * 沙箱文件path
   */
  @Prop sandboxPath: string
  /**
   * 应用上下文
   */
  context: Context | undefined = undefined
  // 增强node集合
  @State private treeNode: TreeNode[] = []
  /**
   * 事件回调
   */
  callback: MdCallback = {
    complete() {
    },
    fail(code: number, message: string) {
    }
  }

  baseCallback(type: "success" | "fail", code?: number, message?: string) {
    if (type == "success") {
      if (this.callback.complete) {
        this.callback?.complete()
      }
    }
    if (type == "fail") {
      if (this.callback.fail && code && message) {
        this.callback?.fail(code, message)
      }
    }
  }

  aboutToAppear(): void {
    Logger.infoForce(TAG, "Thank you for using.")
    this.markdownUnion = this.controller.getUnion()
    this.handleLodeType()
  }

  aboutToDisappear(): void {
    MDBaseController.destroyMarkdownUnion(this.markdownUnion)
  }

  handleLodeType() {
    if (this.mode == "text") {
      this._readText()
    }
    if (this.mode == "rawfile") {
      this._loadRawfile()
    }
    if (this.mode == "sandbox") {
      this._loadSandbox()
    }
  }

  // 1
  _loadRawfile() {
    if (!this.rawfilePath) {
      this.baseCallback("fail", 50011, "The rawfile resource file is incorrect.")
      return
    }
    if (!this.context) {
      this.baseCallback("fail", 50030, "The context is incorrect.")
      return
    }
    try {
      let uint8Array: Uint8Array = this.context?.resourceManager.getRawFileContentSync(this.rawfilePath);
      let bf = buffer.from(uint8Array).buffer;
      let bf2 = new buffer.Blob([bf]);
      let pro = bf2.text();
      pro.then((str: string) => {
        this.text = str
        this._readText()
      });

    } catch (error) {
      this.baseCallback("fail", 50012, "The resourceManager getRawFileContentSync is error, " +
      JSON.stringify(error))
    }
  }

  // 2
  _loadSandbox() {
    if (!this.sandboxPath) {
      this.baseCallback("fail", 50021, "The sandbox file is incorrect.")
      return
    }
    try {
      let readTextOptions: ReadTextOptions = {
        offset: 0,
        length: 0,
        encoding: 'utf-8'
      };
      let stat = fs.statSync(this.sandboxPath);
      readTextOptions.length = stat.size;
      this.text = fs.readTextSync(this.sandboxPath, readTextOptions);
      this._readText()
    } catch (error) {
      this.baseCallback("fail", 50022, "The fileIo readText is error, " +
      JSON.stringify(error))
    }
  }

  _readText() {
    let src = this.text
    Logger.info(TAG, "_readText > " + src)
    src = htmlToMarkdown(src) as string
    this.treeNode = parseMarkdown(src) as TreeNode[]
    Logger.info(TAG, "htmlToMarkdown > " + src)
    src = ""
  }

  build() {
    if (this.treeNode.length > 0) {
      IntactRender({ children: this.treeNode })
        .onAppear(() => {
          this.baseCallback("success")
        })
    }
  }
}
import { CodeTheme } from '../constant/CodeTheme';
import { CodeBlockImpl } from '../impl/CodeBlockImpl';
import { CodeHighlight } from '../model/CodeHighlight';
import { generateRandomString } from '../utils/RandomString';
import { MDBaseController } from './BaseController';

/**
 * @description Markdown 组件的控制器，可以将此对象绑定至 Markdown 组件，然后通过它控制 Markdown 组件的自定义样式。同一个控制器可以控制多个 Markdown 组件，多个 API 支持链式调用语法。
 */
@ObservedV2
export class MarkdownController {
  // 随机字符串
  private union: string = ""
  // ** ================================================= 标题 ==================================================== **
  // 标题-文字颜色
  @Trace private titleColor: ResourceColor = "#ff1d2c39"
  // 标题-字号（1-6级）
  @Trace private titleSize: [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number] =
    [30, 28, 24, 20, 18, 16]
  // 标题-行高（1-6级）
  @Trace private titleLineHeight: [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number] =
    [36, 34, 30, 26, 24, 22]
  // ** ================================================= 普通文本 ==================================================== **
  // 普通文本-颜色
  @Trace private textColor: ResourceColor = "#e61f1f39"
  // 普通文本-行高
  @Trace private textLineHeight: ResourceStr | number = 24
  // 普通文本-字号
  @Trace private textSize: ResourceStr | number = 16
  // ** ================================================= 行内代码 ==================================================== **
  // 行内代码-颜色
  @Trace private inlineCodeColor: ResourceColor = "#F4271C"
  // 行内代码-背景颜色
  @Trace private inlineCodeBackgroundColor: ResourceColor = "#0eff0000"
  // ** ================================================= 引用块 ==================================================== **
  // 引用块-左边颜色
  @Trace private quoteBorderColor: ResourceColor = "#F4271C"
  // 引用块-背景颜色
  @Trace private quoteBackgroundColor: ResourceColor = "#ccf5f7fa"
  // ** ================================================= 代码块 ==================================================== **
  // 代码块-主题
  @Trace private codeBlockTheme: CodeTheme = "light"
  // 代码块-索引控制
  @Trace private codeBlockIdxState: boolean = false
  // 代码块-代码高亮
  @Trace private codeHighlight: CodeHighlight = new CodeHighlight()
  // ** ================================================= 图片 ==================================================== **
  // 图片-宽度
  @Trace private imageWidth: ResourceStr | number | null = "100%"
  // 图片-最大宽度
  @Trace private imageMaxWidth: ResourceStr | number | null = null
  // 图片-高度
  @Trace private imageHeight: ResourceStr | number | null = null
  // 图片-最大高度
  @Trace private imageMaxHeight: ResourceStr | number | null = null
  // 图片-点击监听回调
  @Trace private imageClickListener: (src: string) => boolean = (src: string) => {
    return false
  }
  // 图片-加载代理
  @Trace private imageLoadProxy: (src: string) => string = (src: string) => {
    return src
  }
  // ** ================================================= 超链接 ==================================================== **
  // 超链接-文字颜色
  @Trace private hyperlinkTextColor: ResourceColor = "#0664EC"
  // 超链接-下划线展示状态
  @Trace private hyperlinkUnderlineState: boolean = false
  // 图片-点击监听回调
  @Trace private hyperlinkClickListener: (title: string, src: string) => boolean = (src: string) => {
    return false
  }
  // ** ================================================= 表格 ==================================================== **
  // 表格-背景色
  @Trace private tableBackgroundColor: ResourceColor = "#FFFFFF"
  // 表格-表头背景色
  @Trace private tableTitleBackgroundColor: ResourceColor = "#F5F7FA"
  // 表格-错行背景色
  @Trace private tableInterleaveBackgroundColor: ResourceColor = "#80f5f7fa"
  // ** ================================================= 任务列表 ==================================================== **
  // 任务列表-选中颜色
  @Trace private todoSelectedColor: ResourceColor = "#0A59F7"
  // 任务列表-选项大小
  @Trace private todoSelectSize: ResourceStr | number = 16
  // ** ================================================= 脚注 ==================================================== **
  // 脚注-文字颜色
  @Trace private footnoteTextColor: ResourceColor = "#fffa460d"
  // ** ================================================= 分割线 ==================================================== **
  // 分割线-颜色
  @Trace private lineColor: ResourceColor = "#EEE"

  // function list

  constructor() {
    this.union = generateRandomString()
    MDBaseController.setMarkdownController(this)
  }

  getUnion() {
    return this.union
  }

  // ** ================================================= 标题 ==================================================== **
  /**
   * 设置标题-颜色
   * @param color
   */
  setTitleColor(color: ResourceColor) {
    this.titleColor = color
    return this
  }

  getTitleColor(): ResourceColor {
    return this.titleColor
  }

  /**
   * 设置标题-字号（1-6级）
   * @param titleSize
   */
  setTitleSize(titleSize: [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number]) {
    this.titleSize = titleSize
    return this
  }

  getTitleSize(): [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number] {
    return this.titleSize
  }

  /**
   * 设置标题-行高（1-6级）
   * @param lineHeights
   */
  setTitleLineHeight(lineHeights: [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number]) {
    this.titleLineHeight = lineHeights
    return this
  }

  getTitleLineHeight(): [ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number, ResourceStr | number] {
    return this.titleLineHeight
  }

  // ** ================================================= 普通文本 ==================================================== **
  /**
   * 设置普通文本-颜色
   * @param textColor
   */
  setTextColor(textColor: ResourceColor) {
    this.textColor = textColor
    return this
  }

  getTextColor() {
    return this.textColor
  }

  /**
   * 设置普通文本-行高
   * @param textLineHeight
   * @returns
   */
  setTextLineHeight(textLineHeight: ResourceStr | number) {
    this.textLineHeight = textLineHeight
    return this
  }

  getTextLineHeight() {
    return this.textLineHeight
  }

  /**
   * 设置普通文本-字号
   * @param textSize
   * @returns
   */
  setTextSize(textSize: ResourceStr | number) {
    this.textSize = textSize
    return this
  }

  getTextSize() {
    return this.textSize
  }

  // ** ================================================= 行内代码 ==================================================== **
  /**
   * 设置行内代码-颜色
   * @param inlineCodeColor
   */
  setInlineCodeColor(inlineCodeColor: ResourceColor) {
    this.inlineCodeColor = inlineCodeColor
    return this
  }

  getInlineCodeColor(): ResourceColor {
    return this.inlineCodeColor
  }

  /**
   * 设置行内代码-背景颜色
   * @param inlineCodeBackgroundColor
   */
  setInlineCodeBackgroundColor(inlineCodeBackgroundColor: ResourceColor) {
    this.inlineCodeBackgroundColor = inlineCodeBackgroundColor
    return this
  }

  getInlineCodeBackgroundColor(): ResourceColor {
    return this.inlineCodeBackgroundColor
  }

  // ** ================================================= 引用块 ==================================================== **
  /**
   * 设置引用块-左边颜色
   * @param quoteBorderColor
   * @returns
   */
  setQuoteBorderColor(quoteBorderColor: ResourceColor) {
    this.quoteBorderColor = quoteBorderColor
    return this
  }

  getQuoteBorderColor() {
    return this.quoteBorderColor
  }

  /**
   * 设置引用块-背景颜色
   * @param quoteBackgroundColor
   */
  setQuoteBackgroundColor(quoteBackgroundColor: ResourceColor) {
    this.quoteBackgroundColor = quoteBackgroundColor
    return this
  }

  getQuoteBackgroundColor() {
    return this.quoteBackgroundColor
  }

  // ** ================================================= 代码块 ==================================================== **
  /**
   * 设置代码块-主题
   * @param codeBlockTheme
   * @returns
   */
  setCodeBlockTheme(codeBlockTheme: CodeTheme) {
    this.codeBlockTheme = codeBlockTheme
    CodeBlockImpl.handleThemeChange(this.union, codeBlockTheme)
    return this
  }

  getCodeBlockTheme() {
    return this.codeBlockTheme
  }

  /**
   * 设置代码块-索引展示状态
   * @param codeBlockIdxState
   * @returns
   */
  setCodeBlockIdxState(codeBlockIdxState: boolean) {
    animateTo({ duration: 200 }, () => {
      this.codeBlockIdxState = codeBlockIdxState
    })
    return this
  }

  getCodeBlockIdxState() {
    return this.codeBlockIdxState
  }

  /**
   * 设置代码高亮着色
   * @param codeHighlight
   */
  setCodeHighlight(codeHighlight: CodeHighlight) {
    this.codeHighlight = codeHighlight
    return this
  }

  getCodeHighlight() {
    return this.codeHighlight
  }

  // ** ================================================= 图片 ==================================================== **
  /**
   * 获取图片-宽度
   * @param imageWidth
   */
  setImageWidth(imageWidth: ResourceStr | number | null) {
    this.imageWidth = imageWidth
    return this
  }

  getImageWidth() {
    return this.imageWidth
  }

  /**
   * 设置图片-最大宽度
   * @param imageMaxWidth
   */
  setImageMaxWidth(imageMaxWidth: ResourceStr | number | null) {
    this.imageMaxWidth = imageMaxWidth
    return this
  }

  getImageMaxWidth() {
    return this.imageMaxWidth
  }

  /**
   * 获取图片-高度
   * @param imageWidth
   */
  setImageHeight(imageHeight: ResourceStr | number | null) {
    this.imageHeight = imageHeight
    return this
  }

  getImageHeight() {
    return this.imageHeight
  }

  /**
   * 设置图片-最大高度
   * @param imageMaxWidth
   */
  setImageMaxHeight(imageMaxHeight: ResourceStr | number | null) {
    this.imageMaxHeight = imageMaxHeight
    return this
  }

  getImageMaxHeight() {
    return this.imageMaxHeight
  }

  /**
   * 设置图片-点击监听
   * @param event
   * @returns
   */
  setImageClickListener(event: (src: string) => boolean) {
    this.imageClickListener = event
    return this
  }

  getImageClickListener() {
    return this.imageClickListener
  }

  /**
   * 设置图片加载代理
   * @param event
   * @returns
   */
  setImageLoadProxy(event: (src: string) => string) {
    this.imageLoadProxy = event
    return this
  }

  getImageLoadProxy(src: string) {
    return this.imageLoadProxy(src)
  }

  // ** ================================================= 超链接 ==================================================== **
  /**
   * 设置超链接-文字颜色
   * @param hyperlinkTextColor
   */
  setHyperlinkTextColor(hyperlinkTextColor: ResourceColor) {
    this.hyperlinkTextColor = hyperlinkTextColor
    return this
  }

  getHyperlinkTextColor() {
    return this.hyperlinkTextColor
  }

  /**
   * 设置超链接-下划线展示状态
   * @param hyperlinkUnderlineState
   */
  setHyperlinkUnderlineState(hyperlinkUnderlineState: boolean) {
    this.hyperlinkUnderlineState = hyperlinkUnderlineState
    return this
  }

  getHyperlinkUnderlineState() {
    return this.hyperlinkUnderlineState
  }

  /**
   * 设置超链接-点击监听
   * @param event
   * @returns
   */
  setHyperlinkClickListener(event: (title: string, src: string) => boolean) {
    this.hyperlinkClickListener = event
    return this
  }

  getHyperlinkClickListener() {
    return this.hyperlinkClickListener
  }

  // ** ================================================= 表格 ==================================================== **
  /**
   * 设置表格背景色
   * @param tableBackgroundColor
   */
  setTableBackgroundColor(tableBackgroundColor: ResourceColor) {
    this.tableBackgroundColor = tableBackgroundColor
    return this
  }

  getTableBackgroundColor() {
    return this.tableBackgroundColor
  }

  /**
   * 设置表格-表头背景色
   * @param tableTitleBackgroundColor
   */
  setTableTitleBackgroundColor(tableTitleBackgroundColor: ResourceColor) {
    this.tableTitleBackgroundColor = tableTitleBackgroundColor
    return this
  }

  getTableTitleBackgroundColor() {
    return this.tableTitleBackgroundColor
  }

  /**
   * 设置表格-错行背景色
   * @param tableInterleaveBackgroundColor
   */
  setTableInterleaveBackgroundColor(tableInterleaveBackgroundColor: ResourceColor) {
    this.tableInterleaveBackgroundColor = tableInterleaveBackgroundColor
    return this
  }

  getTableInterleaveBackgroundColor() {
    return this.tableInterleaveBackgroundColor
  }

  // ** ================================================= 任务列表 ==================================================== **
  /**
   * 设置任务列表-选中颜色
   * @param todoSelectedColor
   */
  setTodoSelectedColor(todoSelectedColor: ResourceColor) {
    this.todoSelectedColor = todoSelectedColor
    return this
  }

  getTodoSelectedColor() {
    return this.todoSelectedColor
  }

  /**
   * 设置任务列表-选项大小
   * @param todoSelectSize
   */
  setTodoSelectSize(todoSelectSize: ResourceStr | number) {
    this.todoSelectSize = todoSelectSize
    return this
  }

  getTodoSelectSize() {
    return this.todoSelectSize
  }

  // ** ================================================= 脚注 ==================================================== **
  /**
   * 设置脚注-文字颜色
   * @param footnoteTextColor
   */
  setFootnoteTextColor(footnoteTextColor: ResourceColor) {
    this.footnoteTextColor = footnoteTextColor
    return this
  }

  getFootnoteTextColor() {
    return this.footnoteTextColor
  }

  // ** ================================================= 分割线 ==================================================== **
  /**
   * 设置分割线-颜色
   * @param lineColor
   * @returns
   */
  setLineColor(lineColor: ResourceColor) {
    this.lineColor = lineColor
    return this
  }

  getLineColor() {
    return this.lineColor
  }
}



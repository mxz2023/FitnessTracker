// 基础节点
export interface BaseNode {
  type: string;
  children?: TreeNode[] | FootnoteNode[];
}

// 文本节点
export interface TextNode extends BaseNode {
  type: "text";
  text: string;
}

// 加粗、斜体、删除线等内联节点
interface BoldNode extends BaseNode {
  type: "bold";
  children: TreeNode[];
}

interface ItalicNode extends BaseNode {
  type: "italic";
  children: TreeNode[];
}

interface StrikethroughNode extends BaseNode {
  type: "strikethrough";
  children: TreeNode[];
}

// 行内代码
interface InlineCodeNode extends BaseNode {
  type: "inlineCode";
  text: string;
}

// 链接
interface LinkNode extends BaseNode {
  type: "link";
  url: string;
  children: TreeNode[];
}

// 图片
export interface ImageNode extends BaseNode {
  type: "image";
  url: string;
  alt?: string;
}

// 段落
interface ParagraphNode extends BaseNode {
  type: "paragraph";
  children: TreeNode[];
}

// 分割线
interface HrNode extends BaseNode {
  type: "hr";
}

// 标题
interface HeadingNode extends BaseNode {
  type: "heading";
  level: 1 | 2 | 3 | 4 | 5 | 6;
  children: TreeNode[];
}

// 块引用
interface BlockquoteNode extends BaseNode {
  type: "blockquote";
  children: TreeNode[];
}

// 列表
interface ListItemNode extends BaseNode {
  type: "listItem";
  checked?: boolean,
  children: TreeNode[];
}

interface UlNode extends BaseNode {
  type: "ul";
  children: ListItemNode[];
}

interface OlNode extends BaseNode {
  type: "ol";
  children: ListItemNode[];
}

// 表格
export interface TableCellNode extends BaseNode {
  type: "tableCell";
  children: ParagraphNode[];
}

export interface TableRowNode extends BaseNode {
  type: "tableRow";
  children: TableCellNode[];
}

export interface TableNode extends BaseNode {
  type: "table";
  header: TableCellNode[];
  rows: TableRowNode[];
  align?: ("none" | "left" | "center" | "right")[];
}

// 代码块
export interface CodeBlockNode extends BaseNode {
  type: "codeBlock";
  lang?: string;
  text: string;
}

// 脚注组
export interface FootnotesNode extends BaseNode {
  type: "footnotes";
  children: FootnoteNode[]
}

export interface FootnoteNode extends BaseNode {
  id: string
  children: ParagraphNode[]
}

export interface FootnoteRefNode extends BaseNode {
  type: "footnoteRef";
  id: string
}

// 所有节点的联合类型
export type TreeNode =
  | TextNode
    | BoldNode
    | ItalicNode
    | StrikethroughNode
    | InlineCodeNode
    | LinkNode
    | ImageNode
    | ParagraphNode
    | HrNode
    | HeadingNode
    | BlockquoteNode
    | UlNode
    | OlNode
    | ListItemNode
    | TableNode
    | TableRowNode
    | TableCellNode
    | CodeBlockNode
    | FootnotesNode
    | FootnoteRefNode;

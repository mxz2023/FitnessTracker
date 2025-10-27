// 新增：递归深度控制工具函数
const RECURSION_MAX_DEPTH = 100; // 合理设置递归上限，避免栈溢出

const INLINE_SPECIALS = new Set(['`', '!', '[', ']', '~', '*', '_']);

/* -------------------- 公用工具 -------------------- */
function isEmptyLine(s) {
    return /^\s*$/.test(s || '');
}

function toSpaceCount(s) {
    // 把开头的 \t 视作 4 spaces，返回空格数量
    const tabsReplaced = s.replace(/\t/g, '    ');
    const m = tabsReplaced.match(/^ */);
    return m ? m[0].length : 0;
}

function withRecursionLimit(fn) {
    return function (...args) {
        // 从参数中提取当前深度（默认 0），若无则初始化
        const currentDepth = args[args.length - 1] || 0;
        if (currentDepth >= RECURSION_MAX_DEPTH) {
            console.warn(`递归深度超过上限 ${RECURSION_MAX_DEPTH}，已终止以避免栈溢出`);
            // 返回降级结果（普通文本节点），保证功能不中断
            if (typeof args[0] === 'string') {
                return [{ type: 'text', text: args[0] }];
            }
            return [];
        }
        // 传递深度+1 到下一层递归
        return fn(...args, currentDepth + 1);
    };
}

/* -------------------- 主解析入口（含脚注预扫描） -------------------- */
export function parseMarkdown(md) {
    // 先把原始文本拆成行，预扫描脚注定义（[^id]: ... 多行）
    const rawLines = md.replace(/\r/g, '').split('\n');
    const footnoteDefs = {}; // id -> text (raw markdown)
    const consumed = new Set();

    for (let i = 0; i < rawLines.length; i++) {
        if (consumed.has(i)) {
            continue;
        }
        const line = rawLines[i];
        const m = line.match(/^\s*\[\^([^\]]+)\]:\s*(.*)$/);
        if (m) {
            const id = m[1];
            let content = m[2] || '';
            consumed.add(i);
            // 向下收集缩进行或空行（常见脚注多行用缩进或空行分段）
            let j = i + 1;
            while (j < rawLines.length) {
                if (consumed.has(j)) {
                    j++;
                    continue;
                }
                const next = rawLines[j];
                // 如果是下一个脚注定义，停止
                if (/^\s*\[\^([^\]]+)\]:/.test(next)) {
                    break;
                }
                // 如果是缩进行（起始空格或tab）或空行，视为脚注继续
                if (/^\s+/.test(next) || isEmptyLine(next)) {
                    content += '\n' + next.replace(/^\s{0,4}/, ''); // 去掉最多4个领先空格，保留相对缩进
                    consumed.add(j);
                    j++;
                    continue;
                }
                // 非缩进且非空行：结束脚注体
                break;
            }
            footnoteDefs[id] = content;
            // i 跳到 j-1 下个循环会 i++
            i = j - 1;
        }
    }

    // 重新组装未被 consumed 的行为新的 lines 用于主解析
    const lines = [];
    for (let idx = 0; idx < rawLines.length; idx++) {
        if (!consumed.has(idx)) {
            lines.push(rawLines[idx]);
        }
    }

    // 主解析（参考之前的逻辑，增强了列表与内联）
    const ast = [];
    let i = 0;
    while (i < lines.length) {
        const line = lines[i];

        if (isEmptyLine(line)) {
            i++;
            continue;
        }

        // 标题
        const h = line.match(/^(#{1,6})\s+(.*)$/);
        if (h) {
            ast.push({ type: 'heading', level: h[1].length, children: parseInline(h[2].trim()) });
            i++;
            continue;
        }

        // 分割线
        if (/^\s*([-*_])(\s*\1){2,}\s*$/.test(line)) {
            ast.push({ type: 'hr' });
            i++;
            continue;
        }

        // 代码块(fenced)
        if (/^```/.test(line)) {
            const fenceInfo = line.replace(/^```/, '').trim() || null;
            const lang = fenceInfo;
            i++;
            const buf = [];
            while (i < lines.length && !/^```/.test(lines[i])) {
                buf.push(lines[i]);
                i++;
            }
            i++; // skip ```
            ast.push({ type: 'codeBlock', lang, text: buf.join('\n') });
            continue;
        }

        // 表格（header + align）
        if (line.includes('|') && i + 1 < lines.length) {
            const align = parseTableAlignLine(lines[i + 1]);
            if (align) {
                const headerRaw = splitTableRowRespectingCode(lines[i]);
                i += 2;
                const rowRawLines = [];
                while (i < lines.length && (!isEmptyLine(lines[i]))) {
                    if (lines[i].includes('|')) {
                        rowRawLines.push(lines[i]);
                        i++;
                    } else {
                        if (rowRawLines.length === 0) {
                            break;
                        }
                        rowRawLines[rowRawLines.length - 1] += '\n' + lines[i];
                        i++;
                    }
                }
                const headerCols = headerRaw.map((c) => c.trim());
                const rows = rowRawLines.map((raw) => splitTableRowRespectingCode(raw).map((c) => c.trim()));
                const headerNodes =
                    headerCols.map((h) => ({ type: 'tableCell', children: withRecursionLimit(parseMarkdown)(h) }));
                const rowNodes = rows.map((cols) => {
                    const cells = headerCols.map((_, idx) => {
                        const rawCell = (idx < cols.length) ? cols[idx] : '';
                        return { type: 'tableCell', children: withRecursionLimit(parseMarkdown)(rawCell) };
                    });
                    if (cols.length > headerCols.length) {
                        for (let k = headerCols.length; k < cols.length; k++) {
                            cells.push({ type: 'tableCell', children: withRecursionLimit(parseMarkdown)(cols[k]) });
                        }
                    }
                    return { type: 'tableRow', children: cells };
                });
                ast.push({
                    type: 'table',
                    header: headerNodes,
                    align,
                    rows: rowNodes
                });
                continue;
            }
        }

        // 列表（支持嵌套）
        const listStartMatch = line.match(/^(\s*)([-*+]|(\d+)\.)\s+/);
        if (listStartMatch) {
            const result = parseList(lines, i);
            ast.push(result.node);
            i = result.index;
            continue;
        }

        // 引用块
        if (/^\s*>\s?/.test(line)) {
            const buf = [];
            while (i < lines.length && /^\s*>\s?/.test(lines[i])) {
                buf.push(lines[i].replace(/^\s*>\s?/, ''));
                i++;
            }
            ast.push({ type: 'blockquote', children: withRecursionLimit(parseMarkdown)(buf.join('\n')) });
            continue;
        }

        // 优化后
        let paraText = line; // 直接用字符串拼接，减少数组内存占用
        i++;
        while (i < lines.length && !isEmptyLine(lines[i]) &&
            !/^(#{1,6})\s+/.test(lines[i]) &&
            !/^\s*[-*_]{3,}\s*$/.test(lines[i]) &&
            !/^```/.test(lines[i]) &&
            !/^\s*>/.test(lines[i]) &&
            !(lines[i].includes('|') && parseTableAlignLine(lines[i + 1] || '')) &&
            !/^(\s*)([-*+]|(\d+)\.)\s+/.test(lines[i])
        ) {
            paraText += ' ' + lines[i]; // 实时拼接，避免数组累积
            i++;
        }
        ast.push({ type: 'paragraph', children: parseInline(paraText.trim()) });
    }

    // 把脚注定义追加到 AST 末尾，格式： {type:'footnotes', children:[{id, children: ...}, ...]}
    const footnoteIds = Object.keys(footnoteDefs);
    if (footnoteIds.length > 0) {
        const fchildren = footnoteIds.map((id) => {
            const content = footnoteDefs[id];
            // 递归解析脚注内容（可能包含块级结构）
            return { id, children: withRecursionLimit(parseMarkdown)(content || '') };
        });
        ast.push({ type: 'footnotes', children: fchildren });
    }

    return ast;
}

/* -------------------- 列表解析（支持嵌套，输出规范化 children） -------------------- */
/**
 * parseList(lines, start) -> { node: listNode, index: nextIndex }
 * listNode: { type: 'ul'|'ol', children: [ listItem, ... ] }
 * listItem: { type: 'listItem', checked?: boolean, children: [blockNode, ...] }
 */
function parseList(lines, start) {
    let i = start;
    const firstMatch = lines[start].match(/^(\s*)([-*+]|(\d+)\.)\s+(.*)$/);
    const baseIndent = toSpaceCount(firstMatch[1]);
    const rootType = firstMatch[3] ? 'ol' : 'ul';
    const rootList = { type: rootType, children: [] };
    // stack: each item { indent, node } where node is a list node
    const stack = [{ indent: baseIndent, node: rootList }];

    while (i < lines.length) {
        const line = lines[i];
        if (isEmptyLine(line)) {
            // peek ahead: if next non-empty is list item -> consume blank and continue; else break
            let j = i + 1;
            while (j < lines.length && isEmptyLine(lines[j])) {
                j++;
            }
            // 若下一行是列表项，直接跳转到 j（避免逐行 i++）
            if (j < lines.length && /^(\s*)([-*+]|(\d+)\.)\s+/.test(lines[j])) {
                i = j;
                continue;
            } else {
                i = j; // 直接跳到非空行，减少循环
                break;
            }
        }

        const m = line.match(/^(\s*)([-*+]|(\d+)\.)\s+(.*)$/);
        if (!m) {
            // 非列表行，可能是当前最后一项的 continuation（如果缩进 > top indent）
            const leading = line.match(/^(\s*)/)[1];
            const leadCount = toSpaceCount(leading);
            const top = stack[stack.length - 1];
            if (top && leadCount > top.indent) {
                const parentList = top.node;
                const lastItem = parentList.children[parentList.children.length - 1];
                if (!lastItem) {
                    break;
                }
                // continuation: 将该行作为块内容解析并追加到 lastItem.children
                const trimmed = line.slice(Math.min(leading.length, line.length));
                const blocks = withRecursionLimit(parseMarkdown)(trimmed.trim());
                if (!lastItem.children) {
                    lastItem.children = [];
                }
                lastItem.children.push(...blocks);
                i++;
                continue;
            } else {
                break;
            }
        }

        const leading = m[1];
        const marker = m[2];
        const orderedNum = m[3];
        const rest = m[4];
        const indent = toSpaceCount(leading);
        const isOrdered = !!orderedNum;
        const listType = isOrdered ? 'ol' : 'ul';

        // 调整栈：若缩进小于栈顶则 pop
        while (stack.length > 0 && indent < stack[stack.length - 1].indent) {
            stack.pop();
        }

        // 如果缩进严格大于栈顶 -> 新嵌套列表
        if (indent > stack[stack.length - 1].indent) {
            const parentList = stack[stack.length - 1].node;
            const prevItem = parentList.children[parentList.children.length - 1];
            // 如果没有 prevItem，视为同级（回退到同级）
            if (!prevItem) {
                // 创建一个同级项并继续（保证结构完整）
                const newItem =
                    { type: 'listItem', children: [{ type: 'paragraph', children: parseInline(rest.trim()) }] };
                parentList.children.push(newItem);
                i++;
                continue;
            } else {
                // 创建 nested list 并挂到 prevItem.children
                const newList = { type: listType, children: [] };
                if (!prevItem.children) {
                    prevItem.children = [];
                }
                prevItem.children.push(newList);
                stack.push({ indent, node: newList });
            }
        } else {
            // indent == stack top indent
            // 如果 marker type 与栈顶类型不一致，视为结束当前 list（由上层继续处理）
            if (listType !== stack[stack.length - 1].node.type) {
                // 结束当前 list parsing，让调用者在主循环处理后续类型不同的 list
                break;
            }
        }

        const curList = stack[stack.length - 1].node;

        // 任务项检测
        const taskMatch = rest.match(/^\s*\[( |x|X)\]\s*(.*)$/);
        let listItem;
        if (taskMatch) {
            const checked = taskMatch[1].toLowerCase() === 'x';
            const content = taskMatch[2];
            listItem = {
                type: 'listItem',
                checked,
                children: [{ type: 'paragraph', children: parseInline(content) }]
            };
        } else {
            listItem = {
                type: 'listItem',
                children: [{ type: 'paragraph', children: parseInline(rest.trim()) }]
            };
        }

        curList.children.push(listItem);
        i++;

        // 吃掉紧接着的 continuation 行（缩进 > 当前 indent 且非新的 list item）
        while (i < lines.length) {
            if (isEmptyLine(lines[i])) {
                break;
            }
            const nextMatch = lines[i].match(/^(\s*)([-*+]|(\d+)\.)\s+/);
            const nextLeading = lines[i].match(/^(\s*)/)[1];
            const nextIndent = toSpaceCount(nextLeading);

            if (nextMatch) {
                // 新列表项，交由主循环处理（可能是嵌套、同级或回退）
                break;
            } else {
                if (nextIndent > indent) {
                    const trimmed = lines[i].slice(Math.min(nextLeading.length, lines[i].length));
                    const blocks = withRecursionLimit(parseMarkdown)(trimmed.trim());
                    listItem.children.push(...blocks);
                    i++;
                    continue;
                } else {
                    break;
                }
            }
        }
    }

    return { node: rootList, index: i };
}

/* -------------------- 表格相关工具 -------------------- */
/* 与之前实现一致，处理 inline code 内的 | 和转义 \| */
function splitTableRowRespectingCode(line) {
    const cols = [];
    const curChars = []; // 用数组收集字符，减少临时对象
    let inInlineCode = false;
    let backtickSeq = 0;
    for (let i = 0; i < line.length; i++) {
        const ch = line[i];
        if (ch === '\\' && line[i + 1] === '|') {
            curChars.push('|'); // 数组 push 替代字符串拼接
            i++;
            continue;
        }
        if (ch === '`') {
            let j = i;
            while (j < line.length && line[j] === '`') {
                j++;
            }
            const seq = line.slice(i, j);
            curChars.push(seq); // 直接 push 子串，减少循环
            i = j - 1;
            continue;
        } else if (ch === '|' && !inInlineCode) {
            cols.push(curChars.join('')); // 一次性 join
            curChars.length = 0; // 清空数组，复用内存
        } else {
            curChars.push(ch);
        }
    }
    cols.push(curChars.join(''));
    const trimmed = cols.slice();
    if (line.trim().startsWith('|')) {
        if (trimmed.length && trimmed[0].trim() === '') {
            trimmed.shift();
        }
        if (trimmed.length && trimmed[trimmed.length - 1].trim() === '') {
            trimmed.pop();
        }
    }
    return trimmed;
}

function parseTableAlignLine(line) {
    const parts = splitTableRowRespectingCode(line).map((t) => t.trim());
    if (parts.length === 0) {
        return null;
    }
    const aligns = [];
    for (const p of parts) {
        if (!/^:?-+:?$/.test(p)) {
            return null;
        }
        const left = p.startsWith(':');
        const right = p.endsWith(':');
        if (left &&
            right) {
            aligns.push('center');
        } else if (left) {
            aligns.push('left');
        } else if (right) {
            aligns.push('right');
        } else {
            aligns.push('none');
        }
    }
    return aligns;
}

/* -------------------- 内联解析：轻量 tokenizer（支持图片被链接包裹转为 image+href） -------------------- */

/**
 * Helper: 查找匹配的 ']'（支持嵌套中括号）
 */
function findMatchingBracket(text, startIdx) {
    // startIdx 指向 '['
    let depth = 0;
    for (let i = startIdx; i < text.length; i++) {
        if (text[i] === '[') {
            depth++;
        } else if (text[i] === ']') {
            depth--;
            if (depth === 0) {
                return i;
            }
        } else if (text[i] === '\\') {
            i++; // skip escaped char
        }
    }
    return -1;
}

/**
 * Helper: 在 '(' ... ')', 支持嵌套小括号，返回结束位置索引
 */
function findMatchingParen(text, startIdx) {
    // startIdx 指向 '('
    let depth = 0;
    for (let i = startIdx; i < text.length; i++) {
        if (text[i] === '(') {
            depth++;
        } else if (text[i] === ')') {
            depth--;
            if (depth === 0) {
                return i;
            }
        } else if (text[i] === '\\') {
            i++;
        }
    }
    return -1;
}

/**
 * parseInline: 将文本解析为内联节点数组
 * 支持：
 *  - inline code `...`
 *  - image ![alt](url "title") -> {type:'image', alt, url, title?}
 *  - link [text](url "title") -> {type:'link', url, title?, children: [...]}
 *      special-case: 如果 link 的 children 仅是 single image node -> 转为 image node 并附带 href
 *  - emphasis: ***bolditalic***, **bold**, *italic*
 *  - strikethrough: ~~text~~
 *  - footnote ref: [^id] -> {type:'footnoteRef', id}
 */
function parseInline(text) {
    if (text == null || text === '') {
        return [];
    }

    const nodes = [];
    let p = 0;
    while (p < text.length) {
        const ch = text[p];

        // inline code: `...` (支持多个反引号作为分隔)
        if (ch === '`') {
            let j = p;
            while (j < text.length && text[j] === '`') {
                j++;
            }
            const backticks = text.slice(p, j);
            const end = text.indexOf(backticks, j);
            if (end !== -1) {
                const content = text.slice(j, end);
                nodes.push({ type: 'inlineCode', text: content });
                p = end + backticks.length;
                continue;
            } else {
                // 未闭合，作为普通文本
                nodes.push({ type: 'text', text: ch });
                p++;
                continue;
            }
        }

        // image: ![alt](url "title")
        if (ch === '!' && text[p + 1] === '[') {
            const open = p + 1;
            const close = findMatchingBracket(text, open);
            if (close !== -1) {
                const alt = text.slice(open + 1, close);
                let q = close + 1;
                while (q < text.length && /\s/.test(text[q])) {
                    q++;
                }
                if (text[q] === '(') {
                    const parenEnd = findMatchingParen(text, q);
                    if (parenEnd !== -1) {
                        const inside = text.slice(q + 1, parenEnd).trim();
                        // 在 inside 中尝试提取 title（以最后的引号为准）
                        let url = inside;
                        let title;
                        // title 以 "..." 或 '...' 结尾
                        const mTitle = inside.match(/\s+("([^"]*)"|'([^']*)')\s*$/);
                        if (mTitle) {
                            title = mTitle[2] !== undefined ? mTitle[2] : mTitle[3];
                            url = inside.slice(0, mTitle.index).trim();
                        }
                        nodes.push({
                            type: 'image',
                            alt,
                            url,
                            title
                        });
                        p = parenEnd + 1;
                        continue;
                    }
                }
            }
            // fallback: treat as plain text
            nodes.push({ type: 'text', text: ch });
            p++;
            continue;
        }

        // link: [text](url "title") or reference-style not handled here
        if (ch === '[') {
            const close = findMatchingBracket(text, p);
            if (close !== -1) {
                const linkText = text.slice(p + 1, close);
                let q = close + 1;
                while (q < text.length && /\s/.test(text[q])) {
                    q++;
                }
                if (text[q] === '(') {
                    const parenEnd = findMatchingParen(text, q);
                    if (parenEnd !== -1) {
                        const inside = text.slice(q + 1, parenEnd).trim();
                        let url = inside;
                        let title;
                        const mTitle = inside.match(/\s+("([^"]*)"|'([^']*)')\s*$/);
                        if (mTitle) {
                            title = mTitle[2] !== undefined ? mTitle[2] : mTitle[3];
                            url = inside.slice(0, mTitle.index).trim();
                        }
                        // parse linkText recursively
                        const children = withRecursionLimit(parseInline)(linkText);
                        // special-case: linkText 是单个 image 节点 -> 转换为 image 并附带 href
                        if (children.length === 1 && children[0].type === 'image') {
                            const img = Object.assign({}, children[0]);
                            img.href = url;
                            // 保留 title 优先级：如果 image 自身没有 title，用 link 的 title
                            if (!img.title && title) {
                                img.title = title;
                            }
                            nodes.push(img);
                        } else {
                            nodes.push({
                                type: 'link',
                                url,
                                title,
                                children
                            });
                        }
                        p = parenEnd + 1;
                        continue;
                    }
                }
                // 如果没有括号 URL，可能是简短的 [^id] 脚注引用
                const footRef = linkText.match(/^\^([^\]]+)$/);
                if (footRef) {
                    nodes.push({ type: 'footnoteRef', id: footRef[1] });
                    p = close + 1;
                    continue;
                }
            }
            // fallback -> plain text '['
            nodes.push({ type: 'text', text: ch });
            p++;
            continue;
        }

        // strikethrough: ~~...~~
        if (ch === '~' && text[p + 1] === '~') {
            const end = text.indexOf('~~', p + 2);
            if (end !== -1) {
                const inner = text.slice(p + 2, end);
                nodes.push({ type: 'strikethrough', children: parseInline(inner) });
                p = end + 2;
                continue;
            } else {
                nodes.push({ type: 'text', text: '~' });
                p++;
                continue;
            }
        }

        // emphasis/bold: lookahead for *** / ** / *
        // emphasis/bold with * 或 _
        if (ch === '*' || ch === '_') {
            let j = p;
            while (j < text.length && text[j] === ch) {
                j++;
            }
            const count = j - p;
            if (count >= 3) {
                const end = text.indexOf(ch.repeat(3), p + 3);
                if (end !== -1) {
                    const inner = text.slice(p + 3, end);
                    nodes.push({ type: 'bolditalic', children: parseInline(inner) });
                    p = end + 3;
                    continue;
                }
            }
            if (count >= 2) {
                const end = text.indexOf(ch.repeat(2), p + 2);
                if (end !== -1) {
                    const inner = text.slice(p + 2, end);
                    nodes.push({ type: 'bold', children: parseInline(inner) });
                    p = end + 2;
                    continue;
                }
            }
            const end = text.indexOf(ch, p + 1);
            if (end !== -1) {
                const inner = text.slice(p + 1, end);
                nodes.push({ type: 'italic', children: parseInline(inner) });
                p = end + 1;
                continue;
            }
            nodes.push({ type: 'text', text: ch });
            p++;
            continue;
        }

        const plainTextMatch = text.slice(p).match(/^[^`!\[\\\]~*_]+/);
        if (plainTextMatch) {
            const chunk = plainTextMatch[0];
            nodes.push({ type: 'text', text: chunk });
            p += chunk.length;
        } else {
            // 无匹配时，处理单个字符
            nodes.push({ type: 'text', text: text[p] });
            p++;
        }
    }

    // 合并相邻 text 节点
    const merged = [];
    for (const n of nodes) {
        if (n.type === 'text' && merged.length && merged[merged.length - 1].type === 'text') {
            merged[merged.length - 1].text += n.text;
        } else {
            merged.push(n);
        }
    }
    return merged;
}
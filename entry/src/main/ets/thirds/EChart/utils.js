export function myStringify(value) {
    // 处理 null 值
    if (value === null) {
        return 'null';
    }

    // 处理字符串
    if (typeof value === 'string') {
        return `"${value}"`;
    }

    // 处理数字和布尔值
    if (typeof value === 'number' || typeof value === 'boolean') {
        return String(value);
    }

    // 处理数组
    if (Array.isArray(value)) {
        let result = '[';
        for (let i = 0; i < value.length; i++) {
            // 递归调用 myStringify 处理数组中的每个元素
            const item = myStringify(value[i]);
            result += (item !== undefined ? item : 'null');  // 如果值是 undefined，返回 'null'
            if (i < value.length - 1) {
                result += ',';  // 在元素之间加逗号
            }
        }
        result += ']';
        return result;
    }

    // 处理对象
    if (typeof value === 'object') {
        let result = '{';
        let first = true;
        for (const key in value) {
            if (value.hasOwnProperty(key)) {  // 确保只处理对象自身的属性
                const keyValue = myStringify(value[key]);
                if (keyValue !== undefined) {  // 忽略 undefined 值
                    if (!first) {
                        result += ',';  // 在键值对之间加逗号
                    }
                    result += `"${key}":${keyValue}`;
                    first = false;  // 标记为已添加第一个键值对
                }
            }
        }
        result += '}';
        return result;
    }

    // 其他未处理类型返回 undefined（例如 undefined、函数、symbol）
    return undefined;
}




export class TypeUtils {
  // 字符串判空：undefined/null、去空白后长度为 0
  static isEmptyString(value?: string): boolean {
    if (value === null || value === undefined) {
      return true;
    }
    const s: string = value as string;
    return s.trim().length === 0;
  }

  // 数字判空：undefined/null、非有限数、等于 0
  static isEmptyNumber(value?: number): boolean {
    if (value === null || value === undefined) {
      return true;
    }
    const n: number = value as number;
    if (!Number.isFinite(n)) {
      return true;
    }
    return n === 0;
  }

  // 对象/数组判空：
  // - undefined/null 为空
  // - 字符串：length === 0 为空
  // - 数字：0 为空
  // - 数组：length === 0 为空
  // - 普通对象：无自有键为空
  static isEmpty(value?: Object | Array<Object>): boolean {
    if (typeof value == "undefined") {
      return true
    }

    if (typeof value == "string") {
      return TypeUtils.isEmptyString(value)
    }

    if (typeof value == "number") {
      return TypeUtils.isEmptyNumber(value)
    }

    if (Array.isArray(value)) {
      const arr: Array<Object> = value as Array<Object>;
      return arr.length === 0;
    }

    const obj: Object = value as Object;
    const keys: Array<string> = Object.keys(obj as Record<string, Object>);
    return keys.length === 0;
  }
}
/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file Logger.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-08
 * @desc 日志打印工具类，支持不同等级的日志输出
 */

import hilog from '@ohos.hilog';

/**
 * 日志级别枚举
 */
export enum LogLevel {
  DEBUG = 3,    // 调试信息
  INFO = 4,     // 一般信息
  WARN = 5,     // 警告信息
  ERROR = 6,    // 错误信息
  FATAL = 7     // 致命错误
}

/**
 * 日志配置接口
 */
export interface LogConfig {
  domain: number;           // 日志领域，用于标识子系统
  tag: string;              // 日志标签
  minLevel: LogLevel;       // 最小输出等级
  enableTimestamp: boolean; // 是否显示时间戳
  enableLocation: boolean;  // 是否显示代码位置
}

/**
 * 默认日志配置
 */
const DEFAULT_CONFIG: LogConfig = {
  domain: 0xFF00,
  tag: 'FitnessTracker',
  minLevel: LogLevel.DEBUG,
  enableTimestamp: true,
  enableLocation: true
};

/**
 * 日志打印工具类
 * 支持不同等级的日志输出、格式化、过滤和配置
 */
export class Logger {
  private static instance: Logger;
  private config: LogConfig;

  private constructor(config?: Partial<LogConfig>) {
    // 手动合并配置，符合ArkTS规范
    const newConfig: LogConfig = {
      domain: config?.domain ?? DEFAULT_CONFIG.domain,
      tag: config?.tag ?? DEFAULT_CONFIG.tag,
      minLevel: config?.minLevel ?? DEFAULT_CONFIG.minLevel,
      enableTimestamp: config?.enableTimestamp ?? DEFAULT_CONFIG.enableTimestamp,
      enableLocation: config?.enableLocation ?? DEFAULT_CONFIG.enableLocation
    };
    this.config = newConfig;
  }

  /**
   * 获取Logger单例
   * @param config 可选的日志配置
   * @returns Logger实例
   */
  static getInstance(config?: Partial<LogConfig>): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger(config);
    } else if (config) {
      // 更新配置
      Logger.instance.updateConfig(config);
    }
    return Logger.instance;
  }

  /**
   * 创建指定标签的Logger实例
   * @param tag 日志标签
   * @param config 可选的日志配置
   * @returns Logger实例
   */
  static create(tag: string, config?: Partial<LogConfig>): Logger {
    const mergedConfig: Partial<LogConfig> = {
      domain: config?.domain,
      tag: tag,
      minLevel: config?.minLevel,
      enableTimestamp: config?.enableTimestamp,
      enableLocation: config?.enableLocation
    };
    return new Logger(mergedConfig);
  }

  /**
   * 更新日志配置
   * @param config 部分配置参数
   */
  updateConfig(config: Partial<LogConfig>): void {
    // 手动更新配置，符合ArkTS规范
    if (config.domain !== undefined) {
      this.config.domain = config.domain;
    }
    if (config.tag !== undefined) {
      this.config.tag = config.tag;
    }
    if (config.minLevel !== undefined) {
      this.config.minLevel = config.minLevel;
    }
    if (config.enableTimestamp !== undefined) {
      this.config.enableTimestamp = config.enableTimestamp;
    }
    if (config.enableLocation !== undefined) {
      this.config.enableLocation = config.enableLocation;
    }
  }

  /**
   * 设置最小日志级别
   * @param level 日志级别
   */
  setMinLevel(level: LogLevel): void {
    this.config.minLevel = level;
  }

  /**
   * 获取当前配置
   * @returns 日志配置
   */
  getConfig(): LogConfig {
    // 返回配置副本，符合ArkTS规范
    const configCopy: LogConfig = {
      domain: this.config.domain,
      tag: this.config.tag,
      minLevel: this.config.minLevel,
      enableTimestamp: this.config.enableTimestamp,
      enableLocation: this.config.enableLocation
    };
    return configCopy;
  }

  /**
   * 格式化日志消息
   * @param level 日志级别
   * @param message 日志消息
   * @param args 额外参数
   * @returns 格式化后的消息
   */
  private formatMessage(level: LogLevel, message: string, ...args: (string | number | boolean | object)[]): string {
    let formattedMsg = message;

    // 添加时间戳
    if (this.config.enableTimestamp) {
      const timestamp = new Date().toISOString();
      formattedMsg = `[${timestamp}] ${formattedMsg}`;
    }

    // 添加日志级别名称
    const levelName = LogLevel[level];
    formattedMsg = `[${levelName}] ${formattedMsg}`;

    // 格式化额外参数
    if (args.length > 0) {
      const argsStr = args.map((arg: string | number | boolean | object) => {
        if (typeof arg === 'object') {
          return JSON.stringify(arg, null, 2);
        }
        return String(arg);
      }).join(' ');
      formattedMsg = `${formattedMsg} ${argsStr}`;
    }

    return formattedMsg;
  }

  /**
   * 判断是否应该输出日志
   * @param level 日志级别
   * @returns 是否输出
   */
  private shouldLog(level: LogLevel): boolean {
    return level >= this.config.minLevel;
  }

  /**
   * 输出DEBUG级别日志
   * @param tag 日志标签
   * @param message 日志消息
   * @param args 额外参数
   */
  debug(tag: string, message: string, ...args: (string | number | boolean | object)[]): void {
    if (this.shouldLog(LogLevel.DEBUG)) {
      const formattedMsg = this.formatMessage(LogLevel.DEBUG, message, ...args);
      hilog.debug(this.config.domain, tag, formattedMsg);
    }
  }

  /**
   * 输出INFO级别日志
   * @param tag 日志标签
   * @param message 日志消息
   * @param args 额外参数
   */
  info(tag: string, message: string, ...args: (string | number | boolean | object)[]): void {
    if (this.shouldLog(LogLevel.INFO)) {
      const formattedMsg = this.formatMessage(LogLevel.INFO, message, ...args);
      hilog.info(this.config.domain, tag, formattedMsg);
    }
  }

  /**
   * 输出WARN级别日志
   * @param tag 日志标签
   * @param message 日志消息
   * @param args 额外参数
   */
  warn(tag: string, message: string, ...args: (string | number | boolean | object)[]): void {
    if (this.shouldLog(LogLevel.WARN)) {
      const formattedMsg = this.formatMessage(LogLevel.WARN, message, ...args);
      hilog.warn(this.config.domain, tag, formattedMsg);
    }
  }

  /**
   * 输出ERROR级别日志
   * @param tag 日志标签
   * @param message 日志消息
   * @param args 额外参数
   */
  error(tag: string, message: string, ...args: (string | number | boolean | object)[]): void {
    if (this.shouldLog(LogLevel.ERROR)) {
      const formattedMsg = this.formatMessage(LogLevel.ERROR, message, ...args);
      hilog.error(this.config.domain, tag, formattedMsg);
    }
  }

  /**
   * 输出FATAL级别日志
   * @param tag 日志标签
   * @param message 日志消息
   * @param args 额外参数
   */
  fatal(tag: string, message: string, ...args: (string | number | boolean | object)[]): void {
    if (this.shouldLog(LogLevel.FATAL)) {
      const formattedMsg = this.formatMessage(LogLevel.FATAL, message, ...args);
      hilog.fatal(this.config.domain, tag, formattedMsg);
    }
  }

  /**
   * 输出异常日志
   * @param tag 日志标签
   * @param error 错误对象
   * @param message 可选的额外消息
   */
  exception(tag: string, error: Error, message?: string): void {
    const errorMsg = message ? `${message}: ${error.message}` : error.message;
    const stackTrace = error.stack || 'No stack trace available';
    
    this.error(tag, errorMsg);
    this.debug(tag, 'Stack trace:', stackTrace);
  }

  /**
   * 输出对象日志（以JSON格式）
   * @param tag 日志标签
   * @param level 日志级别
   * @param label 对象标签
   * @param obj 要输出的对象
   */
  object(tag: string, level: LogLevel, label: string, obj: object): void {
    if (this.shouldLog(level)) {
      const jsonStr = JSON.stringify(obj, null, 2);
      const message = `${label}:\n${jsonStr}`;
      
      switch (level) {
        case LogLevel.DEBUG:
          this.debug(tag, message);
          break;
        case LogLevel.INFO:
          this.info(tag, message);
          break;
        case LogLevel.WARN:
          this.warn(tag, message);
          break;
        case LogLevel.ERROR:
          this.error(tag, message);
          break;
        case LogLevel.FATAL:
          this.fatal(tag, message);
          break;
      }
    }
  }

  /**
   * 输出性能日志
   * @param tag 日志标签
   * @param operation 操作名称
   * @param startTime 开始时间戳
   * @param endTime 结束时间戳（可选，默认为当前时间）
   */
  performance(tag: string, operation: string, startTime: number, endTime: number = Date.now()): void {
    const duration = endTime - startTime;
    this.info(tag, `Performance [${operation}]: ${duration}ms`);
  }

  /**
   * 分组日志开始
   * @param tag 日志标签
   * @param label 分组标签
   * @param level 日志级别
   */
  group(tag: string, label: string, level: LogLevel = LogLevel.INFO): void {
    if (this.shouldLog(level)) {
      const separator = '='.repeat(50);
      this.log(tag, level, `\n${separator}\n  ${label}\n${separator}`);
    }
  }

  /**
   * 分组日志结束
   * @param tag 日志标签
   * @param level 日志级别
   */
  groupEnd(tag: string, level: LogLevel = LogLevel.INFO): void {
    if (this.shouldLog(level)) {
      const separator = '='.repeat(50);
      this.log(tag, level, separator);
    }
  }

  /**
   * 通用日志输出方法
   * @param tag 日志标签
   * @param level 日志级别
   * @param message 日志消息
   * @param args 额外参数
   */
  log(tag: string, level: LogLevel, message: string, ...args: (string | number | boolean | object)[]): void {
    switch (level) {
      case LogLevel.DEBUG:
        this.debug(tag, message, ...args);
        break;
      case LogLevel.INFO:
        this.info(tag, message, ...args);
        break;
      case LogLevel.WARN:
        this.warn(tag, message, ...args);
        break;
      case LogLevel.ERROR:
        this.error(tag, message, ...args);
        break;
      case LogLevel.FATAL:
        this.fatal(tag, message, ...args);
        break;
    }
  }
}

/**
 * 默认Logger实例（全局单例）
 */
export const logger = Logger.getInstance();
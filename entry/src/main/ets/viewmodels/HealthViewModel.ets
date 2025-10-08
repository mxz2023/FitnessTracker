/**
 * 健康评估ViewModel抽象类
 * 定义所有健康指标ViewModel的通用接口
 */

import { HealthData, HealthStatus } from '../models/HealthDataModel';

/**
 * 健康评估ViewModel抽象基类
 */
export abstract class HealthViewModel {
  /**
   * 评估健康状态
   * @returns 健康状态枚举
   */
  public abstract getHealthStatus(): HealthStatus;

  /**
   * 获取健康建议
   * @returns 健康建议文本
   */
  public abstract getHealthAdvice(): string;

  /**
   * 获取健康评分
   * @returns 健康评分 0-100
   */
  public abstract getHealthScore(): number;
}
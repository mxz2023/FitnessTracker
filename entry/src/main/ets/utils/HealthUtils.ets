/**
 * 健康工具类
 */

import {
  HealthStatus,
  HealthCardDataType,
  Range
} from '../models/HealthDataModel';

/**
 * 格式化日期
 * @param timestamp 时间戳
 * @param format 格式化字符串，默认为 'YYYY-MM-DD'
 * @returns 格式化后的日期字符串
 */
export function formatDate(timestamp: number, format: string = 'YYYY-MM-DD'): string {
  const date = new Date(timestamp);
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  const seconds = date.getSeconds().toString().padStart(2, '0');

  return format
    .replace('YYYY', year.toString())
    .replace('MM', month)
    .replace('DD', day)
    .replace('HH', hours)
    .replace('mm', minutes)
    .replace('ss', seconds);
}

/**
 * 获取健康状态对应的颜色
 * @param status 健康状态
 * @returns 颜色值
 */
export function getHealthStatusColor(status: HealthStatus): string {
  switch (status) {
    case HealthStatus.EXCELLENT:
      return '#4CAF50'; // 绿色
    case HealthStatus.GOOD:
      return '#8BC34A'; // 浅绿色
    case HealthStatus.MODERATE:
      return '#FFC107'; // 黄色
    case HealthStatus.POOR:
      return '#F44336'; // 红色
    default:
      return '#9E9E9E'; // 灰色
  }
}

/**
 * 获取健康状态对应的文本
 * @param status 健康状态
 * @returns 状态文本
 */
export function getHealthStatusText(status: HealthStatus): string {
  switch (status) {
    case HealthStatus.EXCELLENT:
      return '优';
    case HealthStatus.GOOD:
      return '良';
    case HealthStatus.MODERATE:
      return '中';
    case HealthStatus.POOR:
      return '差';
    default:
      return '未知';
  }
}

/**
 * 根据类型，获取数据量规图表颜色值
 * @param type
 * @returns
 */
export function getHealthStatusColors(type: HealthCardDataType): Array<[ResourceColor | LinearGradient, number]> {
  let colors: Array<[ResourceColor | LinearGradient, number]> = []
  switch (type) {
    case HealthCardDataType.WeightInfo: {
      colors = [
        [new LinearGradient([
          { color: "#54baea", offset: 0 },
          { color: "#dbefa5", offset: 0.2 },
          { color: "#65b50e", offset: 0.5 },
          { color: "#f1e707", offset: 0.8 },
          { color: "#e64566", offset: 1 },
        ]), 1],
      ]
      break;
    }

    case HealthCardDataType.BloodSugarInfo: {
      colors = [
        [new LinearGradient([
          { color: "#54baea", offset: 0 },
          { color: "#dbefa5", offset: 0.15 },
          { color: "#65b50e", offset: 0.3 },
          { color: "#f1e707", offset: 0.5 },
          { color: "#e64566", offset: 1 },
        ]), 1],
      ]
      break;
    }

    case HealthCardDataType.UricAcidInfo: {
      colors = [
        [new LinearGradient([
          { color: "#dbefa5", offset: 0 },
          { color: "#65b50e", offset: 0.5 },
          { color: "#f1e707", offset: 0.7 },
          { color: "#e64566", offset: 1 },
        ]), 1],
      ]
      break;
    }

    default: {
      break;
    }
  }

  return colors
}

/**
 * 获取指标的有效范围
 * @param type
 */
export function getHealthStatusRang(type: HealthCardDataType):Range {
  const res:Range = new Range()
  switch (type) {
    case HealthCardDataType.WeightInfo: {
      res.min = 50
      res.max = 120
      break;
    }
    case HealthCardDataType.BloodSugarInfo: {
      res.min = 3.0
      res.max = 15.0
      break;
    }
    case HealthCardDataType.UricAcidInfo: {
      res.min = 100
      res.max = 600
      break;
    }
  }
  return res
}
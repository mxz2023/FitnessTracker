/**
 * 健康工具类
 */

import {
  HealthStatus, HealthCardDataType, Range
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
export function getHealthColors(type: HealthCardDataType): Array<[ResourceColor, number]> {
  let colors: Array<[ResourceColor, number]> = []
  switch (type) {
    case HealthCardDataType.WeightInfo:
    case HealthCardDataType.BloodSugarInfo: {
      colors = [
        [0x54baea, 0.0],
        [0xdbefa5, 0.2],
        [0x65b50e, 0.5],
        [0xf1e707, 0.8],
        [0xe64566, 1.0]
      ]
      break;
    }

    case HealthCardDataType.BloodPressureInfo: {
      colors = [
        [0x54baea, 0.0],
        [0xb8ef3b, 0.3],
        [0xf1e707, 0.7],
        [0xe64566, 1.0]
      ]
      break;
    }

    case HealthCardDataType.UricAcidInfo: {
      colors = [
        [0xdbefa5, 0.0],
        [0x65b50e, 0.5],
        [0xf1e707, 0.7],
        [0xe64566, 1.0]
      ]
      break;
    }

    case HealthCardDataType.BloodLipidInfo: {
      colors = [
        [0xe64566, 0.0],
        [0xf1e707, 0.5],
        [0x65b50e, 1.0],
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
export function getHealthStatusRang(type: HealthCardDataType): Range[] {
  if (type == HealthCardDataType.WeightInfo) {
    const item1 = new Range(50, 120);
    return [item1]
  } else if (type == HealthCardDataType.BloodSugarInfo) {
    const item1 = new Range(3, 15);
    return [item1]
  } else if (type == HealthCardDataType.UricAcidInfo) {
    const item1 = new Range(100, 600);
    return [item1]
  } else if (type == HealthCardDataType.BloodPressureInfo) {
    const item1 = new Range(50, 300);
    const item2 = new Range(50, 350);
    return [item1, item2]
  } else if (type == HealthCardDataType.BloodLipidInfo) {
    const item1 = new Range(0, 8);
    const item2 = new Range(0, 3);
    const item3 = new Range(0, 3);
    const item4 = new Range(0, 3);
    return [item1, item2, item3, item4]
  } else {
    const item1 = new Range(1, 100);
    return [item1]
  }
}
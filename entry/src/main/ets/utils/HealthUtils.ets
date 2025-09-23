/**
 * 健康工具类
 */

import {
  HealthStatus,
  HealthRanges,
  MeasurementType,
  Gender,
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData
} from '../model/HealthDataModel';

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
 * 评估体重状态
 * @param weight 体重数据
 * @param height 身高，单位m
 * @returns 健康状态
 */
export function evaluateWeightStatus(weightValue: number, height: number): HealthStatus {
  const bmi = weightValue / (height * height);

  if (bmi >= HealthRanges.WEIGHT_EXCELLENT.min && bmi <= HealthRanges.WEIGHT_EXCELLENT.max) {
    return HealthStatus.EXCELLENT;
  } else if (bmi >= HealthRanges.WEIGHT_GOOD.min && bmi <= HealthRanges.WEIGHT_GOOD.max) {
    return HealthStatus.GOOD;
  } else if (bmi >= HealthRanges.WEIGHT_MODERATE.min && bmi <= HealthRanges.WEIGHT_MODERATE.max) {
    return HealthStatus.MODERATE;
  } else {
    return HealthStatus.POOR;
  }
}

/**
 * 评估血压状态
 * @param bp 血压数据
 * @returns 健康状态
 */
export function evaluateBloodPressureStatus(bp: BloodPressureData): HealthStatus {
  if (
    bp.systolic >= HealthRanges.BP_EXCELLENT.systolic.min &&
    bp.systolic <= HealthRanges.BP_EXCELLENT.systolic.max &&
    bp.diastolic >= HealthRanges.BP_EXCELLENT.diastolic.min &&
    bp.diastolic <= HealthRanges.BP_EXCELLENT.diastolic.max
  ) {
    return HealthStatus.EXCELLENT;
  } else if (
    bp.systolic >= HealthRanges.BP_GOOD.systolic.min &&
    bp.systolic <= HealthRanges.BP_GOOD.systolic.max &&
    bp.diastolic >= HealthRanges.BP_GOOD.diastolic.min &&
    bp.diastolic <= HealthRanges.BP_GOOD.diastolic.max
  ) {
    return HealthStatus.GOOD;
  } else if (
    bp.systolic >= HealthRanges.BP_MODERATE.systolic.min &&
    bp.systolic <= HealthRanges.BP_MODERATE.systolic.max &&
    bp.diastolic >= HealthRanges.BP_MODERATE.diastolic.min &&
    bp.diastolic <= HealthRanges.BP_MODERATE.diastolic.max
  ) {
    return HealthStatus.MODERATE;
  } else {
    return HealthStatus.POOR;
  }
}

/**
 * 评估血糖状态
 * @param bs 血糖数据
 * @returns 健康状态
 */
export function evaluateBloodSugarStatus(value: number, measurementType: MeasurementType): HealthStatus {
  const range = measurementType === MeasurementType.FASTING ? 
    HealthRanges.BS_FASTING_EXCELLENT : HealthRanges.BS_AFTER_MEAL_EXCELLENT;

  if (value >= range.min && value <= range.max) {
    return HealthStatus.EXCELLENT;
  } else if (value >= range.min && value <= (range === HealthRanges.BS_FASTING_EXCELLENT ? 
    HealthRanges.BS_FASTING_GOOD.max : HealthRanges.BS_AFTER_MEAL_GOOD.max)) {
    return HealthStatus.GOOD;
  } else if (value >= (range === HealthRanges.BS_FASTING_EXCELLENT ? 
    HealthRanges.BS_FASTING_MODERATE.min : HealthRanges.BS_AFTER_MEAL_MODERATE.min) && 
    value <= (range === HealthRanges.BS_FASTING_EXCELLENT ? 
    HealthRanges.BS_FASTING_MODERATE.max : HealthRanges.BS_AFTER_MEAL_MODERATE.max)) {
    return HealthStatus.MODERATE;
  } else {
    return HealthStatus.POOR;
  }
}

/**
 * 评估尿酸状态
 * @param ua 尿酸数据
 * @returns 健康状态
 */
export function evaluateUricAcidStatus(value: number, gender: Gender = Gender.MALE): HealthStatus {
  const range = gender === Gender.MALE ? 
    HealthRanges.UA_EXCELLENT.male : HealthRanges.UA_EXCELLENT.female;

  if (value >= range.min && value <= range.max) {
    return HealthStatus.EXCELLENT;
  } else if (value >= range.min && value <= (gender === Gender.MALE ? 
    HealthRanges.UA_GOOD.male.max : HealthRanges.UA_GOOD.female.max)) {
    return HealthStatus.GOOD;
  } else if (value >= (gender === Gender.MALE ? 
    HealthRanges.UA_MODERATE.male.min : HealthRanges.UA_MODERATE.female.min) && 
    value <= (gender === Gender.MALE ? 
    HealthRanges.UA_MODERATE.male.max : HealthRanges.UA_MODERATE.female.max)) {
    return HealthStatus.MODERATE;
  } else {
    return HealthStatus.POOR;
  }
}

/**
 * 评估血脂状态
 * @param bl 血脂数据
 * @returns 健康状态
 */
export function evaluateBloodLipidStatus(bl: BloodLipidData): HealthStatus {
  // 检查是否有任何指标处于较差状态
  if (
    bl.totalCholesterol >= HealthRanges.BL_POOR.totalCholesterol.min ||
    bl.triglycerides >= HealthRanges.BL_POOR.triglycerides.min ||
    bl.hdlCholesterol <= HealthRanges.BL_POOR.hdlCholesterol.max ||
    bl.ldlCholesterol >= HealthRanges.BL_POOR.ldlCholesterol.min
  ) {
    return HealthStatus.POOR;
  }
  
  // 检查是否有任何指标处于中等状态
  if (
    (bl.totalCholesterol >= HealthRanges.BL_MODERATE.totalCholesterol.min && 
     bl.totalCholesterol <= HealthRanges.BL_MODERATE.totalCholesterol.max) ||
    (bl.triglycerides >= HealthRanges.BL_MODERATE.triglycerides.min && 
     bl.triglycerides <= HealthRanges.BL_MODERATE.triglycerides.max) ||
    (bl.hdlCholesterol >= HealthRanges.BL_MODERATE.hdlCholesterol.min && 
     bl.hdlCholesterol <= HealthRanges.BL_MODERATE.hdlCholesterol.max) ||
    (bl.ldlCholesterol >= HealthRanges.BL_MODERATE.ldlCholesterol.min && 
     bl.ldlCholesterol <= HealthRanges.BL_MODERATE.ldlCholesterol.max)
  ) {
    return HealthStatus.MODERATE;
  }
  
  // 检查是否有任何指标处于良好状态
  if (
    (bl.totalCholesterol >= HealthRanges.BL_GOOD.totalCholesterol.min && 
     bl.totalCholesterol <= HealthRanges.BL_GOOD.totalCholesterol.max) ||
    (bl.triglycerides >= HealthRanges.BL_GOOD.triglycerides.min && 
     bl.triglycerides <= HealthRanges.BL_GOOD.triglycerides.max) ||
    (bl.hdlCholesterol >= HealthRanges.BL_GOOD.hdlCholesterol.min && 
     bl.hdlCholesterol <= HealthRanges.BL_GOOD.hdlCholesterol.max) ||
    (bl.ldlCholesterol >= HealthRanges.BL_GOOD.ldlCholesterol.min && 
     bl.ldlCholesterol <= HealthRanges.BL_GOOD.ldlCholesterol.max)
  ) {
    return HealthStatus.GOOD;
  }
  
  // 所有指标都在优秀范围内
  return HealthStatus.EXCELLENT;
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
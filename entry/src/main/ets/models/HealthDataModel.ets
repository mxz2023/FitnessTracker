/**
 * 健康数据模型
 */

import { Type as JsonType, plainToClass } from 'class-transformer';
import "reflect-metadata";

import { Gender } from "./UserDataModel";

// 健康指标卡片数据接口
export interface HealthCardData {
  title: string;
  type: HealthCardDataType;
  value1: number;
  value2?: number;
  value3?: number;
  value4?: number;
  unit?: string;
  status: HealthStatus;
  date?: string;
  other?: string;
}

// 健康指标卡片数据类型
export enum HealthCardDataType {
  Unknown,
  BaseInfo, // 基本信息
  WeightInfo, // 体重
  BloodSugarInfo, // 血糖
  UricAcidInfo, // 尿酸
  BloodPressureInfo, // 血压
  BloodLipidInfo, // 血脂
}


// 健康状态枚举
export enum HealthStatus {
  UNKNOWN = 'unknown', // 未知/不参与计算
  EXCELLENT = 'excellent', // 优
  GOOD = 'good', // 良
  MODERATE = 'moderate', // 中
  POOR = 'poor', // 差
}


// 测量类型枚举
export enum MeasurementType {
  FASTING = 'FASTING', // 空腹
  AFTER_MEAL = 'AFTER_MEAL', // 餐后
  RANDOM = 'RANDOM' // 随机
}

// 健康数据基础类
export class HealthData {
  id: string = '';
  timestamp: number = 0; // 记录时间戳
  note: string = ''; // 备注
}

// 体重数据
export class WeightData extends HealthData {
  value: number = 0; // 体重值，单位kg
}

// 血糖数据
export class BloodSugarData extends HealthData {
  value: number = 0; // 血糖值，单位mmol/L
  measurementType: MeasurementType = MeasurementType.FASTING; // 测量类型：空腹、餐后、随机
}

// 尿酸数据
export class UricAcidData extends HealthData {
  value: number = 0; // 尿酸值，单位μmol/L
  gender: Gender = Gender.MALE; // 性别，用于判断参考范围
}

// 血压数据
export class BloodPressureData extends HealthData {
  systolic: number = 0; // 收缩压，单位mmHg
  diastolic: number = 0; // 舒张压，单位mmHg
}


// 血脂数据
export class BloodLipidData extends HealthData {
  totalCholesterol: number = 0; // 总胆固醇，单位mmol/L
  triglycerides: number = 0; // 甘油三酯，单位mmol/L
  hdlCholesterol: number = 0; // 高密度脂蛋白胆固醇，单位mmol/L
  ldlCholesterol: number = 0; // 低密度脂蛋白胆固醇，单位mmol/L
}

// 范围类型
export class Range {
  min: number = 0;
  max: number = 0;

  constructor(min: number = 0, max: number = 0) {
    this.min = min;
    this.max = max;
  }
}

// 血压范围类型
export class BloodPressureRangeType {
  systolic: Range = new Range();
  diastolic: Range = new Range();

  constructor(systolicMin: number = 0, systolicMax: number = 0,
    diastolicMin: number = 0, diastolicMax: number = 0) {
    this.systolic = new Range(systolicMin, systolicMax);
    this.diastolic = new Range(diastolicMin, diastolicMax);
  }
}

// 性别特定范围类型
export class GenderSpecificRange {
  male: Range = new Range();
  female: Range = new Range();

  constructor(maleMin: number = 0, maleMax: number = 0,
    femaleMin: number = 0, femaleMax: number = 0) {
    this.male = new Range(maleMin, maleMax);
    this.female = new Range(femaleMin, femaleMax);
  }
}

// 血脂范围类型
export class BloodLipidRangeType {
  totalCholesterol: Range = new Range();
  triglycerides: Range = new Range();
  hdlCholesterol: Range = new Range();
  ldlCholesterol: Range = new Range();

  constructor(tcMin: number = 0, tcMax: number = 0,
    tgMin: number = 0, tgMax: number = 0,
    hdlMin: number = 0, hdlMax: number = 0,
    ldlMin: number = 0, ldlMax: number = 0) {
    this.totalCholesterol = new Range(tcMin, tcMax);
    this.triglycerides = new Range(tgMin, tgMax);
    this.hdlCholesterol = new Range(hdlMin, hdlMax);
    this.ldlCholesterol = new Range(ldlMin, ldlMax);
  }
}

// 健康指标范围常量
export class HealthRanges {
  // 体重指标范围（基于BMI，需要结合身高计算）
  static readonly WEIGHT_EXCELLENT = new Range(18.5, 23.9); // BMI 正常范围
  static readonly WEIGHT_GOOD = new Range(17.0, 24.9); // BMI 轻微偏离正常范围
  static readonly WEIGHT_MODERATE = new Range(16.0, 29.9); // BMI 中度偏离正常范围
  static readonly WEIGHT_POOR = new Range(0, 999); // BMI 严重偏离正常范围

  // 血糖指标范围（空腹）
  static readonly BS_FASTING_EXCELLENT = new Range(3.9, 5.5); // 理想空腹血糖
  static readonly BS_FASTING_GOOD = new Range(3.9, 6.0); // 正常空腹血糖
  static readonly BS_FASTING_MODERATE = new Range(6.1, 6.9); // 空腹血糖受损
  static readonly BS_FASTING_POOR = new Range(7.0, 999); // 糖尿病

  // 血糖指标范围（餐后2小时）
  static readonly BS_AFTER_MEAL_EXCELLENT = new Range(3.9, 7.0); // 理想餐后血糖
  static readonly BS_AFTER_MEAL_GOOD = new Range(3.9, 7.8); // 正常餐后血糖
  static readonly BS_AFTER_MEAL_MODERATE = new Range(7.9, 11.0); // 糖耐量受损
  static readonly BS_AFTER_MEAL_POOR = new Range(11.1, 999); // 糖尿病

  // 尿酸指标范围
  static readonly UA_EXCELLENT = new GenderSpecificRange(149, 416, 89, 357); // 理想尿酸
  static readonly UA_GOOD = new GenderSpecificRange(149, 450, 89, 380); // 正常尿酸
  static readonly UA_MODERATE = new GenderSpecificRange(451, 500, 381, 420); // 尿酸偏高
  static readonly UA_POOR = new GenderSpecificRange(501, 9999, 421, 9999); // 高尿酸

  // 血压指标范围
  static readonly BP_EXCELLENT = new BloodPressureRangeType(90, 120, 60, 80); // 理想血压
  static readonly BP_GOOD = new BloodPressureRangeType(120, 130, 80, 85); // 正常血压
  static readonly BP_MODERATE = new BloodPressureRangeType(130, 140, 85, 90); // 正常高值
  static readonly BP_POOR = new BloodPressureRangeType(140, 999, 90, 999); // 高血压

  // 血脂指标范围
  static readonly BL_EXCELLENT = new BloodLipidRangeType(0, 5.2, 0, 1.7, 1.0, 999, 0, 3.4);
  static readonly BL_GOOD = new BloodLipidRangeType(0, 5.7, 0, 2.0, 0.9, 999, 0, 3.8);
  static readonly BL_MODERATE = new BloodLipidRangeType(5.8, 6.5, 2.1, 2.5, 0.8, 999, 3.9, 4.5);
  static readonly BL_POOR = new BloodLipidRangeType(6.6, 999, 2.6, 999, 0, 0.7, 4.6, 999);
}
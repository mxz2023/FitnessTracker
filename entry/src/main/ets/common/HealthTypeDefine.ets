/**
 * 通用常量定义
 * 定义项目中使用的各种常量值
 */

/**
 * 健康指标类型常量
 */
export class HealthTypeConstants {
  // 体重相关常量
  static readonly WEIGHT_MIN_VALUE: number = 20; // 最小体重值(kg)
  static readonly WEIGHT_MAX_VALUE: number = 200; // 最大体重值(kg)
  static readonly HEIGHT_MIN_VALUE: number = 100; // 最小身高值(cm)
  static readonly HEIGHT_MAX_VALUE: number = 250; // 最大身高值(cm)
  
  // 血压相关常量
  static readonly SYSTOLIC_MIN_VALUE: number = 60; // 最小收缩压(mmHg)
  static readonly SYSTOLIC_MAX_VALUE: number = 250; // 最大收缩压(mmHg)
  static readonly DIASTOLIC_MIN_VALUE: number = 40; // 最小舒张压(mmHg)
  static readonly DIASTOLIC_MAX_VALUE: number = 150; // 最大舒张压(mmHg)
  
  // 血糖相关常量
  static readonly BLOOD_SUGAR_MIN_VALUE: number = 1.0; // 最小血糖值(mmol/L)
  static readonly BLOOD_SUGAR_MAX_VALUE: number = 30.0; // 最大血糖值(mmol/L)
  
  // 尿酸相关常量
  static readonly URIC_ACID_MIN_VALUE: number = 50; // 最小尿酸值(μmol/L)
  static readonly URIC_ACID_MAX_VALUE: number = 1000; // 最大尿酸值(μmol/L)
  
  // 血脂相关常量
  static readonly CHOLESTEROL_MIN_VALUE: number = 1.0; // 最小胆固醇值(mmol/L)
  static readonly CHOLESTEROL_MAX_VALUE: number = 15.0; // 最大胆固醇值(mmol/L)
  static readonly TRIGLYCERIDES_MIN_VALUE: number = 0.5; // 最小甘油三酯值(mmol/L)
  static readonly TRIGLYCERIDES_MAX_VALUE: number = 10.0; // 最大甘油三酯值(mmol/L)
}

/**
 * 健康状态颜色常量
 */
export class HealthColorConstants {
  static readonly EXCELLENT_COLOR: string = '#4CAF50'; // 优秀状态颜色 - 绿色
  static readonly GOOD_COLOR: string = '#8BC34A'; // 良好状态颜色 - 浅绿色
  static readonly MODERATE_COLOR: string = '#FFC107'; // 中等状态颜色 - 黄色
  static readonly POOR_COLOR: string = '#F44336'; // 较差状态颜色 - 红色
  static readonly UNKNOWN_COLOR: string = '#9E9E9E'; // 未知状态颜色 - 灰色
}

/**
 * 健康状态文本常量
 */
export class HealthTextConstants {
  static readonly EXCELLENT_TEXT: string = '优'; // 优秀状态文本
  static readonly GOOD_TEXT: string = '良'; // 良好状态文本
  static readonly MODERATE_TEXT: string = '中'; // 中等状态文本
  static readonly POOR_TEXT: string = '差'; // 较差状态文本
  static readonly UNKNOWN_TEXT: string = '未知'; // 未知状态文本
}

/**
 * 测量类型文本常量
 */
export class MeasurementTypeConstants {
  static readonly FASTING_TEXT: string = '空腹'; // 空腹测量文本
  static readonly AFTER_MEAL_TEXT: string = '餐后'; // 餐后测量文本
  static readonly RANDOM_TEXT: string = '随机'; // 随机测量文本
}

/**
 * 性别文本常量
 */
export class GenderConstants {
  static readonly MALE_TEXT: string = '男'; // 男性文本
  static readonly FEMALE_TEXT: string = '女'; // 女性文本
  static readonly UNKNOWN_TEXT: string = '未知'; // 未知性别文本
}

/**
 * 单位常量
 */
export class UnitConstants {
  static readonly WEIGHT_UNIT: string = 'kg'; // 体重单位
  static readonly HEIGHT_UNIT: string = 'cm'; // 身高单位
  static readonly BLOOD_PRESSURE_UNIT: string = 'mmHg'; // 血压单位
  static readonly BLOOD_SUGAR_UNIT: string = 'mmol/L'; // 血糖单位
  static readonly URIC_ACID_UNIT: string = 'μmol/L'; // 尿酸单位
  static readonly CHOLESTEROL_UNIT: string = 'mmol/L'; // 胆固醇单位
}

/**
 * 时间常量
 */
export class TimeConstants {
  static readonly ONE_DAY_MS: number = 24 * 60 * 60 * 1000; // 一天的毫秒数
  static readonly ONE_WEEK_MS: number = 7 * 24 * 60 * 60 * 1000; // 一周的毫秒数
  static readonly ONE_MONTH_MS: number = 30 * 24 * 60 * 60 * 1000; // 一个月的毫秒数
}

/**
 * 数据存储常量
 */
export class StorageConstants {
  static readonly WEIGHT_DATA_KEY: string = 'weight_data'; // 体重数据存储键
  static readonly BLOOD_PRESSURE_DATA_KEY: string = 'blood_pressure_data'; // 血压数据存储键
  static readonly BLOOD_SUGAR_DATA_KEY: string = 'blood_sugar_data'; // 血糖数据存储键
  static readonly URIC_ACID_DATA_KEY: string = 'uric_acid_data'; // 尿酸数据存储键
  static readonly BLOOD_LIPID_DATA_KEY: string = 'blood_lipid_data'; // 血脂数据存储键
}
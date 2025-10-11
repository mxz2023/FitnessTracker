/**
 * 血糖健康评估ViewModel
 */

import { HealthStatus, HealthRanges, BloodSugarData, MeasurementType, HealthData } from '../models/HealthDataModel';
import { BaseHealthViewModel } from './BaseHealthViewModel';
import { HealthTextConstants, MeasurementTypeConstants } from '../common/HealthTypeDefine';
import { logger } from '../utils/Logger';

const TAG = 'BloodSugarViewModel';

/**
 * 血糖ViewModel类
 * 用于管理血糖数据和健康状态评估
 */
export class BloodSugarViewModel extends BaseHealthViewModel {
  private _value: number = 0; // 血糖值
  private _measurementType: MeasurementType = MeasurementType.FASTING; // 测量类型
  private _timestamp: number = Date.now(); // 时间戳
  private _id: string = ''; // 数据ID
  private _note: string = ''; // 备注

  /**
   * 构造函数
   * @param value 血糖值，单位mmol/L
   * @param measurementType 测量类型：空腹、餐后、随机
   */
  constructor(value: number = 0, measurementType: MeasurementType = MeasurementType.FASTING) {
    super();
    this._value = value;
    this._measurementType = measurementType;
    this._timestamp = Date.now();
    this._id = `bloodSugar_${this._timestamp}`;
  }

  /**
   * 从BloodSugarData创建ViewModel实例
   * @param data BloodSugarData对象
   * @returns BloodSugarViewModel实例
   */
  public async getBloodSugarData(): Promise<HealthData | null> {
    await this.loadLatestData("bloodSugar");
    return this.toHealthData();
  }

  public static fromData(data: BloodSugarData): BloodSugarViewModel {
    const viewModel = new BloodSugarViewModel(data.value, data.measurementType);
    viewModel._id = data.id;
    viewModel._timestamp = data.timestamp;
    viewModel.note = data.note;
    return viewModel;
  }

  /**
   * 评估健康状态
   * 根据血糖值和测量类型判断健康等级
   * @returns 健康状态
   */
  public getHealthStatus(): HealthStatus {
    // 根据测量类型选择对应的参考范围
    if (this._measurementType === MeasurementType.FASTING) {
      // 空腹血糖评估
      if (this._value >= HealthRanges.BS_FASTING_EXCELLENT.min &&
        this._value <= HealthRanges.BS_FASTING_EXCELLENT.max) {
        return HealthStatus.EXCELLENT;
      } else if (this._value >= HealthRanges.BS_FASTING_GOOD.min &&
        this._value <= HealthRanges.BS_FASTING_GOOD.max) {
        return HealthStatus.GOOD;
      } else if (this._value >= HealthRanges.BS_FASTING_MODERATE.min &&
        this._value <= HealthRanges.BS_FASTING_MODERATE.max) {
        return HealthStatus.MODERATE;
      } else {
        return HealthStatus.POOR;
      }
    } else if (this._measurementType === MeasurementType.AFTER_MEAL) {
      // 餐后血糖评估
      if (this._value >= HealthRanges.BS_AFTER_MEAL_EXCELLENT.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_EXCELLENT.max) {
        return HealthStatus.EXCELLENT;
      } else if (this._value >= HealthRanges.BS_AFTER_MEAL_GOOD.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_GOOD.max) {
        return HealthStatus.GOOD;
      } else if (this._value >= HealthRanges.BS_AFTER_MEAL_MODERATE.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_MODERATE.max) {
        return HealthStatus.MODERATE;
      } else {
        return HealthStatus.POOR;
      }
    } else {
      // 随机血糖评估，使用餐后标准
      if (this._value >= HealthRanges.BS_AFTER_MEAL_EXCELLENT.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_EXCELLENT.max) {
        return HealthStatus.EXCELLENT;
      } else if (this._value >= HealthRanges.BS_AFTER_MEAL_GOOD.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_GOOD.max) {
        return HealthStatus.GOOD;
      } else if (this._value >= HealthRanges.BS_AFTER_MEAL_MODERATE.min &&
        this._value <= HealthRanges.BS_AFTER_MEAL_MODERATE.max) {
        return HealthStatus.MODERATE;
      } else {
        return HealthStatus.POOR;
      }
    }
  }

  /**
   * 获取健康建议
   * 根据健康状态和测量类型提供相应建议
   * @returns 健康建议文本
   */
  public getHealthAdvice(): string {
    const status = this.getHealthStatus();
    let content = '';

    switch (status) {
      case HealthStatus.EXCELLENT:
        content = '您的血糖水平非常理想，请继续保持健康的饮食和运动习惯！';
        break;
      case HealthStatus.GOOD:
        content = '您的血糖水平正常，建议继续保持规律饮食，适量运动，定期监测。';
        break;
      case HealthStatus.MODERATE:
        if (this._measurementType === MeasurementType.FASTING) {
          content = '您的空腹血糖偏高，建议控制碳水化合物摄入，增加运动，定期复查。';
        } else {
          content = '您的餐后血糖偏高，建议调整饮食结构，减少精制糖摄入，餐后适当活动。';
        }
        break;
      case HealthStatus.POOR:
        content = '您的血糖水平偏高，建议及时就医，进行全面检查，必要时进行药物治疗。';
        break;
      default:
        content = '无法评估，请检查数据是否正确。';
    }

    return content;
  }

  /**
   * 获取健康评分
   * 根据血糖值和测量类型计算健康评分（0-100）
   * @returns 健康评分
   */
  public getHealthScore(): number {
    let idealValue = 0;
    let deviation = 0;

    if (this._measurementType === MeasurementType.FASTING) {
      idealValue = 5.0; // 理想空腹血糖
      deviation = Math.abs(this._value - idealValue);
    } else {
      idealValue = 6.5; // 理想餐后血糖
      deviation = Math.abs(this._value - idealValue);
    }

    if (deviation === 0) {
      return 100;
    } else if (deviation <= 0.5) {
      return 95;
    } else if (deviation <= 1.0) {
      return 85;
    } else if (deviation <= 2.0) {
      return 70;
    } else if (deviation <= 3.0) {
      return 50;
    } else {
      return Math.max(20, 50 - (deviation - 3.0) * 10);
    }
  }

  /********************************************* 以下为保护方法 ************************************************/
  /**
   * 将当前ViewModel数据转换为HealthData对象
   * @returns BloodSugarData对象
   */
  protected toHealthData(): HealthData | null {
    if (this._value <= 0) {
      logger.error(TAG, '血糖数据无效');
      return null;
    }

    const bsData = new BloodSugarData();
    bsData.id = this._id;
    bsData.timestamp = this._timestamp;
    bsData.note = this._note;
    bsData.value = this._value;
    bsData.measurementType = this._measurementType;

    return bsData;
  }

  /**
   * 从HealthData对象加载数据到ViewModel
   * @param data HealthData对象
   */
  protected fromHealthData(data: HealthData): void {
    if (data instanceof BloodSugarData) {
      this._id = data.id;
      this._timestamp = data.timestamp;
      this.note = data.note;
      this.value = data.value;
      this.measurementType = data.measurementType;
    } else {
      logger.error(TAG, '数据类型不匹配，期望 BloodSugarData 类型');
    }
  }

  /********************************************* Setter and Getter ************************************************/
  /**
   * 获取血糖值
   */
  get value(): number {
    return this._value;
  }

  /**
   * 设置血糖值
   */
  set value(value: number) {
    this._value = value;
  }

  /**
   * 获取测量类型
   */
  get measurementType(): MeasurementType {
    return this._measurementType;
  }

  /**
   * 设置测量类型
   */
  set measurementType(type: MeasurementType) {
    this._measurementType = type;
  }

  /**
   * 获取备注
   */
  get note(): string {
    return this._note;
  }

  /**
   * 设置备注
   */
  set note(value: string) {
    this._note = value;
  }

  /**
   * 获取测量类型的文本描述
   */
  get measurementTypeText(): string {
    switch (this._measurementType) {
      case MeasurementType.FASTING:
        return MeasurementTypeConstants.FASTING_TEXT;
      case MeasurementType.AFTER_MEAL:
        return MeasurementTypeConstants.AFTER_MEAL_TEXT;
      case MeasurementType.RANDOM:
        return MeasurementTypeConstants.RANDOM_TEXT;
      default:
        return HealthTextConstants.UNKNOWN_TEXT;
    }
  }
}
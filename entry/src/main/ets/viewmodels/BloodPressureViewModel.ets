/**
 * 血压健康评估ViewModel
 */

import { HealthStatus, HealthRanges, BloodPressureData, HealthData } from '../models/HealthDataModel';
import { BaseHealthViewModel } from './BaseHealthViewModel';
import { logger } from '../utils/Logger';

const TAG = 'BloodPressureViewModel';

/**
 * 血压ViewModel类
 * 用于管理血压数据和健康状态评估
 */
export class BloodPressureViewModel extends BaseHealthViewModel {
  private _systolic: number = 0; // 收缩压
  private _diastolic: number = 0; // 舒张压
  private _timestamp: number = Date.now(); // 时间戳
  private _id: string = ''; // 数据ID
  private _note: string = ''; // 备注

  /**
   * 构造函数
   * @param systolic 收缩压，单位mmHg
   * @param diastolic 舒张压，单位mmHg
   */
  constructor(systolic: number = 0, diastolic: number = 0) {
    super();
    this._systolic = systolic;
    this._diastolic = diastolic;
    this._timestamp = Date.now();
    this._id = `bp_${this._timestamp}`;
  }

  /**
   * 从BloodPressureData创建ViewModel实例
   * @param data BloodPressureData对象
   * @returns BloodPressureViewModel实例
   */
  public static fromData(data: BloodPressureData): BloodPressureViewModel {
    const viewModel = new BloodPressureViewModel(data.systolic, data.diastolic);
    viewModel._id = data.id;
    viewModel._timestamp = data.timestamp;
    viewModel.note = data.note;
    return viewModel;
  }

  /**
   * 评估健康状态
   * 根据收缩压和舒张压判断健康等级
   * @returns 健康状态
   */
  public getHealthStatus(): HealthStatus {
    // 判断优秀状态
    if (this._systolic >= HealthRanges.BP_EXCELLENT.systolic.min &&
      this._systolic <= HealthRanges.BP_EXCELLENT.systolic.max &&
      this._diastolic >= HealthRanges.BP_EXCELLENT.diastolic.min &&
      this._diastolic <= HealthRanges.BP_EXCELLENT.diastolic.max) {
      return HealthStatus.EXCELLENT;
    }
    // 判断良好状态
    else if (this._systolic >= HealthRanges.BP_GOOD.systolic.min &&
      this._systolic <= HealthRanges.BP_GOOD.systolic.max &&
      this._diastolic >= HealthRanges.BP_GOOD.diastolic.min &&
      this._diastolic <= HealthRanges.BP_GOOD.diastolic.max) {
      return HealthStatus.GOOD;
    }
    // 判断中等状态
    else if (this._systolic >= HealthRanges.BP_MODERATE.systolic.min &&
      this._systolic <= HealthRanges.BP_MODERATE.systolic.max &&
      this._diastolic >= HealthRanges.BP_MODERATE.diastolic.min &&
      this._diastolic <= HealthRanges.BP_MODERATE.diastolic.max) {
      return HealthStatus.MODERATE;
    }
    // 其他情况为较差状态
    else {
      return HealthStatus.POOR;
    }
  }

  /**
   * 获取健康建议
   * 根据健康状态提供相应建议
   * @returns 健康建议文本
   */
  public getHealthAdvice(): string {
    const status = this.getHealthStatus();
    let content = '';

    switch (status) {
      case HealthStatus.EXCELLENT:
        content = '您的血压非常健康，请继续保持良好的生活习惯！';
        break;
      case HealthStatus.GOOD:
        content = '您的血压正常，建议定期监测，保持健康饮食和适量运动。';
        break;
      case HealthStatus.MODERATE:
        content = '您的血压处于正常高值，建议减少钠盐摄入，增加运动，定期监测。';
        break;
      case HealthStatus.POOR:
        content = '您的血压偏高，建议及时就医咨询，调整生活方式，必要时药物治疗。';
        break;
      default:
        content = '无法评估，请检查数据是否正确。';
    }

    return content;
  }

  /**
   * 获取健康评分
   * 根据血压值计算健康评分（0-100）
   * @returns 健康评分
   */
  public getHealthScore(): number {
    const idealSystolic = 115; // 理想收缩压
    const idealDiastolic = 75; // 理想舒张压

    // 计算与理想值的偏差
    const systolicDeviation = Math.abs(this._systolic - idealSystolic);
    const diastolicDeviation = Math.abs(this._diastolic - idealDiastolic);
    const totalDeviation = systolicDeviation + diastolicDeviation;

    if (totalDeviation === 0) {
      return 100;
    } else if (totalDeviation <= 10) {
      return 95;
    } else if (totalDeviation <= 20) {
      return 85;
    } else if (totalDeviation <= 30) {
      return 70;
    } else if (totalDeviation <= 50) {
      return 50;
    } else {
      return Math.max(20, 50 - (totalDeviation - 50) * 0.5);
    }
  }

  /********************************************* 以下为保护方法 ************************************************/
  /**
   * 将当前ViewModel数据转换为HealthData对象
   * @returns BloodPressureData对象
   */
  protected toHealthData(): HealthData | null {
    if (this._systolic <= 0 || this._diastolic <= 0) {
      logger.error(TAG, '血压数据无效');
      return null;
    }

    const bpData = new BloodPressureData();
    bpData.id = this._id;
    bpData.timestamp = this._timestamp;
    bpData.note = this._note;
    bpData.systolic = this._systolic;
    bpData.diastolic = this._diastolic;

    return bpData;
  }

  /**
   * 从HealthData对象加载数据到ViewModel
   * @param data HealthData对象
   */
  protected fromHealthData(data: HealthData): void {
    if (data instanceof BloodPressureData) {
      this._id = data.id;
      this._timestamp = data.timestamp;
      this.note = data.note;
      this.systolic = data.systolic;
      this.diastolic = data.diastolic;
    } else {
      logger.error(TAG, '数据类型不匹配，期望 BloodPressureData 类型');
    }
  }

  /********************************************* Setter and Getter ************************************************/
  /**
   * 获取收缩压
   */
  get systolic(): number {
    return this._systolic;
  }

  /**
   * 设置收缩压
   */
  set systolic(value: number) {
    this._systolic = value;
  }

  /**
   * 获取舒张压
   */
  get diastolic(): number {
    return this._diastolic;
  }

  /**
   * 设置舒张压
   */
  set diastolic(value: number) {
    this._diastolic = value;
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
}
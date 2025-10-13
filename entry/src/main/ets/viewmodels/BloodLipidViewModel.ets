/**
 * 血脂健康评估ViewModel
 */

import { HealthStatus, HealthRanges, BloodLipidData, HealthData, Range } from '../models/HealthDataModel';
import { BaseHealthViewModel } from './BaseHealthViewModel';
import { logger } from '../utils/Logger';

const TAG = 'BloodLipidViewModel';

/**
 * 血脂ViewModel类
 * 用于管理血脂数据和健康状态评估
 */
@ObservedV2
export class BloodLipidViewModel extends BaseHealthViewModel {
  @Trace private _totalCholesterol: number = 0; // 总胆固醇
  @Trace private _triglycerides: number = 0; // 甘油三酯
  @Trace private _hdlCholesterol: number = 0; // 高密度脂蛋白胆固醇
  @Trace private _ldlCholesterol: number = 0; // 低密度脂蛋白胆固醇
  @Trace private _note: string = ''; // 备注

  /**
   * 构造函数
   */
  constructor() {
    super();
  }

  /**
   * 获取最新数据
   * @returns
   */
  public async getHealthData(): Promise<HealthData | null> {
    await this.loadLatestData("bloodLipid");
    return this.toHealthData();
  }

  /**
   * 评估健康状态
   * 根据各项血脂指标综合判断健康等级
   * @returns 健康状态
   */
  public getHealthStatus(): HealthStatus {
    // 检查各项指标是否在优秀范围内
    if (this._isInRange(this._totalCholesterol, HealthRanges.BL_EXCELLENT.totalCholesterol) &&
    this._isInRange(this._triglycerides, HealthRanges.BL_EXCELLENT.triglycerides) &&
    this._isInRange(this._hdlCholesterol, HealthRanges.BL_EXCELLENT.hdlCholesterol) &&
    this._isInRange(this._ldlCholesterol, HealthRanges.BL_EXCELLENT.ldlCholesterol)) {
      return HealthStatus.EXCELLENT;
    }
    // 检查各项指标是否在良好范围内
    else if (this._isInRange(this._totalCholesterol, HealthRanges.BL_GOOD.totalCholesterol) &&
    this._isInRange(this._triglycerides, HealthRanges.BL_GOOD.triglycerides) &&
    this._isInRange(this._hdlCholesterol, HealthRanges.BL_GOOD.hdlCholesterol) &&
    this._isInRange(this._ldlCholesterol, HealthRanges.BL_GOOD.ldlCholesterol)) {
      return HealthStatus.GOOD;
    }
    // 检查各项指标是否在中等范围内
    else if (this._isInRange(this._totalCholesterol, HealthRanges.BL_MODERATE.totalCholesterol) &&
    this._isInRange(this._triglycerides, HealthRanges.BL_MODERATE.triglycerides) &&
    this._isInRange(this._hdlCholesterol, HealthRanges.BL_MODERATE.hdlCholesterol) &&
    this._isInRange(this._ldlCholesterol, HealthRanges.BL_MODERATE.ldlCholesterol)) {
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
        content = '您的血脂水平非常理想，请继续保持健康的饮食和运动习惯！';
        break;
      case HealthStatus.GOOD:
        content = '您的血脂水平正常，建议保持低脂饮食，适量运动，定期监测。';
        break;
      case HealthStatus.MODERATE:
        content = '您的血脂水平偏高，建议减少饱和脂肪摄入，增加膳食纤维，控制体重。';
        break;
      case HealthStatus.POOR:
        content = '您的血脂水平异常，建议及时就医，进行详细检查，必要时药物治疗。';
        break;
      default:
        content = '无法评估，请检查数据是否正确。';
    }

    return content;
  }

  /**
   * 获取健康评分
   * 根据各项血脂指标计算综合健康评分（0-100）
   * @returns 健康评分
   */
  public getHealthScore(): number {
    // 各项指标的理想值
    const idealTC = 4.5; // 总胆固醇理想值
    const idealTG = 1.2; // 甘油三酯理想值
    const idealHDL = 1.3; // 高密度脂蛋白理想值（越高越好）
    const idealLDL = 2.6; // 低密度脂蛋白理想值

    // 计算各项指标的偏差
    const tcDeviation = Math.abs(this._totalCholesterol - idealTC);
    const tgDeviation = Math.abs(this._triglycerides - idealTG);
    const hdlDeviation = Math.max(0, idealHDL - this._hdlCholesterol); // HDL是越高越好
    const ldlDeviation = Math.abs(this._ldlCholesterol - idealLDL);

    // 综合偏差
    const totalDeviation = tcDeviation + tgDeviation + hdlDeviation + ldlDeviation;

    if (totalDeviation === 0) {
      return 100;
    } else if (totalDeviation <= 1.0) {
      return 95;
    } else if (totalDeviation <= 2.0) {
      return 85;
    } else if (totalDeviation <= 3.0) {
      return 70;
    } else if (totalDeviation <= 5.0) {
      return 50;
    } else {
      return Math.max(20, 50 - (totalDeviation - 5.0) * 3);
    }
  }

  /********************************************* 以下为私有方法 ************************************************/
  /**
   * 检查数值是否在指定范围内
   * @param value 要检查的数值
   * @param range 范围对象
   * @returns 是否在范围内
   */
  private _isInRange(value: number, range: Range): boolean {
    return value >= range.min && value <= range.max;
  }

  /********************************************* 以下为保护方法 ************************************************/
  /**
   * 将当前ViewModel数据转换为HealthData对象
   * @returns BloodLipidData对象
   */
  protected toHealthData(): HealthData | null {
    if (this._totalCholesterol <= 0 || this._triglycerides <= 0 ||
      this._hdlCholesterol <= 0 || this._ldlCholesterol <= 0) {
      logger.error(TAG, '血脂数据无效');
      return null;
    }

    const blData = new BloodLipidData();
    const now = Date.now();
    blData.timestamp = now;
    blData.id = `bloodLipid_${now}`;
    blData.note = this._note;
    blData.totalCholesterol = this._totalCholesterol;
    blData.triglycerides = this._triglycerides;
    blData.hdlCholesterol = this._hdlCholesterol;
    blData.ldlCholesterol = this._ldlCholesterol;

    return blData;
  }

  /**
   * 从HealthData对象加载数据到ViewModel
   * @param data HealthData对象
   */
  protected fromHealthData(data: HealthData): void {
    if (data instanceof BloodLipidData) {
      this.dataId = data.id;
      this.note = data.note;
      this.totalCholesterol = data.totalCholesterol;
      this.triglycerides = data.triglycerides;
      this.hdlCholesterol = data.hdlCholesterol;
      this.ldlCholesterol = data.ldlCholesterol;
      this.updateTime(data.timestamp)
    } else {
      logger.error(TAG, '数据类型不匹配，期望 BloodLipidData 类型');
    }
  }

  /********************************************* Setter and Getter ************************************************/
  /**
   * 获取总胆固醇
   */
  get totalCholesterol(): number {
    return this._totalCholesterol;
  }

  /**
   * 设置总胆固醇
   */
  set totalCholesterol(value: number) {
    this._totalCholesterol = value;
  }

  /**
   * 获取甘油三酯
   */
  get triglycerides(): number {
    return this._triglycerides;
  }

  /**
   * 设置甘油三酯
   */
  set triglycerides(value: number) {
    this._triglycerides = value;
  }

  /**
   * 获取高密度脂蛋白胆固醇
   */
  get hdlCholesterol(): number {
    return this._hdlCholesterol;
  }

  /**
   * 设置高密度脂蛋白胆固醇
   */
  set hdlCholesterol(value: number) {
    this._hdlCholesterol = value;
  }

  /**
   * 获取低密度脂蛋白胆固醇
   */
  get ldlCholesterol(): number {
    return this._ldlCholesterol;
  }

  /**
   * 设置低密度脂蛋白胆固醇
   */
  set ldlCholesterol(value: number) {
    this._ldlCholesterol = value;
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
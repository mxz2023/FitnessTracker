/**
 * 体重健康评估ViewModel
 */

import { HealthStatus, HealthRanges, WeightData, HealthData } from '../models/HealthDataModel';
import { BaseHealthViewModel } from './BaseHealthViewModel';
import { logger } from '../utils/Logger';

const TAG = 'WeightViewModel';


@ObservedV2
export class WeightViewModel extends BaseHealthViewModel {
  @Trace private _weightKg: number = 0;
  @Trace private _note: string = '';
  private heightCm: number = 0;

  constructor(height: number) {
    super();
    this.heightCm = height;
  }

  /**
   * 获取最新数据
   * @returns
   */
  public async getHealthData(): Promise<HealthData | null> {
    await this.loadLatestData("weight");
    return this.toHealthData();
  }

  /**
   * 评估健康状态
   * @returns 健康状态
   */
  public getHealthStatus(): HealthStatus {
    if (this.bmi >= HealthRanges.WEIGHT_EXCELLENT.min && this.bmi <= HealthRanges.WEIGHT_EXCELLENT.max) {
      return HealthStatus.EXCELLENT;
    } else if (this.bmi >= HealthRanges.WEIGHT_GOOD.min && this.bmi <= HealthRanges.WEIGHT_GOOD.max) {
      return HealthStatus.GOOD;
    } else if (this.bmi >= HealthRanges.WEIGHT_MODERATE.min && this.bmi <= HealthRanges.WEIGHT_MODERATE.max) {
      return HealthStatus.MODERATE;
    } else {
      return HealthStatus.POOR;
    }
  }

  /**
   * 获取健康评分
   * @returns 健康评分 0-100
   */
  public getHealthScore(): number {
    const idealBMI = 21.5; // 理想BMI值
    const deviation = Math.abs(this.bmi - idealBMI);

    if (deviation === 0) {
      return 100;
    } else if (deviation <= 1) {
      return 95;
    } else if (deviation <= 2) {
      return 85;
    } else if (deviation <= 3) {
      return 70;
    } else if (deviation <= 5) {
      return 50;
    } else {
      return Math.max(20, 50 - (deviation - 5) * 5);
    }
  }

  /**
   * 获取健康建议
   * @returns 健康建议文本
   */
  public getHealthAdvice(): string {
    const status = this.getHealthStatus();
    let content = ""
    switch (status) {
      case HealthStatus.EXCELLENT:
        content = '您的体重非常健康，请继续保持良好的生活习惯！';
        break;
      case HealthStatus.GOOD:
        content = '您的体重较为健康，建议适当调整饮食和运动。';
        break;
      case HealthStatus.MODERATE:
        if (this.bmi < HealthRanges.WEIGHT_EXCELLENT.min) {
          content = '您的体重偏轻，建议增加营养摄入，适当增重。';
          break;
        } else {
          content = '您的体重偏重，建议控制饮食，增加运动量。';
          break;
        }
      case HealthStatus.POOR:
        if (this.bmi < HealthRanges.WEIGHT_MODERATE.min) {
          content = '您的体重过轻，请咨询医生或营养师，制定增重计划。';
          break;
        } else {
          content = '您的体重超标较多，建议及时就医，制定科学的减重方案。';
          break
        }
      default:
        content = '无法评估，请检查数据是否正确。';
    }

    return content
  }

  /********************************************* 以下为保护方法 ************************************************/
  /**
   * 将当前ViewModel数据转换为HealthData对象
   * @returns WeightData对象
   */
  protected toHealthData(): HealthData | null {
    if (this._weightKg <= 0 || this.heightCm <= 0) {
      logger.error(TAG, '体重或身高数据无效');
      return null;
    }

    const weightData = new WeightData();
    weightData.id = this.dataId;
    weightData.timestamp = this.timestamp;
    weightData.note = this._note;
    weightData.value = this._weightKg;

    return weightData;
  }

  /**
   * 从HealthData对象加载数据到ViewModel
   * @param data HealthData对象
   */
  protected fromHealthData(data: HealthData): void {
    if (data instanceof WeightData) {
      this.dataId = data.id;
      this.timestamp = data.timestamp;
      this.note = data.note;
      this.value = data.value;
    } else {
      logger.error(TAG, '数据类型不匹配，期望 WeightData 类型');
    }
  }

  /********************************************* 以下为私有方法 ************************************************/


  /********************************************* Setter and Getter ************************************************/
  /**
   * 获取体重值
   */
  get value() {
    return this._weightKg
  }

  /**
   * 设置体重值
   */
  set value(n: number) {
    this._weightKg = n
  }

  /**
   * 获取备注
   */
  get note() {
    return this._note;
  }

  /**
   * 设置备注
   */
  set note(s: string) {
    this._note = s;
  }

  /**
   * 获取BMI值
   * @returns BMI值
   */
  get bmi() {
    const heightM = this.heightCm / 100.0
    return this._weightKg / (heightM * heightM);
  }

  /**
   * 设置身高值
   */
  set height(n: number) {
    this.heightCm = n;
  }
}
/**
 * 尿酸健康评估ViewModel
 */

import { HealthStatus, HealthRanges, UricAcidData, HealthData } from '../models/HealthDataModel';
import { BaseHealthViewModel } from './BaseHealthViewModel';
import { Gender } from '../models/UserDataModel';
import { logger } from '../utils/Logger';

const TAG = 'UricAcidViewModel';


/**
 * 尿酸ViewModel类
 * 用于管理尿酸数据和健康状态评估
 */
@ObservedV2
export class UricAcidViewModel extends BaseHealthViewModel {
  @Trace private _value: number = 0; // 尿酸值
  @Trace private _gender: Gender = Gender.MALE; // 性别
  @Trace private _note: string = ''; // 备注

  /**
   * 构造函数
   * @param value 尿酸值，单位μmol/L
   * @param gender 性别
   */
  constructor() {
    super();
  }

  /**
   * 获取最新数据
   * @returns
   */
  public async getHealthData(): Promise<HealthData | null> {
    await this.loadLatestData("uricAcid");
    return this.toHealthData();
  }

  /**
   * 评估健康状态
   * 根据尿酸值和性别判断健康等级
   * @returns 健康状态
   */
  public getHealthStatus(): HealthStatus {
    // 根据性别选择对应的参考范围
    const excellentRange = this._gender === Gender.MALE ?
      HealthRanges.UA_EXCELLENT.male : HealthRanges.UA_EXCELLENT.female;
    const goodRange = this._gender === Gender.MALE ?
      HealthRanges.UA_GOOD.male : HealthRanges.UA_GOOD.female;
    const moderateRange = this._gender === Gender.MALE ?
      HealthRanges.UA_MODERATE.male : HealthRanges.UA_MODERATE.female;
    const poorRange = this._gender === Gender.MALE ?
      HealthRanges.UA_POOR.male : HealthRanges.UA_POOR.female;

    // 判断健康状态
    if (this._value >= excellentRange.min && this._value <= excellentRange.max) {
      return HealthStatus.EXCELLENT;
    } else if (this._value >= goodRange.min && this._value <= goodRange.max) {
      return HealthStatus.GOOD;
    } else if (this._value >= moderateRange.min && this._value <= moderateRange.max) {
      return HealthStatus.MODERATE;
    } else if (this._value >= poorRange.min && this._value <= poorRange.max) {
      return HealthStatus.POOR;
    } else {
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
        content = '您的尿酸水平非常理想，请继续保持健康的饮食习惯！';
        break;
      case HealthStatus.GOOD:
        content = '您的尿酸水平正常，建议保持低嘌呤饮食，多饮水，定期监测。';
        break;
      case HealthStatus.MODERATE:
        content = '您的尿酸水平偏高，建议减少高嘌呤食物摄入（如海鲜、动物内脏），增加饮水量。';
        break;
      case HealthStatus.POOR:
        content = '您的尿酸水平过高，建议及时就医，严格控制饮食，必要时进行药物治疗。';
        break;
      default:
        content = '无法评估，请检查数据是否正确。';
    }

    return content;
  }

  /**
   * 获取健康评分
   * 根据尿酸值和性别计算健康评分（0-100）
   * @returns 健康评分
   */
  public getHealthScore(): number {
    // 理想尿酸值（性别差异）
    const idealValue = this._gender === Gender.MALE ? 300 : 250;
    const deviation = Math.abs(this._value - idealValue);

    if (deviation === 0) {
      return 100;
    } else if (deviation <= 50) {
      return 95;
    } else if (deviation <= 100) {
      return 85;
    } else if (deviation <= 150) {
      return 70;
    } else if (deviation <= 200) {
      return 50;
    } else {
      return Math.max(20, 50 - (deviation - 200) * 0.1);
    }
  }

  /********************************************* 以下为保护方法 ************************************************/
  /**
   * 将当前ViewModel数据转换为HealthData对象
   * @returns UricAcidData对象
   */
  protected toHealthData(): HealthData | null {
    if (this._value <= 0) {
      logger.error(TAG, '尿酸数据无效');
      return null;
    }

    const uaData = new UricAcidData();
    uaData.id = this.dataId;
    uaData.timestamp = this.timestamp;
    uaData.note = this._note;
    uaData.value = this._value;
    uaData.gender = this._gender;

    return uaData;
  }

  /**
   * 从HealthData对象加载数据到ViewModel
   * @param data HealthData对象
   */
  protected fromHealthData(data: HealthData): void {
    if (data instanceof UricAcidData) {
      this.dataId = data.id;
      this.timestamp = data.timestamp;
      this.note = data.note;
      this.value = data.value;
      this.gender = data.gender;
    } else {
      logger.error(TAG, '数据类型不匹配，期望 UricAcidData 类型');
    }
  }

  /********************************************* Setter and Getter ************************************************/
  /**
   * 获取尿酸值
   */
  get value(): number {
    return this._value;
  }

  /**
   * 设置尿酸值
   */
  set value(value: number) {
    this._value = value;
  }

  /**
   * 获取性别
   */
  get gender(): Gender {
    return this._gender;
  }

  /**
   * 设置性别
   */
  set gender(gender: Gender) {
    this._gender = gender;
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
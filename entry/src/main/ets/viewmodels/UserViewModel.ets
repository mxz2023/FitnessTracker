/**
 * 用户信息ViewModel
 * 用于管理用户基本信息的获取、存储和验证
 */

import { Context } from '@ohos.abilityAccessCtrl';

import { UserDataModel, Gender } from '../models/UserDataModel';
import { UserDataServiceImpl } from '../models/UserDataServiceImpl';
import { HealthTypeConstants, GenderConstants } from '../common/HealthTypeDefine';
import { UserConstants } from '../common/CommonDefine';
import { logger } from '../utils/Logger';

const TAG = 'UserViewModel';


/**
 * 用户数据验证结果接口
 */
export interface UserDataValidationResult {
  isValid: boolean;
  errors: string[];
}

/**
 * BMI评估结果接口
 */
export interface BMIEvaluationResult {
  bmi: number;
  status: string;
  description: string;
}

/**
 * 用户信息ViewModel类
 * 负责用户基本信息的业务逻辑处理
 */
export class UserViewModel {
  private userData: UserDataModel;
  private dataService?: UserDataServiceImpl;

  /**
   * 构造函数
   * @param context 应用上下文
   */
  constructor() {
    this.userData = this.getDefaultUserData();
  }

  /**
   * 初始化数据服务
   * @param context 应用上下文
   */
  public async initDataService(context: Context): Promise<void> {
    this.dataService = new UserDataServiceImpl(context);
    await this.dataService.initDataStore()
  }

  /**
   * 设置用户昵称
   * @param nickname 昵称
   * @returns 设置是否成功
   */
  public setNickname(nickname: string): boolean {
    if (nickname.length > UserConstants.NICKNAME_MAX_LENGTH || nickname.trim().length == 0) {
      logger.warn(TAG, '昵称长度超过限制');
      return false;
    }
    this.userData.nickname = nickname.trim();
    logger.info(TAG, `设置昵称: ${this.userData.nickname}`);
    return true;
  }

  /**
   * 设置用户性别
   * @param gender 性别枚举
   * @returns 设置是否成功
   */
  public setGender(gender: Gender): boolean {
    if (gender !== Gender.MALE && gender !== Gender.FEMALE) {
      logger.warn(TAG, '无效的性别值');
      return false;
    }
    this.userData.gender = gender;
    logger.info(TAG, `设置性别: ${gender}`);
    return true;
  }

  /**
   * 设置用户年龄
   * @param age 年龄
   * @returns 设置是否成功
   */
  public setAge(age: number): boolean {
    if (age < UserConstants.AGE_MIN_VALUE || age > UserConstants.AGE_MAX_VALUE) {
      logger.warn(TAG, '年龄值超出有效范围');
      return false;
    }
    this.userData.age = Math.floor(age);
    logger.info(TAG, `设置年龄: ${this.userData.age}`);
    return true;
  }

  /**
   * 设置用户身高
   * @param heightCm 身高（厘米）
   * @returns 设置是否成功
   */
  public setHeightCm(heightCm: number): boolean {
    if (heightCm < HealthTypeConstants.HEIGHT_MIN_VALUE || heightCm > HealthTypeConstants.HEIGHT_MAX_VALUE) {
      logger.warn(TAG, `身高值超出有效范围: ${HealthTypeConstants.HEIGHT_MIN_VALUE}-${HealthTypeConstants.HEIGHT_MAX_VALUE}cm`);
      return false;
    }
    this.userData.heightCm = heightCm;
    logger.info(TAG, `设置身高: ${this.userData.heightCm}cm`);
    return true;
  }

  /**
   * 获取用户昵称
   * @returns 用户昵称
   */
  public getNickname(): string {
    return this.userData.nickname;
  }

  /**
   * 获取用户性别
   * @returns 用户性别枚举
   */
  public getGender(): Gender {
    return this.userData.gender;
  }

  /**
   * 获取用户性别文本
   * @returns 性别文本描述
   */
  public getGenderText(): string {
    switch (this.userData.gender) {
      case Gender.MALE:
        return GenderConstants.MALE_TEXT;
      case Gender.FEMALE:
        return GenderConstants.FEMALE_TEXT;
      default:
        return GenderConstants.UNKNOWN_TEXT;
    }
  }

  /**
   * 获取用户年龄
   * @returns 用户年龄
   */
  public getAge(): number {
    return this.userData.age;
  }

  /**
   * 获取用户身高（厘米）
   * @returns 用户身高（厘米）
   */
  public getHeightCm(): number {
    return this.userData.heightCm;
  }

  /**
   * 获取用户身高（米）
   * @returns 用户身高（米）
   */
  public getHeightM(): number {
    return this.userData.heightCm / 100;
  }

  /**
   * 获取完整的用户数据
   * @returns 用户数据对象
   */
  public getUserData(): UserDataModel {
    return {
      nickname: this.userData.nickname,
      gender: this.userData.gender,
      age: this.userData.age,
      heightCm: this.userData.heightCm
    };
  }

  /**
   * 验证用户数据完整性
   * @returns 验证结果和错误信息
   */
  public validateUserData(): UserDataValidationResult {
    const errors: string[] = [];

    if (!this.userData.nickname || this.userData.nickname.trim().length === 0) {
      errors.push('昵称不能为空');
    }

    if (this.userData.age <= 0) {
      errors.push('年龄必须大于0');
    }

    if (this.userData.heightCm <= 0) {
      errors.push('身高必须大于0');
    }

    if (this.userData.gender === Gender.UNKNOWN) {
      errors.push('请选择性别');
    }

    const result: UserDataValidationResult = {
      isValid: errors.length === 0,
      errors: errors
    };
    return result;
  }

  /**
   * 计算BMI指数
   * @param weightKg 体重（千克）
   * @returns BMI指数，如果数据不完整返回-1
   */
  public calculateBMI(weightKg: number): number {
    if (weightKg <= 0 || this.userData.heightCm <= 0) {
      logger.warn(TAG, '无法计算BMI：体重或身高数据不完整');
      return -1;
    }
    
    const heightM = this.userData.heightCm / 100;
    const bmi = weightKg / (heightM * heightM);
    return Number(bmi.toFixed(1));
  }

  /**
   * 根据BMI评估健康状态
   * @param bmi BMI指数
   * @returns 健康状态描述
   */
  public evaluateBMIStatus(bmi: number): string {
    if (bmi < 0) return '数据不完整';

    if (bmi < 18.5) return '体重过轻';
    if (bmi < 24) return '正常体重';
    if (bmi < 28) return '超重';
    if (bmi < 32) return '肥胖';
    return '严重肥胖';
  }

  /**
   * 计算并评估BMI
   * @param weightKg 体重（千克）
   * @returns BMI评估结果
   */
  public calculateAndEvaluateBMI(weightKg: number): BMIEvaluationResult {
    const bmi = this.calculateBMI(weightKg);
    const status = this.evaluateBMIStatus(bmi);
    
    const result: BMIEvaluationResult = {
      bmi: bmi,
      status: status,
      description: `BMI: ${bmi} - ${status}`
    };
    return result;
  }

  /**
   * 保存用户数据到本地存储
   * @returns 保存是否成功
   */
  public async saveUserData(): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    const validation = this.validateUserData();
    if (!validation.isValid) {
      logger.error(TAG, `用户数据验证失败: ${validation.errors.join(', ')}`);
      return false;
    }

    try {
      const success = await this.dataService.saveUserData(this.userData);
      if (success) {
        logger.info(TAG, '用户数据保存成功');
      } else {
        logger.error(TAG, '用户数据保存失败');
      }
      return success;
    } catch (error) {
      logger.error(TAG, `保存用户数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 从本地存储加载用户数据
   * @returns 加载是否成功
   */
  public async loadUserData(): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    try {
      const loadedData = await this.dataService.loadUserData();
      if (loadedData) {
        this.userData.nickname = loadedData.nickname;
        this.userData.gender = loadedData.gender;
        this.userData.age = loadedData.age;
        this.userData.heightCm = loadedData.heightCm;
        logger.info(TAG, '用户数据加载成功');
        return true;
      } else {
        logger.info(TAG, '未找到用户数据');
        return false;
      }
    } catch (error) {
      logger.error(TAG, `加载用户数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 清除用户数据
   * @returns 清除是否成功
   */
  public async clearUserData(): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    try {
      const success = await this.dataService.clearUserData();
      if (success) {
        this.userData = this.getDefaultUserData();
        logger.info(TAG, '用户数据清除成功');
      } else {
        logger.error(TAG, '用户数据清除失败');
      }
      return success;
    } catch (error) {
      logger.error(TAG, `清除用户数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 检查用户数据是否完整
   * @returns 数据是否完整
   */
  public isUserDataComplete(): boolean {
    return this.userData.nickname.length > 0 &&
           this.userData.age > 0 &&
           this.userData.heightCm > 0 &&
           this.userData.gender !== Gender.UNKNOWN;
  }

  /**
   * 获取用户数据摘要信息
   * @returns 用户数据摘要字符串
   */
  public getUserDataSummary(): string {
    if (!this.isUserDataComplete()) {
      return '用户数据不完整';
    }

    return `${this.userData.nickname}，${this.userData.age}岁，${this.getGenderText()}，身高${this.userData.heightCm}cm`;
  }

  /**
   * 获取默认用户数据
   * @returns 默认用户数据对象
   */
  private getDefaultUserData(): UserDataModel {
    const defaultData: UserDataModel = {
      nickname: '',
      gender: Gender.UNKNOWN,
      age: 0,
      heightCm: 0
    };
    return defaultData;
  }
}
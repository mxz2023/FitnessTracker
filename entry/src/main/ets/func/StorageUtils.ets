/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file StorageUtils.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-09-25
 * @desc 健康数据存储工具类，统一管理体重、血压、血糖、尿酸、血脂的数据存储
 */

import { promptAction } from '@kit.ArkUI';
import { Context } from '@ohos.abilityAccessCtrl';
import { 
  HealthData, 
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData,
  MeasurementType,
} from '../models/HealthDataModel';
import { HealthDataServiceImpl } from '../models/HealthDataServiceImpl';
import { Gender } from '../models/UserDataModel';

const TAG = 'StorageUtils.ets';


/**
 * 健康数据操作结果基础接口
 */
export interface HealthDataResult {
  success: boolean;
}

/**
 * 体重数据操作结果接口
 */
export interface WeightDataResult extends HealthDataResult {
  data: WeightData | null;
}

/**
 * 血压数据操作结果接口
 */
export interface BloodPressureDataResult extends HealthDataResult {
  data: BloodPressureData | null;
}

/**
 * 血糖数据操作结果接口
 */
export interface BloodSugarDataResult extends HealthDataResult {
  data: BloodSugarData | null;
}

/**
 * 尿酸数据操作结果接口
 */
export interface UricAcidDataResult extends HealthDataResult {
  data: UricAcidData | null;
}

/**
 * 血脂数据操作结果接口
 */
export interface BloodLipidDataResult extends HealthDataResult {
  data: BloodLipidData | null;
}

/**
 * 健康数据存储工具类
 */
export class StorageUtils {
  private static instance: StorageUtils;
  private dataService: HealthDataServiceImpl;
  
  private constructor(context?: Context) {
    this.dataService = new HealthDataServiceImpl(context);
  }
  
  /**
   * 获取单例实例
   * @param context 上下文
   * @returns StorageUtils实例
   */
  public static getInstance(context?: Context): StorageUtils {
    if (!StorageUtils.instance) {
      StorageUtils.instance = new StorageUtils(context);
    }
    return StorageUtils.instance;
  }
  
  /**
   * 保存体重数据
   * @param weight 体重值(kg)
   * @param height 身高值(m)
   * @param note 备注
   * @returns 保存结果和健康状态
   */
  public async saveWeightData(weight: number, height: number, note: string = ''): Promise<WeightDataResult> {
    if (weight <= 0) {
      promptAction.showToast({ message: '请输入有效的体重值' });
      return { success: false, data: null };
    }
    
    try {
      // 当天多次记录时，做平均并只保留一条记录
      const now = Date.now();
      // 计算本地当天起止时间戳
      const d = new Date(now);
      const dayStart = new Date(d.getFullYear(), d.getMonth(), d.getDate(), 0, 0, 0, 0).getTime();
      const dayEnd = dayStart + 24 * 60 * 60 * 1000 - 1;
      
      const all = await this.dataService.getDataByType('weight');
      const todayList = (all as WeightData[]).filter(item => item.timestamp >= dayStart && item.timestamp <= dayEnd);
      
      let sum = weight;
      let count = 1;
      for (const it of todayList) {
        sum += it.value;
        count += 1;
      }
      const avg = sum / count;
      
      // 删除当天已有记录
      for (const it of todayList) {
        await this.dataService.deleteData(it.id);
      }
      
      // 保存一条平均值记录
      const record = new WeightData();
      record.id = `weight_${now}`;
      record.timestamp = now;
      record.value = avg;
      record.note = note;
      
      const ok = await this.dataService.saveData(record);
      if (ok) {
        return { success: true, data: record };
      } else {
        return { success: false, data: null };
      }
    } catch (error) {
      console.error(`${TAG} 保存体重数据失败: ${error}`);
      return { success: false, data: null };
    }
  }
  
  /**
   * 保存血压数据
   * @param systolic 收缩压(mmHg)
   * @param diastolic 舒张压(mmHg)
   * @param note 备注
   * @returns 保存结果和健康状态
   */
  public async saveBloodPressureData(systolic: number, diastolic: number, note: string = ''): Promise<BloodPressureDataResult> {
    if (systolic <= 0 || diastolic <= 0) {
      promptAction.showToast({ message: '请输入有效的血压值' });
      return { success: false, data: null };
    }
    
    try {
      const now = Date.now();
      const record = new BloodPressureData();
      record.id = `bloodPressure_${now}`;
      record.timestamp = now;
      record.systolic = systolic;
      record.diastolic = diastolic;
      record.note = note;
      
      const ok = await this.dataService.saveData(record);
      if (ok) {
        return { success: true, data: record };
      } else {
        return { success: false, data: null };
      }
    } catch (error) {
      console.error(`${TAG} 保存血压数据失败: ${error}`);
      return { success: false, data: null };
    }
  }
  
  /**
   * 保存血糖数据
   * @param value 血糖值(mmol/L)
   * @param measurementType 测量类型(空腹、餐后、随机)
   * @param note 备注
   * @returns 保存结果和健康状态
   */
  public async saveBloodSugarData(value: number, measurementType: MeasurementType, note: string = ''): Promise<BloodSugarDataResult> {
    if (value <= 0) {
      promptAction.showToast({ message: '请输入有效的血糖值' });
      return { success: false, data: null };
    }
    
    try {
      const now = Date.now();
      const record = new BloodSugarData();
      record.id = `bloodSugar_${now}`;
      record.timestamp = now;
      record.value = value;
      record.measurementType = measurementType;
      record.note = note;
      
      const ok = await this.dataService.saveData(record);
      if (ok) {
        return { success: true, data: record };
      } else {
        return { success: false, data: null };
      }
    } catch (error) {
      console.error(`${TAG} 保存血糖数据失败: ${error}`);
      return { success: false, data: null };
    }
  }
  
  /**
   * 保存尿酸数据
   * @param value 尿酸值(μmol/L)
   * @param gender 性别
   * @param note 备注
   * @returns 保存结果和健康状态
   */
  public async saveUricAcidData(value: number, gender: Gender, note: string = ''): Promise<UricAcidDataResult> {
    if (value <= 0) {
      promptAction.showToast({ message: '请输入有效的尿酸值' });
      return { success: false, data: null };
    }
    
    try {
      const now = Date.now();
      const record = new UricAcidData();
      record.id = `uricAcid_${now}`;
      record.timestamp = now;
      record.value = value;
      record.gender = gender;
      record.note = note;
      
      const ok = await this.dataService.saveData(record);
      if (ok) {
        return { success: true, data: record };
      } else {
        return { success: false, data: null };
      }
    } catch (error) {
      console.error(`${TAG} 保存尿酸数据失败: ${error}`);
      return { success: false, data: null };
    }
  }
  
  /**
   * 保存血脂数据
   * @param totalCholesterol 总胆固醇(mmol/L)
   * @param triglycerides 甘油三酯(mmol/L)
   * @param hdlCholesterol 高密度脂蛋白胆固醇(mmol/L)
   * @param ldlCholesterol 低密度脂蛋白胆固醇(mmol/L)
   * @param note 备注
   * @returns 保存结果和健康状态
   */
  public async saveBloodLipidData(
    totalCholesterol: number,
    triglycerides: number,
    hdlCholesterol: number,
    ldlCholesterol: number,
    note: string = ''
  ): Promise<BloodLipidDataResult> {
    if (totalCholesterol <= 0 || triglycerides <= 0 || hdlCholesterol <= 0 || ldlCholesterol <= 0) {
      promptAction.showToast({ message: '请输入有效的血脂值' });
      return { success: false, data: null };
    }
    
    try {
      const now = Date.now();
      const record = new BloodLipidData();
      record.id = `bloodLipid_${now}`;
      record.timestamp = now;
      record.totalCholesterol = totalCholesterol;
      record.triglycerides = triglycerides;
      record.hdlCholesterol = hdlCholesterol;
      record.ldlCholesterol = ldlCholesterol;
      record.note = note;
      
      const ok = await this.dataService.saveData(record);
      if (ok) {
        return { success: true, data: record };
      } else {
        return { success: false, data: null };
      }
    } catch (error) {
      console.error(`${TAG} 保存血脂数据失败: ${error}`);
      return { success: false, data: null };
    }
  }
  
  /**
   * 获取最新的体重数据
   * @returns 最新的体重数据，如果没有则返回null
   */
  public async getLatestWeightData(): Promise<WeightData | null> {
    try {
      const data = await this.dataService.getDataByType('weight');
      const list = data as WeightData[];
      if (list.length > 0) {
        return list[0];
      }
      return null;
    } catch (error) {
      console.error(`${TAG} 获取最新体重数据失败: ${error}`);
      return null;
    }
  }
  
  /**
   * 获取最新的血压数据
   * @returns 最新的血压数据，如果没有则返回null
   */
  public async getLatestBloodPressureData(): Promise<BloodPressureData | null> {
    try {
      const data = await this.dataService.getDataByType('bloodPressure');
      const list = data as BloodPressureData[];
      if (list.length > 0) {
        return list[0];
      }
      return null;
    } catch (error) {
      console.error(`${TAG} 获取最新血压数据失败: ${error}`);
      return null;
    }
  }
  
  /**
   * 获取最新的血糖数据
   * @returns 最新的血糖数据，如果没有则返回null
   */
  public async getLatestBloodSugarData(): Promise<BloodSugarData | null> {
    try {
      const data = await this.dataService.getDataByType('bloodSugar');
      const list = data as BloodSugarData[];
      if (list.length > 0) {
        return list[0];
      }
      return null;
    } catch (error) {
      console.error(`${TAG} 获取最新血糖数据失败: ${error}`);
      return null;
    }
  }
  
  /**
   * 获取最新的尿酸数据
   * @returns 最新的尿酸数据，如果没有则返回null
   */
  public async getLatestUricAcidData(): Promise<UricAcidData | null> {
    try {
      const data = await this.dataService.getDataByType('uricAcid');
      const list = data as UricAcidData[];
      if (list.length > 0) {
        return list[0];
      }
      return null;
    } catch (error) {
      console.error(`${TAG} 获取最新尿酸数据失败: ${error}`);
      return null;
    }
  }
  
  /**
   * 获取最新的血脂数据
   * @returns 最新的血脂数据，如果没有则返回null
   */
  public async getLatestBloodLipidData(): Promise<BloodLipidData | null> {
    try {
      const data = await this.dataService.getDataByType('bloodLipid');
      const list = data as BloodLipidData[];
      if (list.length > 0) {
        return list[0];
      }
      return null;
    } catch (error) {
      console.error(`${TAG} 获取最新血脂数据失败: ${error}`);
      return null;
    }
  }
  
  /**
   * 获取指定类型的所有健康数据
   * @param dataType 数据类型 ('weight', 'bloodPressure', 'bloodSugar', 'uricAcid', 'bloodLipid')
   * @returns 健康数据数组
   */
  public async getHealthDataByType(dataType: string): Promise<HealthData[]> {
    try {
      return await this.dataService.getDataByType(dataType);
    } catch (error) {
      console.error(`${TAG} 获取健康数据失败: ${error}`);
      return [];
    }
  }
  
  /**
   * 根据日期范围获取健康数据
   * @param startDate 开始日期时间戳
   * @param endDate 结束日期时间戳
   * @returns 健康数据数组
   */
  public async getHealthDataByDateRange(startDate: number, endDate: number): Promise<HealthData[]> {
    try {
      return await this.dataService.getDataByDateRange(startDate, endDate);
    } catch (error) {
      console.error(`${TAG} 获取日期范围健康数据失败: ${error}`);
      return [];
    }
  }
  
  /**
   * 删除健康数据
   * @param id 数据ID
   * @returns 删除是否成功
   */
  public async deleteHealthData(id: string): Promise<boolean> {
    try {
      return await this.dataService.deleteData(id);
    } catch (error) {
      console.error(`${TAG} 删除健康数据失败: ${error}`);
      return false;
    }
  }
}
/**
 * 健康数据服务实现类
 */

import { preferences } from '@kit.ArkData';
import { Context } from '@ohos.abilityAccessCtrl';
import { plainToClass } from 'class-transformer';
import {
  HealthData,
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData
} from './HealthDataModel';


// 存储健康数据的首选项名称
const HEALTH_DATA_PREFERENCE = 'health_data_preference';

export class HealthDataServiceImpl {
  private dataStore: preferences.Preferences | null = null;
  private initialized: boolean = false;
  private context?: Context

  constructor(context?: Context) {
    this.context = context;
  }

  /**
   * 初始化数据存储
   */
  async initDataStore(): Promise<void> {
    if (!this.initialized) {
      try {
        await preferences.getPreferences(this.context, {
          name: HEALTH_DATA_PREFERENCE
        }).then((store) => {
          this.dataStore = store;
          this.initialized = true;
        });
      } catch (error) {
        console.error(`初始化数据存储失败: ${error}`);
        this.dataStore = null;
        this.initialized = false;
      }
    }
  }

  /**
   * 确保数据存储已初始化
   */
  private async ensureInitialized(): Promise<boolean> {
    if (!this.initialized) {
      await this.initDataStore();
    }
    return this.initialized;
  }

  /**
   * 保存健康数据
   * @param data 健康数据
   * @returns 保存是否成功
   */
  async saveData(data: HealthData): Promise<boolean> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return false;
    }

    try {
      await this.dataStore.put(data.id, JSON.stringify(data));
      await this.dataStore.flush();
      await this.updateIndex(data);
      return true;
    } catch (error) {
      console.error(`保存数据失败: ${error}`);
      return false;
    }
  }

  /**
   * 更新数据索引
   * @param data 健康数据
   */
  private async updateIndex(data: HealthData): Promise<void> {
    if (!this.dataStore) {
      return;
    }

    try {
      const dataType = data.id.split('_')[0];
      const indexKey = `index_${dataType}`;

      let index: string[] = [];
      const indexValue = await this.dataStore.get(indexKey, '[]');

      if (indexValue && typeof indexValue === 'string') {
        index = JSON.parse(indexValue);
      }

      if (!index.includes(data.id)) {
        index.push(data.id);
        index.sort((a, b) => {
          const timestampA = parseInt(a.split('_')[1]);
          const timestampB = parseInt(b.split('_')[1]);
          return timestampB - timestampA;
        });

        await this.dataStore.put(indexKey, JSON.stringify(index));
        await this.dataStore.flush();
      }
    } catch (error) {
      console.error(`更新索引失败: ${error}`);
    }
  }

  /**
   * 根据ID获取健康数据
   * @param id 数据ID
   * @returns 健康数据或null
   */
  async getDataById(id: string): Promise<HealthData | null> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return null;
    }

    try {
      const dataStr = await this.dataStore.get(id, '');
      if (!dataStr || typeof dataStr !== 'string') {
        return null;
      }

      const data = JSON.parse(dataStr) as HealthData;
      if (!data.id || !data.timestamp) {
        return null;
      }
      switch (data.id.split('_')[0]) {
        case 'weight': {
          let res = plainToClass(WeightData, data as WeightData)
          return res;
        }

        case 'bloodPressure': {
          let res = plainToClass(BloodPressureData, data as BloodPressureData)
          return res;
        }

        case 'bloodSugar': {
          let res = plainToClass(BloodSugarData, data as BloodSugarData)
          return res;
        }

        case 'uricAcid': {
          let res = plainToClass(UricAcidData, data as UricAcidData)
          return res;
        }

        case 'bloodLipid': {
          let res = plainToClass(BloodLipidData, data as BloodLipidData)
          return res;
        }

        default: {
          let res = plainToClass(HealthData, data as HealthData)
          return res;
        }

      }
    } catch (error) {
      console.error(`获取数据失败: ${error}`);
      return null;
    }
  }

  /**
   * 根据日期范围获取健康数据
   * @param startDate 开始日期时间戳
   * @param endDate 结束日期时间戳
   * @returns 健康数据数组
   */
  async getDataByDateRange(startDate: number, endDate: number): Promise<HealthData[]> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return [];
    }

    try {
      const dataTypes = ['weight', 'bloodPressure', 'bloodSugar', 'uricAcid', 'bloodLipid'];
      const result: HealthData[] = [];

      for (const dataType of dataTypes) {
        const indexKey = `index_${dataType}`;
        const indexValue = await this.dataStore.get(indexKey, '[]');

        if (indexValue) {
          const index: string[] = JSON.parse(indexValue as string);

          for (const id of index) {
            const data = await this.getDataById(id);
            if (data && data.timestamp >= startDate && data.timestamp <= endDate) {
              result.push(data);
            }
          }
        }
      }

      result.sort((a, b) => a.timestamp - b.timestamp);
      return result;
    } catch (error) {
      console.error(`获取日期范围数据失败: ${error}`);
      return [];
    }
  }

  /**
   * 获取指定类型的所有健康数据
   * @param dataType 数据类型
   * @returns 健康数据数组
   */
  async getDataByType(dataType: string): Promise<HealthData[]> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return [];
    }

    try {
      const indexKey = `index_${dataType}`;
      const indexValue = await this.dataStore.get(indexKey, '[]');

      if (!indexValue) {
        return [];
      }

      const indexList: string[] = JSON.parse(indexValue as string);
      const result: HealthData[] = [];

      for (const id of indexList) {
        const data = await this.getDataById(id);
        if (data) {
          result.push(data);
        }
      }

      return result;
    } catch (error) {
      console.error(`获取类型数据失败: ${error}`);
      return [];
    }
  }

  /**
   * 删除健康数据
   * @param id 数据ID
   * @returns 删除是否成功
   */
  async deleteData(id: string): Promise<boolean> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return false;
    }

    try {
      const dataType = id.split('_')[0];
      const indexKey = `index_${dataType}`;
      const indexValue = await this.dataStore.get(indexKey, '[]');

      if (indexValue) {
        const index: string[] = JSON.parse(indexValue as string);
        const newIndex: string[] = index.filter((item: string) => item !== id);
        await this.dataStore.put(indexKey, JSON.stringify(newIndex));
      }

      await this.dataStore.delete(id);
      await this.dataStore.flush();
      return true;
    } catch (error) {
      console.error(`删除数据失败: ${error}`);
      return false;
    }
  }
}
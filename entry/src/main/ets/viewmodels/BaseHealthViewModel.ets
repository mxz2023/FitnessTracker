/**
 * 健康评估ViewModel基类
 * 封装通用的健康状态处理方法
 */

import { HealthStatus, HealthData } from '../models/HealthDataModel';
import { HealthViewModel } from './HealthViewModel';
import { HealthDataServiceImpl } from '../models/HealthDataServiceImpl';
import { Context } from '@ohos.abilityAccessCtrl';
import { logger } from '../utils/Logger';

const TAG = 'BaseHealthViewModel';

/**
 * 健康评估基础ViewModel
 * 提供通用的状态颜色和文本获取方法以及数据持久化功能
 */
export abstract class BaseHealthViewModel extends HealthViewModel {
  protected dataService?: HealthDataServiceImpl;
  protected context?: Context;
  protected dataId: string = '';
  protected timestamp: number = Date.now();

  /**
   * 将当前ViewModel数据转换为HealthData对象
   * 子类必须实现此方法
   * @returns HealthData对象
   */
  protected abstract toHealthData(): HealthData | null;

  /**
   * 从HealthData对象加载数据到ViewModel
   * 子类必须实现此方法
   * @param data HealthData对象
   */
  protected abstract fromHealthData(data: HealthData): void;

  /**
   * 初始化数据服务
   * @param context 应用上下文
   */
  public async initDataService(context: Context): Promise<void> {
    this.context = context;
    this.timestamp = Date.now();
    this.dataId = `weight_${this.timestamp}`;
    this.dataService = new HealthDataServiceImpl(context);
    await this.dataService.initDataStore()
  }

  /**
   * 日期
   * @returns
   */
  get dataStr() {
    const date = new Date(this.timestamp)
    return `${date.getMonth() + 1}/${date.getDate()}`
  }

  /**
   * 获取健康状态对应的颜色
   * @param status 健康状态
   * @returns 颜色值
   */
  public getHealthStatusColor(status: HealthStatus): string {
    switch (status) {
      case HealthStatus.EXCELLENT:
        return '#4CAF50'; // 绿色
      case HealthStatus.GOOD:
        return '#8BC34A'; // 浅绿色
      case HealthStatus.MODERATE:
        return '#FFC107'; // 黄色
      case HealthStatus.POOR:
        return '#F44336'; // 红色
      default:
        return '#9E9E9E'; // 灰色
    }
  }

  /**
   * 获取健康状态对应的文本
   * @param status 健康状态
   * @returns 状态文本
   */
  public getHealthStatusText(status: HealthStatus): string {
    switch (status) {
      case HealthStatus.EXCELLENT:
        return '优';
      case HealthStatus.GOOD:
        return '良';
      case HealthStatus.MODERATE:
        return '中';
      case HealthStatus.POOR:
        return '差';
      default:
        return '未知';
    }
  }

  /**
   * 获取当前状态的颜色
   * @returns 颜色值
   */
  public getCurrentStatusColor(): string {
    return this.getHealthStatusColor(this.getHealthStatus());
  }

  /**
   * 获取当前状态的文本
   * @returns 状态文本
   */
  public getCurrentStatusText(): string {
    return this.getHealthStatusText(this.getHealthStatus());
  }

  /**
   * 保存健康数据
   * 子类需要实现此方法以提供具体的数据对象
   * @returns 保存是否成功
   */
  public async saveData(): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    const data = this.toHealthData();
    if (!data) {
      logger.error(TAG, '无法获取健康数据对象');
      return false;
    }

    try {
      const success = await this.dataService.saveData(data);
      if (success) {
        logger.info(TAG, `健康数据保存成功: ${data.id}`);
      } else {
        logger.error(TAG, `健康数据保存失败: ${data.id}`);
      }
      return success;
    } catch (error) {
      logger.error(TAG, `保存健康数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 加载指定ID的健康数据
   * @param id 数据ID
   * @returns 加载是否成功
   */
  async loadDataById(id: string): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    try {
      const data = await this.dataService.getDataById(id);
      if (data) {
        this.fromHealthData(data);
        logger.info(TAG, `健康数据加载成功: ${id}`);
        return true;
      } else {
        logger.warn(TAG, `未找到健康数据: ${id}`);
        return false;
      }
    } catch (error) {
      logger.error(TAG, `加载健康数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 加载指定类型的最新健康数据
   * @param dataType 数据类型
   * @returns 加载是否成功
   */
  async loadLatestData(dataType: string): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    try {
      const dataList = await this.dataService.getDataByType(dataType);
      if (dataList && dataList.length > 0) {
        // 获取最新的数据（索引已按时间倒序排列）
        const latestData = dataList[0];
        this.fromHealthData(latestData);
        logger.info(TAG, `加载最新健康数据成功: ${latestData.id}`);
        return true;
      } else {
        logger.warn(TAG, `未找到类型为 ${dataType} 的健康数据`);
        return false;
      }
    } catch (error) {
      logger.error(TAG, `加载最新健康数据异常: ${error}`);
      return false;
    }
  }

  /**
   * 加载指定日期范围的健康数据
   * @param startDate 开始日期时间戳
   * @param endDate 结束日期时间戳
   * @returns 健康数据数组
   */
  async loadDataByDateRange(startDate: number, endDate: number): Promise<HealthData[]> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return [];
    }

    try {
      const dataList = await this.dataService.getDataByDateRange(startDate, endDate);
      logger.info(TAG, `加载日期范围数据成功，共 ${dataList.length} 条`);
      return dataList;
    } catch (error) {
      logger.error(TAG, `加载日期范围数据异常: ${error}`);
      return [];
    }
  }

  /**
   * 加载指定类型的所有健康数据
   * @param dataType 数据类型
   * @returns 健康数据数组
   */
  async loadDataByType(dataType: string): Promise<HealthData[]> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return [];
    }

    try {
      const dataList = await this.dataService.getDataByType(dataType);
      logger.info(TAG, `加载类型数据成功，共 ${dataList.length} 条`);
      return dataList;
    } catch (error) {
      logger.error(TAG, `加载类型数据异常: ${error}`);
      return [];
    }
  }

  /**
   * 删除健康数据
   * @param id 数据ID
   * @returns 删除是否成功
   */
  async deleteData(id: string): Promise<boolean> {
    if (!this.dataService) {
      logger.error(TAG, '数据服务未初始化，请先调用 initDataService()');
      return false;
    }

    try {
      const success = await this.dataService.deleteData(id);
      if (success) {
        logger.info(TAG, `健康数据删除成功: ${id}`);
      } else {
        logger.error(TAG, `健康数据删除失败: ${id}`);
      }
      return success;
    } catch (error) {
      logger.exception(TAG, error, '删除健康数据异常')
      return false;
    }
  }
}
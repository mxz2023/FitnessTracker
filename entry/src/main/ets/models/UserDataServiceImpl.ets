/**
 * 用户数据服务实现类
 * 负责用户基本信息的持久化存储
 */

import { preferences } from '@kit.ArkData';
import { Context } from '@ohos.abilityAccessCtrl';
import { UserDataModel, Gender } from './UserDataModel';
import { logger } from '../utils/Logger';

const TAG = 'UserDataServiceImpl';

// 存储用户数据的首选项名称
const USER_DATA_PREFERENCE = 'user_data_preference';

/**
 * 用户数据服务实现类
 * 提供用户数据的增删改查功能
 */
export class UserDataServiceImpl {
  private dataStore: preferences.Preferences | null = null;
  private initialized: boolean = false;
  private context?: Context;

  constructor(context?: Context) {
    this.context = context;
    this.initDataStore();
  }

  /**
   * 初始化数据存储
   */
  private async initDataStore(): Promise<void> {
    if (!this.initialized) {
      try {
        await preferences.getPreferences(this.context, {
          name: USER_DATA_PREFERENCE
        }).then((store) => {
          this.dataStore = store;
          this.initialized = true;
          logger.info(TAG, '用户数据存储初始化成功');
        });
      } catch (error) {
        logger.error(TAG, `初始化用户数据存储失败: ${error}`);
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
    return this.initialized && this.dataStore !== null;
  }

  /**
   * 保存用户数据
   * @param userData 用户数据对象
   * @returns 保存是否成功
   */
  public async saveUserData(userData: UserDataModel): Promise<boolean> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      logger.error(TAG, '数据存储未初始化');
      return false;
    }

    try {
      await this.dataStore.put('nickname', userData.nickname);
      await this.dataStore.put('gender', userData.gender);
      await this.dataStore.put('age', userData.age);
      await this.dataStore.put('heightCm', userData.heightCm);
      await this.dataStore.flush();

      logger.info(TAG, '用户数据保存成功');
      return true;
    } catch (error) {
      logger.error(TAG, `保存用户数据失败: ${error}`);
      return false;
    }
  }

  /**
   * 加载用户数据
   * @returns 用户数据对象，如果不存在则返回null
   */
  public async loadUserData(): Promise<UserDataModel | null> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      logger.error(TAG, '数据存储未初始化');
      return null;
    }

    try {
      const nickname = await this.dataStore.get('nickname', '');
      const gender = await this.dataStore.get('gender', Gender.UNKNOWN);
      const age = await this.dataStore.get('age', 0);
      const heightCm = await this.dataStore.get('heightCm', 0);

      const userData: UserDataModel = {
        nickname: nickname as string,
        gender: gender as Gender,
        age: age as number,
        heightCm: heightCm as number
      };

      logger.info(TAG, '用户数据加载成功');
      return userData;
    } catch (error) {
      logger.error(TAG, `加载用户数据失败: ${error}`);
      return null;
    }
  }

  /**
   * 清除用户数据
   * @returns 清除是否成功
   */
  public async clearUserData(): Promise<boolean> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      logger.error(TAG, '数据存储未初始化');
      return false;
    }

    try {
      await this.dataStore.clear();
      logger.info(TAG, '用户数据清除成功');
      return true;
    } catch (error) {
      logger.error(TAG, `清除用户数据失败: ${error}`);
      return false;
    }
  }

  /**
   * 检查用户数据是否存在
   * @returns 是否存在用户数据
   */
  public async hasUserData(): Promise<boolean> {
    if (!await this.ensureInitialized() || !this.dataStore) {
      return false;
    }

    try {
      const nickname = await this.dataStore.get('nickname', '');
      return (nickname as string).length > 0;
    } catch (error) {
      logger.error(TAG, `检查用户数据失败: ${error}`);
      return false;
    }
  }
}
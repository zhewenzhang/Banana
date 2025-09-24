// 存储管理器 - 处理用户数据和token的持久化
import { preferences } from '@kit.ArkData';
import { UserData } from './UserTypes';

export interface StoredUserSession {
  userData: UserData;
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
  isLoggedIn: boolean;
}

export class StorageManager {
  private static instance: StorageManager;
  private static readonly PREFERENCES_NAME = 'user_session';
  private static readonly USER_DATA_KEY = 'user_data';
  private static readonly ACCESS_TOKEN_KEY = 'access_token';
  private static readonly REFRESH_TOKEN_KEY = 'refresh_token';
  private static readonly EXPIRES_AT_KEY = 'expires_at';
  private static readonly IS_LOGGED_IN_KEY = 'is_logged_in';

  private preferencesStore: preferences.Preferences | null = null;

  // 单例模式
  public static getInstance(): StorageManager {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
    }
    return StorageManager.instance;
  }

  // 初始化存储
  public async initialize(): Promise<void> {
    try {
      this.preferencesStore = await preferences.getPreferences(getContext(), StorageManager.PREFERENCES_NAME);
      console.log('StorageManager 初始化成功');
    } catch (error) {
      console.error('StorageManager 初始化失败:', error);
    }
  }

  // 保存用户会话信息
  public async saveUserSession(session: StoredUserSession): Promise<boolean> {
    try {
      if (!this.preferencesStore) {
        await this.initialize();
      }

      if (!this.preferencesStore) {
        console.error('存储未初始化');
        return false;
      }

      // 保存用户数据
      await this.preferencesStore.put(StorageManager.USER_DATA_KEY, JSON.stringify(session.userData));
      await this.preferencesStore.put(StorageManager.ACCESS_TOKEN_KEY, session.accessToken);
      await this.preferencesStore.put(StorageManager.REFRESH_TOKEN_KEY, session.refreshToken);
      await this.preferencesStore.put(StorageManager.EXPIRES_AT_KEY, session.expiresAt);
      await this.preferencesStore.put(StorageManager.IS_LOGGED_IN_KEY, session.isLoggedIn);

      // 刷新到磁盘
      await this.preferencesStore.flush();

      console.log('用户会话信息保存成功');
      console.log('保存的用户数据:', session.userData);
      return true;
    } catch (error) {
      console.error('保存用户会话信息失败:', error);
      return false;
    }
  }

  // 获取用户会话信息
  public async getUserSession(): Promise<StoredUserSession | null> {
    try {
      if (!this.preferencesStore) {
        await this.initialize();
      }

      if (!this.preferencesStore) {
        console.error('存储未初始化');
        return null;
      }

      const isLoggedIn = await this.preferencesStore.get(StorageManager.IS_LOGGED_IN_KEY, false) as boolean;
      
      if (!isLoggedIn) {
        console.log('用户未登录');
        return null;
      }

      const userDataStr = await this.preferencesStore.get(StorageManager.USER_DATA_KEY, '') as string;
      const accessToken = await this.preferencesStore.get(StorageManager.ACCESS_TOKEN_KEY, '') as string;
      const refreshToken = await this.preferencesStore.get(StorageManager.REFRESH_TOKEN_KEY, '') as string;
      const expiresAt = await this.preferencesStore.get(StorageManager.EXPIRES_AT_KEY, 0) as number;

      if (!userDataStr || !accessToken) {
        console.log('用户会话数据不完整');
        return null;
      }

      // 检查token是否过期
      const now = Date.now();
      if (expiresAt > 0 && now > expiresAt) {
        console.log('Token已过期');
        await this.clearUserSession();
        return null;
      }

      const userData: UserData = JSON.parse(userDataStr);
      
      console.log('StorageManager - 解析的用户数据:', JSON.stringify(userData, null, 2));
      console.log('StorageManager - 用户ID:', userData?.id);
      console.log('StorageManager - 用户ID类型:', typeof userData?.id);
      
      const session: StoredUserSession = {
        userData,
        accessToken,
        refreshToken,
        expiresAt,
        isLoggedIn: true
      };

      console.log('获取用户会话信息成功');
      console.log('用户数据:', userData);
      return session;
    } catch (error) {
      console.error('获取用户会话信息失败:', error);
      return null;
    }
  }

  // 清除用户会话信息
  public async clearUserSession(): Promise<boolean> {
    try {
      if (!this.preferencesStore) {
        await this.initialize();
      }

      if (!this.preferencesStore) {
        console.error('存储未初始化');
        return false;
      }

      await this.preferencesStore.delete(StorageManager.USER_DATA_KEY);
      await this.preferencesStore.delete(StorageManager.ACCESS_TOKEN_KEY);
      await this.preferencesStore.delete(StorageManager.REFRESH_TOKEN_KEY);
      await this.preferencesStore.delete(StorageManager.EXPIRES_AT_KEY);
      await this.preferencesStore.put(StorageManager.IS_LOGGED_IN_KEY, false);

      // 刷新到磁盘
      await this.preferencesStore.flush();

      console.log('用户会话信息清除成功');
      return true;
    } catch (error) {
      console.error('清除用户会话信息失败:', error);
      return false;
    }
  }

  /**
   * 强制清除所有本地存储数据（用于修复数据结构问题）
   */
  public async forceCleanStorage(): Promise<void> {
    try {
      if (!this.preferencesStore) {
        await this.initialize();
      }

      if (this.preferencesStore) {
        await this.preferencesStore.clear();
        await this.preferencesStore.flush();
        console.log('所有本地存储数据已强制清除');
      }
    } catch (error) {
      console.error('强制清除本地存储失败:', error);
    }
  }

  // 检查是否已登录
  public async isLoggedIn(): Promise<boolean> {
    try {
      const session = await this.getUserSession();
      return session !== null;
    } catch (error) {
      console.error('检查登录状态失败:', error);
      return false;
    }
  }

  // 更新用户数据（保持token不变）
  public async updateUserData(userData: UserData): Promise<boolean> {
    try {
      const session = await this.getUserSession();
      if (!session) {
        console.error('用户未登录，无法更新用户数据');
        return false;
      }

      session.userData = userData;
      return await this.saveUserSession(session);
    } catch (error) {
      console.error('更新用户数据失败:', error);
      return false;
    }
  }
}
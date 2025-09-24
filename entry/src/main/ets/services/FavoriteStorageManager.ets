// 收藏状态本地存储管理器
import dataPreferences from '@ohos.data.preferences';
import { FavoriteRecord } from '../common/UserTypes';

// 收藏缓存接口 - 记录ID到收藏状态的映射
export interface FavoriteCache {
  get(recordId: string): boolean | undefined;
  set(recordId: string, isFavorite: boolean): void;
  has(recordId: string): boolean;
  delete(recordId: string): void;
}

// 用户收藏缓存接口 - 用户ID到收藏缓存的映射
export interface UserFavoriteCache {
  get(userId: string): Map<string, boolean> | undefined;
  set(userId: string, cache: Map<string, boolean>): void;
  has(userId: string): boolean;
  delete(userId: string): void;
}

// 用户收藏记录缓存接口
export interface UserFavoriteRecordsCache {
  get(userId: string): FavoriteRecord[] | undefined;
  set(userId: string, records: FavoriteRecord[]): void;
  has(userId: string): boolean;
  delete(userId: string): void;
}

export class FavoriteStorageManager {
  private static instance: FavoriteStorageManager;
  private preferences: dataPreferences.Preferences | null = null;
  private readonly STORAGE_NAME = 'favorite_storage';
  private readonly FAVORITE_CACHE_KEY = 'favorite_cache';
  private readonly FAVORITE_RECORDS_KEY = 'favorite_records';
  
  // 内存缓存
  private favoriteCache: Map<string, Map<string, boolean>> = new Map();
  private favoriteRecordsCache: Map<string, FavoriteRecord[]> = new Map();

  private constructor() {}

  // 单例模式
  public static getInstance(): FavoriteStorageManager {
    if (!FavoriteStorageManager.instance) {
      FavoriteStorageManager.instance = new FavoriteStorageManager();
    }
    return FavoriteStorageManager.instance;
  }

  // 初始化存储（简化版本，不需要Context参数）
  public async initStorage(): Promise<void> {
    console.log('=== FavoriteStorageManager initStorage 开始 ===');
    
    try {
      // 使用全局上下文获取preferences
      const context = getContext();
      this.preferences = await dataPreferences.getPreferences(context, this.STORAGE_NAME);
      console.log('收藏存储管理器初始化成功');
    } catch (error) {
      console.error('收藏存储管理器初始化失败:', error);
      // 不抛出错误，允许应用继续运行
    }
  }

  // 缓存收藏状态
  public async cacheFavoriteStatus(userId: string, recordId: number, isFavorite: boolean): Promise<void> {
    console.log('=== cacheFavoriteStatus 开始 ===');
    console.log('缓存收藏状态 - userId:', userId, 'recordId:', recordId, 'isFavorite:', isFavorite);

    if (!this.preferences) {
      console.error('存储未初始化');
      return;
    }

    try {
      // 更新内存缓存
      if (!this.favoriteCache.has(userId)) {
        this.favoriteCache.set(userId, new Map<string, boolean>());
      }
      const userCache = this.favoriteCache.get(userId);
      if (userCache) {
        userCache.set(recordId.toString(), isFavorite);
      }

      // 持久化到存储
      const cacheData = this.mapToObject(this.favoriteCache);
      await this.preferences.put(this.FAVORITE_CACHE_KEY, JSON.stringify(cacheData));
      await this.preferences.flush();

      console.log('收藏状态缓存成功');
    } catch (error) {
      console.error('缓存收藏状态失败:', error);
    }
  }

  // 获取缓存的收藏状态
  public async getCachedFavoriteStatus(userId: string, recordId: number): Promise<boolean | null> {
    console.log('=== getCachedFavoriteStatus 开始 ===');
    console.log('获取缓存收藏状态 - userId:', userId, 'recordId:', recordId);

    // 先从内存缓存获取
    const userCache = this.favoriteCache.get(userId);
    if (userCache && userCache.has(recordId.toString())) {
      const isFavorite = userCache.get(recordId.toString());
      console.log('从内存缓存获取收藏状态:', isFavorite);
      return isFavorite ?? null;
    }

    // 内存缓存没有，从持久化存储获取
    if (!this.preferences) {
      console.error('存储未初始化');
      return null;
    }

    try {
      const cacheStr = await this.preferences.get(this.FAVORITE_CACHE_KEY, '{}') as string;
      const cacheData: Record<string, Record<string, boolean>> = JSON.parse(cacheStr) as Record<string, Record<string, boolean>>;
      
      // 恢复到内存缓存
      this.favoriteCache = this.objectToMap(cacheData);
      
      const restoredUserCache = this.favoriteCache.get(userId);
      if (!restoredUserCache || !restoredUserCache.has(recordId.toString())) {
        console.log('用户缓存不存在或记录不存在');
        return null;
      }

      const isFavorite = restoredUserCache.get(recordId.toString());
      console.log('从持久化存储获取收藏状态:', isFavorite);
      return isFavorite ?? null;
    } catch (error) {
      console.error('获取缓存收藏状态失败:', error);
      return null;
    }
  }

  // 缓存收藏记录列表
  public async cacheFavoriteRecords(userId: string, records: FavoriteRecord[]): Promise<void> {
    console.log('=== cacheFavoriteRecords 开始 ===');
    console.log('缓存收藏记录 - userId:', userId, '记录数量:', records.length);

    if (!this.preferences) {
      console.error('存储未初始化');
      return;
    }

    try {
      // 更新内存缓存
      this.favoriteRecordsCache.set(userId, records);

      // 持久化到存储
      const recordsData = this.mapToRecordsObject(this.favoriteRecordsCache);
      await this.preferences.put(this.FAVORITE_RECORDS_KEY, JSON.stringify(recordsData));

      // 同时更新收藏状态缓存
      if (!this.favoriteCache.has(userId)) {
        this.favoriteCache.set(userId, new Map<string, boolean>());
      }
      const userCache = this.favoriteCache.get(userId);
      if (userCache) {
        // 根据记录列表更新状态缓存
        records.forEach(record => {
          userCache.set(record.recordId.toString(), true);
        });
      }

      // 持久化状态缓存
      const cacheData = this.mapToObject(this.favoriteCache);
      await this.preferences.put(this.FAVORITE_CACHE_KEY, JSON.stringify(cacheData));
      await this.preferences.flush();

      console.log('收藏记录缓存成功');
    } catch (error) {
      console.error('缓存收藏记录失败:', error);
    }
  }

  // 获取缓存的收藏记录列表
  public async getCachedFavoriteRecords(userId: string): Promise<FavoriteRecord[]> {
    console.log('=== getCachedFavoriteRecords 开始 ===');
    console.log('获取缓存收藏记录 - userId:', userId);

    // 先从内存缓存获取
    if (this.favoriteRecordsCache.has(userId)) {
      const records = this.favoriteRecordsCache.get(userId);
      console.log('从内存缓存获取收藏记录数量:', records?.length ?? 0);
      return records ?? [];
    }

    // 内存缓存没有，从持久化存储获取
    if (!this.preferences) {
      console.error('存储未初始化');
      return [];
    }

    try {
      const recordsStr = await this.preferences.get(this.FAVORITE_RECORDS_KEY, '{}') as string;
      const recordsData: Record<string, FavoriteRecord[]> = JSON.parse(recordsStr) as Record<string, FavoriteRecord[]>;
      
      // 恢复到内存缓存
      this.favoriteRecordsCache = this.objectToRecordsMap(recordsData);
      
      const userRecords = this.favoriteRecordsCache.get(userId) ?? [];
      console.log('从持久化存储获取收藏记录数量:', userRecords.length);
      
      return userRecords;
    } catch (error) {
      console.error('获取缓存收藏记录失败:', error);
      return [];
    }
  }

  // 清除用户的收藏缓存
  public async clearUserFavoriteCache(userId: string): Promise<void> {
    console.log('=== clearUserFavoriteCache 开始 ===');
    console.log('清除用户收藏缓存 - userId:', userId);

    // 清除内存缓存
    this.favoriteCache.delete(userId);
    this.favoriteRecordsCache.delete(userId);

    if (!this.preferences) {
      console.error('存储未初始化');
      return;
    }

    try {
      // 持久化清除状态缓存
      const cacheData = this.mapToObject(this.favoriteCache);
      await this.preferences.put(this.FAVORITE_CACHE_KEY, JSON.stringify(cacheData));

      // 持久化清除记录缓存
      const recordsData = this.mapToRecordsObject(this.favoriteRecordsCache);
      await this.preferences.put(this.FAVORITE_RECORDS_KEY, JSON.stringify(recordsData));
      await this.preferences.flush();

      console.log('用户收藏缓存清除成功');
    } catch (error) {
      console.error('清除用户收藏缓存失败:', error);
    }
  }

  // 移除特定记录的缓存
  public async removeFavoriteFromCache(userId: string, recordId: number): Promise<void> {
    console.log('=== removeFavoriteFromCache 开始 ===');
    console.log('从缓存移除收藏 - userId:', userId, 'recordId:', recordId);

    // 更新内存缓存
    const userCache = this.favoriteCache.get(userId);
    if (userCache) {
      userCache.delete(recordId.toString());
    }

    const userRecords = this.favoriteRecordsCache.get(userId);
    if (userRecords) {
      const filteredRecords = userRecords.filter(record => record.recordId !== recordId);
      this.favoriteRecordsCache.set(userId, filteredRecords);
    }

    if (!this.preferences) {
      console.error('存储未初始化');
      return;
    }

    try {
      // 持久化更新状态缓存
      const cacheData = this.mapToObject(this.favoriteCache);
      await this.preferences.put(this.FAVORITE_CACHE_KEY, JSON.stringify(cacheData));

      // 持久化更新记录缓存
      const recordsData = this.mapToRecordsObject(this.favoriteRecordsCache);
      await this.preferences.put(this.FAVORITE_RECORDS_KEY, JSON.stringify(recordsData));
      await this.preferences.flush();

      console.log('收藏记录移除成功');
    } catch (error) {
      console.error('移除收藏记录失败:', error);
    }
  }

  // Map 转换为普通对象的辅助方法
  private mapToObject(map: Map<string, Map<string, boolean>>): Record<string, Record<string, boolean>> {
    const obj: Record<string, Record<string, boolean>> = {};
    map.forEach((value, key) => {
      const innerObj: Record<string, boolean> = {};
      value.forEach((innerValue, innerKey) => {
        innerObj[innerKey] = innerValue;
      });
      obj[key] = innerObj;
    });
    return obj;
  }

  // 普通对象转换为 Map 的辅助方法
  private objectToMap(obj: Record<string, Record<string, boolean>>): Map<string, Map<string, boolean>> {
    const map = new Map<string, Map<string, boolean>>();
    Object.keys(obj).forEach(key => {
      const innerMap = new Map<string, boolean>();
      Object.keys(obj[key]).forEach(innerKey => {
        innerMap.set(innerKey, obj[key][innerKey]);
      });
      map.set(key, innerMap);
    });
    return map;
  }

  // Records Map 转换为普通对象的辅助方法
  private mapToRecordsObject(map: Map<string, FavoriteRecord[]>): Record<string, FavoriteRecord[]> {
    const obj: Record<string, FavoriteRecord[]> = {};
    map.forEach((value, key) => {
      obj[key] = value;
    });
    return obj;
  }

  // 普通对象转换为 Records Map 的辅助方法
  private objectToRecordsMap(obj: Record<string, FavoriteRecord[]>): Map<string, FavoriteRecord[]> {
    const map = new Map<string, FavoriteRecord[]>();
    Object.keys(obj).forEach(key => {
      map.set(key, obj[key]);
    });
    return map;
  }
}
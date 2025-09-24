// 收藏功能服务类
import http from '@ohos.net.http';
import { SupabaseConfig } from '../common/SupabaseConfig';
import { FavoriteRecord, FavoriteRequest, FavoriteResponse, FavoriteStatusResponse, CreateFavoriteRecord, HttpHeaders } from '../common/UserTypes';
import { AuthService } from './AuthService';
import { FavoriteStorageManager } from './FavoriteStorageManager';

export class FavoriteService {
  private static instance: FavoriteService;
  private authService: AuthService;
  private storageManager: FavoriteStorageManager;

  private constructor() {
    this.authService = AuthService.getInstance();
    this.storageManager = FavoriteStorageManager.getInstance();
  }

  // 单例模式
  public static getInstance(): FavoriteService {
    if (!FavoriteService.instance) {
      FavoriteService.instance = new FavoriteService();
    }
    return FavoriteService.instance;
  }

  // 添加收藏
  public async addFavorite(request: FavoriteRequest): Promise<FavoriteResponse> {
    console.log('=== FavoriteService addFavorite 开始 ===');
    console.log('收藏请求:', request);

    try {
      // 检查用户是否已登录
      const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        return {
          success: false,
          message: '用户未登录，无法收藏'
        };
      }

      // 获取用户会话信息
      const currentUser = await this.authService.getCurrentUser();
      if (!currentUser) {
        return {
          success: false,
          message: '无法获取用户认证信息'
        };
      }

      // 构造收藏记录数据
      const favoriteRecord: CreateFavoriteRecord = {
        userId: request.userId,
        recordId: request.recordId,
        recordTitle: request.recordData.title,
        recordArtist: request.recordData.artist,
        recordImage: request.recordData.image,
        recordYear: request.recordData.year,
        recordGenres: request.recordData.genres,
        recordFormats: request.recordData.formats,
        favoriteTime: new Date().toISOString()
      };

      console.log('准备保存的收藏记录:', favoriteRecord);

      // 发送到Supabase数据库
      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${currentUser.accessToken}`,
        'Prefer': 'return=representation'
      };

      const requestUrl = `${SupabaseConfig.getRestUrl()}/favorites`;
      console.log('请求URL:', requestUrl);
      console.log('请求头:', headers);

      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.POST,
        header: headers,
        extraData: JSON.stringify(favoriteRecord)
      });

      console.log('响应状态码:', response.responseCode);
      console.log('响应数据:', response.result);

      if (response.responseCode === 201) {
        const savedRecord: FavoriteRecord[] = JSON.parse(response.result as string) as FavoriteRecord[];
        console.log('收藏保存成功:', savedRecord[0]);
        
        // 缓存收藏状态
        await this.storageManager.cacheFavoriteStatus(request.userId, request.recordId, true);
        
        return {
          success: true,
          message: '收藏成功',
          data: savedRecord[0]
        };
      } else {
        console.error('收藏保存失败，状态码:', response.responseCode);
        return {
          success: false,
          message: '收藏保存失败'
        };
      }

    } catch (error) {
      console.error('addFavorite 错误:', error);
      return {
        success: false,
        message: '收藏操作失败: ' + (error as Error).message
      };
    }
  }

  // 移除收藏
  public async removeFavorite(userId: string, recordId: number): Promise<FavoriteResponse> {
    console.log('=== FavoriteService removeFavorite 开始 ===');
    console.log('移除收藏 - userId:', userId, 'recordId:', recordId);

    try {
      // 检查用户是否已登录
      const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        return {
          success: false,
          message: '用户未登录，无法操作'
        };
      }

      // 获取用户会话信息
      const currentUser = await this.authService.getCurrentUser();
      if (!currentUser) {
        return {
          success: false,
          message: '无法获取用户认证信息'
        };
      }

      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${currentUser.accessToken}`
      };

      const requestUrl = `${SupabaseConfig.getRestUrl()}/favorites?userId=eq.${userId}&recordId=eq.${recordId}`;
      console.log('删除请求URL:', requestUrl);

      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.DELETE,
        header: headers
      });

      console.log('删除响应状态码:', response.responseCode);

      if (response.responseCode === 204) {
        console.log('收藏移除成功');
        
        // 从缓存中移除
        await this.storageManager.removeFavoriteFromCache(userId, recordId);
        
        return {
          success: true,
          message: '取消收藏成功'
        };
      } else {
        console.error('收藏移除失败，状态码:', response.responseCode);
        return {
          success: false,
          message: '取消收藏失败'
        };
      }

    } catch (error) {
      console.error('removeFavorite 错误:', error);
      return {
        success: false,
        message: '取消收藏操作失败: ' + (error as Error).message
      };
    }
  }

  // 检查收藏状态
  public async checkFavoriteStatus(userId: string, recordId: number): Promise<FavoriteStatusResponse> {
    console.log('=== FavoriteService checkFavoriteStatus 开始 ===');
    console.log('检查收藏状态 - userId:', userId, 'recordId:', recordId);

    try {
      // 检查用户是否已登录
      const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        return {
          isFavorite: false
        };
      }

      // 首先尝试从缓存获取
      const cachedStatus = await this.storageManager.getCachedFavoriteStatus(userId, recordId);
      if (cachedStatus !== null) {
        console.log('从缓存获取收藏状态:', cachedStatus);
        return {
          isFavorite: cachedStatus
        };
      }

      // 缓存中没有，从服务器获取
      console.log('缓存中无数据，从服务器查询');

      // 获取用户会话信息
      const currentUser = await this.authService.getCurrentUser();
      if (!currentUser) {
        return {
          isFavorite: false
        };
      }

      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${currentUser.accessToken}`
      };

      const requestUrl = `${SupabaseConfig.getRestUrl()}/favorites?userId=eq.${userId}&recordId=eq.${recordId}`;
      console.log('查询请求URL:', requestUrl);

      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        header: headers
      });

      console.log('查询响应状态码:', response.responseCode);
      console.log('查询响应数据:', response.result);

      if (response.responseCode === 200) {
        const favorites: FavoriteRecord[] = JSON.parse(response.result as string) as FavoriteRecord[];
        const isFavorite = favorites.length > 0;
        
        console.log('收藏状态查询结果:', isFavorite);
        
        // 缓存查询结果
        await this.storageManager.cacheFavoriteStatus(userId, recordId, isFavorite);
        
        return {
          isFavorite: isFavorite,
          favoriteRecord: isFavorite ? favorites[0] : undefined
        };
      } else {
        console.error('收藏状态查询失败，状态码:', response.responseCode);
        return {
          isFavorite: false
        };
      }

    } catch (error) {
      console.error('checkFavoriteStatus 错误:', error);
      
      // 发生错误时，尝试从缓存获取
      const cachedStatus = await this.storageManager.getCachedFavoriteStatus(userId, recordId);
      return {
        isFavorite: cachedStatus ?? false
      };
    }
  }

  // 获取用户的所有收藏
  public async getUserFavorites(userId: string): Promise<FavoriteRecord[]> {
    console.log('=== FavoriteService getUserFavorites 开始 ===');
    console.log('获取用户收藏 - userId:', userId);

    try {
      // 检查用户是否已登录
      const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        return [];
      }

      // 首先尝试从缓存获取
      const cachedFavorites = await this.storageManager.getCachedFavoriteRecords(userId);
      if (cachedFavorites && cachedFavorites.length > 0) {
        console.log('从缓存获取收藏列表，数量:', cachedFavorites.length);
        return cachedFavorites;
      }

      // 缓存中没有，从服务器获取
      console.log('缓存中无数据，从服务器查询收藏列表');

      // 获取用户会话信息
      const currentUser = await this.authService.getCurrentUser();
      if (!currentUser) {
        return [];
      }

      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${currentUser.accessToken}`
      };

      const requestUrl = `${SupabaseConfig.getRestUrl()}/favorites?userId=eq.${userId}&order=favoriteTime.desc`;
      console.log('获取收藏列表请求URL:', requestUrl);

      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        header: headers
      });

      console.log('获取收藏列表响应状态码:', response.responseCode);

      if (response.responseCode === 200) {
        const favorites: FavoriteRecord[] = JSON.parse(response.result as string) as FavoriteRecord[];
        console.log('获取到收藏记录数量:', favorites.length);
        
        // 缓存查询结果
        await this.storageManager.cacheFavoriteRecords(userId, favorites);
        
        return favorites;
      } else {
        console.error('获取收藏列表失败，状态码:', response.responseCode);
        return [];
      }

    } catch (error) {
      console.error('getUserFavorites 错误:', error);
      
      // 发生错误时，尝试从缓存获取
      const cachedFavorites = await this.storageManager.getCachedFavoriteRecords(userId);
      return cachedFavorites ?? [];
    }
  }
}
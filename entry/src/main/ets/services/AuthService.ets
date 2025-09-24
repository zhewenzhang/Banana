// 用戶認證服務
import { SupabaseConfig } from '../common/SupabaseConfig';
import { UserData, UserStats } from '../common/UserTypes';
import { StorageManager, StoredUserSession } from '../common/StorageManager';
import { http } from '@kit.NetworkKit';

// 會話信息接口
export interface SessionInfo {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}

// 認證響應接口
export interface AuthResponse {
  success: boolean;
  message: string;
  user?: UserData;
  session?: SessionInfo;
}

// 註冊請求接口
export interface RegisterRequest {
  email: string;
  password: string;
  username: string;
}

// 登錄請求接口
export interface LoginRequest {
  email: string;
  password: string;
}

// Supabase 用戶數據接口
interface SupabaseUserData {
  username: string;
  display_name: string;
}

// Supabase 註冊數據接口
interface SupabaseSignupData {
  email: string;
  password: string;
  data: SupabaseUserData;
}

// Supabase 登錄數據接口
interface SupabaseLoginData {
  email: string;
  password: string;
}

// HTTP 請求頭接口
interface HttpHeaders {
  'Content-Type': string;
  'apikey': string;
  'Authorization': string;
}

// Supabase 用戶資料接口
interface SupabaseProfile {
  id?: string;
  email?: string;
  full_name?: string;
  username?: string;
  display_name?: string;
  bio?: string;
  avatar_url?: string;
  records_count?: number;
  followers_count?: number;
  following_count?: number;
  created_at?: string;
  updated_at?: string;
}

// Supabase 用戶接口
interface SupabaseUser {
  id: string;
}

// Supabase 響應數據接口
interface SupabaseResponse {
  user?: SupabaseUser;
  session?: SessionInfo;
  access_token?: string;
  error_description?: string;
}

export class AuthService {
  private static instance: AuthService;
  private storageManager: StorageManager;
  
  // 單例模式
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  // 私有构造函数
  private constructor() {
    this.storageManager = StorageManager.getInstance();
  }

  // 初始化服务
  public async initialize(): Promise<void> {
    await this.storageManager.initialize();
  }

  // 检查是否已登录
  public async isLoggedIn(): Promise<boolean> {
    return await this.storageManager.isLoggedIn();
  }

  // 获取当前用户数据（包含accessToken）
  public async getCurrentUser(): Promise<UserData | null> {
    const session = await this.storageManager.getUserSession();
    if (!session?.userData) {
      return null;
    }
    
    // 将accessToken添加到userData中，确保FavoriteService能够获取到认证令牌
    const userDataWithToken: UserData = {
      id: session.userData.id,
      name: session.userData.name,
      username: session.userData.username,
      bio: session.userData.bio,
      avatar: session.userData.avatar,
      joinDate: session.userData.joinDate,
      stats: session.userData.stats,
      accessToken: session.accessToken
    };
    
    return userDataWithToken;
  }
  
  // 用戶註冊
  public async register(request: RegisterRequest): Promise<AuthResponse> {
    try {
      // 檢查配置
      if (!SupabaseConfig.isConfigured()) {
        const errorResponse: AuthResponse = {
          success: false,
          message: '請先配置 Supabase 連接信息'
        };
        return errorResponse;
      }
      
      // 構建註冊請求
      const userData: SupabaseUserData = {
        username: request.username,
        display_name: request.username
      };
      
      const signupData: SupabaseSignupData = {
        email: request.email,
        password: request.password,
        data: userData
      };
      
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        `${SupabaseConfig.getAuthUrl()}/signup`,
        {
          method: http.RequestMethod.POST,
          header: SupabaseConfig.getHeaders(),
          extraData: JSON.stringify(signupData)
        }
      );
      
      if (response.responseCode === 200) {
        const responseData: SupabaseResponse = JSON.parse(response.result as string);
        
        // 創建用戶數據
        const userStats: UserStats = {
          records: 0,
          followers: 0,
          following: 0
        };
        
        const userData: UserData = {
          id: responseData.user?.id || `register_${request.username}_${Date.now()}`, // 添加用户ID
          name: request.username,
          username: `@${request.username}`,
          bio: 'Music lover • New member',
          avatar: '',
          joinDate: 'Joined ' + new Date().toLocaleDateString(),
          stats: userStats
        };
        
        return {
          success: true,
          message: '註冊成功',
          user: userData,
          session: responseData.session
        };
      } else {
        const errorData: SupabaseResponse = JSON.parse(response.result as string);
        return {
          success: false,
          message: errorData.error_description || '註冊失敗'
        };
      }
    } catch (error) {
      console.error('註冊錯誤:', error);
      
      // 如果是網絡錯誤，返回模擬數據用於測試
      if (!SupabaseConfig.isConfigured()) {
        return this.mockRegister(request);
      }
      
      const errorResponse: AuthResponse = {
        success: false,
        message: '網絡錯誤，請檢查網絡連接'
      };
      return errorResponse;
    }
  }
  
  // 用戶登錄
  public async login(request: LoginRequest): Promise<AuthResponse> {
    try {
      // 檢查配置
      if (!SupabaseConfig.isConfigured()) {
        return {
          success: false,
          message: '請先配置 Supabase 連接信息'
        };
      }
      
      const loginData: SupabaseLoginData = {
        email: request.email,
        password: request.password
      };
      
      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        `${SupabaseConfig.getAuthUrl()}/token?grant_type=password`,
        {
          method: http.RequestMethod.POST,
          header: SupabaseConfig.getHeaders(),
          extraData: JSON.stringify(loginData)
        }
      );
      
      if (response.responseCode === 200) {
        const responseData: SupabaseResponse = JSON.parse(response.result as string);
        console.log('登录响应数据:', responseData);
        
        // 獲取用戶資料
        const userData = await this.getUserProfile(responseData.user?.id || '', responseData.access_token || '');
        console.log('最终返回的用户数据:', userData);
        
        // 保存用户会话信息到本地存储
        const session: StoredUserSession = {
          userData,
          accessToken: responseData.access_token || '',
          refreshToken: responseData.session?.refresh_token || '',
          expiresAt: responseData.session?.expires_in ? Date.now() + (responseData.session.expires_in * 1000) : 0,
          isLoggedIn: true
        };
        
        const saveResult = await this.storageManager.saveUserSession(session);
        if (saveResult) {
          console.log('用户会话信息保存成功');
        } else {
          console.error('用户会话信息保存失败');
        }
        
        return {
          success: true,
          message: '登錄成功',
          user: userData,
          session: responseData.session
        };
      } else {
        const errorData: SupabaseResponse = JSON.parse(response.result as string);
        return {
          success: false,
          message: errorData.error_description || '登錄失敗'
        };
      }
    } catch (error) {
      console.error('登錄錯誤:', error);
      
      // 如果是網絡錯誤，返回模擬數據用於測試
      if (!SupabaseConfig.isConfigured()) {
        return await this.mockLogin(request);
      }
      
      return {
        success: false,
        message: '網絡錯誤，請檢查網絡連接'
      };
    }
  }
  
  // 獲取用戶資料
  private async getUserProfile(userId: string, accessToken: string): Promise<UserData> {
    console.log('=== getUserProfile 开始 ===');
    console.log('userId:', userId);
    console.log('accessToken:', accessToken ? '已提供' : '未提供');
    
    try {
      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${accessToken}`
      };
      
      // 修改查询逻辑：如果userId为空或无效，则查询所有profiles并取第一个
      let requestUrl = `${SupabaseConfig.getRestUrl()}/profiles`;
      if (userId && userId.trim() !== '') {
        requestUrl += `?id=eq.${userId}`;
        console.log('按用户ID查询:', userId);
      } else {
        requestUrl += '?limit=1';
        console.log('查询第一个可用的用户profile');
      }
      
      console.log('请求URL:', requestUrl);
      console.log('请求头:', headers);
      
      const response = await httpRequest.request(requestUrl, {
        method: http.RequestMethod.GET,
        header: headers
      });
      
      console.log('响应状态码:', response.responseCode);
      console.log('响应数据:', response.result);
      
      if (response.responseCode === 200) {
        const profiles: SupabaseProfile[] = JSON.parse(response.result as string);
        console.log('解析的profiles数据:', profiles);
        
        if (profiles && profiles.length > 0) {
          const profile = profiles[0];
          console.log('用户profile数据:', profile);
          
          const userStats: UserStats = {
            records: profile.records_count || 0,
            followers: profile.followers_count || 0,
            following: profile.following_count || 0
          };
          
          const userData: UserData = {
            id: profile.id || userId, // 修正：只使用profile.id或userId
            name: profile.display_name || profile.full_name || profile.username || 'User',
            username: profile.username ? `@${profile.username}` : `@${profile.email?.split('@')[0] || 'user'}`,
            bio: profile.bio || 'Music lover',
            avatar: profile.avatar_url || '',
            joinDate: 'Joined ' + new Date(profile.created_at || '').toLocaleDateString(),
            stats: userStats
          };
          
          console.log('构造的用户数据:', userData);
          return userData;
        } else {
          console.log('未找到用户profile数据');
        }
      } else {
        console.log('请求失败，状态码:', response.responseCode);
      }
    } catch (error) {
      console.error('獲取用戶資料錯誤:', error);
    }
    
    // 返回默認用戶數據
    console.log('=== 返回默认用户数据 ===');
    const defaultStats: UserStats = {
      records: 0,
      followers: 0,
      following: 0
    };
    
    const defaultUserData: UserData = {
      id: userId || 'default_user_id', // 添加默认用户ID
      name: 'User',
      username: '@user',
      bio: 'Music lover',
      avatar: '',
      joinDate: 'Joined ' + new Date().toLocaleDateString(),
      stats: defaultStats
    };
    
    console.log('默认用户数据:', defaultUserData);
    return defaultUserData;
  }
  
  // 模擬註冊（用於測試）
  private mockRegister(request: RegisterRequest): AuthResponse {
    console.log('使用模擬註冊數據');
    
    const userStats: UserStats = {
      records: 0,
      followers: 0,
      following: 0
    };
    
    const userData: UserData = {
      id: `mock_${request.username}_${Date.now()}`, // 添加模拟用户ID
      name: request.username,
      username: `@${request.username}`,
      bio: 'Music lover • New member',
      avatar: '',
      joinDate: 'Joined ' + new Date().toLocaleDateString(),
      stats: userStats
    };
    
    return {
      success: true,
      message: '註冊成功（模擬數據）',
      user: userData
    };
  }
  
  // 模擬登錄（用於測試）
  private async mockLogin(request: LoginRequest): Promise<AuthResponse> {
    console.log('使用模擬登錄數據');
    
    // 簡單的模擬驗證
    if (request.email && request.password) {
      const username = request.email.split('@')[0] || 'user';
      const userStats: UserStats = {
        records: 5,
        followers: 10,
        following: 8
      };
      
      const userData: UserData = {
        id: `mock_${username}_${Date.now()}`, // 添加模拟用户ID
        name: username.charAt(0).toUpperCase() + username.slice(1), // 首字母大写
        username: `@${username}`,
        bio: 'Music lover • Demo user',
        avatar: '',
        joinDate: 'Joined ' + new Date().toLocaleDateString(),
        stats: userStats
      };
      
      // 保存模拟用户会话信息到本地存储
      const session: StoredUserSession = {
        userData,
        accessToken: 'mock_access_token_' + Date.now(),
        refreshToken: 'mock_refresh_token_' + Date.now(),
        expiresAt: Date.now() + (24 * 60 * 60 * 1000), // 24小时后过期
        isLoggedIn: true
      };
      
      const saveResult = await this.storageManager.saveUserSession(session);
      if (saveResult) {
        console.log('模拟用户会话信息保存成功');
      } else {
        console.error('模拟用户会话信息保存失败');
      }
      
      return {
        success: true,
        message: '登錄成功（模擬數據）',
        user: userData
      };
    }
    
    return {
      success: false,
      message: '請填寫完整的登錄信息'
    };
  }
  
  // 登出
  public async logout(): Promise<boolean> {
    try {
      // 清除本地存储的用户会话信息
      const clearResult = await this.storageManager.clearUserSession();
      if (clearResult) {
        console.log('用户会话信息清除成功');
        return true;
      } else {
        console.error('用户会话信息清除失败');
        return false;
      }
    } catch (error) {
      console.error('登出錯誤:', error);
      return false;
    }
  }
}
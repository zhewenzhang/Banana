// 用戶認證服務
import { SupabaseConfig } from '../common/SupabaseConfig';
import { UserData, UserStats } from '../common/UserTypes';
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
  username?: string;
  display_name?: string;
  bio?: string;
  avatar_url?: string;
  records_count?: number;
  followers_count?: number;
  following_count?: number;
  created_at?: string;
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
  
  // 單例模式
  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
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
        
        // 獲取用戶資料
        const userData = await this.getUserProfile(responseData.user?.id || '', responseData.access_token || '');
        
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
        return this.mockLogin(request);
      }
      
      return {
        success: false,
        message: '網絡錯誤，請檢查網絡連接'
      };
    }
  }
  
  // 獲取用戶資料
  private async getUserProfile(userId: string, accessToken: string): Promise<UserData> {
    try {
      const httpRequest = http.createHttp();
      const baseHeaders = SupabaseConfig.getHeaders();
      const headers: HttpHeaders = {
        'Content-Type': baseHeaders['Content-Type'] ?? 'application/json',
        'apikey': baseHeaders['apikey'] ?? '',
        'Authorization': `Bearer ${accessToken}`
      };
      
      const response = await httpRequest.request(
        `${SupabaseConfig.getRestUrl()}/profiles?id=eq.${userId}`,
        {
          method: http.RequestMethod.GET,
          header: headers
        }
      );
      
      if (response.responseCode === 200) {
        const profiles: SupabaseProfile[] = JSON.parse(response.result as string);
        if (profiles && profiles.length > 0) {
          const profile = profiles[0];
          const userStats: UserStats = {
            records: profile.records_count || 0,
            followers: profile.followers_count || 0,
            following: profile.following_count || 0
          };
          
          return {
            name: profile.display_name || profile.username || 'User',
            username: `@${profile.username || 'user'}`,
            bio: profile.bio || 'Music lover',
            avatar: profile.avatar_url || '',
            joinDate: 'Joined ' + new Date(profile.created_at || '').toLocaleDateString(),
            stats: userStats
          };
        }
      }
    } catch (error) {
      console.error('獲取用戶資料錯誤:', error);
    }
    
    // 返回默認用戶數據
    const defaultStats: UserStats = {
      records: 0,
      followers: 0,
      following: 0
    };
    
    return {
      name: 'User',
      username: '@user',
      bio: 'Music lover',
      avatar: '',
      joinDate: 'Joined ' + new Date().toLocaleDateString(),
      stats: defaultStats
    };
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
  private mockLogin(request: LoginRequest): AuthResponse {
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
        name: username,
        username: `@${username}`,
        bio: 'Music lover',
        avatar: '',
        joinDate: 'Joined ' + new Date().toLocaleDateString(),
        stats: userStats
      };
      
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
      // 清除本地存儲的用戶信息
      // 這裡可以添加清除 token 的邏輯
      return true;
    } catch (error) {
      console.error('登出錯誤:', error);
      return false;
    }
  }
}
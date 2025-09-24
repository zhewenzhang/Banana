// Supabase 配置管理
export class SupabaseConfig {
  // Supabase 項目配置
  private static SUPABASE_URL: string = 'https://uwvlduprxppwdkjkvwby.supabase.co';
  private static SUPABASE_ANON_KEY: string = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dmxkdXByeHBwd2Rramt2d2J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5NDYxMTMsImV4cCI6MjA2NTUyMjExM30.IT_7wL-0Buf1iyGKI1cw2PY0GtlKFljFiNOVYBvA_o0';
  
  // 設置配置
  public static setConfig(url: string, anonKey: string): void {
    SupabaseConfig.SUPABASE_URL = url;
    SupabaseConfig.SUPABASE_ANON_KEY = anonKey;
  }
  
  // 獲取 Supabase URL
  public static getUrl(): string {
    return SupabaseConfig.SUPABASE_URL;
  }
  
  // 獲取匿名密鑰
  public static getAnonKey(): string {
    return SupabaseConfig.SUPABASE_ANON_KEY;
  }
  
  // 獲取認證 API URL
  public static getAuthUrl(): string {
    return `${SupabaseConfig.SUPABASE_URL}/auth/v1`;
  }
  
  // 獲取 REST API URL
  public static getRestUrl(): string {
    return `${SupabaseConfig.SUPABASE_URL}/rest/v1`;
  }
  
  // 檢查配置是否完整
  public static isConfigured(): boolean {
    const url = SupabaseConfig.SUPABASE_URL;
    const key = SupabaseConfig.SUPABASE_ANON_KEY;
    
    return url !== null && url !== undefined && url.length > 0 &&
           key !== null && key !== undefined && key.length > 0;
  }
  
  // 獲取 HTTP 請求頭
  public static getHeaders(): Record<string, string> {
    const url = SupabaseConfig.SUPABASE_URL || '';
    const key = SupabaseConfig.SUPABASE_ANON_KEY || '';
    
    return {
      'Content-Type': 'application/json',
      'apikey': key,
      'Authorization': `Bearer ${key}`
    };
  }
}
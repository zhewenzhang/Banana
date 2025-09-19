// API配置管理
export class ApiConfig {
  // Discogs API配置
  public static readonly DISCOGS_API_URL = 'https://api.discogs.com';
  public static readonly USER_AGENT = 'BananaRecordApp/1.0';
  
  // API密钥配置 - 用户需要在这里填入自己的API密钥
  // 获取方式：访问 https://www.discogs.com/settings/developers 创建应用并获取token
  private static DISCOGS_TOKEN = 'NavEcjohrJttDkWwMzWNKEIRmyLsecfRSSWoCIVA'; // 在这里填入你的Discogs API Token
  
  // 获取Discogs API Token
  public static getDiscogsToken(): string {
    return ApiConfig.DISCOGS_TOKEN;
  }
  
  // 设置Discogs API Token
  public static setDiscogsToken(token: string): void {
    ApiConfig.DISCOGS_TOKEN = token;
  }
  
  // 检查是否已配置API Token
  public static hasDiscogsToken(): boolean {
    return ApiConfig.DISCOGS_TOKEN !== '' && ApiConfig.DISCOGS_TOKEN.trim().length > 0;
  }
  
  // 构建带认证的请求头
  public static getDiscogsHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'User-Agent': ApiConfig.USER_AGENT,
      'Accept': 'application/json'
    };
    
    if (ApiConfig.hasDiscogsToken()) {
      headers['Authorization'] = `Discogs token=${ApiConfig.DISCOGS_TOKEN}`;
    }
    
    return headers;
  }
  
  // 构建搜索URL
  public static buildSearchUrl(query: string, type: string = 'release', perPage: number = 20): string {
    const baseUrl = `${ApiConfig.DISCOGS_API_URL}/database/search`;
    // 手动构建查询参数，避免使用URLSearchParams
    const params: string[] = [];
    params.push(`q=${encodeURIComponent(query)}`);
    params.push(`type=${encodeURIComponent(type)}`);
    params.push(`per_page=${perPage.toString()}`);
    
    return `${baseUrl}?${params.join('&')}`;
  }
}
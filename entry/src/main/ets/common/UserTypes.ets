// 用戶數據類型定義

export interface UserStats {
  records: number;
  followers: number;
  following: number;
}

export interface UserData {
  id: string; // 用戶ID - 必需字段
  name: string;
  username: string;
  bio: string;
  avatar: string;
  joinDate: string;
  stats: UserStats;
  accessToken?: string; // 訪問令牌
}

export interface LoginModalProps {
  isVisible: boolean;
  onClose?: () => void;
  onLoginSuccess?: (userData: UserData) => void;
}

// 收藏唱片的数据类型定义
export interface FavoriteRecord {
  id?: string; // 收藏记录的唯一ID（数据库生成）
  userId: string; // 用户ID
  recordId: number; // 唱片ID（来自Discogs API）
  recordTitle: string; // 唱片标题
  recordArtist: string; // 艺术家名称
  recordImage?: string; // 唱片封面图片URL
  recordYear?: string; // 发行年份
  recordGenres?: string[]; // 音乐风格
  recordFormats?: string[]; // 唱片格式
  favoriteTime: string; // 收藏时间（ISO字符串）
  createdAt?: string; // 数据库创建时间
  updatedAt?: string; // 数据库更新时间
}

// 收藏记录数据接口
export interface FavoriteRecordData {
  title: string;
  artist: string;
  image?: string;
  year?: string;
  genres?: string[];
  formats?: string[];
}

// 创建收藏记录的接口（不包含数据库生成的字段）
export interface CreateFavoriteRecord {
  userId: string; // 用户ID
  recordId: number; // 唱片ID（来自Discogs API）
  recordTitle: string; // 唱片标题
  recordArtist: string; // 艺术家名称
  recordImage?: string; // 唱片封面图片URL
  recordYear?: string; // 发行年份
  recordGenres?: string[]; // 音乐风格
  recordFormats?: string[]; // 唱片格式
  favoriteTime: string; // 收藏时间（ISO字符串）
}

// HTTP请求头接口
export interface HttpHeaders {
  'Content-Type'?: string;
  'apikey'?: string;
  'Authorization'?: string;
  'Prefer'?: string;
}

// 收藏操作的请求接口
export interface FavoriteRequest {
  userId: string;
  recordId: number;
  recordData: FavoriteRecordData;
}

// 收藏操作的响应接口
export interface FavoriteResponse {
  success: boolean;
  message: string;
  data?: FavoriteRecord;
}

// 检查收藏状态的响应接口
export interface FavoriteStatusResponse {
  isFavorite: boolean;
  favoriteRecord?: FavoriteRecord;
}
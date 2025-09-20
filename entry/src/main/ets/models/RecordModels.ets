// 唱片相關數據模型

// Discogs API 響應接口
export interface DiscogsResponse {
  pagination?: PaginationInfo;
  results?: RecordItem[];
}

// 分頁信息接口
export interface PaginationInfo {
  page?: number;
  pages?: number;
  per_page?: number;
  items?: number;
  urls?: UrlsInfo;
}

// 唱片項目接口
export interface RecordItem {
  id?: number;
  title?: string;
  year?: number;
  format?: string[];
  label?: string[];
  genre?: string[];
  style?: string[];
  country?: string;
  released?: string;
  thumb?: string;
  cover_image?: string;
  resource_url?: string;
  uri?: string;
  master_id?: number;
  master_url?: string;
  type?: string;
  user_data?: UserData;
  basic_information?: BasicInformation;
  // 添加缺少的屬性以匹配BasicInformation
  artists?: ArtistInfo[];
  genres?: string[];
  labels?: LabelInfo[];
}

// 基本信息接口
export interface BasicInformation {
  id?: number;
  master_id?: number;
  master_url?: string;
  resource_url?: string;
  thumb?: string;
  cover_image?: string;
  title?: string;
  year?: number;
  formats?: FormatInfo[];
  labels?: LabelInfo[];
  artists?: ArtistInfo[];
  genres?: string[];
  styles?: string[];
}

// 格式信息接口
export interface FormatInfo {
  name?: string;
  qty?: string;
  descriptions?: string[];
}

// 標籤信息接口
export interface LabelInfo {
  name?: string;
  catno?: string;
  entity_type?: string;
  entity_type_name?: string;
  id?: number;
  resource_url?: string;
}

// 藝術家信息接口
export interface ArtistInfo {
  name?: string;
  anv?: string;
  join?: string;
  role?: string;
  tracks?: string;
  id?: number;
  resource_url?: string;
}

// 本地唱片數據接口（用於UI顯示）
export interface LocalRecord {
  id: string;
  title: string;
  artist: string;
  year: string;
  coverImage: string;
  genre: string;
  label: string;
}

// URLs信息接口
export interface UrlsInfo {
  last?: string;
  next?: string;
}

// 用戶數據接口
export interface UserData {
  in_wantlist?: boolean;
  in_collection?: boolean;
}

// 唱片瀑布流項目接口
export interface WaterfallItem {
  record: LocalRecord;
  height: number; // 用於瀑布流布局的高度
}
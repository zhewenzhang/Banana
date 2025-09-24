import http from '@ohos.net.http';

// 定义API响应接口
export interface ApiRecordItem {
  id: string;
  title: string;
  artist: string;
  image: string;
  year?: number;
  genres?: string[];
  formats?: string[];
  playcount?: number;
  listeners?: number;
  url?: string;
}

export interface ApiArtistItem {
  id: string;
  name: string;
  image: string;
  playcount?: number;
  listeners?: number;
  bio?: string;
  url?: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T[];
  error?: string;
}

// Last.fm API响应接口
interface LastFmResponse {
  success?: boolean;
  data?: Record<string, ESObject>;
  error?: string;
}

interface LastFmRequestParams {
  method: string;
  api_key: string;
  format: string;
  artist?: string;
  album?: string;
  track?: string;
  limit?: string;
  page?: string;
}

// Discogs API接口定义
interface DiscogsSearchResponse {
  results?: DiscogsSearchResult[];
  pagination?: DiscogsPagination;
}

interface DiscogsSearchResult {
  id?: number;
  title?: string;
  year?: number;
  format?: string[];
  label?: string[];
  genre?: string[];
  style?: string[];
  thumb?: string;
  cover_image?: string;
  resource_url?: string;
  master_id?: number;
  master_url?: string;
  uri?: string;
  catno?: string;
  barcode?: string[];
  community?: DiscogsCommunity;
}

interface DiscogsCommunity {
  want?: number;
  have?: number;
}

interface DiscogsPagination {
  page?: number;
  pages?: number;
  per_page?: number;
  items?: number;
  urls?: DiscogsUrls;
}

interface DiscogsUrls {
  next?: string;
  prev?: string;
  first?: string;
  last?: string;
}

interface DiscogsRequestParams {
  q?: string;
  type?: string;
  title?: string;
  release_title?: string;
  credit?: string;
  artist?: string;
  anv?: string;
  label?: string;
  genre?: string;
  style?: string;
  country?: string;
  year?: string;
  format?: string;
  catno?: string;
  barcode?: string;
  track?: string;
  submitter?: string;
  contributor?: string;
  page?: string;
  per_page?: string;
  sort?: string;
  sort_order?: string;
}

export class MusicApiService {
  // Last.fm API配置
  private readonly LASTFM_API_KEY: string = 'demo_key'; // 使用demo key進行測試，實際部署時需要替換為真實的API Key
  private readonly LASTFM_BASE_URL: string = 'https://ws.audioscrobbler.com/2.0/';
  
  // Discogs API配置
  private readonly DISCOGS_BASE_URL: string = 'https://api.discogs.com';
  private readonly DISCOGS_USER_AGENT: string = 'BananaApp/1.0 +https://banana.app';
  
  // 备用数据，当API不可用时使用 - 使用可靠的图片源
  private readonly FALLBACK_RECORDS: ApiRecordItem[] = [
    {
      id: '249504',
      title: 'After Hours',
      artist: 'The Weeknd',
      image: 'https://i.discogs.com/r300-/release/15043464-the-weeknd-after-hours.jpg',
      year: 2020,
      genres: ['Pop', 'Synthwave'],
      playcount: 120000000
    },
    {
      id: '9823525',
      title: '÷ (Divide)',
      artist: 'Ed Sheeran',
      image: 'https://i.discogs.com/r300-/release/9823525-ed-sheeran-divide.jpg',
      year: 2017,
      genres: ['Pop', 'Folk'],
      playcount: 95000000
    },
    {
      id: '4262072',
      title: 'A Night At The Opera',
      artist: 'Queen',
      image: 'https://i.discogs.com/r300-/release/4262072-queen-a-night-at-the-opera.jpg',
      year: 1975,
      genres: ['Rock', 'Progressive Rock'],
      playcount: 85000000
    },
    {
      id: '1218307',
      title: 'Hotel California',
      artist: 'Eagles',
      image: 'https://i.discogs.com/r300-/release/1218307-eagles-hotel-california.jpg',
      year: 1976,
      genres: ['Rock', 'Pop Rock'],
      playcount: 80000000
    },
    {
      id: '24755573',
      title: 'Midnights',
      artist: 'Taylor Swift',
      image: 'https://i.discogs.com/r300-/release/24755573-taylor-swift-midnights.jpg',
      year: 2022,
      genres: ['Pop', 'Alternative'],
      playcount: 150000000
    },
    {
      id: '19456789',
      title: 'Happier Than Ever',
      artist: 'Billie Eilish',
      image: 'https://i.discogs.com/r300-/release/19456789-billie-eilish-happier-than-ever.jpg',
      year: 2021,
      genres: ['Alternative', 'Pop'],
      playcount: 90000000
    }
  ];

  private readonly FALLBACK_ARTISTS: ApiArtistItem[] = [
    {
      id: '1',
      name: 'Kendrick Lamar',
      image: 'https://i.scdn.co/image/ab6761610000e5eb437b9e2a82505b3d93ff1022',
      listeners: 5000000,
      bio: 'American rapper and songwriter'
    },
    {
      id: '2',
      name: 'The Beatles',
      image: 'https://i.scdn.co/image/ab6761610000e5ebe9348cc01ff5d55971b22433',
      listeners: 8000000,
      bio: 'Legendary British rock band'
    },
    {
      id: '3',
      name: 'Pink Floyd',
      image: 'https://i.scdn.co/image/ab6761610000e5eb7e2f8c1589ed6c0b0b5e2e8a',
      listeners: 6000000,
      bio: 'Progressive rock pioneers'
    },
    {
      id: '4',
      name: 'Daft Punk',
      image: 'https://i.scdn.co/image/ab6761610000e5eb0d54a654c4a2d3b3b3b3b3b3',
      listeners: 4000000,
      bio: 'French electronic music duo'
    },
    {
      id: '5',
      name: 'The Strokes',
      image: 'https://i.scdn.co/image/ab6761610000e5eb46b2d7b2b2b2b2b2b2b2b2b2',
      listeners: 3000000,
      bio: 'American indie rock band'
    }
  ];

  /**
   * 获取热门唱片
   */
  async getTrendingRecords(): Promise<ApiResponse<ApiRecordItem>> {
    try {
      // 优先尝试从Discogs API获取真实数据
      const discogsResponse = await this.getDiscogsTrendingRecords();
      if (discogsResponse?.success && discogsResponse.data && discogsResponse.data.length > 0) {
        return discogsResponse;
      }
      
      // 如果Discogs失败，尝试从Last.fm API获取数据
      const params: LastFmRequestParams = {
        method: 'chart.gettoptracks',
        api_key: this.LASTFM_API_KEY,
        format: 'json',
        limit: '10'
      };
      const response: LastFmResponse = await this.fetchFromLastFm(params);
      
      if (response?.success && response.data) {
        const records: ApiRecordItem[] = this.parseTracksResponse(response.data);
        const result: ApiResponse<ApiRecordItem> = {
          success: true,
          data: records
        };
        return result;
      }
    } catch (error) {
      console.error('获取热门唱片失败:', error);
    }

    // 返回备用数据
    const fallbackResult: ApiResponse<ApiRecordItem> = {
      success: true,
      data: this.FALLBACK_RECORDS
    };
    return fallbackResult;
  }

  /**
   * 获取热门艺术家
   */
  async getPopularArtists(): Promise<ApiResponse<ApiArtistItem>> {
    try {
      // 尝试从Last.fm API获取数据
      const params: LastFmRequestParams = {
        method: 'chart.gettopartists',
        api_key: this.LASTFM_API_KEY,
        format: 'json',
        limit: '10'
      };
      const response: LastFmResponse = await this.fetchFromLastFm(params);
      
      if (response?.success && response.data) {
        const artists: ApiArtistItem[] = this.parseArtistsResponse(response.data);
        const result: ApiResponse<ApiArtistItem> = {
          success: true,
          data: artists
        };
        return result;
      }
    } catch (error) {
      console.error('获取热门艺术家失败:', error);
    }

    // 返回备用数据
    const fallbackResult: ApiResponse<ApiArtistItem> = {
      success: true,
      data: this.FALLBACK_ARTISTS
    };
    return fallbackResult;
  }

  /**
   * 根据艺术家ID获取其唱片
   */
  async getArtistAlbums(artistName: string): Promise<ApiResponse<ApiRecordItem>> {
    try {
      const params: LastFmRequestParams = {
        method: 'artist.gettopalbums',
        api_key: this.LASTFM_API_KEY,
        format: 'json',
        artist: artistName,
        limit: '20'
      };
      const response: LastFmResponse = await this.fetchFromLastFm(params);
      
      if (response?.success && response.data) {
        const albums: ApiRecordItem[] = this.parseAlbumsResponse(response.data, artistName);
        const result: ApiResponse<ApiRecordItem> = {
          success: true,
          data: albums
        };
        return result;
      }
    } catch (error) {
      console.error('获取艺术家唱片失败:', error);
    }

    // 返回空数据
    const emptyResult: ApiResponse<ApiRecordItem> = {
      success: false,
      data: [],
      error: '无法获取艺术家唱片'
    };
    return emptyResult;
  }

  /**
   * 获取唱片详情
   */
  async getRecordDetails(artist: string, album: string): Promise<ApiRecordItem | null> {
    try {
      const params: LastFmRequestParams = {
        method: 'album.getinfo',
        api_key: this.LASTFM_API_KEY,
        format: 'json',
        artist: artist,
        album: album
      };
      const response: LastFmResponse = await this.fetchFromLastFm(params);
      
      if (response?.success && response.data) {
        return this.parseAlbumDetailsResponse(response.data);
      }
    } catch (error) {
      console.error('获取唱片详情失败:', error);
    }

    return null;
  }

  /**
   * 从Last.fm API获取数据
   */
  /**
   * 从Discogs API获取数据
   */
  private async fetchFromDiscogs(endpoint: string, params?: DiscogsRequestParams): Promise<DiscogsSearchResponse | null> {
    const httpRequest = http.createHttp();
    
    try {
      // 构建查询参数
      const queryParams: string[] = [];
      if (params) {
        Object.keys(params).forEach((key: string) => {
          const value = (params as Record<string, string>)[key];
          if (value) {
            queryParams.push(`${key}=${encodeURIComponent(value)}`);
          }
        });
      }
      
      // 构建完整的URL
      const fullUrl: string = queryParams.length > 0 
        ? `${this.DISCOGS_BASE_URL}${endpoint}?${queryParams.join('&')}`
        : `${this.DISCOGS_BASE_URL}${endpoint}`;

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json',
          'User-Agent': this.DISCOGS_USER_AGENT
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data: DiscogsSearchResponse = JSON.parse(response.result as string) as DiscogsSearchResponse;
        return data;
      }
    } catch (error) {
      console.error('Discogs API请求失败:', error);
    } finally {
      httpRequest.destroy();
    }

    return null;
  }

  /**
   * 获取Discogs热门发布（基于社区数据）
   */
  async getDiscogsTrendingRecords(): Promise<ApiResponse<ApiRecordItem>> {
    try {
      // 获取当前年份的热门发布，按社区需求量排序
      const currentYear = new Date().getFullYear();
      const params: DiscogsRequestParams = {
        type: 'release',
        year: currentYear.toString(),
        per_page: '50',
        page: '1'
      };
      
      const response: DiscogsSearchResponse | null = await this.fetchFromDiscogs('/database/search', params);
      
      if (response?.results && response.results.length > 0) {
        // 按社区需求量排序（want + have）
        const sortedResults = response.results
          .filter((item: DiscogsSearchResult) => item.community?.want || item.community?.have)
          .sort((a: DiscogsSearchResult, b: DiscogsSearchResult) => {
            const aScore = (a.community?.want || 0) + (a.community?.have || 0);
            const bScore = (b.community?.want || 0) + (b.community?.have || 0);
            return bScore - aScore;
          })
          .slice(0, 20); // 取前20个

        const records: ApiRecordItem[] = sortedResults.map((item: DiscogsSearchResult, index: number): ApiRecordItem => {
          const recordItem: ApiRecordItem = {
            id: item.id?.toString() || `discogs_${index}`,
            title: item.title || '未知专辑',
            artist: this.extractArtistFromTitle(item.title || ''),
            image: item.cover_image || item.thumb || '',
            year: item.year ? Number(item.year) : undefined
          };
          return recordItem;
        });

        const result: ApiResponse<ApiRecordItem> = {
          success: true,
          data: records
        };
        return result;
      }
    } catch (error) {
      console.error('获取Discogs热门发布失败:', error);
    }

    // 返回备用数据
    const fallbackResult: ApiResponse<ApiRecordItem> = {
      success: true,
      data: this.FALLBACK_RECORDS
    };
    return fallbackResult;
  }

  /**
   * 从标题中提取艺术家名称
   */
  private extractArtistFromTitle(title: string): string {
    // Discogs的标题格式通常是 "Artist - Album"
    const parts = title.split(' - ');
    return parts.length > 1 ? parts[0].trim() : '未知艺术家';
  }

  private async fetchFromLastFm(params: LastFmRequestParams): Promise<LastFmResponse> {
    const httpRequest = http.createHttp();
    
    try {
      // 構建查詢參數
      const queryParams: string[] = [];
      queryParams.push(`method=${encodeURIComponent(params.method)}`);
      queryParams.push(`api_key=${encodeURIComponent(params.api_key)}`);
      queryParams.push(`format=${encodeURIComponent(params.format)}`);
      
      // 添加其他参数
      if (params.artist) queryParams.push(`artist=${encodeURIComponent(params.artist)}`);
      if (params.album) queryParams.push(`album=${encodeURIComponent(params.album)}`);
      if (params.track) queryParams.push(`track=${encodeURIComponent(params.track)}`);
      if (params.limit) queryParams.push(`limit=${encodeURIComponent(params.limit)}`);
      if (params.page) queryParams.push(`page=${encodeURIComponent(params.page)}`);

      // 構建完整的 URL
      const fullUrl: string = `${this.LASTFM_BASE_URL}?${queryParams.join('&')}`;

      const response = await httpRequest.request(fullUrl, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data: Record<string, ESObject> = JSON.parse(response.result as string) as Record<string, ESObject>;
        const result: LastFmResponse = {
          success: true,
          data: data
        };
        return result;
      }
    } catch (error) {
      console.error('API请求失败:', error);
    } finally {
      httpRequest.destroy();
    }

    const failureResult: LastFmResponse = { success: false };
    return failureResult;
  }

  /**
   * 解析tracks响应数据
   */
  private parseTracksResponse(data: Record<string, ESObject>): ApiRecordItem[] {
    const tracks: ESObject[] = (data?.tracks?.track as ESObject[]) || [];
    return tracks.slice(0, 5).map((track: ESObject, index: number) => {
      // 生成一个基于内容的伪随机数字ID，确保与Discogs API兼容
      const generateNumericId = (trackName: string, artistName: string, index: number): string => {
        const combined = `${trackName}_${artistName}_${index}`;
        let hash = 0;
        for (let i = 0; i < combined.length; i++) {
          const char = combined.charCodeAt(i);
          hash = ((hash << 5) - hash) + char;
          hash = hash & hash; // 转换为32位整数
        }
        // 确保是正数并转换为字符串
        return Math.abs(hash).toString();
      };

      const trackName = (track.name as string) || '未知专辑';
      const artistName = ((track.artist as ESObject)?.name as string) || '未知艺术家';
      
      const trackResult: ApiRecordItem = {
        id: (track.mbid as string) || generateNumericId(trackName, artistName, index),
        title: trackName,
        artist: artistName,
        image: this.extractImageUrl(track.image as ESObject[]) || this.getPlaceholderImage(index),
        playcount: parseInt((track.playcount as string) || '0') || 0,
        listeners: parseInt((track.listeners as string) || '0') || 0,
        url: (track.url as string) || undefined
      };
      return trackResult;
    });
  }

  /**
   * 解析artists响应数据
   */
  private parseArtistsResponse(data: Record<string, ESObject>): ApiArtistItem[] {
    const artists: ESObject[] = (data?.artists?.artist as ESObject[]) || [];
    return artists.slice(0, 5).map((artist: ESObject, index: number) => {
      const artistResult: ApiArtistItem = {
        id: (artist.mbid as string) || `artist_${index}`,
        name: (artist.name as string) || '未知艺术家',
        image: this.extractImageUrl(artist.image as ESObject[]) || this.getPlaceholderImage(index),
        playcount: parseInt((artist.playcount as string) || '0') || 0,
        listeners: parseInt((artist.listeners as string) || '0') || 0,
        url: (artist.url as string) || undefined
      };
      return artistResult;
    });
  }

  /**
   * 解析albums响应数据
   */
  private parseAlbumsResponse(data: Record<string, ESObject>, artistName: string): ApiRecordItem[] {
    const albums: ESObject[] = (data?.topalbums?.album as ESObject[]) || [];
    return albums.map((album: ESObject, index: number) => {
      const albumResult: ApiRecordItem = {
        id: (album.mbid as string) || `album_${index}`,
        title: (album.name as string) || '未知专辑',
        artist: artistName,
        image: this.extractImageUrl(album.image as ESObject[]) || this.getPlaceholderImage(index),
        playcount: parseInt((album.playcount as string) || '0') || 0,
        url: (album.url as string) || undefined
      };
      return albumResult;
    });
  }

  /**
   * 解析专辑详情响应数据
   */
  private parseAlbumDetailsResponse(data: Record<string, ESObject>): ApiRecordItem {
    const album: ESObject | undefined = data?.album;
    const albumResult: ApiRecordItem = {
      id: (album?.mbid as string) || 'unknown',
      title: (album?.name as string) || '未知专辑',
      artist: (album?.artist as string) || '未知艺术家',
      image: this.extractImageUrl(album?.image as ESObject[]) || '',
      year: album?.wiki?.published ? new Date(album.wiki.published as string).getFullYear() : undefined,
      playcount: parseInt((album?.playcount as string) || '0') || 0,
      listeners: parseInt((album?.listeners as string) || '0') || 0,
      url: (album?.url as string) || undefined
    };
    return albumResult;
  }

  /**
   * 提取图片URL
   */
  private extractImageUrl(images: ESObject[] | undefined): string {
    if (!images || !Array.isArray(images)) return '';
    
    // 优先选择大尺寸图片
    const largeImage: ESObject | undefined = images.find((img: ESObject): boolean => 
      img.size === 'extralarge' || img.size === 'large'
    );
    if (largeImage?.['#text']) {
      const imageUrl = largeImage['#text'] as string;
      // 过滤掉Last.fm的占位符图片
      if (imageUrl && !imageUrl.includes('2a96cbd8b46e442fc41c2b86b821562f')) {
        return imageUrl;
      }
    }
    
    // 备选任意尺寸图片，但排除占位符
    const fallbackImage: ESObject | undefined = images.find((img: ESObject): boolean => {
      const url = img['#text'] as string;
      return Boolean(url) && !url.includes('2a96cbd8b46e442fc41c2b86b821562f');
    });
    return (fallbackImage?.['#text'] as string) || '';
  }

  /**
   * 获取占位符图片（渐变色）
   */
  private getPlaceholderImage(index: number): string {
    // 返回空字符串，让UI组件使用渐变色占位符
    return '';
  }

  /**
   * 检查图片URL是否有效
   */
  static isValidImageUrl(url: string): boolean {
    return !!(url && url.trim() !== '' && (url.startsWith('http') || url.startsWith('https')));
  }
}
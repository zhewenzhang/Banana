import http from '@ohos.net.http';
import { DiscogsResponse, RecordItem, LocalRecord, ArtistInfo, LabelInfo } from '../models/RecordModels';
import { ApiConfig } from '../common/ApiConfig';

// Discogs API 服務類
export class DiscogsService {
  private static readonly BASE_URL = 'https://api.discogs.com';
  private static readonly USER_AGENT = 'BananaRecordApp/1.0';
  
  // 獲取熱門唱片數據
  public static async getPopularRecords(page: number = 1, perPage: number = 50): Promise<LocalRecord[]> {
    try {
      const url = `${DiscogsService.BASE_URL}/database/search?type=release&sort=have&sort_order=desc&page=${page}&per_page=${perPage}`;
      
      const httpRequest = http.createHttp();
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: ApiConfig.getDiscogsHeaders(), // 使用ApiConfig提供的认证头
        connectTimeout: 10000,
        readTimeout: 10000
      });
      
      if (response.responseCode === 200) {
        const data: DiscogsResponse = JSON.parse(response.result as string);
        console.log('API响应数据:', JSON.stringify(data, null, 2)); // 添加调试日志
        return DiscogsService.transformToLocalRecords(data.results || []);
      } else {
        console.error('Discogs API 請求失敗:', response.responseCode);
        return DiscogsService.getMockData();
      }
    } catch (error) {
      console.error('獲取 Discogs 數據時發生錯誤:', error);
      return DiscogsService.getMockData();
    }
  }

  // 獲取高價值唱片數據（用於價值排行榜）
  public static async getValueRankingRecords(page: number = 1, perPage: number = 50): Promise<LocalRecord[]> {
    try {
      // 使用多個搜索策略來獲取高價值唱片，增加搜索范围以获取更多数据
      const searchQueries = [
        // 搜索經典高價值唱片 - 1960年代摇滚
        `${DiscogsService.BASE_URL}/database/search?type=release&genre=Rock&decade=1960&sort=have&sort_order=desc&page=${page}&per_page=${Math.ceil(perPage/5)}`,
        // 搜索限量版唱片
        `${DiscogsService.BASE_URL}/database/search?type=release&format=Vinyl&sort=want&sort_order=desc&page=${page}&per_page=${Math.ceil(perPage/5)}`,
        // 搜索收藏家喜愛的唱片
        `${DiscogsService.BASE_URL}/database/search?type=release&sort=rating&sort_order=desc&page=${page}&per_page=${Math.ceil(perPage/5)}`,
        // 搜索1970年代经典专辑
        `${DiscogsService.BASE_URL}/database/search?type=release&genre=Rock&decade=1970&sort=have&sort_order=desc&page=${page}&per_page=${Math.ceil(perPage/5)}`,
        // 搜索爵士经典专辑
        `${DiscogsService.BASE_URL}/database/search?type=release&genre=Jazz&sort=want&sort_order=desc&page=${page}&per_page=${Math.ceil(perPage/5)}`
      ];

      const httpRequest = http.createHttp();
      const allRecords: LocalRecord[] = [];

      for (const url of searchQueries) {
        try {
          const response = await httpRequest.request(url, {
            method: http.RequestMethod.GET,
            header: ApiConfig.getDiscogsHeaders(),
            connectTimeout: 10000,
            readTimeout: 10000
          });

          if (response.responseCode === 200) {
            const data: DiscogsResponse = JSON.parse(response.result as string);
            const records = DiscogsService.transformToLocalRecords(data.results || []);
            allRecords.push(...records);
          }
        } catch (queryError) {
          console.error('單個查詢失敗:', queryError);
        }
      }

      // 如果獲取到數據，返回去重後的結果
      if (allRecords.length > 0) {
        const uniqueRecords = DiscogsService.removeDuplicateRecords(allRecords);
        return uniqueRecords.slice(0, perPage);
      } else {
        console.warn('所有API查詢都失敗，使用模擬高價值數據');
        return DiscogsService.getMockValueRankingData();
      }
    } catch (error) {
      console.error('獲取高價值唱片數據時發生錯誤:', error);
      return DiscogsService.getMockValueRankingData();
    }
  }

  // 去除重複唱片
  private static removeDuplicateRecords(records: LocalRecord[]): LocalRecord[] {
    const seen = new Set<string>();
    return records.filter(record => {
      const key = `${record.title}-${record.artist}`;
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return true;
    });
  }
  
  // 將 Discogs API 數據轉換為本地數據格式
  private static transformToLocalRecords(items: RecordItem[]): LocalRecord[] {
    return items.map((item, index) => {
      const basicInfo = item.basic_information || item;
      
      // 提取封面图片URL，优先使用高质量图片
      const coverImage = basicInfo.cover_image || basicInfo.thumb || item.cover_image || item.thumb || 'https://via.placeholder.com/300x300/2a2a3e/ffffff?text=No+Cover';
      
      const localRecord: LocalRecord = {
        id: (basicInfo.id || index).toString(),
        title: basicInfo.title || item.title || '未知專輯',
        artist: DiscogsService.extractArtistName(basicInfo.artists || []),
        year: (basicInfo.year || item.year || 0).toString(),
        coverImage: coverImage,
        genre: (basicInfo.genres || item.genre || []).join(', ') || '未知類型',
        label: DiscogsService.extractLabelName(basicInfo.labels || [])
      };
      
      // 添加调试日志，检查封面图片URL
      console.log(`唱片 ${localRecord.title} 的封面URL: ${localRecord.coverImage}`);
      
      return localRecord;
    }).filter(record => record.id && record.title); // 只过滤掉没有基本信息的唱片
  }
  
  // 提取藝術家名稱
  private static extractArtistName(artists: ArtistInfo[]): string {
    if (!artists || artists.length === 0) {
      return '未知藝術家';
    }
    
    return artists.map((artist: ArtistInfo): string => artist.name || '').filter((name: string): boolean => name !== '').join(', ') || '未知藝術家';
  }
  
  // 提取廠牌名稱
  private static extractLabelName(labels: LabelInfo[]): string {
    if (!labels || labels.length === 0) {
      return '未知廠牌';
    }
    
    return labels.map((label: LabelInfo): string => label.name || '').filter((name: string): boolean => name !== '').join(', ') || '未知廠牌';
  }
  
  // 模擬數據（當API不可用時使用）
  private static getMockData(): LocalRecord[] {
    return [
      {
        id: '1',
        title: 'Abbey Road',
        artist: 'The Beatles',
        year: '1969',
        coverImage: 'https://i.discogs.com/r300-/release/10329784-abbey-road.jpg',
        genre: 'Rock, Pop',
        label: 'Apple Records'
      },
      {
        id: '2',
        title: 'Dark Side of the Moon',
        artist: 'Pink Floyd',
        year: '1973',
        coverImage: 'https://i.discogs.com/r300-/release/14270417-dark-side-of-the-moon.jpg',
        genre: 'Progressive Rock',
        label: 'Harvest'
      },
      {
        id: '3',
        title: 'Thriller',
        artist: 'Michael Jackson',
        year: '1982',
        coverImage: 'https://i.discogs.com/r300-/release/294846-thriller.jpg',
        genre: 'Pop, Funk',
        label: 'Epic'
      },
      {
        id: '4',
        title: 'Nevermind',
        artist: 'Nirvana',
        year: '1991',
        coverImage: 'https://i.discogs.com/r300-/release/380709-nevermind.jpg',
        genre: 'Grunge, Alternative Rock',
        label: 'DGC'
      },
      {
        id: '5',
        title: 'OK Computer',
        artist: 'Radiohead',
        year: '1997',
        coverImage: 'https://i.discogs.com/r300-/release/1109832-ok-computer.jpg',
        genre: 'Alternative Rock',
        label: 'Parlophone'
      },
      {
        id: '6',
        title: 'The Velvet Underground & Nico',
        artist: 'The Velvet Underground',
        year: '1967',
        coverImage: 'https://i.discogs.com/r300-/release/1109832-velvet-underground-nico.jpg',
        genre: 'Art Rock, Experimental',
        label: 'Verve'
      }
    ];
  }

  // 高價值唱片模擬數據（與TimeMachine.ets保持一致）
  private static getMockValueRankingData(): LocalRecord[] {
    return [
      {
        id: '1',
        title: 'The Velvet Underground & Nico',
        artist: 'The Velvet Underground & Nico',
        year: '1967',
        coverImage: 'https://i.discogs.com/r300-/release/1109832-velvet-underground-nico.jpg',
        genre: 'Art Rock, Experimental',
        label: 'Verve Records'
      },
      {
        id: '2',
        title: 'Led Zeppelin',
        artist: 'Led Zeppelin',
        year: '1969',
        coverImage: 'https://i.discogs.com/r300-/release/1565832-led-zeppelin.jpg',
        genre: 'Hard Rock, Blues Rock',
        label: 'Atlantic Records'
      },
      {
        id: '3',
        title: 'Abbey Road',
        artist: 'The Beatles',
        year: '1969',
        coverImage: 'https://i.discogs.com/r300-/release/10329784-abbey-road.jpg',
        genre: 'Rock, Pop',
        label: 'Apple Records'
      },
      {
        id: '4',
        title: 'Pet Sounds',
        artist: 'The Beach Boys',
        year: '1966',
        coverImage: 'https://i.discogs.com/r300-/release/1234567-pet-sounds.jpg',
        genre: 'Pop Rock, Psychedelic Pop',
        label: 'Capitol Records'
      },
      {
        id: '5',
        title: 'Kind of Blue',
        artist: 'Miles Davis',
        year: '1959',
        coverImage: 'https://i.discogs.com/r300-/release/987654-kind-of-blue.jpg',
        genre: 'Jazz, Modal Jazz',
        label: 'Columbia Records'
      }
    ];
  }
}
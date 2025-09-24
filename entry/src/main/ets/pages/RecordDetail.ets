import router from '@ohos.router';
import http from '@ohos.net.http';
import { FavoriteService } from '../services/FavoriteService';
import { AuthService } from '../services/AuthService';
import { FavoriteRequest } from '../common/UserTypes';
import { FavoriteStorageManager } from '../services/FavoriteStorageManager';
import { ApiRecordItem, MusicApiService } from '../services/MusicApiService';
import { ApiConfig } from '../common/ApiConfig';

// 定義Discogs API返回的詳細數據接口
interface DiscogsArtist {
  name: string;
  role?: string;
}

interface DiscogsExtraArtist {
  name: string;
  role: string;
}

interface DiscogsTrack {
  position: string;
  title: string;
  duration?: string;
  artists?: DiscogsArtist[];
  extraartists?: DiscogsExtraArtist[];
}

interface DiscogsLabel {
  name: string;
  catno?: string;
}

interface DiscogsImage {
  type: string;
  uri: string;
  uri150?: string;
  width?: number;
  height?: number;
}

interface DiscogsReleaseArtist {
  name: string;
}

interface DiscogsFormat {
  name: string;
  qty?: string;
  descriptions?: string[];
}

interface DiscogsCompany {
  name: string;
  entity_type_name: string;
}

// 模擬數據的類型定義
interface MockRecordData {
  title: string;
  artist: string;
  year: string;
  genres: string[];
  image: string;
}

interface DiscogsReleaseDetail {
  id: number;
  title: string;
  artists: DiscogsReleaseArtist[];
  images?: DiscogsImage[];
  labels?: DiscogsLabel[];
  formats?: DiscogsFormat[];
  country?: string;
  released?: string;
  year?: number; // 發行年份
  genres?: string[];
  styles?: string[];
  tracklist?: DiscogsTrack[];
  extraartists?: DiscogsExtraArtist[];
  companies?: DiscogsCompany[];
  notes?: string;
}

@Entry
@Component
struct RecordDetail {
  @State recordId: string = '';
  @State recordDetail: DiscogsReleaseDetail | null = null;
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State selectedImageIndex: number = 0;
  @State isFavorite: boolean = false; // 收藏状态
  @State private isProcessingFavorite: boolean = false; // 收藏操作处理状态
  private favoriteService: FavoriteService = FavoriteService.getInstance();
  private authService: AuthService = AuthService.getInstance();
  private storageManager: FavoriteStorageManager = FavoriteStorageManager.getInstance();

  // 顏色主題
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private cardBgColor: string = '#1e1e2e';

  // Discogs API配置
  private readonly DISCOGS_API_URL = 'https://api.discogs.com';
  private readonly USER_AGENT = 'BananaRecordApp/1.0';

  aboutToAppear() {
    console.log('=== RecordDetail aboutToAppear 开始 ===');
    
    // 初始化存储管理器
    this.storageManager.initStorage();
    
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    console.log('路由参数:', params);
    
    // 提取recordId
    this.recordId = (params?.recordId as string) || '';
    console.log('提取的recordId:', this.recordId, '类型:', typeof this.recordId);
    
    // 检查是否有额外的唱片信息参数
    const recordTitle = params?.recordTitle as string;
    const recordArtist = params?.recordArtist as string;
    const recordImage = params?.recordImage as string;
    
    if (recordTitle && recordArtist) {
      // 如果有额外的唱片信息，直接使用这些信息构建详情
      console.log('使用传递的唱片信息:', { recordTitle, recordArtist, recordImage });
      this.buildRecordFromParams(recordTitle, recordArtist, recordImage);
      this.checkFavoriteStatus(); // 检查收藏状态
    } else {
      // 否则按原有逻辑加载
      if (this.recordId) {
        this.loadRecordDetail();
        this.checkFavoriteStatus(); // 检查收藏状态
      } else {
        console.error('未提供recordId参数');
      }
    }
  }

  // 新增方法：根据传递的参数构建唱片详情
  private buildRecordFromParams(title: string, artist: string, image?: string): void {
    this.isLoading = false;
    this.recordDetail = {
      id: parseInt(this.recordId) || 0,
      title: title,
      artists: [{ name: artist }],
      year: 2023,
      genres: ['Pop'],
      images: image ? [{ type: 'primary', uri: image, uri150: image }] : [],
      labels: [{ name: '未知厂牌', catno: 'N/A' }],
      formats: [{ name: 'Digital', descriptions: ['Album'] }],
      tracklist: [],
      extraartists: [],
      notes: `这是来自首页潮流趋势的热门专辑《${title}》，由${artist}演出。`,
      released: '2023',
      country: 'Unknown'
    };
    console.log('构建的recordDetail:', this.recordDetail);
  }

  // 載入唱片詳情
  private async loadRecordDetail() {
    if (!this.recordId) return;

    this.isLoading = true;
    
    try {
      // 检查是否配置了API Token
      if (!ApiConfig.hasDiscogsToken()) {
        console.warn('Discogs API Token未配置，使用模拟数据');
        this.loadMockDetail();
        return;
      }

      const httpRequest = http.createHttp();
      const url = `${ApiConfig.DISCOGS_API_URL}/releases/${this.recordId}`;
      
      console.log(`正在加载唱片详情，ID: ${this.recordId}, URL: ${url}`);
      console.log('使用API Token:', ApiConfig.hasDiscogsToken() ? '已配置' : '未配置');
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: ApiConfig.getDiscogsHeaders(),
        connectTimeout: 10000,
        readTimeout: 10000
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as DiscogsReleaseDetail;
        console.log('✅ 成功从Discogs API获取唱片详情:', data.title);
        console.log('API返回的完整数据:', JSON.stringify(data, null, 2));
        this.recordDetail = data;
      } else if (response.responseCode === 404) {
        console.warn(`唱片ID ${this.recordId} 在Discogs数据库中不存在，使用模拟数据`);
        this.loadMockDetail();
      } else {
        console.error('Discogs API error:', response.responseCode, response.result);
        console.log('API调用失败，使用模拟数据');
        this.loadMockDetail();
      }
    } catch (error) {
      console.error('Load detail error:', error);
      console.log('网络请求异常，使用模拟数据');
      this.loadMockDetail();
    } finally {
      this.isLoading = false;
    }
  }

  // 載入模擬詳情數據
  private loadMockDetail() {
    console.log('=== loadMockDetail 开始 ===');
    console.log('当前recordId:', this.recordId);
    console.log('recordId类型:', typeof this.recordId);
    console.log('⚠️ 注意：当前显示的是模拟数据，不是真实的Discogs API数据');
    
    // 根據recordId生成對應的模擬數據 - 使用真实Discogs高价值唱片数据
    const mockDataMap: Record<string, MockRecordData> = {
      '249504': {
        title: 'Please Please Me',
        artist: 'The Beatles',
        year: '1963',
        genres: ['Rock', 'Pop'],
        image: 'https://i.discogs.com/r300-/release/249504-The-Beatles-Please-Please-Me.jpg'
      },
      '9823525': {
        title: 'Wish You Were Here',
        artist: 'Pink Floyd',
        year: '1975',
        genres: ['Rock', 'Progressive Rock'],
        image: 'https://i.discogs.com/r300-/release/9823525-Pink-Floyd-Wish-You-Were-Here.jpg'
      },
      '4262072': {
        title: 'Xanadu',
        artist: 'Olivia Newton-John & Electric Light Orchestra',
        year: '1980',
        genres: ['Pop', 'Soundtrack'],
        image: 'https://i.discogs.com/r300-/release/4262072-Olivia-Newton-John-Electric-Light-Orchestra-Xanadu.jpg'
      },
      '1218307': {
        title: 'Overseas',
        artist: 'Tommy Flanagan Trio',
        year: '1958',
        genres: ['Jazz'],
        image: 'https://i.discogs.com/r300-/release/1218307-Tommy-Flanagan-Trio-Overseas.jpg'
      },
      '5678901': {
        title: 'Your Love Is What I Want',
        artist: 'The Ravins',
        year: '1969',
        genres: ['Soul', 'Northern Soul'],
        image: 'https://i.discogs.com/r300-/release/5678901-The-Ravins-Your-Love-Is-What-I-Want.jpg'
      }
    };

    // 为动态生成的recordId添加通用的模拟数据
    let mockData: MockRecordData = mockDataMap[this.recordId];
    
    if (!mockData) {
      // 如果没有找到对应的mockData，生成通用的模拟数据
      console.log('未找到对应的mockData，使用通用模拟数据');
      mockData = {
        title: '热门专辑',
        artist: '知名艺术家',
        year: '2023',
        genres: ['Pop', 'Rock'],
        image: 'https://i.scdn.co/image/ab67616d0000b273ef6f049cce6fcc59a6e52233'
      };
    }
    
    console.log('选择的mockData:', mockData);
    console.log('是否使用默认数据:', !mockDataMap[this.recordId]);
    console.log('💡 提示：要获取真实的唱片详情，请配置Discogs API Token');
    
    const mockArtists: DiscogsReleaseArtist[] = [{ name: mockData.artist }];
    const mockImages: DiscogsImage[] = [
      {
        type: 'primary',
        uri: mockData.image,
        uri150: mockData.image
      }
    ];
    const mockLabels: DiscogsLabel[] = [
      {
        name: '華星唱片',
        catno: 'CAL-03-1040'
      }
    ];
    const mockFormats: DiscogsFormat[] = [
      {
        name: 'Vinyl',
        descriptions: ['LP', 'Album']
      }
    ];
    const mockExtraArtists1: DiscogsExtraArtist[] = [
      { name: '奧金寶', role: 'Arranged By' },
      { name: '楊保羅', role: 'Lyrics By' },
      { name: '小林明子', role: 'Music By' }
    ];
    const mockExtraArtists2: DiscogsExtraArtist[] = [
      { name: '卡龍', role: 'Lyrics By' },
      { name: '黎小田', role: 'Music By, Arranged By' }
    ];
    const mockExtraArtists3: DiscogsExtraArtist[] = [
      { name: '羅廸', role: 'Arranged By' },
      { name: '林振強', role: 'Lyrics By' },
      { name: '大野克夫', role: 'Music By' }
    ];
    const mockExtraArtists4: DiscogsExtraArtist[] = [
      { name: '黃霑', role: 'Lyrics By' },
      { name: '顧嘉煇', role: 'Music By, Arranged By' }
    ];
    const mockExtraArtists5: DiscogsExtraArtist[] = [
      { name: '羅廸', role: 'Arranged By' },
      { name: '潘偉源', role: 'Lyrics By' },
      { name: 'Motoaki Masuo', role: 'Music By' }
    ];
    const mockExtraArtists6: DiscogsExtraArtist[] = [
      { name: '趙增熹', role: 'Arranged By' },
      { name: '小美', role: 'Lyrics By' },
      { name: '谷村新司', role: 'Music By' }
    ];
    const mockExtraArtists7: DiscogsExtraArtist[] = [
      { name: 'Nanba Hiroyuki', role: 'Arranged By' },
      { name: '林振強', role: 'Lyrics By' },
      { name: '沢村拓二', role: 'Music By' }
    ];
    const mockExtraArtists8: DiscogsExtraArtist[] = [
      { name: '姚志漢', role: 'Arranged By' },
      { name: 'Leslie', role: 'Lyrics By' },
      { name: '林哲司', role: 'Music By' }
    ];
    const mockExtraArtists9: DiscogsExtraArtist[] = [
      { name: '蘇德華', role: 'Arranged By' },
      { name: '林振強', role: 'Lyrics By' },
      { name: 'Annie', role: 'Music By' }
    ];
    const mockExtraArtists10: DiscogsExtraArtist[] = [
      { name: '杜自持', role: 'Arranged By' },
      { name: '卡龍', role: 'Lyrics By' },
      { name: 'Justin Peters, Steve Davis', role: 'Music By' }
    ];
    
    const mockTracklist: DiscogsTrack[] = [
      {
        position: 'A1',
        title: '迷惑我',
        duration: '4:22',
        extraartists: mockExtraArtists1
      },
      {
        position: 'A2',
        title: '情到濃時',
        duration: '3:56',
        extraartists: mockExtraArtists2
      },
      {
        position: 'A3',
        title: '隱身人',
        duration: '3:38',
        extraartists: mockExtraArtists3
      },
      {
        position: 'A4',
        title: '當年情',
        duration: '4:15',
        extraartists: mockExtraArtists4
      },
      {
        position: 'A5',
        title: '愛的決擇',
        duration: '4:11',
        extraartists: mockExtraArtists5
      },
      {
        position: 'B1',
        title: '有誰共鳴',
        duration: '3:53',
        extraartists: mockExtraArtists6
      },
      {
        position: 'B2',
        title: '烈火邊緣',
        duration: '3:38',
        extraartists: mockExtraArtists7
      },
      {
        position: 'B3',
        title: '愛火',
        duration: '4:29',
        extraartists: mockExtraArtists8
      },
      {
        position: 'B4',
        title: 'Crazy Rock',
        duration: '4:14',
        extraartists: mockExtraArtists9
      },
      {
        position: 'B5',
        title: 'Miracle',
        duration: '3:51',
        extraartists: mockExtraArtists10
      }
    ];

    const mockReleaseExtraArtists: DiscogsExtraArtist[] = [
      { name: '劉培基', role: 'Art Direction' },
      { name: '李韻揚, 陳樹發', role: 'Design' },
      { name: '黎小田, 邱德材', role: 'Mixed By' },
      { name: '孫淑興', role: 'Photography By' },
      { name: '張國榮, 黎小田', role: 'Producer' },
      { name: '邱德材', role: 'Recorded By' }
    ];

    const mockCompanies: DiscogsCompany[] = [
      { name: 'Capital Artists Ltd.', entity_type_name: 'Phonographic Copyright (p)' },
      { name: 'Capital Artists Ltd.', entity_type_name: 'Copyright (c)' }
    ];

    this.recordDetail = {
      id: parseInt(this.recordId),
      title: mockData.title,
      artists: mockArtists,
      images: mockImages,
      labels: mockLabels,
      formats: mockFormats,
      country: 'USA',
      released: mockData.year,
      genres: mockData.genres,
      styles: mockData.genres,
      tracklist: mockTracklist,
      extraartists: mockReleaseExtraArtists,
      companies: mockCompanies
    };
  }

  // 返回上一頁
  private goBack() {
    router.back();
  }

  // 切換收藏狀態
  private async toggleFavorite() {
    console.log('=== toggleFavorite 开始 ===');
    console.log('当前收藏状态:', this.isFavorite);
    console.log('唱片ID:', this.recordId);

    // 防止重复点击
    if (this.isProcessingFavorite) {
      console.log('正在处理收藏操作，忽略重复点击');
      return;
    }

    // 检查用户登录状态
    const isLoggedIn = await this.authService.isLoggedIn();
    if (!isLoggedIn) {
      console.log('用户未登录，无法收藏');
      // TODO: 显示登录提示或跳转到登录页面
      return;
    }

    // 获取当前用户信息
    const currentUser = await this.authService.getCurrentUser();
    console.log('用户信息详细内容:', JSON.stringify(currentUser, null, 2));
    console.log('用户ID:', currentUser?.id);
    console.log('用户ID类型:', typeof currentUser?.id);
    if (!currentUser?.id) {
      console.log('无法获取用户信息');
      return;
    }

    // 检查唱片详情是否已加载
    if (!this.recordDetail) {
      console.log('唱片详情未加载，无法收藏');
      return;
    }

    this.isProcessingFavorite = true;

    try {
      if (this.isFavorite) {
        // 取消收藏
        console.log('执行取消收藏操作');
        const result = await this.favoriteService.removeFavorite(currentUser.id, parseInt(this.recordId));
        
        if (result.success) {
          this.isFavorite = false;
          console.log('取消收藏成功');
        } else {
          console.error('取消收藏失败:', result.message);
        }
      } else {
        // 添加收藏
        console.log('执行添加收藏操作');
        
        // 构造收藏请求数据
        const favoriteRequest: FavoriteRequest = {
          userId: currentUser.id,
          recordId: parseInt(this.recordId),
          recordData: {
            title: this.recordDetail.title ?? '',
            artist: this.recordDetail.artists?.map(artist => artist.name).join(', ') ?? '',
            image: this.recordDetail.images?.[0]?.uri ?? '',
            year: this.recordDetail.year?.toString() ?? '',
            genres: this.recordDetail.genres ?? [],
            formats: this.recordDetail.formats?.map(format => format.name) ?? []
          }
        };

        console.log('收藏请求数据:', favoriteRequest);

        const result = await this.favoriteService.addFavorite(favoriteRequest);
        
        if (result.success) {
          this.isFavorite = true;
          console.log('添加收藏成功');
        } else {
          console.error('添加收藏失败:', result.message);
        }
      }
    } catch (error) {
      console.error('收藏操作异常:', error);
    } finally {
      this.isProcessingFavorite = false;
    }
  }

  // 检查收藏状态
  private async checkFavoriteStatus() {
    console.log('=== checkFavoriteStatus 开始 ===');
    
    try {
      // 检查用户登录状态
    const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        console.log('用户未登录，设置收藏状态为false');
        this.isFavorite = false;
        return;
      }

      // 获取当前用户信息
      const currentUser = await this.authService.getCurrentUser();
      if (!currentUser?.id || !this.recordId) {
        console.log('用户信息或唱片ID无效');
        this.isFavorite = false;
        return;
      }

      console.log('检查收藏状态 - userId:', currentUser.id, 'recordId:', this.recordId);

      // 查询收藏状态
      const statusResult = await this.favoriteService.checkFavoriteStatus(currentUser.id, parseInt(this.recordId));
      this.isFavorite = statusResult.isFavorite;
      
      console.log('收藏状态查询结果:', this.isFavorite);
    } catch (error) {
      console.error('检查收藏状态异常:', error);
      this.isFavorite = false;
    }
  }

  // 格式化發行日期
  private formatReleaseDate(dateStr?: string): string {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return date.toLocaleDateString('zh-TW', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  }

  build() {
    Column() {
      // 頂部標題欄
      Row() {
        Image($r('app.media.arrow_back'))
          .width(24)
          .height(24)
          .fillColor(this.textPrimary)
          .onClick(() => {
            this.goBack();
          })

        Text('唱片信息')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 佔位符保持對稱
        Row().width(24).height(24)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.bgColor)

      // 主要內容區域
      if (this.isLoading) {
        // 載入中狀態
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(this.primaryColor)
          
          Text('载入中...')
            .fontSize(16)
            .fontColor(this.textSecondary)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (!this.recordDetail) {
        // 錯誤狀態
        Column() {
          Image($r('app.media.error'))
            .width(60)
            .height(60)
            .fillColor(this.textSecondary)
          
          Text('载入失败')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textPrimary)
            .margin({ top: 16 })
          
          Text('网络好像怪怪的')
            .fontSize(14)
            .fontColor(this.textSecondary)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 詳情內容
        Scroll() {
          Column({ space: 20 }) {
            // 唱片封面和基本信息
            Column({ space: 16 }) {
              // 封面圖片
              if (this.recordDetail.images && this.recordDetail.images.length > 0) {
                Image(this.recordDetail.images[this.selectedImageIndex].uri)
                  .width(200)
                  .height(200)
                  .borderRadius(12)
                  .objectFit(ImageFit.Cover)
                  .alt($r('app.media.placeholder_album'))
              } else {
                Column()
                  .width(200)
                  .height(200)
                  .borderRadius(12)
                  .backgroundColor(this.secondaryColor)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
              }

              // 標題和藝術家
              Column({ space: 8 }) {
                Text(this.recordDetail.title)
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)
                  .textAlign(TextAlign.Center)
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                if (this.recordDetail.artists && this.recordDetail.artists.length > 0) {
                  Text(this.recordDetail.artists.map(artist => artist.name).join(', '))
                    .fontSize(18)
                    .fontColor(this.primaryColor)
                    .textAlign(TextAlign.Center)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
              }
              .width('100%')

              // 收藏按钮
              Button() {
                Row({ space: 8 }) {
                  if (this.isProcessingFavorite) {
                    LoadingProgress()
                      .width(16)
                      .height(16)
                      .color(this.textSecondary)
                  } else {
                    Image($r('app.media.ic_favorite'))
                      .width(20)
                      .height(20)
                      .fillColor(this.isFavorite ? '#ff4757' : this.textSecondary)
                  }
                  
                  Text(this.isProcessingFavorite ? '处理中...' : (this.isFavorite ? '已收藏' : '收藏'))
                    .fontSize(16)
                    .fontColor(this.isFavorite ? '#ff4757' : this.textPrimary)
                }
              }
              .width(120)
              .height(40)
              .backgroundColor(this.isFavorite ? 'rgba(255, 71, 87, 0.1)' : this.cardBgColor)
              .borderRadius(20)
              .border({
                width: 1,
                color: this.isFavorite ? '#ff4757' : this.textSecondary
              })
              .enabled(!this.isProcessingFavorite) // 处理中时禁用按钮
              .onClick(() => {
                this.toggleFavorite();
              })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Center)

            // 基本信息卡片
            Column({ space: 16 }) {
              // Label
              if (this.recordDetail.labels && this.recordDetail.labels.length > 0) {
                Column({ space: 8 }) {
                  Text('Label:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  ForEach(this.recordDetail.labels, (label: DiscogsLabel) => {
                    Text(`${label.name}${label.catno ? ` – ${label.catno}` : ''}`)
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                  })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              // Format
              if (this.recordDetail.formats && this.recordDetail.formats.length > 0) {
                Column({ space: 8 }) {
                  Text('Format:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  ForEach(this.recordDetail.formats, (format: DiscogsFormat) => {
                    Text(`${format.name}${format.descriptions ? ', ' + format.descriptions.join(', ') : ''}`)
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                  })
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              // Country
              if (this.recordDetail.country) {
                Column({ space: 8 }) {
                  Text('Country:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  Text(this.recordDetail.country)
                    .fontSize(14)
                    .fontColor(this.textSecondary)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              // Released
              if (this.recordDetail.released) {
                Column({ space: 8 }) {
                  Text('Released:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  Text(this.formatReleaseDate(this.recordDetail.released))
                    .fontSize(14)
                    .fontColor(this.textSecondary)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              // Genre
              if (this.recordDetail.genres && this.recordDetail.genres.length > 0) {
                Column({ space: 8 }) {
                  Text('Genre:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  Text(this.recordDetail.genres.join(', '))
                    .fontSize(14)
                    .fontColor(this.textSecondary)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }

              // Style
              if (this.recordDetail.styles && this.recordDetail.styles.length > 0) {
                Column({ space: 8 }) {
                  Text('Style:')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                  
                  Text(this.recordDetail.styles.join(', '))
                    .fontSize(14)
                    .fontColor(this.textSecondary)
                }
                .width('100%')
                .alignItems(HorizontalAlign.Start)
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.cardBgColor)
            .borderRadius(12)
            .alignItems(HorizontalAlign.Start)

            // 曲目列表
            if (this.recordDetail.tracklist && this.recordDetail.tracklist.length > 0) {
              Column({ space: 12 }) {
                Text('曲目列表')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)
                  .width('100%')

                ForEach(this.recordDetail.tracklist, (track: DiscogsTrack) => {
                  Column({ space: 8 }) {
                    Row() {
                      Text(track.position)
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(this.primaryColor)
                        .width(40)

                      Text(track.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(this.textPrimary)
                        .layoutWeight(1)
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })

                      if (track.duration) {
                        Text(track.duration)
                          .fontSize(14)
                          .fontColor(this.textSecondary)
                      }
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Top)

                    // 創作人員信息
                    if (track.extraartists && track.extraartists.length > 0) {
                      Column({ space: 4 }) {
                        ForEach(track.extraartists, (artist: DiscogsExtraArtist) => {
                          Text(`${artist.role} – ${artist.name}`)
                            .fontSize(12)
                            .fontColor(this.textSecondary)
                            .width('100%')
                            .margin({ left: 40 })
                        })
                      }
                      .width('100%')
                    }
                  }
                  .width('100%')
                  .padding(12)
                  .backgroundColor(this.cardBgColor)
                  .borderRadius(8)
                })
              }
              .width('100%')
            }

            // 製作人員信息
            if (this.recordDetail.extraartists && this.recordDetail.extraartists.length > 0) {
              Column({ space: 12 }) {
                Text('创作人员')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)
                  .width('100%')

                Column({ space: 8 }) {
                  ForEach(this.recordDetail.extraartists, (artist: DiscogsExtraArtist) => {
                    Text(`${artist.role} – ${artist.name}`)
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                      .width('100%')
                  })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.cardBgColor)
                .borderRadius(12)
              }
              .width('100%')
            }

            // 版權信息
            if (this.recordDetail.companies && this.recordDetail.companies.length > 0) {
              Column({ space: 12 }) {
                Text('版权信息')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)
                  .width('100%')

                Column({ space: 8 }) {
                  ForEach(this.recordDetail.companies, (company: DiscogsCompany) => {
                    Text(`${company.entity_type_name} – ${company.name}`)
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                      .width('100%')
                  })
                }
                .width('100%')
                .padding(16)
                .backgroundColor(this.cardBgColor)
                .borderRadius(12)
              }
              .width('100%')
            }
          }
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }

      // 底部導航欄
      Row() {
        Column({ space: 4 }) {
          Image($r('app.media.search'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 0 ? this.primaryColor : this.textSecondary)

          Text('搜唱片')
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === 0 ? this.primaryColor : this.textSecondary)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 0;
          router.pushUrl({ url: 'pages/Index' });
        })

        Column({ space: 4 }) {
          Image($r('app.media.grid'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 1 ? this.primaryColor : this.textSecondary)

          Text('唱片墙')
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === 1 ? this.primaryColor : this.textSecondary)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 1;
          router.pushUrl({ url: 'pages/RecordWall' });
        })

        Column({ space: 4 }) {
          Image($r('app.media.history'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 2 ? this.primaryColor : this.textSecondary)

          Text('时光机')
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === 2 ? this.primaryColor : this.textSecondary)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 2;
          router.pushUrl({ url: 'pages/TimeMachine' });
        })

        Column({ space: 4 }) {
          Image($r('app.media.person'))
            .width(24)
            .height(24)
            .fillColor(this.currentTab === 3 ? this.primaryColor : this.textSecondary)

          Text('我')
            .fontSize(10)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentTab === 3 ? this.primaryColor : this.textSecondary)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.currentTab = 3;
          router.pushUrl({ url: 'pages/Profile' });
        })
      }
      .width('100%')
      .height(80)
      .padding({ top: 8, bottom: 8 })
      .backgroundColor('#000000CC')
      .border({ width: { top: 1 }, color: this.secondaryColor + '80' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
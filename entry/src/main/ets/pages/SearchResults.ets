import router from '@ohos.router';
import http from '@ohos.net.http';
import { ApiConfig } from '../common/ApiConfig';

// 定義Discogs API返回的數據接口
interface DiscogsSearchResult {
  id: number;
  title: string;
  artist?: string;
  thumb?: string;
  cover_image?: string;
  year?: string;
  label?: string[];
  genre?: string[];
  style?: string[];
  format?: string[];
  country?: string;
}

interface DiscogsSearchResponse {
  results: DiscogsSearchResult[];
  pagination: DiscogsSearchPagination;
}

interface DiscogsSearchPagination {
  pages: number;
  page: number;
  per_page: number;
  items: number;
}

@Entry
@Component
struct SearchResults {
  @State searchQuery: string = '';
  @State searchResults: DiscogsSearchResult[] = [];
  @State isLoading: boolean = false;
  @State currentTab: number = 0;

  // 顏色主題
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private cardBgColor: string = '#1e1e2e';

  // Discogs API配置 - 现在使用ApiConfig管理
  private readonly DISCOGS_API_URL = ApiConfig.DISCOGS_API_URL;
  private readonly USER_AGENT = ApiConfig.USER_AGENT;

  aboutToAppear() {
    // 獲取路由參數
    const params = router.getParams() as Record<string, Object>;
    if (params && params.query) {
      this.searchQuery = params.query as string;
      this.searchDiscogs();
    }
  }

  // 搜索Discogs API
  private async searchDiscogs() {
    if (!this.searchQuery.trim()) return;

    this.isLoading = true;
    
    try {
      // 检查是否配置了API Token
      if (!ApiConfig.hasDiscogsToken()) {
        console.warn('Discogs API Token未配置，使用模拟数据');
        this.loadMockData();
        return;
      }
      
      const httpRequest = http.createHttp();
      const url = ApiConfig.buildSearchUrl(this.searchQuery, 'release', 20);
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: ApiConfig.getDiscogsHeaders()
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as DiscogsSearchResponse;
        this.searchResults = data.results || [];
        console.log(`搜索成功，找到 ${this.searchResults.length} 个结果`);
      } else {
        console.error('Discogs API error:', response.responseCode);
        // 使用模擬數據作為後備
        this.loadMockData();
      }
    } catch (error) {
      console.error('Search error:', error);
      // 使用模擬數據作為後備
      this.loadMockData();
    } finally {
      this.isLoading = false;
    }
  }

  // 載入模擬數據（用於測試和API失敗時的後備）
  private loadMockData() {
    this.searchResults = [
      {
        id: 1,
        title: '張國榮',
        artist: '張國榮',
        thumb: 'https://i.discogs.com/example1.jpg',
        year: '1986',
        label: ['華星唱片'],
        genre: ['Pop'],
        style: ['Cantopop'],
        format: ['Vinyl', 'LP', 'Album'],
        country: 'Hong Kong'
      },
      {
        id: 2,
        title: 'To Pimp a Butterfly',
        artist: 'Kendrick Lamar',
        thumb: 'https://i.discogs.com/example2.jpg',
        year: '2015',
        label: ['Top Dawg Entertainment'],
        genre: ['Hip Hop'],
        style: ['Conscious'],
        format: ['CD', 'Album'],
        country: 'US'
      }
    ];
  }

  // 跳轉到唱片詳情頁面
  private goToRecordDetail(recordId: number) {
    router.pushUrl({
      url: 'pages/RecordDetail',
      params: {
        recordId: recordId
      }
    });
  }

  // 返回上一頁
  private goBack() {
    router.back();
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

        Text(`搜索: ${this.searchQuery}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

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
          
          Text('搜索中...')
            .fontSize(16)
            .fontColor(this.textSecondary)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.searchResults.length === 0) {
        // 無結果狀態
        Column() {
          Image($r('app.media.search'))
            .width(60)
            .height(60)
            .fillColor(this.textSecondary)
          
          Text('未找到相关唱片')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textPrimary)
            .margin({ top: 16 })
          
          Text('试试别的关键词')
            .fontSize(14)
            .fontColor(this.textSecondary)
            .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 搜索結果列表
        Scroll() {
          Column({ space: 12 }) {
            ForEach(this.searchResults, (record: DiscogsSearchResult, index: number) => {
              Row({ space: 12 }) {
                // 唱片封面
                if (record.thumb && record.thumb.length > 0) {
                  Image(record.thumb)
                    .width(80)
                    .height(80)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                    .alt($r('app.media.placeholder_album'))
                } else {
                  // 佔位符封面
                  Column()
                    .width(80)
                    .height(80)
                    .borderRadius(8)
                    .backgroundColor(this.secondaryColor)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                }

                // 唱片信息
                Column({ space: 4 }) {
                  Text(record.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.textPrimary)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })

                  if (record.artist) {
                    Text(record.artist)
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }

                  Row({ space: 8 }) {
                    if (record.year) {
                      Text(record.year)
                        .fontSize(12)
                        .fontColor(this.textSecondary)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor(this.secondaryColor + '80')
                        .borderRadius(4)
                    }

                    if (record.format && record.format.length > 0) {
                      Text(record.format[0])
                        .fontSize(12)
                        .fontColor(this.textSecondary)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .backgroundColor(this.secondaryColor + '80')
                        .borderRadius(4)
                    }
                  }
                  .alignItems(VerticalAlign.Center)

                  if (record.genre && record.genre.length > 0) {
                    Text(record.genre.join(', '))
                      .fontSize(12)
                      .fontColor(this.primaryColor)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Start)

                // 箭頭圖標
                Image($r('app.media.arrow_right'))
                  .width(16)
                  .height(16)
                  .fillColor(this.textSecondary)
              }
              .width('100%')
              .padding(16)
              .backgroundColor(this.cardBgColor)
              .borderRadius(12)
              .alignItems(VerticalAlign.Center)
              .onClick(() => {
                this.goToRecordDetail(record.id);
              })
            }, (record: DiscogsSearchResult) => record.id.toString())
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
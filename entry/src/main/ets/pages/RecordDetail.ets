import router from '@ohos.router';
import http from '@ohos.net.http';

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

interface DiscogsReleaseDetail {
  id: number;
  title: string;
  artists: DiscogsReleaseArtist[];
  images?: DiscogsImage[];
  labels?: DiscogsLabel[];
  formats?: DiscogsFormat[];
  country?: string;
  released?: string;
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
  @State recordId: number = 0;
  @State recordDetail: DiscogsReleaseDetail | null = null;
  @State isLoading: boolean = false;
  @State currentTab: number = 0;
  @State selectedImageIndex: number = 0;

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
    // 獲取路由參數
    const params = router.getParams() as Record<string, Object>;
    if (params && params.recordId) {
      this.recordId = params.recordId as number;
      this.loadRecordDetail();
    }
  }

  // 載入唱片詳情
  private async loadRecordDetail() {
    if (!this.recordId) return;

    this.isLoading = true;
    
    try {
      const httpRequest = http.createHttp();
      const url = `${this.DISCOGS_API_URL}/releases/${this.recordId}`;
      
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'User-Agent': this.USER_AGENT,
          'Accept': 'application/json'
        }
      });

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as DiscogsReleaseDetail;
        this.recordDetail = data;
      } else {
        console.error('Discogs API error:', response.responseCode);
        // 使用模擬數據作為後備
        this.loadMockDetail();
      }
    } catch (error) {
      console.error('Load detail error:', error);
      // 使用模擬數據作為後備
      this.loadMockDetail();
    } finally {
      this.isLoading = false;
    }
  }

  // 載入模擬詳情數據
  private loadMockDetail() {
    const mockArtists: DiscogsReleaseArtist[] = [{ name: '張國榮' }];
    const mockImages: DiscogsImage[] = [
      {
        type: 'primary',
        uri: 'https://i.discogs.com/example1.jpg',
        uri150: 'https://i.discogs.com/example1_150.jpg'
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
      id: this.recordId,
      title: '張國榮',
      artists: mockArtists,
      images: mockImages,
      labels: mockLabels,
      formats: mockFormats,
      country: 'Hong Kong',
      released: '1986-10-01',
      genres: ['Pop'],
      styles: ['Cantopop'],
      tracklist: mockTracklist,
      extraartists: mockReleaseExtraArtists,
      companies: mockCompanies
    };
  }

  // 返回上一頁
  private goBack() {
    router.back();
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
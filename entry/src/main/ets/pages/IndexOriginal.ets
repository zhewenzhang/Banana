import router from '@ohos.router';
import { ApiRecordItem, ApiArtistItem, MusicApiService } from '../services/MusicApiService';

// 保留原有接口作为兼容
interface RecordItem {
  title: string;
  artist: string;
  image: string;
}

interface ArtistItem {
  name: string;
  image: string;
}

@Entry
@Component
struct Index {
  @State searchText: string = '';
  @State private currentTab: number = 0;
  @State private trendingRecords: ApiRecordItem[] = [];
  @State private popularArtists: ApiArtistItem[] = [];
  @State private isLoadingRecords: boolean = true;
  @State private isLoadingArtists: boolean = true;
  @State private recordsError: string = '';
  @State private artistsError: string = '';
  @State private failedImages: Set<string> = new Set(); // 記錄加載失敗的圖片URL

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private accentColor: string = '#4ECDC4';

  private musicApiService: MusicApiService = new MusicApiService();

  async aboutToAppear(): Promise<void> {
    await this.loadTrendingRecords();
    await this.loadPopularArtists();
  }

  private async loadTrendingRecords(): Promise<void> {
    try {
      this.isLoadingRecords = true;
      this.recordsError = '';
      const response = await this.musicApiService.getTrendingRecords();
      if (response?.success && response.data) {
        this.trendingRecords = response.data;
      } else {
        this.recordsError = response?.error || '加载失败';
      }
    } catch (error) {
      console.error('加载热门唱片失败:', error);
      this.recordsError = '加载失败，请稍后重试';
    } finally {
      this.isLoadingRecords = false;
    }
  }

  private async loadPopularArtists(): Promise<void> {
    try {
      this.isLoadingArtists = true;
      this.artistsError = '';
      const response = await this.musicApiService.getPopularArtists();
      if (response?.success && response.data) {
        this.popularArtists = response.data;
      } else {
        this.artistsError = response?.error || '加载失败';
      }
    } catch (error) {
      console.error('加载热门艺术家失败:', error);
      this.artistsError = '加载失败，请稍后重试';
    } finally {
      this.isLoadingArtists = false;
    }
  }

  // 處理唱片點擊事件
  private onRecordClick(record: ApiRecordItem): void {
    console.log('点击唱片:', record);
    try {
      router.pushUrl({
        url: 'pages/RecordDetail',
        params: {
          recordId: record.id, // 直接传递string类型的recordId
          recordTitle: record.title,
          recordArtist: record.artist,
          recordImage: record.image
        }
      });
    } catch (error) {
      console.error('跳转到唱片详情页面失败:', error);
    }
  }

  private onArtistClick(artist: ApiArtistItem): void {
    router.pushUrl({
      url: 'pages/ArtistDetail',
      params: {
        artistId: artist.id,
        artistName: artist.name,
        imageUrl: artist.image
      }
    }).catch((error: Error) => {
      console.error('导航到艺术家详情页失败:', error);
    });
  }

  // 生成渐变色占位符的方法
  private getGradientColors(index: number): string[] {
    const gradients = [
      ['#FF6B6B', '#4ECDC4'], // 红到青
      ['#A8E6CF', '#FFD93D'], // 绿到黄
      ['#FF8A80', '#FF80AB'], // 粉红渐变
      ['#81C784', '#4FC3F7'], // 绿到蓝
      ['#FFB74D', '#F06292'], // 橙到粉
      ['#9575CD', '#64B5F6'], // 紫到蓝
      ['#FF7043', '#42A5F5'], // 橙到蓝
      ['#AB47BC', '#26C6DA'], // 紫到青
      ['#66BB6A', '#FFA726'], // 绿到橙
      ['#EF5350', '#7E57C2'], // 红到紫
    ];
    return gradients[index % gradients.length];
  }

  // 創建唱片封面占位符組件
  @Builder
  private RecordPlaceholder(record: ApiRecordItem, index: number, width: number = 144, height: number = 144) {
    Stack() {
      // 漸變背景
      Row() {}
        .width(width)
        .height(height)
        .borderRadius(8)
        .linearGradient({
          angle: 45,
          colors: [
            [this.getGradientColors(index)[0], 0.0],
            [this.getGradientColors(index)[1], 1.0]
          ]
        })
      
      // 唱片名稱文字
      Column({ space: 4 }) {
        Text(record.title || '未知專輯')
          .fontSize(width > 120 ? 14 : 12)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textShadow({ radius: 2, color: Color.Black, offsetX: 1, offsetY: 1 })
        
        Text(record.artist || '未知藝術家')
          .fontSize(width > 120 ? 12 : 10)
          .fontColor('#E0E0E0')
          .textAlign(TextAlign.Center)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textShadow({ radius: 1, color: Color.Black, offsetX: 1, offsetY: 1 })
      }
      .padding(8)
      .width(width - 16)
      .justifyContent(FlexAlign.Center)
    }
    .width(width)
    .height(height)
  }

  // 搜索唱片的方法
  private searchRecords() {
    if (this.searchText.trim()) {
      router.pushUrl({
        url: 'pages/SearchResults',
        params: {
          query: this.searchText
        }
      });
    }
  }

  // 检查图片URL是否有效的方法
  private isValidImageUrl(url: string): boolean {
    return !!(url && url.trim() !== '' && (url.startsWith('http') || url.startsWith('https')));
  }


  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('享胶')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.bgColor)

      // 主要内容区域
      Scroll() {
        Column({ space: 32 }) {
          // 搜索框
          Row() {
            Image($r('app.media.search'))
              .width(20)
              .height(20)
              .fillColor(this.textSecondary)
              .margin({ left: 12 })

            TextInput({ placeholder: '搜索唱片、CD名称和艺术家', text: this.searchText })
              .placeholderColor(this.textSecondary)
              .fontColor(this.textPrimary)
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .layoutWeight(1)
              .onChange((value: string) => {
                this.searchText = value;
              })
              .onSubmit(() => {
                if (this.searchText.trim().length > 0) {
                  this.searchRecords();
                }
              })

            if (this.searchText.length > 0) {
              Image($r('app.media.close'))
                .width(20)
                .height(20)
                .fillColor(this.textSecondary)
                .margin({ right: 12 })
                .onClick(() => {
                  this.searchText = '';
                })
            }
          }
          .width('100%')
          .height(48)
          .backgroundColor(this.secondaryColor + '80')
          .borderRadius(8)
          .alignItems(VerticalAlign.Center)

          // 热门唱片区域
          Column({ space: 16 }) {
            Row() {
              Text('潮流趋势')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textPrimary)
              
              Blank()
              
              Text('...')
                .fontSize(14)
                .fontColor(this.textSecondary)
                .onClick(() => {
                  // 可以添加查看全部的逻辑
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            
            if (this.isLoadingRecords) {
              // 加载状态
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color(this.textSecondary)
                
                Text('正在加载热门唱片...')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .margin({ left: 8 })
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .height(120)
            } else if (this.recordsError) {
              // 错误状态
              Column({ space: 8 }) {
                Text('😔')
                  .fontSize(24)
                
                Text(this.recordsError)
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .textAlign(TextAlign.Center)
                
                Button('重试')
                  .fontSize(12)
                  .backgroundColor(this.secondaryColor)
                  .borderRadius(16)
                  .padding({ left: 16, right: 16, top: 6, bottom: 6 })
                  .onClick(() => {
                    this.loadTrendingRecords();
                  })
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')
              .height(120)
            } else {
              // 数据展示
              Scroll() {
                Row({ space: 16 }) {
                  ForEach(this.trendingRecords, (record: ApiRecordItem, index: number) => {
                    Column({ space: 8 }) {
                      // 图片或占位符 - 增强错误处理和重试机制
                      if (this.isValidImageUrl(record.image) && !this.failedImages.has(record.image)) {
                        Image(record.image)
                          .width(144)
                          .height(144)
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover)
                          .alt(`${record.title} by ${record.artist}`)
                          .onError(() => {
                            // 圖片加載失敗時，記錄失敗的URL並觸發重新渲染
                            console.error(`Failed to load image: ${record.image} for ${record.title}`);
                            this.failedImages.add(record.image);
                            // 强制触发状态更新以重新渲染
                            this.trendingRecords = [...this.trendingRecords];
                          })
                          .onComplete(() => {
                            console.log(`Successfully loaded image for: ${record.title}`);
                          })
                      } else {
                        // 使用新的占位符組件
                        this.RecordPlaceholder(record, index, 144, 144)
                      }

                      Column({ space: 4 }) {
                        Text(record.title || '未知专辑')
                          .fontSize(14)
                          .fontWeight(FontWeight.Medium)
                          .fontColor(this.textPrimary)
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })

                        Text(record.artist)
                          .fontSize(12)
                          .fontColor(this.textSecondary)
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .width(144)
                      .alignItems(HorizontalAlign.Start)
                    }
                    .onClick(() => {
                      this.onRecordClick(record);
                    })
                  })
                }
                .padding({ left: 16, right: 16 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .margin({ left: -16, right: -16 })
            }
          }

          // 流行艺术家区域
          this.PopularArtistsSection()
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部导航栏
      this.BottomNavigation()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  private PopularArtistsSection() {
    Column({ space: 16 }) {
      Row() {
        Text('热门艺术家')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
        
        Blank()
        
        Text('...')
          .fontSize(14)
          .fontColor(this.textSecondary)
          .onClick(() => {
            // 可以添加查看全部的逻辑
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20 })
      
      if (this.isLoadingArtists) {
        // 加载状态
        Row() {
          LoadingProgress()
            .width(24)
            .height(24)
            .color(this.accentColor)
          
          Text('正在加载热门艺术家...')
            .fontSize(14)
            .fontColor(this.textSecondary)
            .margin({ left: 8 })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(120)
      } else if (this.artistsError) {
        // 错误状态
        Column({ space: 8 }) {
          Text('😔')
            .fontSize(24)
          
          Text(this.artistsError)
            .fontSize(14)
            .fontColor(this.textSecondary)
            .textAlign(TextAlign.Center)
          
          Button('重试')
            .fontSize(12)
            .backgroundColor(this.accentColor)
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 6, bottom: 6 })
            .onClick(() => {
              this.loadPopularArtists();
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height(120)
      } else {
        // 数据展示
        Column({ space: 16 }) {
          ForEach(this.popularArtists, (artist: ApiArtistItem, index: number) => {
            this.ArtistCard(artist, index)
          })
        }
        .padding({ left: 20, right: 20 })
      }
    }
  }

  @Builder
  private RecordCard(record: ApiRecordItem, index: number) {
    Column({ space: 8 }) {
      // 图片或占位符
      if (this.isValidImageUrl(record.image) && !this.failedImages.has(record.image)) {
        Image(record.image)
          .width(144)
          .height(144)
          .borderRadius(8)
          .objectFit(ImageFit.Cover)
          .onError(() => {
            // 圖片加載失敗時，記錄失敗的URL並觸發重新渲染
            console.error(`Failed to load image: ${record.image}`);
            this.failedImages.add(record.image);
          })
      } else {
        // 使用新的占位符組件
        this.RecordPlaceholder(record, index, 144, 144)
      }

      Column({ space: 4 }) {
        Text(record.title || '未知专辑')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(record.artist || '未知艺术家')
          .fontSize(12)
          .fontColor(this.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width(144)
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      this.onRecordClick(record);
    })
  }

  @Builder
  private ArtistCard(artist: ApiArtistItem, index: number) {
    Row({ space: 16 }) {
      // 艺术家头像或渐变色占位符
      if (this.isValidImageUrl(artist.image)) {
        Image(artist.image)
          .width(64)
          .height(64)
          .borderRadius(32)
          .objectFit(ImageFit.Cover)
      } else {
        // 圆形渐变色占位符
        Row() {}
          .width(64)
          .height(64)
          .borderRadius(32)
          .linearGradient({
            angle: 135,
            colors: [
              [this.getGradientColors(index + 3)[0], 0.0],
              [this.getGradientColors(index + 3)[1], 1.0]
            ]
          })
      }

      Column({ space: 4 }) {
        Text(artist.name || '未知艺术家')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary)

        Text('Artist')
          .fontSize(14)
          .fontColor(this.textSecondary)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.arrow_right'))
        .width(24)
        .height(24)
        .fillColor(this.textSecondary)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onArtistClick(artist);
    })
  }

  @Builder
  private BottomNavigation() {
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
        // 当前已在首页，无需跳转
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
        // 导航到唱片墙页面
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
        // 导航到时光机页面
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
        // 导航到Profile页面
        router.pushUrl({ url: 'pages/Profile' });
      })
    }
    .width('100%')
    .height(80)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor('#000000CC')
    .border({ width: { top: 1 }, color: this.secondaryColor + '80' })
  }
}
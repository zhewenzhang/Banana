import router from '@ohos.router';
import { ApiArtistItem, ApiRecordItem, MusicApiService } from '../services/MusicApiService';

@Entry
@Component
struct ArtistDetail {
  @State artistData: ApiArtistItem | null = null;
  @State artistAlbums: ApiRecordItem[] = [];
  @State isLoading: boolean = true;
  @State isLoadingAlbums: boolean = false;
  @State errorMessage: string = '';

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private accentColor: string = '#6366f1';

  aboutToAppear() {
    this.loadArtistData();
  }

  /**
   * 加载艺术家数据
   */
  private async loadArtistData(): Promise<void> {
    try {
      const params = router.getParams() as { artist?: ApiArtistItem };
      
      if (params?.artist) {
        this.artistData = params.artist;
        this.isLoading = false;
        
        // 加载艺术家的专辑
        await this.loadArtistAlbums(this.artistData.name);
      } else {
        this.errorMessage = '缺少艺术家信息';
        this.isLoading = false;
      }
    } catch (error) {
      console.error('加载艺术家数据失败:', error);
      this.errorMessage = '加载失败，请重试';
      this.isLoading = false;
    }
  }

  /**
   * 加载艺术家专辑
   */
  private async loadArtistAlbums(artistName: string): Promise<void> {
    this.isLoadingAlbums = true;
    
    try {
      const response = await MusicApiService.getArtistAlbums(artistName);
      if (response.success) {
        this.artistAlbums = response.data;
      }
    } catch (error) {
      console.error('加载艺术家专辑失败:', error);
    } finally {
      this.isLoadingAlbums = false;
    }
  }

  /**
   * 返回上一页
   */
  private goBack(): void {
    router.back();
  }

  /**
   * 跳转到唱片详情
   */
  private navigateToRecord(record: ApiRecordItem): void {
    router.pushUrl({
      url: 'pages/RecordDetail',
      params: {
        record: record
      }
    });
  }

  /**
   * 生成渐变色占位符
   */
  private getGradientColors(index: number): string[] {
    const gradients = [
      ['#FF6B6B', '#4ECDC4'],
      ['#A8E6CF', '#FFD93D'],
      ['#FF8A80', '#FF80AB'],
      ['#81C784', '#4FC3F7'],
      ['#FFB74D', '#F06292'],
      ['#9575CD', '#64B5F6'],
    ];
    return gradients[index % gradients.length];
  }

  /**
   * 格式化数字
   */
  private formatNumber(count: number): string {
    if (count >= 1000000) {
      return `${(count / 1000000).toFixed(1)}M`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}K`;
    }
    return count.toString();
  }

  @Builder
  private LoadingContent() {
    Column({ space: 20 }) {
      LoadingProgress()
        .width(50)
        .height(50)
        .color(this.accentColor)

      Text('加载中...')
        .fontSize(16)
        .fontColor(this.textSecondary)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private ErrorContent() {
    Column({ space: 20 }) {
      Image($r('app.media.close'))
        .width(60)
        .height(60)
        .fillColor(this.textSecondary)

      Text(this.errorMessage)
        .fontSize(16)
        .fontColor(this.textSecondary)
        .textAlign(TextAlign.Center)

      Button('重试')
        .backgroundColor(this.accentColor)
        .fontColor(this.textPrimary)
        .borderRadius(8)
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .onClick(() => {
          this.isLoading = true;
          this.errorMessage = '';
          this.loadArtistData();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(32)
  }

  @Builder
  private ArtistContent() {
    if (!this.artistData) return;

    Scroll() {
      Column({ space: 24 }) {
        // 艺术家头像和基本信息
        Column({ space: 20 }) {
          // 艺术家头像
          if (MusicApiService.isValidImageUrl(this.artistData.image || '')) {
            Image(this.artistData.image)
              .width(200)
              .height(200)
              .borderRadius(100)
              .objectFit(ImageFit.Cover)
              .shadow({
                radius: 20,
                color: '#00000040',
                offsetX: 0,
                offsetY: 8
              })
          } else {
            // 渐变色占位符
            Row() {}
              .width(200)
              .height(200)
              .borderRadius(100)
              .linearGradient({
                angle: 135,
                colors: [
                  [this.getGradientColors(0)[0], 0.0],
                  [this.getGradientColors(0)[1], 1.0]
                ]
              })
              .shadow({
                radius: 20,
                color: '#00000040',
                offsetX: 0,
                offsetY: 8
              })
          }

          // 艺术家名称
          Text(this.artistData.name || '未知艺术家')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textPrimary)
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 简介
          if (this.artistData.bio) {
            Text(this.artistData.bio)
              .fontSize(16)
              .fontColor(this.textSecondary)
              .textAlign(TextAlign.Center)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // 统计信息
        if (this.artistData.playcount || this.artistData.listeners) {
          Row({ space: 48 }) {
            if (this.artistData.playcount) {
              Column({ space: 4 }) {
                Text(this.formatNumber(this.artistData.playcount))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)

                Text('播放次数')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
              }
              .alignItems(HorizontalAlign.Center)
            }

            if (this.artistData.listeners) {
              Column({ space: 4 }) {
                Text(this.formatNumber(this.artistData.listeners))
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.textPrimary)

                Text('听众数')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
              }
              .alignItems(HorizontalAlign.Center)
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }

        // 操作按钮
        Row({ space: 16 }) {
          Button('关注')
            .backgroundColor(this.accentColor)
            .fontColor(this.textPrimary)
            .borderRadius(24)
            .layoutWeight(1)
            .height(48)
            .onClick(() => {
              // TODO: 实现关注功能
              console.log('关注艺术家:', this.artistData?.name);
            })

          Button('分享')
            .backgroundColor(this.secondaryColor)
            .fontColor(this.textPrimary)
            .borderRadius(24)
            .layoutWeight(1)
            .height(48)
            .onClick(() => {
              // TODO: 实现分享功能
              console.log('分享艺术家:', this.artistData?.name);
            })
        }
        .width('100%')
        .padding({ left: 32, right: 32 })

        // 专辑列表
        Column({ space: 16 }) {
          Row() {
            Text('热门专辑')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.textPrimary)

            if (this.isLoadingAlbums) {
              LoadingProgress()
                .width(20)
                .height(20)
                .color(this.accentColor)
                .margin({ left: 12 })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          if (this.artistAlbums.length > 0) {
            Column({ space: 12 }) {
              ForEach(this.artistAlbums, (album: ApiRecordItem, index: number) => {
                Row({ space: 16 }) {
                  // 专辑封面
                  if (MusicApiService.isValidImageUrl(album.image || '')) {
                    Image(album.image)
                      .width(60)
                      .height(60)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                  } else {
                    // 渐变色占位符
                    Row() {}
                      .width(60)
                      .height(60)
                      .borderRadius(8)
                      .linearGradient({
                        angle: 45,
                        colors: [
                          [this.getGradientColors(index)[0], 0.0],
                          [this.getGradientColors(index)[1], 1.0]
                        ]
                      })
                  }

                  // 专辑信息
                  Column({ space: 4 }) {
                    Text(album.title || '未知专辑')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    if (album.playcount) {
                      Text(`${this.formatNumber(album.playcount)} 播放`)
                        .fontSize(14)
                        .fontColor(this.textSecondary)
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  // 箭头图标
                  Image($r('app.media.arrow_right'))
                    .width(20)
                    .height(20)
                    .fillColor(this.textSecondary)
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                .backgroundColor(this.secondaryColor + '40')
                .borderRadius(12)
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  this.navigateToRecord(album);
                })
              })
            }
          } else if (!this.isLoadingAlbums) {
            Text('暂无专辑信息')
              .fontSize(16)
              .fontColor(this.textSecondary)
              .textAlign(TextAlign.Center)
              .padding(32)
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .padding({ left: 24, right: 24, top: 24, bottom: 100 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .fillColor(this.textPrimary)
          .onClick(() => this.goBack())

        Text('艺术家详情')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位符，保持标题居中
        Row() {}
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.bgColor)
      .alignItems(VerticalAlign.Center)

      // 主要内容
      if (this.isLoading) {
        this.LoadingContent()
      } else if (this.errorMessage) {
        this.ErrorContent()
      } else {
        this.ArtistContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }
}
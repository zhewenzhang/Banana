import router from '@ohos.router';

// 定义数据接口
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
  @State currentTab: number = 0;

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';

  // 热门唱片数据（添加一些测试数据，包含无效图片URL）
  private trendingRecords: RecordItem[] = [
    {
      title: 'To Pimp a Butterfly',
      artist: 'Kendrick Lamar',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDAet2JfK8LXN03CmGuqZVj0UjHXbIYhJqQmmgmh3bjJ8SrXLg7Pmo3XiY1IMLF4cYosQdFkLMdey3kTlXmIfKMWMfZIvXcHmUCGtZCmUvsuGuYYKkHXiqN9xBIdLTSqXV5-FotcFi44khMtVRBpSC52aTXWrNbJwpxCN1jECk_BRWHMO27RqrpZW3BovL73j-KqLwxOg7j7peWzUb7PILwjQz49FKIAp89OJpXx_-2OX6hG1oYbHESksVt8yafOy8y08gpxctWc0I'
    },
    {
      title: 'Is This It',
      artist: 'The Strokes',
      image: '' // 测试空图片URL
    },
    {
      title: 'Discovery',
      artist: 'Daft Punk',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDEs1Rr0JPEiuFCOrDN4D6zYVm4nn7ZYsI4npm_HeCoT0gwZGK8-Si-ePV3BRjBQAveEpoHNjJSY04O71dT677kOlcbcBGDPto8sHYpZjEsbegjh-XyXN0PFc-YhTFUmVHdlHKLHXZm7kUd-MU2eW7j1M5uWAOkVxx3H1FxmIyPQA2f-Nl93ezjbqV1FOed0viHd3hDh5_0Qq6ygxBBuCEf1kVvUMgbtxlR7UGTe9m3dwNtTloVeHS_ZGcNeyN_CCDVyQ_gIlU5Ds0'
    },
    {
      title: 'Test Album',
      artist: 'Test Artist',
      image: 'invalid-url' // 测试无效图片URL
    }
  ];

  // 生成渐变色占位符的方法
  private getGradientColors(index: number): string[] {
    const gradients = [
      ['#FF6B6B', '#4ECDC4'], // 红到青
      ['#A8E6CF', '#FFD93D'], // 绿到黄
      ['#FF8A80', '#FF80AB'], // 粉红渐变
      ['#81C784', '#4FC3F7'], // 绿到蓝
      ['#FFB74D', '#F06292'], // 橙到粉
      ['#9575CD', '#64B5F6'], // 紫到蓝
    ];
    return gradients[index % gradients.length];
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
  // 流行艺术家数据（添加测试数据，包含无效图片URL）
  private popularArtists: ArtistItem[] = [
    {
      name: 'Kendrick Lamar',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCi5-XJKKDPfhWcaRAR3L3BSL8jW3cxG4_ciRsvXuyaDDO96xM3gI_Xp9w9U27YNAED7ZzDtSLyCb5BUyka6moK0WMAbhWSRh0-6xgmU55kszfWjM13eSSuNxXE5tgadT0ebg7AWqI8KL9DW_n95_PFqYw_xTn0D5T16I0Khv8oGCm0MG2iRp5k-6imjiIwVyKgeETXnill37XleUutzvg25ObZkekbwM34XITGFPuJksJsvcUSOrAh-P6MaYRoe8NY1QTDFiZ_VcA'
    },
    {
      name: 'The Strokes',
      image: '' // 测试空图片URL
    },
    {
      name: 'Daft Punk',
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA2MSHItzeERnZWA-8zC7DNd6HueQB5kXG9aNLAMd4cEmcNPe1yOGhC4Ow3Cxw1zGFzXVYoZ4G2bV6l4YGE7ScglYLPB2BPS-DLzddxDHNAH3-Y0F0WI85BmXg7XzJRsqUnJQBCQIE3_d7xw-VD_CbCgLsig4e5SnS7BNI4zrbNRylGL8Cp1523qkxk2RQRerXfgbKQJdNbUiAsfIQVu3EkD9OHvVt5qyGa9ovAoaol5UZoJVq2gs6OF6k-DWDz84lZaXHk--3tlrc'
    },
    {
      name: 'Test Artist',
      image: 'invalid-url' // 测试无效图片URL
    }
  ];

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
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Scroll() {
              Row({ space: 16 }) {
                ForEach(this.trendingRecords, (record: RecordItem, index: number) => {
                  Column({ space: 8 }) {
                    // 图片或渐变色占位符
                    if (this.isValidImageUrl(record.image)) {
                      Image(record.image)
                        .width(144)
                        .height(144)
                        .borderRadius(8)
                        .objectFit(ImageFit.Cover)
                    } else {
                      // 渐变色占位符
                      Row() {}
                        .width(144)
                        .height(144)
                        .borderRadius(8)
                        .linearGradient({
                          angle: 45,
                          colors: [
                            [this.getGradientColors(index)[0], 0.0],
                            [this.getGradientColors(index)[1], 1.0]
                          ]
                        })
                    }

                    Column({ space: 4 }) {
                      Text(record.title)
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
                })
              }
              .padding({ left: 16, right: 16 })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .margin({ left: -16, right: -16 })
          }

          // 流行艺术家区域
          Column({ space: 16 }) {
            Row() {
              Text('热门艺术家')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.textPrimary)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)

            Column({ space: 16 }) {
              ForEach(this.popularArtists, (artist: ArtistItem, index: number) => {
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
                    Text(artist.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.textPrimary)

                    Text('Artist')
                      .fontSize(14)
                      .fontColor(this.textSecondary)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Image($r('app.media.person'))
                    .width(24)
                    .height(24)
                    .fillColor(this.textSecondary)
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  console.log('Clicked artist:', artist.name);
                })
              })
            }
          }
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部导航栏
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
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
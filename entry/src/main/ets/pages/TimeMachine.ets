import router from '@ohos.router';

// 定义价值排行榜唱片接口
interface ValueRankingRecord {
  id: number;
  rank: number;
  title: string;
  artist: string;
  thumb?: string;
  year?: string;
  genre?: string[];
  format?: string[];
  estimatedValue: number; // 估值（美元）
  priceChange: number; // 价格变化百分比
}

@Entry
@Component
struct TimeMachine {
  @State currentTab: number = 2; // TimeMachine页面对应tab 2
  @State topValueRecords: ValueRankingRecord[] = [];
  @State isLoading: boolean = true;

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#9393c8';
  private cardBgColor: string = '#1e1e2e';
  private goldColor: string = '#FFD700';
  private silverColor: string = '#C0C0C0';
  private bronzeColor: string = '#CD7F32';

  aboutToAppear() {
    this.loadTopValueRecords();
  }

  // 加载价值最高的唱片数据（模拟数据）
  private loadTopValueRecords(): void {
    // 模拟加载延迟
    setTimeout(() => {
      this.topValueRecords = this.generateMockValueRecords();
      this.isLoading = false;
    }, 1000);
  }

  // 生成模拟的高价值唱片数据
  private generateMockValueRecords(): ValueRankingRecord[] {
    const mockRecords: ValueRankingRecord[] = [
      {
        id: 1, rank: 1, title: 'The Velvet Underground & Nico', artist: 'The Velvet Underground & Nico',
        thumb: '', year: '1967', genre: ['Rock', 'Art Rock'],
        format: ['Vinyl', 'LP'], estimatedValue: 25000, priceChange: 15.2
      },
      {
        id: 2, rank: 2, title: 'Led Zeppelin', artist: 'Led Zeppelin',
        thumb: '', year: '1969', genre: ['Rock', 'Hard Rock'],
        format: ['Vinyl', 'LP'], estimatedValue: 18500, priceChange: 8.7
      },
      {
        id: 3, rank: 3, title: 'Please Please Me', artist: 'The Beatles',
        thumb: '', year: '1963', genre: ['Pop', 'Rock'],
        format: ['Vinyl', 'LP'], estimatedValue: 15000, priceChange: -2.1
      },
      {
        id: 4, rank: 4, title: 'The Freewheelin\' Bob Dylan', artist: 'Bob Dylan',
        thumb: '', year: '1963', genre: ['Folk', 'Rock'],
        format: ['Vinyl', 'LP'], estimatedValue: 12800, priceChange: 12.3
      },
      {
        id: 5, rank: 5, title: 'My Generation', artist: 'The Who',
        thumb: '', year: '1965', genre: ['Rock', 'Mod'],
        format: ['Vinyl', 'LP'], estimatedValue: 11200, priceChange: 5.9
      }
    ];

    // 定义专辑数据接口
    interface AlbumData {
      title: string;
      artist: string;
    }

    // 使用一些真实的专辑名称和艺术家名称作为示例
    const albumData: AlbumData[] = [
      { title: "Pet Sounds", artist: "The Beach Boys" },
      { title: "Revolver", artist: "The Beatles" },
      { title: "Kind of Blue", artist: "Miles Davis" },
      { title: "The Dark Side of the Moon", artist: "Pink Floyd" },
      { title: "Abbey Road", artist: "The Beatles" },
      { title: "Led Zeppelin IV", artist: "Led Zeppelin" },
      { title: "Thriller", artist: "Michael Jackson" },
      { title: "Nevermind", artist: "Nirvana" },
      { title: "OK Computer", artist: "Radiohead" }
    ];

    // 生成更多数据到50名
    for (let i = 6; i <= 50; i++) {
      const albumInfo = albumData[(i - 6) % albumData.length];
      mockRecords.push({
        id: i,
        rank: i,
        title: `${albumInfo.title} ${i > 15 ? `(Rare Edition ${i})` : ''}`,
        artist: albumInfo.artist,
        thumb: '', // 暂时设为空，使用占位符
        year: `${1960 + Math.floor(Math.random() * 40)}`,
        genre: [['Rock'], ['Pop'], ['Jazz'], ['Blues'], ['Electronic']][Math.floor(Math.random() * 5)],
        format: [['Vinyl'], ['LP'], ['EP'], ['7"']][Math.floor(Math.random() * 4)],
        estimatedValue: Math.floor(10000 - (i * 150) + Math.random() * 1000),
        priceChange: (Math.random() - 0.5) * 20
      });
    }

    return mockRecords;
  }

  // 获取排名颜色
  private getRankColor(rank: number): string {
    if (rank === 1) return this.goldColor;
    if (rank === 2) return this.silverColor;
    if (rank === 3) return this.bronzeColor;
    return this.textSecondary;
  }

  // 格式化价格
  private formatPrice(value: number): string {
    if (value >= 1000) {
      return `$${(value / 1000).toFixed(1)}K`;
    }
    return `$${value}`;
  }

  // 跳转到唱片详情页面
  private goToRecordDetail(recordId: number): void {
    router.pushUrl({
      url: 'pages/RecordDetail',
      params: {
        recordId: recordId
      }
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.arrow_back'))
          .width(24)
          .height(24)
          .fillColor(this.textPrimary)
          .onClick(() => {
            router.back();
          })

        Text('价值排行榜')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位符保持对称
        Row().width(24).height(24)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.bgColor)

      // 主要内容区域
      if (this.isLoading) {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(this.primaryColor)
          
          Text('加载排行榜中...')
            .fontSize(16)
            .fontColor(this.textSecondary)
            .margin({ top: 16 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 排行榜内容
        Column() {
          // 排行榜标题
          Row() {
            Text('目前价值最高的唱片')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.textPrimary)
            
            Text('TOP 50')
              .fontSize(14)
              .fontColor(this.goldColor)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .backgroundColor(this.goldColor + '20')
              .borderRadius(4)
              .margin({ left: 8 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 8 })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          // 排行榜列表
          Scroll() {
            Column({ space: 8 }) {
              ForEach(this.topValueRecords, (record: ValueRankingRecord) => {
                Row({ space: 12 }) {
                  // 排名显示
                  Column() {
                    Text(`${record.rank}`)
                      .fontSize(record.rank <= 3 ? 20 : 16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.getRankColor(record.rank))
                  }
                  .width(40)
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)

                  // 唱片封面 - 只有当有封面数据时才显示
                  if (record.thumb && record.thumb.trim() !== '') {
                    Image(record.thumb)
                      .width(60)
                      .height(60)
                      .borderRadius(6)
                      .objectFit(ImageFit.Cover)
                      .onError(() => {
                        // 如果图片加载失败，可以在这里处理
                        console.log(`封面图片加载失败: ${record.thumb}`);
                      })
                  } else {
                    // 没有封面时显示占位符，保持布局一致
                    Column()
                      .width(60)
                      .height(60)
                      .borderRadius(6)
                      .backgroundColor(this.cardBgColor)
                      .justifyContent(FlexAlign.Center)
                      .alignItems(HorizontalAlign.Center)
                      .border({ width: 1, color: this.secondaryColor + '40' }) {
                      Text('♪')
                        .fontSize(24)
                        .fontColor(this.textSecondary)
                    }
                  }

                  // 唱片信息
                  Column({ space: 4 }) {
                    Text(record.title)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.textPrimary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(record.artist)
                      .fontSize(12)
                      .fontColor(this.textSecondary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Row({ space: 6 }) {
                      if (record.year) {
                        Text(record.year)
                          .fontSize(10)
                          .fontColor(this.textSecondary)
                          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                          .backgroundColor(this.secondaryColor + '60')
                          .borderRadius(3)
                      }

                      if (record.format && record.format.length > 0) {
                        Text(record.format[0])
                          .fontSize(10)
                          .fontColor(this.textSecondary)
                          .padding({ left: 4, right: 4, top: 1, bottom: 1 })
                          .backgroundColor(this.secondaryColor + '60')
                          .borderRadius(3)
                      }
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .justifyContent(FlexAlign.Start)

                  // 价值信息
                  Column({ space: 2 }) {
                    Text(this.formatPrice(record.estimatedValue))
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.primaryColor)

                    Row({ space: 4 }) {
                      Text(record.priceChange >= 0 ? '↗' : '↘')
                        .fontSize(12)
                        .fontColor(record.priceChange >= 0 ? '#00FF88' : '#FF4444')

                      Text(`${Math.abs(record.priceChange).toFixed(1)}%`)
                        .fontSize(10)
                        .fontColor(record.priceChange >= 0 ? '#00FF88' : '#FF4444')
                    }
                    .alignItems(VerticalAlign.Center)
                  }
                  .alignItems(HorizontalAlign.End)
                  .justifyContent(FlexAlign.Center)

                  // 箭头图标
                  Image($r('app.media.arrow_right'))
                    .width(12)
                    .height(12)
                    .fillColor(this.textSecondary)
                }
                .width('100%')
                .padding(12)
                .backgroundColor(this.cardBgColor)
                .borderRadius(8)
                .alignItems(VerticalAlign.Center)
                .onClick(() => {
                  this.goToRecordDetail(record.id);
                })
              }, (record: ValueRankingRecord) => record.id.toString())
            }
            .padding({ left: 16, right: 16, bottom: 100 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
        .layoutWeight(1)
      }

      // 底部导航栏
      Row() {
        // 搜唱片
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

        // 唱片墙
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

        // 时光机 (当前页面)
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
          // 当前页面，无需跳转
        })

        // 个人资料
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
      .backgroundColor(this.bgColor)
      .padding({ top: 8, bottom: 8 })
      .border({
        width: { top: 1 },
        color: this.secondaryColor + '40'
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
  }
}
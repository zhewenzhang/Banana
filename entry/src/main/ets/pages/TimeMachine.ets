import router from '@ohos.router';
import { ValueRankingRecord } from '../models/RecordModels';
import { DiscogsService } from '../services/DiscogsService';
import { ApiConfig } from '../common/ApiConfig';

@Entry
@Component
struct TimeMachine {
  @State currentTab: number = 2; // TimeMachine页面对应tab 2
  @State private topValueRecords: ValueRankingRecord[] = [];
  @State private isLoading: boolean = false;
  @State private errorMessage: string = '';

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

  aboutToAppear(): void {
    this.loadTopValueRecords();
  }

  // 加载价值最高的唱片数据
  private async loadTopValueRecords(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';
    
    try {
      // 检查是否配置了API Token
      const hasApiToken: boolean = ApiConfig.hasDiscogsToken();
      
      if (!hasApiToken) {
        this.errorMessage = '未配置 Discogs API Token，请先配置后使用';
        console.error('未配置API Token');
        return;
      }

      console.log('使用 Discogs API 获取高价值唱片数据');
      const apiRecords = await DiscogsService.getValueRankingRecords(1, 50);
      
      if (apiRecords && apiRecords.length > 0) {
        this.topValueRecords = apiRecords.map((record, index) => {
          const mappedRecord: ValueRankingRecord = {
            rank: index + 1,
            id: parseInt(record.id) || index + 1, // 将字符串id转换为数字，如果转换失败则使用索引
            title: record.title,
            artist: record.artist,
            year: record.year,
            estimatedValue: this.generateEstimatedValue(index),
            priceChange: (Math.random() - 0.5) * 20,
            thumb: record.coverImage, // LocalRecord使用coverImage属性而不是thumb
            genre: record.genre ? [record.genre] : undefined,
            format: record.label ? [record.label] : undefined
          };
          return mappedRecord;
        });
        console.log('成功获取API数据:', this.topValueRecords.length, '条记录');
      } else {
        throw new Error('API返回数据为空');
      }
    } catch (error) {
      console.error('加载价值排行榜数据失败:', error);
      const errorMsg = error instanceof Error ? error.message : '未知错误';
      this.errorMessage = `数据加载失败: ${errorMsg}，请检查网络连接或API配置`;
      this.topValueRecords = []; // 清空数据
    } finally {
      this.isLoading = false;
    }
  }

  // 生成估计价值（基於排名）
  private generateEstimatedValue(index: number): number {
    // 为Top50提供更丰富的价值分布
    if (index < 5) {
      const topValues: number[] = [25000, 18500, 15000, 12800, 11200];
      return topValues[index];
    } else if (index < 10) {
      return 10000 - (index - 5) * 800; // 10000-6600
    } else if (index < 20) {
      return 6000 - (index - 10) * 300; // 6000-3000
    } else if (index < 30) {
      return 3000 - (index - 20) * 100; // 3000-2000
    } else if (index < 40) {
      return 2000 - (index - 30) * 50; // 2000-1500
    } else {
      return 1500 - (index - 40) * 30; // 1500-1200
    }
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

  // 刷新數據
  private refreshData(): void {
    this.loadTopValueRecords();
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

        Text('价值排行榜 Top50')
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
          // 排行榜标题 - 移到顶部
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
          .padding({ left: 16, right: 16, top: 16, bottom: 12 })
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)

          // 错误信息显示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor('#FF6B6B')
              .padding({ left: 16, right: 16, bottom: 8 })
              .width('100%')
              .textAlign(TextAlign.Start)
          }

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
                    Column() {
                      Text('♪')
                        .fontSize(24)
                        .fontColor(this.textSecondary)
                    }
                    .width(60)
                    .height(60)
                    .borderRadius(6)
                    .backgroundColor(this.cardBgColor)
                    .justifyContent(FlexAlign.Center)
                    .alignItems(HorizontalAlign.Center)
                    .border({ width: 1, color: this.secondaryColor + '40' })
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
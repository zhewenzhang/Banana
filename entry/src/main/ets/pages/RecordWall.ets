import router from '@ohos.router';
import { DiscogsService } from '../services/DiscogsService';
import { LocalRecord } from '../models/RecordModels';

@Entry
@Component
struct RecordWall {
  @State currentTab: number = 1; // RecordWall页面对应tab 1
  @State records: LocalRecord[] = []; // 唱片數據
  @State isLoading: boolean = true; // 加載狀態
  @State isLoadingMore: boolean = false; // 加载更多状态
  @State scrollOffset: number = 0; // 滾動偏移量
  @State currentPage: number = 1; // 当前页码
  @State hasMoreData: boolean = true; // 是否还有更多数据
  @State clickedCardId: string = ''; // 被点击的卡片ID，用于点击反馈动画

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#9393c8';

  // 組件生命週期
  async aboutToAppear() {
    await this.loadRecords();
    this.startAutoScroll();
  }

  // 加載唱片數據
  private async loadRecords(page: number = 1, append: boolean = false): Promise<void> {
    try {
      if (append) {
        this.isLoadingMore = true;
      } else {
        this.isLoading = true;
      }
      
      const recordData = await DiscogsService.getPopularRecords(page, 20); // 每页20笔数据
      
      if (append) {
        // 追加数据（加载更多）
        this.records = [...this.records, ...recordData];
      } else {
        // 替换数据（初始加载）
        this.records = recordData;
      }
      
      // 检查是否还有更多数据
      this.hasMoreData = recordData.length >= 20;
      this.currentPage = page;
    } catch (error) {
      console.error('加载唱片数据失败:', error);
    } finally {
      if (append) {
        this.isLoadingMore = false;
      } else {
        this.isLoading = false;
      }
    }
  }

  // 加载更多数据
  private async loadMoreRecords(): Promise<void> {
    if (!this.hasMoreData || this.isLoadingMore) {
      return;
    }
    
    await this.loadRecords(this.currentPage + 1, true);
  }

  // 開始自動滾動
  private startAutoScroll(): void {
    setInterval(() => {
      this.scrollOffset += 0.5; // 每次增加0.5px，實現慢速滾動
      if (this.scrollOffset >= 200) { // 當滾動到一定距離時重置
        this.scrollOffset = 0;
      }
    }, 50); // 每50ms更新一次
  }

  // 跳转到唱片详情页面
  private navigateToDetail(record: LocalRecord): void {
    try {
      // 将string类型的id转换为number类型
      const recordId = parseInt(record.id);
      if (isNaN(recordId)) {
        console.error('无效的唱片ID:', record.id);
        return;
      }

      // 跳转到详情页面，传递recordId参数
      router.pushUrl({
        url: 'pages/RecordDetail',
        params: {
          recordId: recordId
        }
      }).then(() => {
        console.log(`成功跳转到唱片详情页面: ${record.title} (ID: ${recordId})`);
      }).catch((error: Error) => {
        console.error('跳转详情页面失败:', error);
      });
    } catch (error) {
      console.error('处理唱片详情跳转时发生错误:', error);
    }
  }

  // 唱片卡片組件
  @Builder
  private RecordCard(record: LocalRecord, index: number) {
    Column() {
      // 唱片封面 - 添加调试日志和错误处理
      Image(record.coverImage || $r('app.media.placeholder_album'))
        .width('100%')
        .aspectRatio(1) // 正方形比例
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#2a2a3e')
        .onComplete(() => {
          console.log(`封面图片加载成功: ${record.title} - ${record.coverImage}`);
        })
        .onError(() => {
          console.error(`封面图片加载失败: ${record.title} - ${record.coverImage}`);
        })
        .alt($r('app.media.placeholder_album')) // 设置备用图片

      // 唱片信息
      Column({ space: 4 }) {
        Text(record.title)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(record.artist)
          .fontSize(10)
          .fontColor(this.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Text(record.year)
          .fontSize(9)
          .fontColor(this.textSecondary)
          .width('100%')
      }
      .alignItems(HorizontalAlign.Start)
      .padding({ top: 8 })
    }
    .width('100%')
    .padding(8)
    .backgroundColor('#1a1a2e')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#000000',
      offsetX: 0,
      offsetY: 2
    })
    // 添加点击事件处理
    .onClick(() => {
      this.navigateToDetail(record);
    })
    // 添加点击反馈动画
    .animation({
      duration: 150,
      curve: Curve.EaseInOut
    })
    .scale({
      x: this.clickedCardId === record.id ? 0.95 : 1.0,
      y: this.clickedCardId === record.id ? 0.95 : 1.0
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.clickedCardId = record.id;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.clickedCardId = '';
      }
    })
  }

  // 瀑布流布局組件
  @Builder
  private WaterfallLayout() {
    if (this.isLoading) {
      // 加載狀態
      Column() {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(this.primaryColor)

        Text('正在加载唱片...')
          .fontSize(14)
          .fontColor(this.textSecondary)
          .margin({ top: 16 })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .height(300)
    } else {
      // 瀑布流內容 - 添加自動滾動效果
      Scroll() {
        Column() {
          // 使用Grid實現2列布局
          Grid() {
            ForEach(this.records, (record: LocalRecord, index: number) => {
              GridItem() {
                Column() {
                  this.RecordCard(record, index)
                }
                .opacity(1)
                .scale({ x: 1, y: 1 })
                .transform({ translateY: this.scrollOffset * (index % 2 === 0 ? 1 : -1) }) // 交替滾動方向
                .animation({
                  duration: 300,
                  curve: Curve.EaseOut
                })
              }
              .transition({
                type: TransitionType.Insert,
                opacity: 0,
                scale: { x: 0.8, y: 0.8 },
                translate: { y: 50 }
              })
              .animation({
                duration: 400,
                curve: Curve.EaseOut
              })
            })
          }
          .columnsTemplate('1fr 1fr') // 2列等寬
          .rowsGap(12)
          .columnsGap(12)
          .padding({ left: 16, right: 16, top: 16, bottom: 100 })

          // 底部間距，避免被導航欄遮擋
          Row().height(100)
          
          // 加载更多指示器
          if (this.isLoadingMore) {
            Column() {
              LoadingProgress()
                .width(30)
                .height(30)
                .color(this.primaryColor)
              
              Text('加载更多...')
                .fontSize(12)
                .fontColor(this.textSecondary)
                .margin({ top: 8 })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .opacity(1)
            .animation({
              duration: 300,
              curve: Curve.EaseInOut
            })
          } else if (this.hasMoreData && this.records.length > 0) {
            // 显示"加载更多"按钮
            Button('加载更多')
              .width(120)
              .height(36)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor(this.primaryColor)
              .borderRadius(18)
              .margin({ top: 16, bottom: 16 })
              .opacity(1)
              .scale({ x: 1, y: 1 })
              .animation({
                duration: 300,
                curve: Curve.EaseInOut
              })
              .onClick(() => {
                this.loadMoreRecords();
              })
          } else if (!this.hasMoreData && this.records.length > 0) {
            // 没有更多数据时显示提示
            Text('已加载全部唱片')
              .fontSize(12)
              .fontColor(this.textSecondary)
              .margin({ top: 16, bottom: 16 })
              .textAlign(TextAlign.Center)
              .width('100%')
              .opacity(0.8)
              .animation({
                duration: 500,
                curve: Curve.EaseInOut
              })
          }
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1)
      .onScrollEdge((side: Edge) => {
        // 滑动到底部时自动加载更多数据
        if (side === Edge.Bottom && this.hasMoreData && !this.isLoadingMore) {
          console.log('触发自动加载更多');
          this.loadMoreRecords();
        }
      })
      .onScroll((xOffset: number, yOffset: number) => {
        // 滚动监听，可以用于优化用户体验
        // 这里可以添加滚动相关的动画效果
      })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
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

          Text('唱片墙')
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
        .backgroundColor(this.bgColor + 'CC')

        // 主要内容区域 - 瀑布流
        this.WaterfallLayout()
      }
      .width('100%')
      .height('100%')

      // 底部导航栏 - 使用Stack固定在底部
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
      .backgroundColor('#12121e')
      .border({ width: { top: 1 }, color: this.secondaryColor + '80' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
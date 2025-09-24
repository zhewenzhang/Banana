import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State private searchText: string = '';
  @State private currentTab: number = 0;

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private accentColor: string = '#4ECDC4';

  // 搜索方法
  private searchRecords(): void {
    if (!this.searchText?.trim()) {
      return;
    }

    try {
      router.pushUrl({
        url: 'pages/SearchResults',
        params: {
          query: this.searchText.trim()
        }
      });
    } catch (error) {
      console.error('搜索跳转失败:', error);
    }
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
        Column({ space: 24 }) {
          // 搜索区域 - 放在中部偏上位置
          this.SearchSection()
        }
        .padding({ top: 40, bottom: 80 })
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

  // 主搜索区域
  @Builder
  private SearchSection() {
    Column({ space: 20 }) {
      // 标题
      Text('音乐收藏搜索')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary)
        .textAlign(TextAlign.Center)

      // 搜索框
      Row() {
        TextInput({ placeholder: '搜索艺术家、专辑或歌曲...', text: this.searchText })
          .fontSize(16)
          .fontColor(this.textPrimary)
          .backgroundColor('#2a2a3e')
          .borderRadius(12)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .placeholderColor(this.textSecondary)
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.searchRecords();
          })
          .layoutWeight(1)

        Button('搜索')
          .fontSize(16)
          .fontColor(this.primaryColor)
          .backgroundColor(this.accentColor)
          .borderRadius(12)
          .padding({ left: 20, right: 20, top: 12, bottom: 12 })
          .margin({ left: 12 })
          .onClick(() => {
            this.searchRecords();
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 24, bottom: 24 })
  }

  // 底部导航栏
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

        Text('我的')
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.currentTab === 3 ? this.primaryColor : this.textSecondary)
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTab = 3;
        // 导航到个人页面
        router.pushUrl({ url: 'pages/Profile' });
      })
    }
    .width('100%')
    .height(60)
    .backgroundColor(this.bgColor)
    .padding({ top: 8, bottom: 8 })
    .justifyContent(FlexAlign.SpaceAround)
    .alignItems(VerticalAlign.Center)
  }
}
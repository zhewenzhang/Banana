import router from '@ohos.router';

@Entry
@Component
struct SearchPage {
  @State currentTab: number = 0; // Search页面对应tab 0

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#9393c8';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('搜唱片')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.bgColor + 'CC')

      // 主要内容区域
      Column() {
        Text('搜索功能')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .margin({ top: 100 })

        Text('这里将显示搜索界面')
          .fontSize(16)
          .fontColor(this.textSecondary)
          .margin({ top: 20 })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

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
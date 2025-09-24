// 收藏页面 - 显示用户的收藏唱片列表
import router from '@ohos.router';
import { FavoriteService } from '../services/FavoriteService';
import { AuthService } from '../services/AuthService';
import { FavoriteRecord } from '../common/UserTypes';

@Entry
@Component
struct FavoritesPage {
  @State private favoriteRecords: FavoriteRecord[] = [];
  @State private isLoading: boolean = true;
  @State private errorMessage: string = '';
  
  private favoriteService: FavoriteService = FavoriteService.getInstance();
  private authService: AuthService = AuthService.getInstance();

  // 颜色主题
  private primaryColor: string = '#FF6B35';
  private backgroundColor: string = '#F5F5F5';
  private cardBackgroundColor: string = '#FFFFFF';
  private textPrimaryColor: string = '#333333';
  private textSecondaryColor: string = '#666666';

  aboutToAppear() {
    this.loadFavorites();
  }

  // 加载收藏列表
  private async loadFavorites(): Promise<void> {
    console.log('=== FavoritesPage loadFavorites 开始 ===');
    
    try {
      this.isLoading = true;
      this.errorMessage = '';

      // 检查登录状态
    const isLoggedIn = await this.authService.isLoggedIn();
      if (!isLoggedIn) {
        this.errorMessage = '请先登录';
        this.isLoading = false;
        return;
      }

      // 获取用户信息
      const userData = await this.authService.getCurrentUserData();
      if (!userData?.id) {
        this.errorMessage = '获取用户信息失败';
        this.isLoading = false;
        return;
      }

      // 获取收藏列表
      const favorites = await this.favoriteService.getUserFavorites(userData.id);
      this.favoriteRecords = favorites;
      
      console.log('收藏列表加载完成，数量:', favorites.length);

    } catch (error) {
      console.error('加载收藏列表失败:', error);
      this.errorMessage = '加载收藏列表失败';
    } finally {
      this.isLoading = false;
    }
  }

  // 跳转到唱片详情页
  private goToRecordDetail(recordId: number): void {
    router.pushUrl({
      url: 'pages/RecordDetail',
      params: { recordId: recordId }
    });
  }

  // 返回上一页
  private goBack(): void {
    router.back();
  }

  // 刷新收藏列表
  private async refreshFavorites(): Promise<void> {
    await this.loadFavorites();
  }

  @Builder
  private FavoriteRecordCard(record: FavoriteRecord) {
    Row() {
      // 封面图片
      Image(record.coverImageUrl || '')
        .width(80)
        .height(80)
        .borderRadius(8)
        .backgroundColor('#F0F0F0')
        .alt('唱片封面')

      // 唱片信息
      Column() {
        Text(record.title || '未知标题')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimaryColor)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)

        Text(record.artist || '未知艺术家')
          .fontSize(14)
          .fontColor(this.textSecondaryColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ top: 4 })

        if (record.year) {
          Text(`${record.year}年`)
            .fontSize(12)
            .fontColor(this.textSecondaryColor)
            .margin({ top: 4 })
        }

        Text(`收藏于 ${new Date(record.createdAt || '').toLocaleDateString()}`)
          .fontSize(12)
          .fontColor(this.textSecondaryColor)
          .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })

      // 箭头图标
      Image($r('app.media.ic_arrow_right'))
        .width(20)
        .height(20)
        .fillColor(this.textSecondaryColor)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.cardBackgroundColor)
    .borderRadius(12)
    .shadow({
      radius: 4,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.goToRecordDetail(record.recordId);
    })
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor(this.textPrimaryColor)
          .onClick(() => {
            this.goBack();
          })

        Text('我的收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimaryColor)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Image($r('app.media.ic_refresh'))
          .width(24)
          .height(24)
          .fillColor(this.textPrimaryColor)
          .onClick(() => {
            this.refreshFavorites();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor(this.cardBackgroundColor)

      // 内容区域
      if (this.isLoading) {
        // 加载中状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(this.primaryColor)

          Text('加载中...')
            .fontSize(14)
            .fontColor(this.textSecondaryColor)
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.backgroundColor)

      } else if (this.errorMessage) {
        // 错误状态
        Column() {
          Image($r('app.media.ic_error'))
            .width(60)
            .height(60)
            .fillColor(this.textSecondaryColor)

          Text(this.errorMessage)
            .fontSize(16)
            .fontColor(this.textSecondaryColor)
            .margin({ top: 16 })

          Button('重试')
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor(this.primaryColor)
            .borderRadius(20)
            .padding({ left: 24, right: 24, top: 8, bottom: 8 })
            .margin({ top: 16 })
            .onClick(() => {
              this.loadFavorites();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.backgroundColor)

      } else if (this.favoriteRecords.length === 0) {
        // 空状态
        Column() {
          Image($r('app.media.ic_favorite_empty'))
            .width(80)
            .height(80)
            .fillColor(this.textSecondaryColor)

          Text('暂无收藏')
            .fontSize(18)
            .fontColor(this.textPrimaryColor)
            .margin({ top: 16 })

          Text('去发现一些喜欢的唱片吧')
            .fontSize(14)
            .fontColor(this.textSecondaryColor)
            .margin({ top: 8 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.backgroundColor)

      } else {
        // 收藏列表
        List() {
          ForEach(this.favoriteRecords, (record: FavoriteRecord, index: number) => {
            ListItem() {
              this.FavoriteRecordCard(record)
            }
            .margin({ 
              top: index === 0 ? 16 : 8, 
              bottom: index === this.favoriteRecords.length - 1 ? 16 : 0,
              left: 16,
              right: 16
            })
          })
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor(this.backgroundColor)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.backgroundColor)
  }
}
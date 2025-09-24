import { router } from '@kit.ArkUI';
import { StorageManager } from '../services/StorageManager';

@Entry
@Component
struct ClearStoragePage {
  @State private isClearing: boolean = false;
  @State private clearResult: string = '';

  // 强制清除所有本地存储数据
  private async clearAllStorage() {
    this.isClearing = true;
    this.clearResult = '';

    try {
      const storageManager = StorageManager.getInstance();
      await storageManager.forceCleanStorage();
      
      this.clearResult = '✅ 本地存储数据已清除成功！\n请重新登录以获取正确的用户数据。';
      
      console.log('强制清除存储完成');
    } catch (error) {
      console.error('清除存储失败:', error);
      this.clearResult = '❌ 清除失败，请重试。';
    } finally {
      this.isClearing = false;
    }
  }

  // 返回首页
  private goHome() {
    router.replaceUrl({
      url: 'pages/Index'
    });
  }

  build() {
    Column({ space: 32 }) {
      // 标题
      Text('清除本地数据')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')

      // 说明文字
      Column({ space: 16 }) {
        Text('如果遇到用户ID为undefined的问题，请点击下方按钮清除旧的本地存储数据。')
          .fontSize(16)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
          .lineHeight(24)

        Text('清除后需要重新登录。')
          .fontSize(14)
          .fontColor('#999999')
          .textAlign(TextAlign.Center)
      }

      // 清除按钮
      Button() {
        Row({ space: 8 }) {
          if (this.isClearing) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color('#ffffff')
          }
          
          Text(this.isClearing ? '清除中...' : '清除本地数据')
            .fontSize(16)
            .fontColor('#ffffff')
        }
      }
      .width('80%')
      .height(48)
      .backgroundColor('#ff4757')
      .borderRadius(24)
      .enabled(!this.isClearing)
      .onClick(() => {
        this.clearAllStorage();
      })

      // 结果显示
      if (this.clearResult) {
        Text(this.clearResult)
          .fontSize(14)
          .fontColor(this.clearResult.includes('✅') ? '#27ae60' : '#e74c3c')
          .textAlign(TextAlign.Center)
          .lineHeight(20)
          .padding(16)
          .backgroundColor('#f8f9fa')
          .borderRadius(8)
          .width('100%')
      }

      // 返回按钮
      if (this.clearResult.includes('✅')) {
        Button('返回首页')
          .width('60%')
          .height(40)
          .backgroundColor('#2ecc71')
          .borderRadius(20)
          .onClick(() => {
            this.goHome();
          })
      }
    }
    .width('100%')
    .height('100%')
    .padding(32)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#ffffff')
  }
}
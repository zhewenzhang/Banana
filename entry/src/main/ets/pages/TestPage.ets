import { MusicApiService, ApiRecordItem, ApiArtistItem } from '../services/MusicApiService';

@Entry
@Component
struct TestPage {
  @State private testResults: string[] = [];
  @State private isLoading: boolean = false;
  
  private musicApiService: MusicApiService = new MusicApiService();
  
  // 颜色主题
  private bgColor: string = '#12121e';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#a0a0d0';
  private accentColor: string = '#4ECDC4';

  private async testApiService(): Promise<void> {
    this.isLoading = true;
    this.testResults = [];
    
    try {
      // 测试获取热门唱片
      this.testResults.push('正在测试获取热门唱片...');
      const records = await this.musicApiService.getTrendingRecords();
      this.testResults.push(`✅ 获取到 ${records.length} 张热门唱片`);
      
      if (records.length > 0) {
        const firstRecord = records[0];
        this.testResults.push(`第一张唱片: ${firstRecord?.name || '未知'} - ${firstRecord?.artist || '未知艺术家'}`);
      }
      
      // 测试获取热门艺术家
      this.testResults.push('正在测试获取热门艺术家...');
      const artists = await this.musicApiService.getPopularArtists();
      this.testResults.push(`✅ 获取到 ${artists.length} 位热门艺术家`);
      
      if (artists.length > 0) {
        const firstArtist = artists[0];
        this.testResults.push(`第一位艺术家: ${firstArtist?.name || '未知艺术家'}`);
      }
      
      this.testResults.push('🎉 所有测试通过！');
      
    } catch (error) {
      this.testResults.push(`❌ 测试失败: ${error}`);
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column({ space: 20 }) {
      // 标题
      Text('API 服务测试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.textPrimary)
        .margin({ top: 40 })

      // 测试按钮
      Button('开始测试 API 服务')
        .fontSize(16)
        .backgroundColor(this.accentColor)
        .borderRadius(8)
        .padding({ horizontal: 20, vertical: 12 })
        .onClick(() => {
          this.testApiService();
        })
        .enabled(!this.isLoading)

      // 加载指示器
      if (this.isLoading) {
        Row({ space: 8 }) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(this.accentColor)
          
          Text('测试中...')
            .fontSize(14)
            .fontColor(this.textSecondary)
        }
      }

      // 测试结果
      if (this.testResults.length > 0) {
        Column({ space: 8 }) {
          Text('测试结果:')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.textPrimary)
            .alignSelf(ItemAlign.Start)

          ForEach(this.testResults, (result: string, index: number) => {
            Text(result)
              .fontSize(14)
              .fontColor(this.textSecondary)
              .padding({ horizontal: 16, vertical: 4 })
              .backgroundColor('#1a1a2e')
              .borderRadius(4)
              .width('100%')
              .textAlign(TextAlign.Start)
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .padding(20)
  }
}
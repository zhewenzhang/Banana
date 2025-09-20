import router from '@ohos.router';
import { LoginModal } from '../components/LoginModal';
import { UserData, UserStats } from '../common/UserTypes';

// 用户设置项接口
interface SettingItem {
  icon: string;
  title: string;
  hasToggle?: boolean;
  isToggled?: boolean;
}

@Entry
@Component
struct Profile {
  @State currentTab: number = 3; // Profile页面对应tab 3
  @State isLoggedIn: boolean = false; // 登錄狀態
  @State showLoginModal: boolean = false; // 登錄彈窗顯示狀態
  @State loginModalMode: boolean = true; // 登錄彈窗模式：true=登錄，false=註冊

  // 颜色主题
  private primaryColor: string = '#FFFFFF';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private cardBgColor: string = '#1a1a32';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#9393c8';
  private customBorderColor: string = '#2a2a4a';

  // 用户数据 - 默認為空，登錄後填充
  @State userData: UserData = {
    name: '',
    username: '',
    joinDate: '',
    bio: '',
    avatar: '',
    stats: {
      records: 0,
      followers: 0,
      following: 0
    }
  };

  // 设置选项
  private settingItems: SettingItem[] = [
    { icon: 'notifications', title: 'Notifications', hasToggle: true, isToggled: true },
    { icon: 'lock', title: 'Privacy & Security' },
    { icon: 'visibility', title: 'Appearance' },
    { icon: 'language', title: 'Language & Region' },
    { icon: 'help', title: 'Help & Support' },
    { icon: 'info', title: 'About' }
  ];

  // 生成渐变色占位符的方法
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

  // 检查图片URL是否有效的方法
  private isValidImageUrl(url: string): boolean {
    return !!(url && url.trim() !== '' && (url.startsWith('http') || url.startsWith('https')));
  }

  // 處理登錄成功
  private handleLoginSuccess = (userData: UserData) => {
    this.isLoggedIn = true;
    this.userData = userData;
    this.showLoginModal = false;
    console.log('Login successful:', userData);
  }

  // 處理登出
  private handleLogout = () => {
    this.isLoggedIn = false;
    this.userData = {
      name: '',
      username: '',
      joinDate: '',
      bio: '',
      avatar: '',
      stats: {
        records: 0,
        followers: 0,
        following: 0
      }
    };
    console.log('用戶已登出');
  }

  // 顯示登錄彈窗
  private showLogin = () => {
    this.showLoginModal = true;
  }

  // 構建未登錄狀態的提示頁面
  @Builder
  LoginPromptContent() {

    Column({ space: 32 }) {
      // 提示文字
      Column({ space: 12 }) {
        Text('一起享受胶片吧')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .textAlign(TextAlign.Center)
          .margin({ top: 40 })

        Text('登录后可以收藏和交流唱片信息\n小众爱好的小天地')
          .fontSize(16)
          .fontColor(this.textSecondary)
          .textAlign(TextAlign.Center)
          .lineHeight(24)
      }

      // 登錄和註冊按鈕
      Column({ space: 16 }) {
        Button('登录')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .backgroundColor(this.secondaryColor)
          .borderRadius(8)
          .onClick(() => {
            this.loginModalMode = true; // 设置为登录模式
            this.showLoginModal = true;
          })

        Button('注册')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.primaryColor)
          .backgroundColor('transparent')
          .border({ width: 1, color: this.primaryColor })
          .borderRadius(8)
          .onClick(() => {
            this.loginModalMode = false; // 设置为注册模式
            this.showLoginModal = true;
          })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .padding({ top: 60 })
    .justifyContent(FlexAlign.Center)
  }

  // 構建已登錄狀態的用戶資料頁面
  @Builder
  UserProfileContent() {
    Column({ space: 24 }) {
      // 用户信息区域
      Column({ space: 16 }) {
        // 用户信息
        Column({ space: 4 }) {
          Text(this.userData?.name || '')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textPrimary)

          Text(this.userData?.username || '')
            .fontSize(16)
            .fontColor(this.textSecondary)

          Text(this.userData?.bio || '')
            .fontSize(14)
            .fontColor(this.textSecondary + '80')
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.userData?.joinDate || '')
            .fontSize(12)
            .fontColor(this.textSecondary + '60')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)

        // 编辑资料按钮
        Button('编辑资料')
          .width(120)
          .height(36)
          .fontSize(14)
          .fontColor(this.primaryColor)
          .backgroundColor('transparent')
          .border({ width: 1, color: this.primaryColor })
          .borderRadius(18)
          .onClick(() => {
            console.log('Edit Profile clicked');
          })
      }
      .alignItems(HorizontalAlign.Center)

      // 统计数据
      Row({ space: 12 }) {
        // Records
        Column({ space: 4 }) {
          Text((this.userData?.stats?.records || 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textPrimary)

          Text('记录')
            .fontSize(14)
            .fontColor(this.textSecondary)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor((this.cardBgColor || '#FFFFFF') + '80')
        .borderRadius(8)
        .border({ width: 1, color: this.customBorderColor || '#E0E0E0' })
        .alignItems(HorizontalAlign.Center)

        // Followers
        Column({ space: 4 }) {
          Text((this.userData?.stats?.followers || 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textPrimary)

          Text('关注者')
            .fontSize(14)
            .fontColor(this.textSecondary)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor((this.cardBgColor || '#FFFFFF') + '80')
        .borderRadius(8)
        .border({ width: 1, color: this.customBorderColor || '#E0E0E0' })
        .alignItems(HorizontalAlign.Center)

        // Following
        Column({ space: 4 }) {
          Text((this.userData?.stats?.following || 0).toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.textPrimary)

          Text('正在关注')
            .fontSize(14)
            .fontColor(this.textSecondary)
        }
        .layoutWeight(1)
        .padding(12)
        .backgroundColor((this.cardBgColor || '#FFFFFF') + '80')
        .borderRadius(8)
        .border({ width: 1, color: this.customBorderColor || '#E0E0E0' })
        .alignItems(HorizontalAlign.Center)
      }

      // 设置区域
      Column({ space: 0 }) {
        Text('设定')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .width('100%')
          .margin({ bottom: 12 })

        Column() {
          ForEach(this.settingItems, (item: SettingItem, index: number) => {
            Column() {
              Row({ space: 16 }) {
                // 图标
                Row() {
                  Image($r(`app.media.${item?.icon || 'ic_default'}`))
                    .width(20)
                    .height(20)
                    .fillColor(this.textPrimary || '#000000')
                }
                .width(40)
                .height(40)
                .backgroundColor(this.customBorderColor || '#E0E0E0')
                .borderRadius(8)
                .justifyContent(FlexAlign.Center)

                // 标题
                Text(item?.title || '')
                  .fontSize(16)
                  .fontColor(this.textPrimary || '#000000')
                  .layoutWeight(1)

                // 切换开关或箭头
                if (item?.hasToggle) {
                  Toggle({ type: ToggleType.Switch, isOn: item?.isToggled || false })
                    .selectedColor(this.primaryColor || '#007AFF')
                    .switchPointColor(Color.White)
                    .onChange((isOn: boolean) => {
                      console.log(`${item?.title || ''} toggled: ${isOn}`);
                    })
                } else {
                  Image($r('app.media.chevron_right'))
                    .width(20)
                    .height(20)
                    .fillColor(this.textSecondary || '#666666')
                }
              }
              .width('100%')
              .height(56)
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                console.log(`Clicked: ${item?.title || ''}`);
              })

              // 分割线（除了最后一项）
              if (index < (this.settingItems?.length || 0) - 1) {
                Divider()
                  .color(this.customBorderColor || '#E0E0E0')
                  .strokeWidth(1)
              }
            }
          })
        }
        .backgroundColor((this.cardBgColor || '#FFFFFF') + '80')
        .borderRadius(8)
        .border({ width: 1, color: this.customBorderColor || '#E0E0E0' })
      }

      // 退出登录按钮
      Button('登出')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FF4444')
        .backgroundColor((this.cardBgColor || '#FFFFFF') + '80')
        .border({ width: 1, color: '#FF4444' + '40' })
        .borderRadius(8)
        .onClick(() => {
          this.handleLogout();
        })
    }
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
            // 返回上一页逻辑
            router.back();
          })

        Text('我')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.textPrimary)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        // 占位符保持对称
        Row() {}
          .width(24)
          .height(24)
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .backgroundColor(this.bgColor + 'CC')

      // 主要内容区域
      Scroll() {
        Column({ space: 24 }) {
          // 根據登錄狀態顯示不同內容
          if (this.isLoggedIn) {
            // 已登錄 - 顯示用戶信息
            this.UserProfileContent()
          } else {
            // 未登錄 - 顯示登錄提示
            this.LoginPromptContent()
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
          // 导航到搜索页面
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
        })
      }
      .width('100%')
      .height(80)
      .padding({ top: 8, bottom: 8 })
      .backgroundColor('#000000CC')
      .border({ width: { top: 1 }, color: this.secondaryColor + '80' })

      // LoginModal 弹窗
      if (this.showLoginModal) {
        LoginModal({
          isVisible: this.showLoginModal,
          initialMode: this.loginModalMode, // 传入初始模式
          onClose: () => {
            this.showLoginModal = false;
          },
          onLoginSuccess: (userData: UserData) => {
            this.handleLoginSuccess(userData);
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
// 登錄彈窗組件
import { UserData, UserStats } from '../common/UserTypes';
import { AuthService, AuthResponse, LoginRequest, RegisterRequest } from '../services/AuthService';

@Component
export struct LoginModal {
  @State isVisible: boolean = false;
  @State isLogin: boolean = true; // true: 登錄, false: 註冊
  @State username: string = '';
  @State email: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  // AuthService 實例
  private authService: AuthService = AuthService.getInstance();

  // 顏色主題
  private primaryColor: string = '#1717cf';
  private secondaryColor: string = '#3d3d6b';
  private bgColor: string = '#12121e';
  private cardBgColor: string = '#1a1a32';
  private textPrimary: string = '#ffffff';
  private textSecondary: string = '#9393c8';
  private customBorderColor: string = '#2a2a4a';

  // 回調函數
  onClose?: () => void;
  onLoginSuccess?: (userData: UserData) => void;

  // 顯示彈窗
  show() {
    this.isVisible = true;
  }

  // 隱藏彈窗
  hide() {
    this.isVisible = false;
    this.resetForm();
    if (this.onClose) {
      this.onClose();
    }
  }

  // 重置表單
  private resetForm() {
    this.username = '';
    this.email = '';
    this.password = '';
    this.confirmPassword = '';
    this.isLoading = false;
    this.errorMessage = '';
  }

  // 切換登錄/註冊模式
  private toggleMode() {
    this.isLogin = !this.isLogin;
    this.resetForm();
  }

  // 處理登錄
  private async handleLogin() {
    // 基本驗證
    if (!this.email || !this.password) {
      this.errorMessage = '請填寫完整信息';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const loginRequest: LoginRequest = {
        email: this.email,
        password: this.password
      };

      const response: AuthResponse = await this.authService.login(loginRequest);

      if (response.success && response.user) {
        console.log('登錄成功:', response.message);
        
        if (this.onLoginSuccess) {
          this.onLoginSuccess(response.user);
        }
        
        this.hide();
      } else {
        this.errorMessage = response.message || '登錄失敗';
      }
    } catch (error) {
      console.error('登錄錯誤:', error);
      this.errorMessage = '登錄過程中發生錯誤';
    } finally {
      this.isLoading = false;
    }
  }

  // 處理註冊
  private async handleRegister() {
    // 基本驗證
    if (!this.username || !this.email || !this.password || !this.confirmPassword) {
      this.errorMessage = '請填寫完整信息';
      return;
    }

    if (this.password !== this.confirmPassword) {
      this.errorMessage = '密碼不一致';
      return;
    }

    // 簡單的郵箱格式驗證
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      this.errorMessage = '請輸入有效的郵箱地址';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const registerRequest: RegisterRequest = {
        email: this.email,
        password: this.password,
        username: this.username
      };

      const response: AuthResponse = await this.authService.register(registerRequest);

      if (response.success && response.user) {
        console.log('註冊成功:', response.message);
        
        if (this.onLoginSuccess) {
          this.onLoginSuccess(response.user);
        }
        
        this.hide();
      } else {
        this.errorMessage = response.message || '註冊失敗';
      }
    } catch (error) {
      console.error('註冊錯誤:', error);
      this.errorMessage = '註冊過程中發生錯誤';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    if (this.isVisible) {
      Stack() {
        // 背景遮罩
        Column() {}
          .width('100%')
          .height('100%')
          .backgroundColor('#000000AA')
          .onClick(() => {
            this.hide();
          })

        // 彈窗內容
        Column({ space: 24 }) {
          // 標題區域
          Row() {
            Text(this.isLogin ? '登錄' : '註冊')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.textPrimary)
              .layoutWeight(1)

            // 關閉按鈕
            Image($r('app.media.close'))
              .width(24)
              .height(24)
              .fillColor(this.textSecondary)
              .onClick(() => {
                this.hide();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)

          // 表單區域
          Column({ space: 16 }) {
            // 用戶名輸入（登錄模式）或郵箱輸入（註冊模式）
            if (this.isLogin) {
              Column({ space: 8 }) {
                Text('郵箱')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .width('100%')

                TextInput({ placeholder: '請輸入郵箱地址' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor(this.textPrimary)
                  .backgroundColor(this.customBorderColor)
                  .borderRadius(8)
                  .border({ width: 1, color: this.customBorderColor })
                  .placeholderColor(this.textSecondary + '80')
                  .type(InputType.Email)
                  .onChange((value: string) => {
                    this.email = value;
                  })
              }
            } else {
              Column({ space: 8 }) {
                Text('用戶名')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .width('100%')

                TextInput({ placeholder: '請輸入用戶名' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor(this.textPrimary)
                  .backgroundColor(this.customBorderColor)
                  .borderRadius(8)
                  .border({ width: 1, color: this.customBorderColor })
                  .placeholderColor(this.textSecondary + '80')
                  .onChange((value: string) => {
                    this.username = value;
                  })
              }
            }

            // 註冊模式下顯示郵箱輸入
            if (!this.isLogin) {
              Column({ space: 8 }) {
                Text('郵箱')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .width('100%')

                TextInput({ placeholder: '請輸入郵箱地址' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor(this.textPrimary)
                  .backgroundColor(this.customBorderColor)
                  .borderRadius(8)
                  .border({ width: 1, color: this.customBorderColor })
                  .placeholderColor(this.textSecondary + '80')
                  .type(InputType.Email)
                  .onChange((value: string) => {
                    this.email = value;
                  })
              }
            }

            // 密碼輸入
            Column({ space: 8 }) {
              Text('密碼')
                .fontSize(14)
                .fontColor(this.textSecondary)
                .width('100%')

              TextInput({ placeholder: '請輸入密碼' })
                .width('100%')
                .height(48)
                .fontSize(16)
                .fontColor(this.textPrimary)
                .backgroundColor(this.customBorderColor)
                .borderRadius(8)
                .border({ width: 1, color: this.customBorderColor })
                .placeholderColor(this.textSecondary + '80')
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })
            }

            // 註冊模式下顯示確認密碼
            if (!this.isLogin) {
              Column({ space: 8 }) {
                Text('確認密碼')
                  .fontSize(14)
                  .fontColor(this.textSecondary)
                  .width('100%')

                TextInput({ placeholder: '請再次輸入密碼' })
                  .width('100%')
                  .height(48)
                  .fontSize(16)
                  .fontColor(this.textPrimary)
                  .backgroundColor(this.customBorderColor)
                  .borderRadius(8)
                  .border({ width: 1, color: this.customBorderColor })
                  .placeholderColor(this.textSecondary + '80')
                  .type(InputType.Password)
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                  })
              }
            }
          }

          // 錯誤消息顯示
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(14)
              .fontColor('#ff4444')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 8, bottom: 8 })
          }

          // 按鈕區域
          Column({ space: 12 }) {
            // 主要按鈕
            Button(this.isLoading ? '處理中...' : (this.isLogin ? '登錄' : '註冊'))
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.White)
              .backgroundColor(this.isLoading ? this.textSecondary : this.primaryColor)
              .borderRadius(8)
              .enabled(!this.isLoading)
              .onClick(() => {
                if (this.isLogin) {
                  this.handleLogin();
                } else {
                  this.handleRegister();
                }
              })

            // 切換模式按鈕
            Row({ space: 4 }) {
              Text(this.isLogin ? '還沒有賬戶？' : '已有賬戶？')
                .fontSize(14)
                .fontColor(this.textSecondary)

              Text(this.isLogin ? '立即註冊' : '立即登錄')
                .fontSize(14)
                .fontColor(this.primaryColor)
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  this.toggleMode();
                })
            }
            .justifyContent(FlexAlign.Center)
          }
        }
        .width('90%')
        .constraintSize({ maxWidth: 400 })
        .padding(24)
        .backgroundColor(this.cardBgColor)
        .borderRadius(16)
        .border({ width: 1, color: this.customBorderColor })
        .position({ x: '5%', y: '50%' })
        .markAnchor({ x: 0, y: '50%' })
        .transition({
          type: TransitionType.All,
          opacity: this.isVisible ? 1 : 0,
          translate: { x: 0, y: this.isVisible ? 0 : 200 },
          scale: { x: this.isVisible ? 1 : 0.9, y: this.isVisible ? 1 : 0.9 }
        })
        .animation({
          duration: 300,
          curve: Curve.EaseInOut
        })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(1000)
    }
  }
}
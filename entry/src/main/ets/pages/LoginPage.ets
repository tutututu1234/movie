import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { BackendApi } from '../api/BackendApi';
import { AuthManager } from '../utils/AuthManager';

@Entry
@Component
struct LoginPage {
  @State phone: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State showPassword: boolean = false;

  private backendApi: BackendApi = BackendApi.getInstance();
  private authManager: AuthManager = AuthManager.getInstance();

  aboutToAppear(): void {
    if (this.authManager.isLoggedIn()) {
      router.replaceUrl({ url: 'pages/Index' });
    }
  }

  build() {
    Column() {
      Column({ space: 12 }) {
        Column() { Text('🎬').fontSize(36) }
          .width(80).height(80).borderRadius(40)
          .backgroundColor('#E8F4FD').justifyContent(FlexAlign.Center)

        Text('观影追剧助手')
          .fontSize(26).fontWeight(FontWeight.Bold).fontColor('#333333')

        Text('记录每一部好片')
          .fontSize(14).fontColor('#999999')
      }
      .width('100%').padding({ top: 60, bottom: 40 })
      .justifyContent(FlexAlign.Center)

      Column({ space: 16 }) {
        // 手机号输入
        Row({ space: 8 }) {
          Text('📱').fontSize(20).fontColor('#999999')
          TextInput({ placeholder: '请输入手机号', text: this.phone })
            .type(InputType.PhoneNumber)
            .layoutWeight(1).height(48).backgroundColor('transparent')
            .maxLength(11)
            .onChange((value: string) => { this.phone = value; })
        }
        .width('100%').height(48)
        .backgroundColor('#F5F5F5').borderRadius(8)
        .padding({ left: 12, right: 12 })

        // 密码输入
        Row({ space: 8 }) {
          Text('🔒').fontSize(20).fontColor('#999999')
          TextInput({ placeholder: '请输入密码', text: this.password })
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .layoutWeight(1).height(48).backgroundColor('transparent')
            .onChange((value: string) => { this.password = value; })

          Text('👁').fontSize(20)
            .fontColor(this.showPassword ? '#4A90D9' : '#999999')
            .onClick(() => { this.showPassword = !this.showPassword; })
        }
        .width('100%').height(48)
        .backgroundColor('#F5F5F5').borderRadius(8)
        .padding({ left: 12, right: 12 })

        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%').height(48)
          .backgroundColor(this.isLoading ? '#A0C4E8' : '#4A90D9')
          .fontColor('#FFFFFF').fontSize(16)
          .borderRadius(24)
          .onClick(() => { this.handleLogin(); })
          .enabled(!this.isLoading)
      }
      .width('100%').padding({ left: 24, right: 24 })

      Row() {
        Text('还没有账号？').fontSize(14).fontColor('#999999')
        Text('立即注册')
          .fontSize(14).fontColor('#4A90D9').fontWeight(FontWeight.Medium)
          .onClick(() => { router.pushUrl({ url: 'pages/RegisterPage' }); })
      }.margin({ top: 24 })

      Text('登录即表示同意用户协议和隐私政策')
        .fontSize(12).fontColor('#CCCCCC').margin({ top: 40 })
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF').padding(24)
  }

  private async handleLogin(): Promise<void> {
    if (!this.phone.trim()) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!/^1[3-9]\d{9}$/.test(this.phone.trim())) {
      promptAction.showToast({ message: '请输入正确的手机号' });
      return;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    this.isLoading = true;
    try {
      const result = await this.backendApi.login(this.phone, this.password);
      await this.authManager.saveLogin(
        result.token, result.userId, result.username, result.phone
      );
      promptAction.showToast({ message: '登录成功' });
      router.replaceUrl({ url: 'pages/Index' });
    } catch (err) {
      const errMsg: string = err instanceof Error ? err.message : '登录失败';
      promptAction.showToast({ message: errMsg });
    } finally {
      this.isLoading = false;
    }
  }
}

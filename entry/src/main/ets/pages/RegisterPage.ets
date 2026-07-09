import { promptAction } from '@kit.ArkUI';
import { router } from '@kit.ArkUI';
import { BackendApi } from '../api/BackendApi';
import { AuthManager } from '../utils/AuthManager';

@Entry
@Component
struct RegisterPage {
  @State username: string = '';
  @State phone: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;

  private backendApi: BackendApi = BackendApi.getInstance();
  private authManager: AuthManager = AuthManager.getInstance();

  build() {
    Column() {
      Row() {
        Button() {
          Text('‹').fontSize(28).fontColor('#333333')
        }
        .type(ButtonType.Circle).backgroundColor('transparent')
        .onClick(() => { router.back(); })

        Text('创建账号')
          .fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
          .layoutWeight(1).textAlign(TextAlign.Center)

        Column().width(24).height(24)
      }
      .width('100%').padding(12)

      Column({ space: 16 }) {
        TextInput({ placeholder: '请输入用户名（2-20个字符）', text: this.username })
          .height(48).backgroundColor('#F5F5F5').borderRadius(8)
          .padding({ left: 16, right: 16 }).maxLength(20)
          .onChange((value: string) => { this.username = value; })

        TextInput({ placeholder: '请输入手机号', text: this.phone })
          .type(InputType.PhoneNumber)
          .height(48).backgroundColor('#F5F5F5').borderRadius(8)
          .padding({ left: 16, right: 16 }).maxLength(11)
          .onChange((value: string) => { this.phone = value; })

        TextInput({ placeholder: '请输入密码（6-30个字符）', text: this.password })
          .type(InputType.Password)
          .height(48).backgroundColor('#F5F5F5').borderRadius(8)
          .padding({ left: 16, right: 16 }).maxLength(30)
          .onChange((value: string) => { this.password = value; })

        TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
          .type(InputType.Password)
          .height(48).backgroundColor('#F5F5F5').borderRadius(8)
          .padding({ left: 16, right: 16 }).maxLength(30)
          .onChange((value: string) => { this.confirmPassword = value; })

        Button(this.isLoading ? '注册中...' : '注册')
          .width('100%').height(48)
          .backgroundColor(this.isLoading ? '#A0C4E8' : '#4A90D9')
          .fontColor('#FFFFFF').fontSize(16)
          .borderRadius(24)
          .onClick(() => { this.handleRegister(); })
          .enabled(!this.isLoading)
      }
      .width('100%').padding({ left: 24, right: 24, top: 24 })

      Row() {
        Text('已有账号？').fontSize(14).fontColor('#999999')
        Text('立即登录')
          .fontSize(14).fontColor('#4A90D9').fontWeight(FontWeight.Medium)
          .onClick(() => { router.back(); })
      }.margin({ top: 24 })
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF').padding({ top: 40 })
  }

  private async handleRegister(): Promise<void> {
    if (this.username.length < 2 || this.username.length > 20) {
      promptAction.showToast({ message: '用户名长度应为2-20个字符' });
      return;
    }
    if (!this.phone.trim()) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (!/^1[3-9]\d{9}$/.test(this.phone.trim())) {
      promptAction.showToast({ message: '请输入正确的手机号' });
      return;
    }
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度至少6个字符' });
      return;
    }
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }

    this.isLoading = true;
    try {
      const result = await this.backendApi.register(this.username, this.phone, this.password);
      await this.authManager.saveLogin(
        result.token, result.userId, result.username, result.phone
      );
      promptAction.showToast({ message: '注册成功' });
      router.replaceUrl({ url: 'pages/Index' });
    } catch (err) {
      const errMsg: string = err instanceof Error ? err.message : '注册失败';
      promptAction.showToast({ message: errMsg });
    } finally {
      this.isLoading = false;
    }
  }
}

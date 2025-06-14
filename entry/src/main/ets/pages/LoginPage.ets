// /pages/LoginPage.ets

import { authService } from '../services/AuthService';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State message: string = '请输入您的凭据';
  @State isLoading: boolean = false;
  @State isPasswordVisible: boolean = false;

  async handleLogin() {
    console.info('[LoginPage] 开始登录流程');
    this.isLoading = true;
    this.message = '正在登录...';
    try {
      const result = await authService.login(this.username, this.password);
      this.message = result.message;
      console.info(`[LoginPage] 登录响应: code=${result.code}, message=${result.message}`);
      if (result.code === 200) {
        console.info('[LoginPage] 登录成功，准备进入问卷调查');
        await router.pushUrl({ url: 'pages/Index' });
      } else {
        // 登录失败
        console.warn('[LoginPage] 登录失败，显示错误提示');
        await promptAction.showDialog({
          title: '登录失败',
          message: result.message || '用户ID或密码错误，请重新输入',
          buttons: [{ text: '确定', color: '#007DFF' }]
        });
      }
    } catch (error) {
      console.error(`[LoginPage] 登录过程发生错误: ${JSON.stringify(error)}`);
      await promptAction.showDialog({
        title: '登录失败',
        message: '网络连接异常，请检查网络后重试',
        buttons: [{ text: '确定', color: '#007DFF' }]
      });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Stack() {
      // 背景层
      Column() {
        Image($r('app.media.login_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .height('100%')

      // 内容层
    Column() {
        // Logo和标题
        Column({ space: 12 }) {
          Image($r('app.media.app_logo'))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Contain)

          Text('健康伴侣')
            .fontSize(36)
        .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          Text('您的健康生活从这里开始')
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .margin({ top: 8, bottom: 60 })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 80 })

        // 登录表单
        Column({ space: 24 }) {
          // 用户名输入框
          Column() {
            Text('用户名')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })

            Row() {
              Image($r('app.media.user_icon'))
                .width(20)
                .height(20)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入用户名' })
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .fontSize(16)
                .fontColor('#333333')
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .onChange((value: string) => {
                  this.username = value;
                })
            }
            .width('100%')
            .height(56)
            .borderRadius(28)
            .backgroundColor('#FFFFFF')
            .padding({ left: 24, right: 24 })
          }

          // 密码输入框
          Column() {
            Text('密码')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })

            Row() {
              Image($r('app.media.lock_icon'))
                .width(20)
                .height(20)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入密码' })
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .fontSize(16)
                .fontColor('#333333')
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })

              Button() {
                Image($r('app.media.lock_icon'))
                  .width(24)
                  .height(24)
                  .fillColor(this.isPasswordVisible ? '#007DFF' : '#666666')
              }
              .backgroundColor(Color.Transparent)
              .onClick(() => {
                this.isPasswordVisible = !this.isPasswordVisible;
              })
            }
            .width('100%')
            .height(56)
            .borderRadius(28)
            .backgroundColor('#FFFFFF')
            .padding({ left: 24, right: 24 })
          }

          // 登录按钮
          Button(this.isLoading ? '登录中...' : '登录')
            .width('100%')
            .height(56)
            .borderRadius(28)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.isLoading ? '#79BBFF' : '#007DFF')
            .fontColor(Color.White)
            .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
            .enabled(!this.isLoading)
            .onClick(async () => this.handleLogin())

          // 注册链接
          Row() {
            Text('还没有账号？')
              .fontSize(14)
              .fontColor('#333333')

            Text('立即注册')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#007DFF')
              .onClick(async () => {
                try {
                  await router.pushUrl({ url: 'pages/RegisterPage' });
                } catch (error) {
                  console.error(`[LoginPage] 跳转到注册页面失败: ${error.message}`);
                }
              })
          }
          .margin({ top: 16 })
        }
        .width('85%')
        .padding(24)
        .borderRadius(16)
        .backgroundColor('rgba(255, 255, 255, 0.9)')
        .shadow({ radius: 24, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 8 })

        if (this.isLoading) {
          LoadingProgress()
            .color('#007DFF')
            .width(30)
            .height(30)
            .margin({ top: 20 })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .height('100%')
  }
}
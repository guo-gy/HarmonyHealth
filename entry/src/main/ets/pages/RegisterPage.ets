import router from '@ohos.router';
import NetworkService from '../services/NetworkService';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct RegisterPage {
  @State user_id: string = '';
  @State password: string = '';
  @State confirm_user_password: string = '';
  @State isLoading: boolean = false;

  aboutToAppear() {
    console.info('[RegisterPage] 页面即将显示');
  }

  build() {
    Column() {
      Text('注册')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50, bottom: 50 })

      TextInput({ placeholder: '用户名' })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.user_id = value;
        })

      TextInput({ placeholder: '密码' })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      TextInput({ placeholder: '确认密码' })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.confirm_user_password = value;
        })

      Button('注册')
        .width('80%')
        .height(50)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
        .enabled(!this.isLoading)
        .onClick(async () => {
          console.info('[RegisterPage] 开始注册流程');
          //有空
          if (!this.user_id || !this.password || !this.confirm_user_password) {
            await promptAction.showDialog({
              title: '提示',
              message: '请填写所有字段',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
            return;
          }
          //重复密码不同
          if (this.password !== this.confirm_user_password) {
            await promptAction.showDialog({
              title: '提示',
              message: '两次输入的密码不一致',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
            return;
          }
          //注册
          this.isLoading = true;
          const response = await NetworkService.register(this.user_id, this.password);
          console.info(`[RegisterPage] 注册响应: code=${response.code}, message=${response.message}`);
          //注册成功
          if (response.code === 200) {
            console.info('[RegisterPage] 注册成功，准备返回登录页面');
            await promptAction.showDialog({
              title: '注册成功',
              message: '请使用新账号登录',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
            console.info('[RegisterPage] 正在返回登录页面');
            await router.pushUrl({ url: 'pages/LoginPage' });
            //注册失败
          } else {
            console.warn('[RegisterPage] 注册失败');
            await promptAction.showDialog({
              title: '注册失败',
              message: response.message || '注册失败，请稍后重试',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
          }
          this.isLoading = false;
        })

      Row() {
        Text('已有账号？')
          .fontSize(14)
          .fontColor('#666666')
        Text('去登录')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(async () => {
            console.info('[RegisterPage] 用户选择返回登录页面');
            try {
              await router.pushUrl({ url: 'pages/LoginPage' });
            } catch (error) {
              console.error(`[RegisterPage] 跳转到登录页面失败: ${error.message}`);
            }
          })
      }
      .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 
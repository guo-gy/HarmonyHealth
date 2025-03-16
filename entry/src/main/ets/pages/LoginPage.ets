import promptAction from '@ohos.promptAction';
import router from '@ohos.router';
import NetworkService from '../services/NetworkService';

@Entry
@Component
struct LoginPage {
  @State user_id: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;

  build() {
    Column() {
      // 标题
      Text('欢迎登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 100, bottom: 50 })

      // 用户ID输入框
      TextInput({ placeholder: '请输入用户ID' })
        .width('80%')
        .height(50)
        .margin({ bottom: 20 })
        .onChange((value: string) => {
          this.user_id = value;
        })

      // 密码输入框
      TextInput({ placeholder: '请输入密码' })
        .width('80%')
        .height(50)
        .margin({ bottom: 40 })
        .type(InputType.Password)
        .onChange((value: string) => {
          this.password = value;
        })

      // 登录按钮
      Button('登录')
        .width('80%')
        .height(50)
        .backgroundColor('#007DFF')
        .enabled(!this.isLoading)
        .onClick(async () => {
          console.info('[LoginPage] 开始登录流程');
          //有空
          if (!this.user_id || !this.password) {
            await promptAction.showDialog({
              title: '提示',
              message: '请填写所有字段',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
            return;
          }
          //登录
          this.isLoading = true;
          const response = await NetworkService.login(this.user_id, this.password);
          console.info(`[LoginPage] 登录响应: code=${response.code}, message=${response.message}`);
          //登录成功
          if (response.code === 200) {
            console.info('[LoginPage] 登录成功，准备进入主页');
            await router.pushUrl({ url: 'pages/Index' });
            //登录失败
          } else {
            console.warn('[LoginPage] 登录失败');
            await promptAction.showDialog({
              title: '登录失败',
              message: response.message || '登录失败，请稍后重试',
              buttons: [{ text: '确定', color: '#007DFF' }]
            });
          }
          this.isLoading = false;
        })

      // 注册按钮
      Button('注册账号')
        .width('80%')
        .height(50)
        .margin({ top: 20 })
        .backgroundColor('#FFFFFF')
        .fontColor('#007DFF')
        .onClick(async () => {
          try {
            await router.pushUrl({ url: 'pages/RegisterPage' });
          } catch (error) {
            console.error(`[LoginPage] 跳转到注册页面失败: ${error.message}`);
          }
        })

      if (this.isLoading) {
        LoadingProgress()
          .width(30)
          .height(30)
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
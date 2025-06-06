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
  @State isPasswordVisible: boolean = false;
  @State isConfirmPasswordVisible: boolean = false;

  aboutToAppear() {
    console.info('[RegisterPage] 页面即将显示');
  }

  build() {
    Stack() {
      // 背景层
      Column() {
        Image($r('app.media.register_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .height('100%')
      
      // 内容层
    Column() {
        // 标题
        Column({ space: 8 }) {
          Text('创建账号')
            .fontSize(32)
        .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          
          Text('开启您的健康旅程')
            .fontSize(16)
            .fontColor('rgba(255, 255, 255, 0.8)')
            .margin({ bottom: 40 })
        }
        .margin({ top: 80 })
        .alignItems(HorizontalAlign.Center)
        
        // 注册表单
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
          this.user_id = value;
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
          
          // 确认密码输入框
          Column() {
            Text('确认密码')
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
              
              TextInput({ placeholder: '请再次输入密码' })
                .placeholderColor('#999999')
                .placeholderFont({ size: 16 })
                .fontSize(16)
                .fontColor('#333333')
                .backgroundColor(Color.Transparent)
                .layoutWeight(1)
                .type(this.isConfirmPasswordVisible ? InputType.Normal : InputType.Password)
        .onChange((value: string) => {
          this.confirm_user_password = value;
        })

              Button() {
                Image($r('app.media.lock_icon'))
                  .width(24)
                  .height(24)
                  .fillColor(this.isConfirmPasswordVisible ? '#007DFF' : '#666666')
              }
              .backgroundColor(Color.Transparent)  
              .onClick(() => {
                this.isConfirmPasswordVisible = !this.isConfirmPasswordVisible;
              })
            }
            .width('100%')
            .height(56)
            .borderRadius(28)
            .backgroundColor('#FFFFFF')
            .padding({ left: 24, right: 24 })
          }
          
          // 注册按钮
      Button('注册')
            .width('100%')
            .height(56)
            .borderRadius(28)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .fontColor(Color.White)
            .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
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
          console.info('开始请求注册');
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

          // 返回登录链接
      Row() {
        Text('已有账号？')
          .fontSize(14)
              .fontColor('#333333')
            
            Text('立即登录')
          .fontSize(14)
              .fontWeight(FontWeight.Medium)
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
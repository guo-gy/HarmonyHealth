import promptAction from '@ohos.promptAction';

@CustomDialog
export struct UserPrivacyDialog {
  controller: CustomDialogController;  // 移除 null 初始值
  confirm: () => void = () => {};  // 保留默认空函数
  cancel: () => void = () => {};   // 保留默认空函数

  build() {
    Column() {
      Text('用户协议与隐私政策')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })
      
      Text('欢迎使用鸿蒙健康助手！我们非常重视您的个人信息和隐私保护。在使用我们的产品前，请您认真阅读并了解《用户协议》和《隐私政策》的全部内容。')
        .fontSize(16)
        .margin({ bottom: 10 })
        .padding({ left: 20, right: 20 })
      
      Text('点击"同意"即表示您已阅读并同意上述协议，我们将严格保护您的个人信息安全。')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 20 })
        .padding({ left: 20, right: 20 })
      
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('不同意')
          .width(120)
          .height(40)
          .backgroundColor('#F5F5F5')
          .fontColor('#666666')
          .onClick(() => {
            this.controller.close();
            this.cancel();
            promptAction.showToast({ message: '您需要同意用户协议才能使用本应用' });
          })
        
        Button('同意')
          .width(120)
          .height(40)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .onClick(() => {
            this.controller.close();
            this.confirm();
          })
      }
      .width('100%')
      .margin({ bottom: 20 })
    }
    .width('90%')
    .backgroundColor(Color.White)
    .borderRadius(10)
  }
}
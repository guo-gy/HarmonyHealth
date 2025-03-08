@Preview
@CustomDialog
export default  struct UserPrivacyDialog{
  controller: CustomDialogController = new CustomDialogController({builder:''})
  cancel: Function = () => {}
  confirm: Function = () => {}
  build() {
    Column() {
      Text($r('app.string.UserPrivacyDialog_title'))
        .margin({top:10})
      Text(){
        Span($r('app.string.UserPrivacyDialog_content'))
      }
      Button("同意")
        .margin({top:10})
        .backgroundColor($r('app.color.confirm_button_color'))
        .onClick(()=>{
            this.confirm()
            this.controller.close()
          })
      Button("拒绝")
        .margin({top:10})
        .backgroundColor($r('app.color.cancel_button_color'))
        .onClick(()=>{
          this.cancel()
          this.controller.close()
        })
    }
    .width('80%')
    .height('50%')
  }
}
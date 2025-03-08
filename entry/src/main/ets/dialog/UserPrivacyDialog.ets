@Preview
@CustomDialog
export default  struct UserPrivacyDialog{
  controller: CustomDialogController = new CustomDialogController({builder:''})
  cancel: Function = () => {}
  confirm: Function = () => {}
  build() {
    Column() {
      Text($r('app.string.UserPrivacyDialog_title'))
      Text(){
        Span($r('app.string.UserPrivacyDialog_content'))
      }
      Button("Yes")
        .margin({bottom:10})
        .backgroundColor($r('app.color.confirm_button_color'))
        .onClick(()=>{
            this.confirm()
            this.controller.close()
          })
      Button("No")
        .margin({bottom:10})
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
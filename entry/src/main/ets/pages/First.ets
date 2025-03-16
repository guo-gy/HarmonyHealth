import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '为了您的健康计划更加个性化，\n\n我们会询问您一系列问题，\n\n如果同意请点击继续。'

  build() {
    Column() {
      Column() {
        Text(`${this.message}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        Button("继续")
          .borderRadius("5vp")
          .width("80%")
          .height("50vp")
          .margin({ top: "10vp" })
          .onClick(() => this.clickNext())
      }
      .width("100%")
      .height("100%")
      .justifyContent(FlexAlign.Center)
    }
    .width("100%")
    .height("100%")
  }

  clickNext() {
    router.pushUrl({
      url: "pages/Second",
      params: {}
    }, router.RouterMode.Single)
  }
}
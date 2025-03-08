import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message1: string = '\n您偏好的食品种类？\n'
  @State message2: string = '\n您偏好的就餐时间？\n'
  @State message3: string = '\n饮食计划期望目标？\n'

  build() {
    Column() {
      Column() {
        Text(`${this.message1}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
        Text(`${this.message2}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
        Text(`${this.message3}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
        Button("继续")
          .borderRadius("5vp")
          .width("80%")
          .height("50vp")
          .margin({ top: "10vp" })
          .onClick(this.clickNext.bind(this))
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
      url: "pages/Home",
      params: {}
    }, router.RouterMode.Single)
  }
}
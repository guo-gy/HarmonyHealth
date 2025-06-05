import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '为了您的健康计划更加个性化，\n我们会询问您一系列问题，\n如果同意请点击继续。'

  build() {
    Stack() {
      // 背景
      Image($r('app.media.survey_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      
      // 内容层
      Column() {
        // 图标
        Image($r('app.media.survey_icon'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .margin({ bottom: 40 })
        
        // 消息卡片
        Column() {
          Text('健康评估')
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 20 })
            
          Text(`${this.message}`)
            .fontSize(16)
            .lineHeight(26)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .width('90%')
          
          Button("继续")
            .width("80%")
            .height(56)
            .borderRadius(28)
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .margin({ top: 40 })
            .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
            .onClick(() => this.clickNext())
        }
        .width('90%')
        .borderRadius(16)
        .backgroundColor('rgba(255, 255, 255, 0.95)')
        .padding({ top: 40, bottom: 40, left: 20, right: 20 })
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.1)', offsetX: 0, offsetY: 8 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  clickNext() {
    router.pushUrl({
      url: "pages/Second",
      params: {}
    }, router.RouterMode.Single)
  }
}
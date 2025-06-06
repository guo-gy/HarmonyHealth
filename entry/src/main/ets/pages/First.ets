import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State message: string = '为了您的健康计划更加个性化，\n我们会询问您一系列问题，\n如果同意请点击继续。'
  @State isButtonPressed: boolean = false
  @State isPageLoaded: boolean = false

  aboutToAppear() {
    // 添加页面加载动画
    setTimeout(() => {
      this.isPageLoaded = true;
    }, 100);
  }

  build() {
    Stack() {
      // 背景
      Image($r('app.media.survey_background'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(this.isPageLoaded ? 1 : 0.6)
        .animation({
          duration: 800,
          curve: Curve.EaseOut,
          delay: 100,
          iterations: 1
        })
      
      // 内容层
      Column() {
        // 右上角跳过按钮
        Row() {
          Blank()
          Button("跳过")
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#007DFF')
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius(16)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .margin({ right: 16, top: 16 })
            .onClick(() => this.skipToMain())
            .opacity(this.isPageLoaded ? 1 : 0)
            .animation({
              duration: 500,
              curve: Curve.EaseOut,
              delay: 300,
              iterations: 1
            })
        }
        .width('100%')
        
        // 图标
        Image($r('app.media.survey_icon'))
          .width(120)
          .height(120)
          .objectFit(ImageFit.Contain)
          .margin({ bottom: 40, top: 20 })
          .opacity(this.isPageLoaded ? 1 : 0)
          .scale({ x: this.isPageLoaded ? 1 : 0.8, y: this.isPageLoaded ? 1 : 0.8 })
          .animation({
            duration: 800,
            curve: Curve.EaseOut,
            delay: 200,
            iterations: 1
          })
        
        // 消息卡片
        Column() {
          Text('健康评估')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 20 })
            .opacity(this.isPageLoaded ? 1 : 0)
            .animation({
              duration: 600,
              curve: Curve.EaseOut,
              delay: 400,
              iterations: 1
            })
            
          Text(`${this.message}`)
            .fontSize(18)
            .lineHeight(28)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .width('90%')
            .opacity(this.isPageLoaded ? 1 : 0)
            .animation({
              duration: 600,
              curve: Curve.EaseOut,
              delay: 600,
              iterations: 1
            })
          
          Button({ type: ButtonType.Capsule }) {
            Row() {
              Text("开始评估")
                .fontColor(Color.White)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
              
              if (this.isPageLoaded) {
                Image($r('app.media.arrow_right'))
                  .width(20)
                  .height(20)
                  .margin({ left: 8 })
                  .fillColor(Color.White)
              }
            }
          }
          .width("80%")
          .height(56)
          .backgroundColor(this.isButtonPressed ? '#0055CC' : '#007DFF')
          .margin({ top: 40 })
          .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
          .onClick(() => this.clickNext())
          .onTouch((event: TouchEvent) => {
            if (event.type === TouchType.Down) {
              this.isButtonPressed = true;
            } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
              this.isButtonPressed = false;
            }
          })
          .opacity(this.isPageLoaded ? 1 : 0)
          .animation({
            duration: 600,
            curve: Curve.EaseOut,
            delay: 800,
            iterations: 1
          })
        }
        .width('90%')
        .borderRadius(20)
        .backgroundColor('rgba(255, 255, 255, 0.95)')
        .padding({ top: 40, bottom: 40, left: 24, right: 24 })
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 24, color: 'rgba(0, 0, 0, 0.12)', offsetX: 0, offsetY: 12 })
        .translate({ y: this.isPageLoaded ? 0 : 50 })
        .opacity(this.isPageLoaded ? 1 : 0)
        .animation({
          duration: 800,
          curve: Curve.EaseOut,
          delay: 300,
          iterations: 1
        })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  clickNext() {
    animateTo({ duration: 200 }, () => {
      router.pushUrl({
        url: "pages/Second",
        params: {}
      }, router.RouterMode.Single)
    })
  }
  
  skipToMain() {
    router.pushUrl({
      url: "pages/Second",
      params: {}
    }, router.RouterMode.Single)
  }
}
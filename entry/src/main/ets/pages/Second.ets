import router from '@ohos.router';

interface BasicInfo {
  age: string;
  height: string;
  weight: string;
}

@Entry
@Component
struct Index {
  @State message1: string = '请问您的年龄是？'
  @State message2: string = '请问您的身高是？(cm)'
  @State message3: string = '请问您的体重是？(kg)'
  @State basicInfo: BasicInfo = {
    age: '25',
    height: '170',
    weight: '65'
  }
  @State errors: BasicInfo = {
    age: '',
    height: '',
    weight: ''
  }
  @State isSubmitting: boolean = false

  // 定义合理的值范围
  private ageRange: [number, number] = [12, 100]
  private heightRange: [number, number] = [100, 220]
  private weightRange: [number, number] = [30, 200]

  validateInput() {
    // 这里的验证逻辑简化了，因为我们使用了受限的输入组件
    return true;
  }

  build() {
    Column() {
      // 右上角跳过按钮
      Row() {
        Blank()
        Button("跳过")
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#007DFF')
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .borderRadius(16)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .margin({ right: 16, top: 16 })
          .onClick(() => this.skipToMain())
      }
      .width('100%')
      
      // 标题
      Text('基本信息')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Scroll() {
        Column() {
          // 年龄输入
          Column() {
            Text(this.message1)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })
              .fontColor('#333333')
            
            Row() {
              Text(this.ageRange[0].toString())
                .fontSize(14)
                .fontColor('#999999')
              
              Slider({
                value: parseInt(this.basicInfo.age),
                min: this.ageRange[0],
                max: this.ageRange[1],
                step: 1,
                style: SliderStyle.OutSet
              })
                .blockColor('#007DFF')
                .trackColor('#E0E0E0')
                .selectedColor('#007DFF')
                .showSteps(true)
                .showTips(true)
                .width('70%')
                .onChange((value: number) => {
                  this.basicInfo.age = value.toString();
                })
              
              Text(this.ageRange[1].toString())
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 })
            
            Row() {
              Text("已选：")
                .fontSize(16)
                .fontColor('#333333')
              
              Text(this.basicInfo.age + " 岁")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#007DFF')
            }
            .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          // 身高输入
          Column() {
            Text(this.message2)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })
              .fontColor('#333333')
            
            Row() {
              Counter() {
                Text(this.basicInfo.height)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
              }
              .onInc(() => {
                let h = parseInt(this.basicInfo.height);
                if (h < this.heightRange[1]) {
                  this.basicInfo.height = (h + 1).toString();
                }
              })
              .onDec(() => {
                let h = parseInt(this.basicInfo.height);
                if (h > this.heightRange[0]) {
                  this.basicInfo.height = (h - 1).toString();
                }
              })
              .margin({ right: 8 })
              
              Text("cm")
                .fontSize(16)
                .fontColor('#666666')
            }
            .width('90%')
            .justifyContent(FlexAlign.Center)
            
            Text(`范围: ${this.heightRange[0]}cm - ${this.heightRange[1]}cm`)
              .fontSize(14)
              .fontColor('#999999')
              .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          // 体重输入
          Column() {
            Text(this.message3)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 16 })
              .fontColor('#333333')
            
            Row() {
              Text(this.weightRange[0].toString())
                .fontSize(14)
                .fontColor('#999999')
              
              Slider({
                value: parseInt(this.basicInfo.weight),
                min: this.weightRange[0],
                max: this.weightRange[1],
                step: 0.5,
                style: SliderStyle.OutSet
              })
                .blockColor('#007DFF')
                .trackColor('#E0E0E0')
                .selectedColor('#007DFF')
                .showTips(true)
                .width('70%')
                .onChange((value: number) => {
                  this.basicInfo.weight = value.toString();
                })
              
              Text(this.weightRange[1].toString())
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('90%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 8 })
            
            Row() {
              Text("已选：")
                .fontSize(16)
                .fontColor('#333333')
              
              Text(this.basicInfo.weight + " kg")
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#007DFF')
            }
            .margin({ top: 8 })
          }
          .width('100%')
          .margin({ bottom: 40 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .layoutWeight(1)

      // 底部按钮
      Button(this.isSubmitting ? '提交中...' : '继续')
        .width('90%')
        .height(56)
        .borderRadius(28)
        .backgroundColor(this.isSubmitting ? '#CCCCCC' : '#007DFF')
        .fontColor(Color.White)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 40 })
        .enabled(!this.isSubmitting)
        .onClick(() => {
          if (this.validateInput()) {
            this.isSubmitting = true;
            // 模拟提交延迟
            setTimeout(() => {
              this.clickNext();
            }, 500);
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  clickNext() {
    router.pushUrl({
      url: "pages/Third",
      params: this.basicInfo
    }, router.RouterMode.Single)
  }
  
  skipToMain() {
    router.pushUrl({
      url: "pages/Third",
      params: {}
    }, router.RouterMode.Single)
  }
}

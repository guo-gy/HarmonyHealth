import router from '@ohos.router';

// 定义表单数据接口
interface FormData {
  foodType: string;
  mealTime: string;
  dietGoal: string;
}

@Entry
@Component
struct Index {
  @State message1: string = '您偏好的食品种类'
  @State message2: string = '您偏好的就餐时间'
  @State message3: string = '饮食计划期望目标'
  @State formData: FormData = {
    foodType: '',
    mealTime: '',
    dietGoal: ''
  }
  @State errors: FormData = {
    foodType: '',
    mealTime: '',
    dietGoal: ''
  }
  @State isSubmitting: boolean = false

  // 食品种类选项
  private foodTypes: string[] = ['均衡饮食', '素食', '低碳水', '高蛋白', '无麸质', '其他']
  // 就餐时间选项
  private mealTimes: string[] = ['早餐(6-9点)', '午餐(11-13点)', '晚餐(17-19点)', '加餐(10点/15点)', '其他时间']
  // 饮食目标选项
  private dietGoals: string[] = ['减重', '增重', '维持体重', '改善体质', '控制血糖', '其他']

  validateInput() {
    let isValid = true;
    const newErrors: FormData = {
      foodType: '',
      mealTime: '',
      dietGoal: ''
    };

    if (!this.formData.foodType) {
      newErrors.foodType = '请选择食品种类';
      isValid = false;
    }
    if (!this.formData.mealTime) {
      newErrors.mealTime = '请选择就餐时间';
      isValid = false;
    }
    if (!this.formData.dietGoal) {
      newErrors.dietGoal = '请选择饮食目标';
      isValid = false;
    }

    this.errors = newErrors;
    return isValid;
  }

  @Builder
  OptionButton(text: string, isSelected: boolean, onClick: () => void) {
    Button(text)
      .width('45%')
      .height(48)
      .borderRadius(24)
      .backgroundColor(isSelected ? '#007DFF' : '#F5F5F5')
      .fontColor(isSelected ? Color.White : '#333333')
      .fontSize(16)
      .fontWeight(isSelected ? FontWeight.Medium : FontWeight.Normal)
      .margin({ bottom: 12 })
      .onClick(onClick)
      .animation({
        duration: 200,
        curve: Curve.EaseOut,
        iterations: 1,
        playMode: PlayMode.Normal
      })
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
      Text('饮食偏好')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Scroll() {
        Column() {
          // 食品种类选择
          Column() {
            Row() {
              Text(this.message1)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.foodType) {
                Text(`已选: ${this.formData.foodType}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.foodTypes, (type: string) => {
                this.OptionButton(
                  type,
                  this.formData.foodType === type,
                  () => {
                    this.formData.foodType = type;
                    if (this.errors.foodType) {
                      this.errors.foodType = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.foodType) {
              Text(this.errors.foodType)
                .fontSize(14)
                .fontColor('#FF4D4F')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .margin({ bottom: 32 })
          .padding({ left: 2, right: 2 })
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 1, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })

          // 就餐时间选择
          Column() {
            Row() {
              Text(this.message2)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.mealTime) {
                Text(`已选: ${this.formData.mealTime}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.mealTimes, (time: string) => {
                this.OptionButton(
                  time,
                  this.formData.mealTime === time,
                  () => {
                    this.formData.mealTime = time;
                    if (this.errors.mealTime) {
                      this.errors.mealTime = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.mealTime) {
              Text(this.errors.mealTime)
                .fontSize(14)
                .fontColor('#FF4D4F')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .margin({ bottom: 32 })
          .padding({ left: 2, right: 2 })
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 1, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })

          // 饮食目标选择
          Column() {
            Row() {
              Text(this.message3)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.dietGoal) {
                Text(`已选: ${this.formData.dietGoal}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.dietGoals, (goal: string) => {
                this.OptionButton(
                  goal,
                  this.formData.dietGoal === goal,
                  () => {
                    this.formData.dietGoal = goal;
                    if (this.errors.dietGoal) {
                      this.errors.dietGoal = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.dietGoal) {
              Text(this.errors.dietGoal)
                .fontSize(14)
                .fontColor('#FF4D4F')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .margin({ bottom: 40 })
          .padding({ left: 2, right: 2 })
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .shadow({ radius: 1, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 2 })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .layoutWeight(1)

      // 底部按钮
      Button(this.isSubmitting ? '提交中...' : '完成')
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
      url: "pages/Index",
      params: this.formData
    }, router.RouterMode.Single)
  }
  
  skipToMain() {
    router.pushUrl({
      url: "pages/Index",
      params: {}
    }, router.RouterMode.Single)
  }
}

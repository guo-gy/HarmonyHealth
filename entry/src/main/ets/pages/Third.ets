import router from '@ohos.router';

// 定义表单数据接口
interface FormData {
  exerciseType: string;
  exerciseTime: string;
  exerciseGoal: string;
}

@Entry
@Component
struct Index {
  @State message1: string = '您偏好的运动方式'
  @State message2: string = '您偏好的运动时间'
  @State message3: string = '运动计划期望目标'
  @State formData: FormData = {
    exerciseType: '',
    exerciseTime: '',
    exerciseGoal: ''
  }
  @State errors: FormData = {
    exerciseType: '',
    exerciseTime: '',
    exerciseGoal: ''
  }
  @State isSubmitting: boolean = false

  // 运动方式选项
  private exerciseTypes: string[] = ['有氧运动', '力量训练', '瑜伽/普拉提', '游泳', '球类运动', '其他']
  // 运动时间选项
  private exerciseTimes: string[] = ['早晨(6-9点)', '上午(9-12点)', '下午(12-18点)', '晚上(18-22点)', '其他时间']
  // 运动目标选项
  private exerciseGoals: string[] = ['减脂塑形', '增肌增重', '提高心肺功能', '改善体态', '缓解压力', '其他']

  validateInput() {
    let isValid = true;
    const newErrors: FormData = {
      exerciseType: '',
      exerciseTime: '',
      exerciseGoal: ''
    };

    if (!this.formData.exerciseType) {
      newErrors.exerciseType = '请选择运动方式';
      isValid = false;
    }
    if (!this.formData.exerciseTime) {
      newErrors.exerciseTime = '请选择运动时间';
      isValid = false;
    }
    if (!this.formData.exerciseGoal) {
      newErrors.exerciseGoal = '请选择运动目标';
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
      Text('运动偏好')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 40 })
        .fontColor('#333333')

      Scroll() {
        Column() {
          // 运动方式选择
          Column() {
            Row() {
              Text(this.message1)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.exerciseType) {
                Text(`已选: ${this.formData.exerciseType}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.exerciseTypes, (type: string) => {
                this.OptionButton(
                  type,
                  this.formData.exerciseType === type,
                  () => {
                    this.formData.exerciseType = type;
                    if (this.errors.exerciseType) {
                      this.errors.exerciseType = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.exerciseType) {
              Text(this.errors.exerciseType)
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

          // 运动时间选择
          Column() {
            Row() {
              Text(this.message2)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.exerciseTime) {
                Text(`已选: ${this.formData.exerciseTime}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.exerciseTimes, (time: string) => {
                this.OptionButton(
                  time,
                  this.formData.exerciseTime === time,
                  () => {
                    this.formData.exerciseTime = time;
                    if (this.errors.exerciseTime) {
                      this.errors.exerciseTime = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.exerciseTime) {
              Text(this.errors.exerciseTime)
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

          // 运动目标选择
          Column() {
            Row() {
              Text(this.message3)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
              
              if (this.formData.exerciseGoal) {
                Text(`已选: ${this.formData.exerciseGoal}`)
                  .fontSize(14)
                  .fontColor('#007DFF')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
            
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.exerciseGoals, (goal: string) => {
                this.OptionButton(
                  goal,
                  this.formData.exerciseGoal === goal,
                  () => {
                    this.formData.exerciseGoal = goal;
                    if (this.errors.exerciseGoal) {
                      this.errors.exerciseGoal = '';
                    }
                  }
                )
              })
            }
            .width('100%')
            
            if (this.errors.exerciseGoal) {
              Text(this.errors.exerciseGoal)
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
      url: "pages/Forth",
      params: this.formData
    }, router.RouterMode.Single)
  }
  
  skipToMain() {
    router.pushUrl({
      url: "pages/Forth",
      params: {}
    }, router.RouterMode.Single)
  }
}

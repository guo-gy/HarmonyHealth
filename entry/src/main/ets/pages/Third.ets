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
  @State message1: string = '\n您偏好的运动方式？\n'
  @State message2: string = '\n您偏好的运动时间？\n'
  @State message3: string = '\n运动计划期望目标？\n'
  @State formData: FormData = {
    exerciseType: '',
    exerciseTime: '',
    exerciseGoal: ''
  }

  build() {
    Column() {
      Column() {
        Text(`${this.message1}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.exerciseType = value;
          })
        Text(`${this.message2}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.exerciseTime = value;
          })
        Text(`${this.message3}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.exerciseGoal = value;
          })
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
    // 使用明确的类型而不是空对象字面�?
    const params: FormData = this.formData;
    router.pushUrl({
      url: "pages/Forth",
      params: params
    }, router.RouterMode.Single)
  }
}

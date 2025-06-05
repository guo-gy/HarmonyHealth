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
  @State message1: string = '\n您偏好的食品种类？\n'
  @State message2: string = '\n您偏好的就餐时间？\n'
  @State message3: string = '\n饮食计划期望目标？\n'
  @State formData: FormData = {
    foodType: '',
    mealTime: '',
    dietGoal: ''
  }

  build() {
    Column() {
      Column() {
        Text(`${this.message1}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.foodType = value;
          })
        Text(`${this.message2}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.mealTime = value;
          })
        Text(`${this.message3}`)
          .textAlign(TextAlign.Center)
          .fontWeight(FontWeight.Bold)
        TextInput()
          .onChange((value: string) => {
            this.formData.dietGoal = value;
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
    const params: FormData = {
      foodType: this.formData.foodType,
      mealTime: this.formData.mealTime,
      dietGoal: this.formData.dietGoal
    };
    
    router.pushUrl({
      url: "pages/Index", // 修改为正确的Index页面
      params: params
    }, router.RouterMode.Single)
  }
}

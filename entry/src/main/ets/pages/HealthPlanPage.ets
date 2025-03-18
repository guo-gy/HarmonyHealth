import { CommonConstants } from '../common/constants/CommonConstants'
import router from '@ohos.router'
import HomeNetworkService from '../services/HomeNetworkService'

@Entry
@Component
struct HealthPlanPage {
  @State message: string = '健康计划'
  @State selectedDay: number = 1
  @State planData: any = null
  @State isLoading: boolean = false

  private weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日']

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text(this.message)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(20)

      // 周选择器
      Row() {
        ForEach(this.weekDays, (day, index) => {
          Text(day)
            .fontSize(16)
            .padding(10)
            .backgroundColor(this.selectedDay === index + 1 ? '#007DFF' : '#F5F5F5')
            .fontColor(this.selectedDay === index + 1 ? '#FFFFFF' : '#000000')
            .borderRadius(8)
            .onClick(() => {
              this.selectedDay = index + 1
              this.loadPlanData()
            })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding(10)

      // 计划内容展示区域
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .width(50)
          .height(50)
      } else if (this.planData) {
        Column() {
          // 饮食计划
          Column() {
            Text('饮食计划')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })
            
            Text(this.planData.diet)
              .fontSize(16)
              .margin({ bottom: 20 })
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)

          // 运动计划
          Column() {
            Text('运动计划')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 10 })
            
            Text(this.planData.exercise)
              .fontSize(16)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
          .margin({ top: 20 })
        }
        .width('100%')
        .padding(20)
      }
    }
    .width('100%')
    .height('100%')
  }

  loadPlanData() {
    this.isLoading = true
    HomeNetworkService.getHealthPlanByDay(this.selectedDay)
      .then((response) => {
        this.planData = response.data
        this.isLoading = false
      })
      .catch((error) => {
        this.planData = null
        this.isLoading = false
      })
  }

  aboutToAppear() {
    this.loadPlanData()
  }
}
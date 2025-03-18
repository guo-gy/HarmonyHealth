import { CommonConstants } from '../common/constants/CommonConstants'
import router from '@ohos.router'
import HomeNetworkService from '../services/HomeNetworkService'

@Entry
@Component
struct AssistantPage {
  @State message: string = '智能健康助手'
  @State isLoading: boolean = false
  @State planContent: string = ''

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

      // 主要内容区域
      Column() {
        // 欢迎语
        Text('您好！我是您的智能健康助手')
          .fontSize(20)
          .margin({ top: 20, bottom: 20 })

        // 生成计划按钮
        Button('生成健康计划')
          .width('80%')
          .height(50)
          .backgroundColor('#007DFF')
          .onClick(() => {
            this.generateHealthPlan()
          })
          .margin({ top: 20, bottom: 20 })

        // 加载动画
        if (this.isLoading) {
          LoadingProgress()
            .color('#007DFF')
            .width(50)
            .height(50)
        }

        // 计划内容展示区域
        if (this.planContent) {
          Text(this.planContent)
            .fontSize(16)
            .margin({ top: 20 })
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
        }
      }
      .width('100%')
      .padding(20)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }

  generateHealthPlan() {
    this.isLoading = true
    this.planContent = ''
    
    // 调用网络服务生成计划
    HomeNetworkService.generateHealthPlan()
      .then((response) => {
        this.planContent = response.data.plan
        this.isLoading = false
      })
      .catch((error) => {
        this.planContent = '生成计划失败，请稍后重试'
        this.isLoading = false
      })
  }
} 
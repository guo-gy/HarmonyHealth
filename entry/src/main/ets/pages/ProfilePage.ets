import { CommonConstants } from '../common/constants/CommonConstants'
import router from '@ohos.router'
import HomeNetworkService from '../services/HomeNetworkService'

@Entry
@Component
struct ProfilePage {
  @State message: string = '个人中心'
  @State userInfo: any = null
  @State exerciseHistory: any[] = []
  @State isLoading: boolean = false

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

      // 个人信息卡片
      if (this.userInfo) {
        Column() {
          Row() {
            Image(this.userInfo.avatar || '/images/default_avatar.png')
              .width(80)
              .height(80)
              .borderRadius(40)
              .margin({ right: 15 })
            
            Column() {
              Text(this.userInfo.username)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
              Text(this.userInfo.email)
                .fontSize(14)
                .fontColor('#666666')
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .padding(15)
          .backgroundColor('#F5F5F5')
          .borderRadius(10)
        }
        .width('100%')
        .padding(20)
      }

      // 运动历史标题
      Text('运动历史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 10 })

      // 运动历史列表
      List() {
        ForEach(this.exerciseHistory, (item) => {
          ListItem() {
            Row() {
              Column() {
                Text(item.date)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                Text(item.exerciseType)
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text(item.duration + '分钟')
                .fontSize(16)
                .fontColor('#007DFF')
            }
            .width('100%')
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ bottom: 10 })
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding(20)

      // 加载动画
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .width(50)
          .height(50)
      }
    }
    .width('100%')
    .height('100%')
  }

  aboutToAppear() {
    this.loadUserData()
  }

  loadUserData() {
    this.isLoading = true
    Promise.all([
      HomeNetworkService.getUserInfo(),
      HomeNetworkService.getExerciseHistory()
    ])
      .then(([userInfo, exerciseHistory]) => {
        this.userInfo = userInfo.data
        this.exerciseHistory = exerciseHistory.data
        this.isLoading = false
      })
      .catch((error) => {
        this.isLoading = false
      })
  }
}
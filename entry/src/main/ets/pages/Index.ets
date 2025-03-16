import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  @Builder TabBuilder(title: string, index: number, normalImage: Resource, selectedImage: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImage : normalImage)
        .width(24)
        .height(24)
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Tabs({
      barPosition: BarPosition.End,
      controller: this.tabsController
    }) {

      // 智能助手
      TabContent() {
        Column() {
          Text('智能助手')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      }
      .tabBar(this.TabBuilder('智能助手', 2, $r('app.media.ai_normal'), $r('app.media.ai_selected')))

      // 健康规划
      TabContent() {
        Column() {
          Text('健康计划')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      }
      .tabBar(this.TabBuilder('健康计划', 1, $r('app.media.health_normal'), $r('app.media.health_selected')))


      // 我的
      TabContent() {
        Column() {
          Text('我的')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#F5F5F5')
      }
      .tabBar(this.TabBuilder('我的', 3, $r('app.media.profile_normal'), $r('app.media.profile_selected')))
    }
    .scrollable(false)
    .barHeight(60)
    .onChange((index: number) => {
      this.currentIndex = index;
    })
  }
} 
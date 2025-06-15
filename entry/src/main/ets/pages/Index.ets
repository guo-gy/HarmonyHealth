// 文件路径: src/main/ets/pages/Index.ets

import router from '@ohos.router';
import { AssistantPage } from './AssistantPage';
import { HealthPlanPage } from './HealthPlanPage';
import { ProfilePage } from './ProfilePage';
import { WorkoutPage } from './WorkoutPage';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();

  // ***** 1. 定义一个用于处理所有Tab切换逻辑的中心方法 *****
  private jumpToTab(index: number) {
    // 避免重复切换
    if (this.currentIndex !== index) {
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
    }
  }

  @Builder TabBuilder(title: string, index: number, normalImg: Resource) {
    Column() {
      Image(normalImg)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#007DFF' : '#666666')

      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#666666')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      // ***** 2. 让Tab栏的点击也调用这个中心方法，保持代码统一 *****
      this.jumpToTab(index);
    })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.tabsController }) {
        TabContent() {
          AssistantPage()
        }
        .tabBar(this.TabBuilder('智能助手', 0, $r('app.media.assistant_normal')))

        TabContent() {
          HealthPlanPage()
        }
        .tabBar(this.TabBuilder('健康计划', 1, $r('app.media.health_normal')))

        TabContent() {
          WorkoutPage()
        }
        .tabBar(this.TabBuilder('时间记录', 2, $r('app.media.workout_normal')))

        TabContent() {
          // ***** 3. 在这里，将 jumpToTab 方法作为 onJumpRequest 属性的值，传递给 ProfilePage *****
          // .bind(this) 是必需的，它确保在 jumpToTab 方法内部，'this' 关键字仍然指向 Index 组件实例
          ProfilePage({ onJumpRequest: this.jumpToTab.bind(this) })
        }
        .tabBar(this.TabBuilder('个人中心', 3, $r('app.media.home_normal')))
      }
      .width('100%')
      .height('100%')
      .barHeight(60)
      .onChange((index: number) => {
        // 当用户通过滑动切换Tab时，也需要同步 currentIndex 的状态
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
  }
}
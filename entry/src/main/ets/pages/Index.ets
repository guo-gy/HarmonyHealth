import router from '@ohos.router';
import { AssistantPage } from './AssistantPage';
import { HealthPlanPage } from './HealthPlanPage';
import { ProfilePage } from './ProfilePage';
import { WorkoutPage } from './WorkoutPage';

// 在文件顶部添加接口定义
interface FormData {
  exerciseType?: string;
  exerciseTime?: string;
  exerciseGoal?: string;
  foodType?: string;
  mealTime?: string;
  dietGoal?: string;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State formData: FormData = {};
  private tabsController: TabsController = new TabsController();

  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as FormData;
    if (params) {
      this.formData = params;
      console.info('[Index] 收到问卷数据:', JSON.stringify(this.formData));
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
      this.currentIndex = index;
      this.tabsController.changeIndex(index);
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
        .tabBar(this.TabBuilder('运动轨迹', 2, $r('app.media.workout_normal')))
        
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder('个人中心', 3, $r('app.media.home_normal')))
      }
      .width('100%')
      .height('100%')
      .barHeight(60)
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
  }
}
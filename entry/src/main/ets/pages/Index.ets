import router from '@ohos.router';
import { AssistantPage } from './AssistantPage';
import { HealthPlanPage } from './HealthPlanPage';
import { ProfilePage } from './ProfilePage';

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
  
  @Builder TabBuilder(title: string, index: number, normalImg: Resource, selectedImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width(26)
        .height(26)
        .objectFit(ImageFit.Contain)
      
      Text(title)
        .fontSize(12)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .animation({
      duration: 250,
      curve: Curve.EaseOut
    })
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
        .tabBar(this.TabBuilder('智能助手', 0, $r('app.media.assistant_normal'), $r('app.media.assistant_selected')))
        
        TabContent() {
          HealthPlanPage()
        }
        .tabBar(this.TabBuilder('健康计划', 1, $r('app.media.plan_normal'), $r('app.media.plan_selected')))
        
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder('个人中心', 2, $r('app.media.profile_normal'), $r('app.media.profile_selected')))
      }
      .width('100%')
      .height('100%')
      .barHeight(70)
      .barMode(BarMode.Fixed)
      .backgroundColor('#FFFFFF')
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
}

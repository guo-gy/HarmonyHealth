import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 定义计划数据接口
interface PlanData {
  diet: string;
  exercise: string;
  steps: number;
  calories: number;
  water: number;
  completed: boolean;
}

// 定义成就接口
interface Achievement {
  title: string;
  description: string;
  icon: Resource;
  unlocked: boolean;
}

@Component
export struct HealthPlanPage {
  @State message: string = '健康计划';
  @State selectedDay: number = new Date().getDay() || 7; // 获取当前星期几，周日为0转为7
  @State selectedDate: Date = new Date();
  @State planData: PlanData | null = null;
  @State isLoading: boolean = false;
  @State completionRate: number = 0;
  @State achievements: Achievement[] = [
    {
      title: '运动达人',
      description: '连续7天完成运动计划',
      icon: $r('app.media.icon'),  // 将 default_avatar 替换为 icon
      unlocked: true
    },
    {
      title: '饮食均衡',
      description: '连续5天遵循健康饮食',
      icon: $r('app.media.icon'),  // 将 default_avatar 替换为 icon
      unlocked: false
    },
    {
      title: '水分充足',
      description: '连续3天达成饮水目标',
      icon: $r('app.media.icon'),  // 将 default_avatar 替换为 icon
      unlocked: true
    }
  ];

  private weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private months = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

  build() {
    Column() {
      // 顶部标题和日期
      Row() {
        Column() {
          Text(this.message)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
          
          Text(`${this.months[this.selectedDate.getMonth()]} ${this.selectedDate.getDate()}, ${this.selectedDate.getFullYear()}`)
            .fontSize(16)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
          .layoutWeight(1)
        
        Button() {
          Image($r('app.media.icon'))  // 将 default_avatar 替换为 icon
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
        .onClick(() => {
          // 日历选择功能
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })

      // 周选择器
      Row() {
        ForEach(this.weekDays, (day: string, index: number) => {  // 添加明确的类型
          Column() {
            Text(day)
              .fontSize(14)
              .fontColor(this.selectedDay === index + 1 ? '#007DFF' : '#666666')
            
            Text(`${index + 1}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selectedDay === index + 1 ? '#007DFF' : '#000000')
              .margin({ top: 5 })
            
            Circle({ width: 6, height: 6 })
              .fill(this.selectedDay === index + 1 ? '#007DFF' : 'transparent')
              .margin({ top: 5 })
          }
          .width(40)
          .height(70)
          .padding(5)
          .borderRadius(20)
          .backgroundColor(this.selectedDay === index + 1 ? '#E6F2FF' : 'transparent')
          .onClick(() => {
            this.selectedDay = index + 1;
            // 计算选中日期
            const today = new Date();
            const diff = index + 1 - (today.getDay() || 7);
            this.selectedDate = new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
            this.loadPlanData();
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ left: 10, right: 10, top: 10, bottom: 20 })

      // 进度概览
      Row() {
        Column() {
          Text('今日进度')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Progress({ value: this.completionRate, total: 100 })
            .color('#007DFF')
            .width('100%')
            .height(10)
            .margin({ top: 10, bottom: 5 })
          
          Text(`${this.completionRate}%`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
      }
      .width('90%')
      .padding(15)
      .backgroundColor('#F5F5F5')
      .borderRadius(10)

      // 计划内容展示区域
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .width(50)
          .height(50)
          .margin({ top: 50 })
      } else if (this.planData) {
        Scroll() {
          Column() {
            // 数据概览卡片
            Row() {
              Column() {
                Text('步数')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text(`${this.planData.steps}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                
                Image($r('app.media.icon'))  // 修改这里，将 default_avatar 替换为 icon
                  .width(24)
                  .height(24)
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
              
              Divider()
                .vertical(true)
                .height('80%')
                .color('#E0E0E0')
              
              Column() {
                Text('卡路里')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text(`${this.planData.calories}`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                
                Image($r('app.media.icon'))  // 修改这里，将 default_avatar 替换为 icon
                  .width(24)
                  .height(24)
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
              
              Divider()
                .vertical(true)
                .height('80%')
                .color('#E0E0E0')
              
              Column() {
                Text('饮水量')
                  .fontSize(14)
                  .fontColor('#666666')
                
                Text(`${this.planData.water}ml`)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                
                Image($r('app.media.icon'))  // 修改这里，将 default_avatar 替换为 icon
                  .width(24)
                  .height(24)
                  .margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1)
            }
            .width('100%')
            .height(100)
            .padding(15)
            .backgroundColor('#F5F5F5')
            .borderRadius(10)
            .margin({ top: 15 })
            .onClick((event: ClickEvent) => {  // 已修改，使用明确的 ClickEvent 类型
              // 点击事件处理逻辑
            })
          }
          .width('90%')
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        Column() {
          Image($r('app.media.icon'))  // 修改这里，将 default_avatar 替换为 icon
            .width(150)
            .height(150)
            .margin({ top: 50, bottom: 20 })
          
          Text('暂无计划数据')
            .fontSize(18)
            .fontColor('#666666')
          
          Button('创建计划')
            .width(150)
            .height(40)
            .backgroundColor('#007DFF')
            .margin({ top: 20 })
            .onClick(() => {
              this.createDefaultPlan();
            })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  updateCompletionRate() {
    // 简单计算完成率
    this.completionRate = this.planData && this.planData.completed ? 100 : 0;
  }

  createDefaultPlan() {
    this.planData = {
      diet: '早餐：全麦面包配鸡蛋和牛奶\n午餐：糙米饭、蔬菜沙拉和鸡胸肉\n晚餐：鱼肉、蒸蔬菜和少量主食\n加餐：水果或坚果',
      exercise: '1. 有氧运动：慢跑30分钟\n2. 力量训练：俯卧撑3组，每组15个\n3. 拉伸运动：全身拉伸10分钟',
      steps: 8000,
      calories: 350,
      water: 2000,
      completed: false
    };
    this.updateCompletionRate();
  }

  loadPlanData() {
    this.isLoading = true;
    
    // 模拟加载数据
    setTimeout(() => {
      if (this.selectedDay === 1 || this.selectedDay === 3 || this.selectedDay === 5) {
        this.planData = {
          diet: '早餐：全麦面包配鸡蛋和牛奶\n午餐：糙米饭、蔬菜沙拉和鸡胸肉\n晚餐：鱼肉、蒸蔬菜和少量主食\n加餐：水果或坚果',
          exercise: '1. 有氧运动：慢跑30分钟\n2. 力量训练：俯卧撑3组，每组15个\n3. 拉伸运动：全身拉伸10分钟',
          steps: 8000,
          calories: 350,
          water: 2000,
          completed: this.selectedDay < new Date().getDay()
        };
      } else if (this.selectedDay === 2 || this.selectedDay === 4) {
        this.planData = {
          diet: '早餐：燕麦粥配水果和酸奶\n午餐：意大利面配番茄酱和瘦肉\n晚餐：豆腐、蔬菜炒饭\n加餐：酸奶或水果',
          exercise: '1. 力量训练：哑铃训练上肢和下肢\n2. 核心训练：平板支撑3组，每组30秒\n3. 柔韧性训练：瑜伽15分钟',
          steps: 6000,
          calories: 280,
          water: 2200,
          completed: this.selectedDay < new Date().getDay()
        };
      } else {
        this.planData = {
          diet: '早餐：蛋白质奶昔和水果\n午餐：沙拉配金枪鱼和藜麦\n晚餐：烤鸡肉配蔬菜\n加餐：坚果或蛋白棒',
          exercise: '1. 休息日：轻度活动\n2. 拉伸运动：全身拉伸15分钟\n3. 放松活动：散步20分钟',
          steps: 5000,
          calories: 200,
          water: 2500,
          completed: this.selectedDay < new Date().getDay()
        };
      }
      
      this.updateCompletionRate();
      this.isLoading = false;
    }, 1000);
  }

  aboutToAppear() {
    this.loadPlanData();
  }
}
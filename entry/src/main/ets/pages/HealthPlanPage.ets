import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { planService } from '../services/PlanService';
import { Plan } from '../models/PlanModels';

@Entry
@Component
export struct HealthPlanPage {
  @State message: string = '健康计划';
  @State selectedDay: number = new Date().getDay() === 0 ? 7 : new Date().getDay();
  @State isLoading: boolean = false;
  @State dailyPlanItems: Plan[] = [];

  // 页面显示时，进行初始加载
  onPageShow(): void {
    this.loadPlansForSelectedDay();
  }

  private weekDays = ['一', '二', '三', '四', '五', '六', '日'];
  private months = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

  // --- 辅助方法 ---
  private getSelectedDate(): Date {
    const today = new Date();
    const todayDayOfWeek = today.getDay() === 0 ? 7 : today.getDay();
    const diff = this.selectedDay - todayDayOfWeek;
    return new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
  }

  private getCompletionRate(): number {
    if (this.dailyPlanItems.length === 0) {
      return 100;
    }
    const completedCount = this.dailyPlanItems.filter((item: Plan) => item.is_completed).length;
    return Math.round((completedCount / this.dailyPlanItems.length) * 100);
  }

  // --- 新增：专门用于计算日期数字的辅助方法 ---
  private getDayNumberFor(index: number): number {
    const today = new Date();
    // 使用 getDay() || 7 的技巧处理周日
    const todayDayOfWeek = today.getDay() || 7;
    const targetDayOfWeek = index + 1;
    const diff = targetDayOfWeek - todayDayOfWeek;
    const targetDate = new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
    return targetDate.getDate();
  }

  // --- 核心逻辑函数 ---
  async aboutToAppear(): Promise<void> {
    await this.loadPlansForSelectedDay();
  }

  async loadPlansForSelectedDay(): Promise<void> {
    this.isLoading = true;
    this.dailyPlanItems = [];
    try {
      const result = await planService.getPlans(this.selectedDay);
      if (result.code === 200 && result.data) {
        this.dailyPlanItems = result.data.plans.sort((a: Plan, b: Plan) => a.start_time.localeCompare(b.start_time));
      } else {
        promptAction.showToast({ message: `加载计划失败: ${result.message}` });
      }
    } catch (e) {
      const err = e as Error;
      promptAction.showToast({ message: `网络异常: ${err.message}` });
    } finally {
      this.isLoading = false;
    }
  }

  async togglePlanCompletion(planToUpdate: Plan): Promise<void> {
    const originalStatus = planToUpdate.is_completed;
    const planIndex = this.dailyPlanItems.findIndex((p: Plan) => p.id === planToUpdate.id);
    if (planIndex === -1) {
      return;
    }
    this.dailyPlanItems[planIndex].is_completed = !originalStatus;
    this.dailyPlanItems = [...this.dailyPlanItems];
    try {
      const result = await planService.updatePlan(planToUpdate.id, { is_completed: !originalStatus });
      if (result.code !== 200) {
        promptAction.showToast({ message: `更新失败: ${result.message}` });
        this.dailyPlanItems[planIndex].is_completed = originalStatus;
        this.dailyPlanItems = [...this.dailyPlanItems];
      }
    } catch (e) {
      promptAction.showToast({ message: `网络异常，更新失败` });
      this.dailyPlanItems[planIndex].is_completed = originalStatus;
      this.dailyPlanItems = [...this.dailyPlanItems];
    }
  }

  build() {
    // 1. 最外层使用 Scroll 组件，使其所有子组件都可滚动
    Scroll() {
      // 2. 在 Scroll 内部使用一个 Column 来垂直排列所有内容
      Column({ space: 16 }) { // 给页面元素之间增加一些垂直间距
        // 顶部标题和日期
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.message).fontSize(24).fontWeight(FontWeight.Bold)
            Text(`${this.months[this.getSelectedDate().getMonth()]} ${this.getSelectedDate()
              .getDate()}日, 周${this.weekDays[this.selectedDay - 1]}`)
              .fontSize(14).fontColor(Color.Gray)
          }.alignItems(HorizontalAlign.Start).layoutWeight(1)

          Button({ type: ButtonType.Circle }) {
            Image($r('app.media.calendar_icon')).width(24).height(24)
          }.width(44).height(44).backgroundColor(Color.White)
        }
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 20, // 顶部留出状态栏空间
          bottom: 10
        })

        // 周选择器 (水平滚动)
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.weekDays, (day: string, index: number) => {
              Column({ space: 8 }) {
                Text(day).fontSize(14).fontColor(this.selectedDay === index + 1 ? Color.White : Color.Gray)
                Text(this.getDayNumberFor(index).toString())
                  .width(36)
                  .height(36)
                  .borderRadius(18)
                  .backgroundColor(this.selectedDay === index + 1 ? Color.White : Color.Transparent)
                  .fontColor(this.selectedDay === index + 1 ? '#007DFF' : Color.Black)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .lineHeight(36)
              }
              .width(52)
              .height(80)
              .borderRadius(26)
              .backgroundColor(this.selectedDay === index + 1 ? '#007DFF' : Color.Transparent)
              .justifyContent(FlexAlign.Center)
              .animation({ duration: 300, curve: Curve.EaseInOut })
              .onClick(async () => {
                this.selectedDay = index + 1;
                await this.loadPlansForSelectedDay();
              })
            }, (item: string, index: number) => index.toString())
          }
        }.width('100%').scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
        .padding({ left: 20, right: 20 })

        // 概览卡片
        Column({ space: 12 }) {
          Row() {
            Text('今日概览').fontSize(18).fontWeight(FontWeight.Bold)
          }

          Row({ space: 8 }) {
            Text('完成度').fontSize(16)
            Text(`${this.getCompletionRate()}%`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#007DFF')
          }

          Progress({ value: this.getCompletionRate(), total: 100 })
            .width('100%').height(8).color('#007DFF').borderRadius(4)
        }
        .padding(16).backgroundColor(Color.White).borderRadius(16)
        .width('90%') // 使用百分比保持居中

        // 计划列表卡片
        Column({ space: 12 }) {
          Row() {
            Text('今日计划').fontSize(18).fontWeight(FontWeight.Bold)
          }

          if (this.isLoading) {
            LoadingProgress().width(40).height(40).margin({ top: 60, bottom: 60 })
          } else if (this.dailyPlanItems.length === 0) {
            Column() {
              Image($r('app.media.calendar_icon')).width(80).height(80).opacity(0.5).margin({ bottom: 16 })
              Text('今天没有计划，好好放松一下吧！').fontSize(16).fontColor(Color.Gray)
            }.width('100%').height(200).justifyContent(FlexAlign.Center)
          } else {
            // 3. 将 List 换回 Column + ForEach，因为它不再需要独立滚动
            Column({ space: 12 }) {
              ForEach(this.dailyPlanItems, (item: Plan) => {
                // 单个列表项的布局没有变化
                Row({ space: 12 }) {
                  Text(`${item.start_time}\n${item.end_time}`)
                    .fontSize(14).fontColor(Color.Gray).textAlign(TextAlign.Center).width(60)

                  Row({ space: 12 }) {
                    Column({ space: 4 }) {
                      Text(item.title).fontSize(16).fontWeight(FontWeight.Bold)
                      if (item.description) {
                        Text(item.description)
                          .fontSize(14).fontColor(Color.Gray)
                          .textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1)
                      }
                    }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                    Toggle({ type: ToggleType.Checkbox, isOn: item.is_completed })
                      .selectedColor('#007DFF').width(24).height(24)
                      .onChange(() => {
                        this.togglePlanCompletion(item);
                      })
                  }
                  .padding(16)
                  .backgroundColor('#F7F8FA') // 使用浅灰色背景
                  .borderRadius(12)
                  .layoutWeight(1)
                }.alignItems(VerticalAlign.Center)
              }, (item: Plan) => item.id.toString())
            }
          }
        }
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .width('90%') // 使用百分比保持居中
        // 4. 移除所有 layoutWeight(1) 属性
        .margin({ bottom: 20 }) // 在页面底部增加一些边距，避免内容紧贴屏幕边缘
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center) // 让所有子组件（卡片）水平居中
    }
    .backgroundColor('#F0F2F5')
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Auto) // 显示滚动条
    .edgeEffect(EdgeEffect.Spring) // 可以设置滚动到边缘的回弹效果
  }
}
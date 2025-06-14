import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { planService } from '../services/PlanService';
import { Plan } from '../models/PlanModels';
import http from '@ohos.net.http';

// 定义天气数据接口
interface WeatherData {
  max_degree: string;
  day_weather_short: string;
  time: string;
}

// 定义 forecast_24h 对象的类型别名
type Forecast24hCollection = Record<string, WeatherData>;

// 新增：为 API 响应中的空对象定义专用类，以满足 ArkTS 严格的类型要求
class ApiRiseObject {}
class ApiForecast1hObject {}

// 定义 API 响应中可能为空的嵌套对象类
class EmptyApiObject {}
class EmptyApiArray extends Array<object> {}

// 定义 API 响应中 data 对象的接口
interface WeatherApiResponseData {
  forecast_24h: Forecast24hCollection;
  // 其他可能存在的属性，如果需要可以使用 any 或更具体的接口
  air?: object | null;
  limit?: object | null;
  index?: object | null;
  observe?: object | null;
  tips?: object | null;
  alarm?: object[];
  rise?: object;
  forecast_1h?: object;
}

// 定义主响应接口
interface WeatherResponse {
  status: number;
  message: string;
  data: WeatherApiResponseData;
}

@Entry
@Component
export struct HealthPlanPage {
  @State message: string = '健康计划';
  @State selectedDay: number = new Date().getDay() === 0 ? 7 : new Date().getDay();
  @State isLoading: boolean = false;
  @State dailyPlanItems: Plan[] = [];
  @State temperatures: string[] = Array(7).fill('--°');
  @State weathers: string[] = Array(7).fill('--');

  private weekDays = ['一', '二', '三', '四', '五', '六', '日'];
  private months = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

  // 获取天气数据
  private async fetchWeatherData(): Promise<void> {
    let httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        'https://wis.qq.com/weather/common?source=pc&weather_type=observe|forecast_24h&province=山东&city=济南&county=历下区',
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          }
        }
      );
      
      console.log(`Weather API Response Code: ${response.responseCode}`);
      console.log(`Weather API Response Result: ${response.result}`);

      if (response.responseCode === 200) {
        const data = JSON.parse(response.result as string) as WeatherResponse; // 直接断言为接口类型
        console.log(`Parsed Weather Data: ${JSON.stringify(data)}`);

        if (data.status === 200 && data.data && data.data.forecast_24h) {
          const forecastObject = data.data.forecast_24h;
          const forecastArray: WeatherData[] = Object.values(forecastObject);

          // Sort the array by 'time' to ensure correct order
          forecastArray.sort((a, b) => new Date(a.time).getTime() - new Date(b.time).getTime());

          console.log(`Weather Forecast Array (after conversion and sort): ${JSON.stringify(forecastArray)}`);

          for (let i = 0; i < forecastArray.length; i++) {
            const dayForecast = forecastArray[i];
            if (dayForecast && dayForecast.time) {
              const forecastDate = new Date(dayForecast.time); // 获取预报日期
              // 计算星期几对应的 0-6 索引 (0:周一, ..., 6:周日)
              let dayOfWeekIndex = forecastDate.getDay(); // 0:周日, 1:周一, ..., 6:周六
              dayOfWeekIndex = (dayOfWeekIndex === 0) ? 6 : (dayOfWeekIndex - 1); // 转换为 0:周一, ..., 6:周日

              if (dayOfWeekIndex >= 0 && dayOfWeekIndex < 7) {
                this.temperatures[dayOfWeekIndex] = `${dayForecast.max_degree}°`;
                this.weathers[dayOfWeekIndex] = dayForecast.day_weather_short;
              }
            }
          }
          this.temperatures = [...this.temperatures]; // Trigger UI update
          this.weathers = [...this.weathers]; // Trigger UI update
        }
      }
    } catch (error) {
      console.error('获取天气数据失败:', error instanceof Error ? error.message : String(error));
    } finally {
      httpRequest.destroy();
    }
  }

  // --- 辅助方法 ---
  private getSelectedDate(): Date {
    const today = new Date();
    const todayDayOfWeek = today.getDay() === 0 ? 7 : today.getDay();
    const diff = this.selectedDay - todayDayOfWeek;
    return new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
  }

  private getCompletionRate(): number {
    if (this.dailyPlanItems.length === 0) return 100;
    const completedCount = this.dailyPlanItems.filter((item: Plan) => item.is_completed).length;
    return Math.round((completedCount / this.dailyPlanItems.length) * 100);
  }

  // --- 新增：专门用于计算日期数字的辅助方法 ---
  private getDayNumberFor(index: number): number {
    const today = new Date();
    const todayDayOfWeek = today.getDay() || 7;
    const targetDayOfWeek = index + 1;
    const diff = targetDayOfWeek - todayDayOfWeek;
    const targetDate = new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
    return targetDate.getDate();
  }

  // --- 核心逻辑函数 ---
  async aboutToAppear(): Promise<void> {
    await Promise.all([
      this.loadPlansForSelectedDay(),
      this.fetchWeatherData()
    ]);
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
    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      promptAction.showToast({ message: `网络异常: ${err.message}` });
    } finally {
      this.isLoading = false;
    }
  }

  async togglePlanCompletion(planToUpdate: Plan): Promise<void> {
    const originalStatus = planToUpdate.is_completed;
    const planIndex = this.dailyPlanItems.findIndex((p: Plan) => p.id === planToUpdate.id);
    if (planIndex === -1) return;
    this.dailyPlanItems[planIndex].is_completed = !originalStatus;
    this.dailyPlanItems = [...this.dailyPlanItems];
    try {
      const result = await planService.updatePlan(planToUpdate.id, { is_completed: !originalStatus });
      if (result.code !== 200) {
        promptAction.showToast({ message: `更新失败: ${result.message}` });
        this.dailyPlanItems[planIndex].is_completed = originalStatus;
        this.dailyPlanItems = [...this.dailyPlanItems];
      }
    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      promptAction.showToast({ message: `网络异常，更新失败: ${err.message}` });
      this.dailyPlanItems[planIndex].is_completed = originalStatus;
      this.dailyPlanItems = [...this.dailyPlanItems];
    }
  }

  // --- UI 构建函数 (已修复) ---
  build() {
    Column() {
      // 顶部标题和日期
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.message).fontSize(24).fontWeight(FontWeight.Bold)
          Text(`${this.months[this.getSelectedDate().getMonth()]} ${this.getSelectedDate().getDate()}日, 周${this.weekDays[this.selectedDay - 1]}`)
            .fontSize(14).fontColor(Color.Gray)
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.calendar_icon')).width(24).height(24)
        }.width(44).height(44).backgroundColor(Color.White)
      }.width('100%').padding({ left: 20, right: 20, top: 20, bottom: 10 })

      // 周选择器
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.weekDays, (day: string, index: number) => {
            Column({ space: 4 }) {
              Text(day).fontSize(14).fontColor(this.selectedDay === index + 1 ? Color.White : Color.Gray)
              // --- 在这里调用新的辅助方法 ---
              Text(this.getDayNumberFor(index).toString())
                .width(36).height(36).borderRadius(18)
                .backgroundColor(this.selectedDay === index + 1 ? Color.White : Color.Transparent)
                .fontColor(this.selectedDay === index + 1 ? '#007DFF' : Color.Black)
                .fontSize(16).fontWeight(FontWeight.Bold)
                .textAlign(TextAlign.Center).lineHeight(36)
              Text(this.temperatures[index])
                .fontSize(12)
                .fontColor(this.selectedDay === index + 1 ? Color.White : Color.Gray)
              Text(this.weathers[index])
                .fontSize(12)
                .fontColor(this.selectedDay === index + 1 ? Color.White : Color.Gray)
            }
            .width(52).height(100).borderRadius(26).backgroundColor(this.selectedDay === index + 1 ? '#007DFF' : Color.Transparent)
            .justifyContent(FlexAlign.Center).animation({ duration: 300, curve: Curve.EaseInOut })
            .onClick(async () => {
              this.selectedDay = index + 1;
              await this.loadPlansForSelectedDay();
            })
          }, (item: string, index: number) => index.toString())
        }
      }.width('100%').scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
      .padding({ left: 20, right: 20, top: 10, bottom: 15 })
      // 概览卡片
      Column({ space: 12 }) {
        Row() { Text('今日概览').fontSize(18).fontWeight(FontWeight.Bold) }
        Row({ space: 8 }) {
          Text('完成度').fontSize(16)
          Text(`${this.getCompletionRate()}%`).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#007DFF')
        }
        Progress({ value: this.getCompletionRate(), total: 100 }).width('100%').height(8).color('#007DFF').borderRadius(4)
      }.padding(16).backgroundColor(Color.White).borderRadius(16).width('90%').margin({ bottom: 16 })
      // 计划列表卡片
      Column({ space: 12 }) {
        Row() { Text('今日计划').fontSize(18).fontWeight(FontWeight.Bold) }
        if (this.isLoading) {
          LoadingProgress().width(40).height(40).margin({ top: 60, bottom: 60 })
        } else if (this.dailyPlanItems.length === 0) {
          Column() {
            Image($r('app.media.calendar_icon')).width(80).height(80).opacity(0.5).margin({ bottom: 16 })
            Text('今天没有计划，好好放松一下吧！').fontSize(16).fontColor(Color.Gray)
          }.width('100%').height(200).justifyContent(FlexAlign.Center)
        } else {
          ForEach(this.dailyPlanItems, (item: Plan) => {
            Row({ space: 12 }) {
              Text(`${item.start_time}\n${item.end_time}`).fontSize(14).fontColor(Color.Gray).textAlign(TextAlign.Center).width(60)
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(item.title).fontSize(16).fontWeight(FontWeight.Bold)
                  if (item.description) {
                    Text(item.description).fontSize(14).fontColor(Color.Gray).textOverflow({ overflow: TextOverflow.Ellipsis }).maxLines(1)
                  }
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                Toggle({ type: ToggleType.Checkbox, isOn: item.is_completed })
                  .selectedColor('#007DFF').width(24).height(24)
                  .onChange(() => { this.togglePlanCompletion(item); })
              }.padding(16).layoutWeight(1).backgroundColor(Color.White).borderRadius(12)
            }.alignItems(VerticalAlign.Center)
          }, (item: Plan) => item.id.toString())
        }
      }.padding(16).backgroundColor(Color.White).borderRadius(16)
    }
    .backgroundColor('#F0F2F5').height('100%')
  }
}
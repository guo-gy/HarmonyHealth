import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { planService } from '../services/PlanService';
import { Plan } from '../models/PlanModels';
import http from '@ohos.net.http';

// ===== 天气相关接口定义 =====
// 定义单个天气数据点的接口
interface WeatherData {
  max_degree: string;      // 最高温度
  day_weather_short: string; // 天气状况（如：晴、多云、雨等）
  time: string;            // 时间戳
}

// 定义24小时天气预报集合的类型
// 使用Record类型，键为字符串，值为WeatherData类型
type Forecast24hCollection = Record<string, WeatherData>;

// 新增：为 API 响应中的空对象定义专用类，以满足 ArkTS 严格的类型要求
class ApiRiseObject {}
class ApiForecast1hObject {}

// 定义 API 响应中可能为空的嵌套对象类
class EmptyApiObject {}
class EmptyApiArray extends Array<object> {}

// 定义天气API响应中data对象的接口
interface WeatherApiResponseData {
  forecast_24h: Forecast24hCollection;  // 24小时天气预报数据
  air?: object | null;                  // 空气质量数据（可选）
  limit?: object | null;                // 限行信息（可选）
  index?: object | null;                // 生活指数（可选）
  observe?: object | null;              // 实时天气观测（可选）
  tips?: object | null;                 // 天气提示（可选）
  alarm?: object[];                     // 天气预警（可选）
  rise?: object;                        // 日出日落信息（可选）
  forecast_1h?: object;                 // 1小时预报（可选）
}

// 定义完整的天气API响应接口
interface WeatherResponse {
  status: number;                       // 响应状态码
  message: string;                      // 响应消息
  data: WeatherApiResponseData;         // 天气数据
}

@Entry
@Component
export struct HealthPlanPage {
  @State message: string = '健康计划';
  @State selectedDay: number = new Date().getDay() === 0 ? 7 : new Date().getDay();
  @State isLoading: boolean = false;
  @State dailyPlanItems: Plan[] = [];
  @State temperatures: string[] = Array(7).fill('--°');  // 初始化7天的温度数组
  @State weathers: string[] = Array(7).fill('--');       // 初始化7天的天气数组

  private weekDays = ['一', '二', '三', '四', '五', '六', '日'];
  private months = ['一月', '二月', '三月', '四月', '五月', '六月', '七月', '八月', '九月', '十月', '十一月', '十二月'];

  // --- 核心逻辑函数 ---

  // 页面即将显示时，并行加载计划和天气数据
  async aboutToAppear(): Promise<void> {
    await Promise.all([
      this.loadPlansForSelectedDay(),
      this.fetchWeatherData()
    ]);
  }

  // ===== 天气数据获取方法 =====
  /**
   * 获取天气数据
   * 调用腾讯天气API获取济南历下区的天气信息
   * 处理返回数据并更新状态变量
   */
  private async fetchWeatherData(): Promise<void> {
    let httpRequest = http.createHttp();
    try {
      // 发送HTTP请求获取天气数据
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

      if (response.responseCode === 200) {
        // 解析返回的JSON数据
        const data = JSON.parse(response.result as string) as WeatherResponse;
        console.log(`Parsed Weather Data: ${JSON.stringify(data)}`);

        if (data.status === 200 && data.data && data.data.forecast_24h) {
          // 获取24小时预报数据
          const forecastObject = data.data.forecast_24h;
          // 将对象转换为数组以便处理
          const forecastArray: WeatherData[] = Object.values(forecastObject);

          // 按时间排序确保数据顺序正确
          forecastArray.sort((a, b) => new Date(a.time).getTime() - new Date(b.time).getTime());

          console.log(`Weather Forecast Array (after conversion and sort): ${JSON.stringify(forecastArray)}`);
          let weather=""
          // 处理每一天的天气数据
          for (let i = 0; i < forecastArray.length; i++) {
            const dayForecast = forecastArray[i];
            if (dayForecast && dayForecast.time) {
              const forecastDate = new Date(dayForecast.time);
              // 计算星期几对应的索引 (0:周一, ..., 6:周日)
              let dayOfWeekIndex = forecastDate.getDay();
              dayOfWeekIndex = (dayOfWeekIndex === 0) ? 6 : (dayOfWeekIndex - 1);

              // 更新对应日期的温度和天气数据
              if (dayOfWeekIndex >= 0 && dayOfWeekIndex < 7) {
                this.temperatures[dayOfWeekIndex] = `${dayForecast.max_degree}°`;
                this.weathers[dayOfWeekIndex] = dayForecast.day_weather_short;
                weather+=this.weathers[dayOfWeekIndex];
              }
              AppStorage.SetOrCreate("weather", weather);
            }
          }
          // 触发UI更新
          this.temperatures = [...this.temperatures];
          this.weathers = [...this.weathers];
        }
      }
    } catch (error) {
      // 错误处理
      console.error('获取天气数据失败:', error instanceof Error ? error.message : String(error));
    } finally {
      // 清理HTTP请求
      httpRequest.destroy();
    }
  }

  // 加载选定日期的计划
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

  // 切换计划完成状态
  async togglePlanCompletion(planToUpdate: Plan): Promise<void> {
    const originalStatus = planToUpdate.is_completed;
    const planIndex = this.dailyPlanItems.findIndex((p: Plan) => p.id === planToUpdate.id);
    if (planIndex === -1) {
      return;
    }
    // 立即更新UI以获得即时反馈
    this.dailyPlanItems[planIndex].is_completed = !originalStatus;
    this.dailyPlanItems = [...this.dailyPlanItems];
    try {
      const result = await planService.updatePlan(planToUpdate.id, { is_completed: !originalStatus });
      // 如果API调用失败，则恢复原状
      if (result.code !== 200) {
        promptAction.showToast({ message: `更新失败: ${result.message}` });
        this.dailyPlanItems[planIndex].is_completed = originalStatus;
        this.dailyPlanItems = [...this.dailyPlanItems];
      }
    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      promptAction.showToast({ message: `网络异常，更新失败: ${err.message}` });
      // 如果API调用失败，则恢复原状
      this.dailyPlanItems[planIndex].is_completed = originalStatus;
      this.dailyPlanItems = [...this.dailyPlanItems];
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
    if (this.dailyPlanItems.length === 0) {
      return 100; // 如果没有计划，可以视为100%完成
    }
    const completedCount = this.dailyPlanItems.filter((item: Plan) => item.is_completed).length;
    return Math.round((completedCount / this.dailyPlanItems.length) * 100);
  }

  private getDayNumberFor(index: number): number {
    const today = new Date();
    const todayDayOfWeek = today.getDay() || 7;
    const targetDayOfWeek = index + 1;
    const diff = targetDayOfWeek - todayDayOfWeek;
    const targetDate = new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
    return targetDate.getDate();
  }

  build() {
    // 1. 最外层使用 Scroll 组件，使其所有子组件都可滚动
    Scroll() {
      // 2. 在 Scroll 内部使用一个 Column 来垂直排列所有内容
      Column({ space: 16 }) {
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
        .padding({ left: 20, right: 20, top: 20, bottom: 10 })

        // 周选择器 (水平滚动)
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.weekDays, (day: string, index: number) => {
              Column({ space: 4 }) {
                Text(day).fontSize(14).fontColor(this.selectedDay === index + 1 ? Color.White : Color.Gray)

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
              .width(52).height(100).borderRadius(26)
              .backgroundColor(this.selectedDay === index + 1 ? '#007DFF' : Color.Transparent)
              .justifyContent(FlexAlign.Center)
              .animation({ duration: 300, curve: Curve.EaseInOut })
              .onClick(async () => {
                this.selectedDay = index + 1;
                // 点击后只加载计划，天气数据在页面加载时已获取一周
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
            // 3. 使用 Column + ForEach 实现列表，因为它不再需要独立滚动
            Column({ space: 12 }) {
              ForEach(this.dailyPlanItems, (item: Plan) => {
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
        .margin({ bottom: 20 }) // 在页面底部增加一些边距
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center) // 让所有子组件（卡片）水平居中
    }
    .backgroundColor('#F0F2F5')
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }
}
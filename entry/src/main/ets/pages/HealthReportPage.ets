import { HealthReport, WorkoutTrend, HealthPlan } from '../models/HealthReportModels';
import { HealthReportService } from '../services/HealthReportService';

@Entry
@Component
struct HealthReportPage {
  @State report: HealthReport | null = null;
  @State isLoading: boolean = true;
  private healthReportService: HealthReportService = HealthReportService.getInstance();

  aboutToAppear() {
    this.generateReport();
  }

  async generateReport() {
    try {
      this.report = await this.healthReportService.generateReport();
    } catch (error) {
      console.error('生成报告失败:', error instanceof Error ? error.message : '未知错误');
    } finally {
      this.isLoading = false;
    }
  }

  @Builder
  WorkoutTrendChart(trend: WorkoutTrend[]) {
    Column() {
      Text('运动趋势')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        ForEach(trend, (item: WorkoutTrend) => {
          Column() {
            Text(item.count.toString())
              .fontSize(12)
              .fontColor('#666666')

            Column()
              .width(20)
              .height(`${Math.min(item.count * 20, 100)}%`)
              .backgroundColor('#007DFF')
              .borderRadius(10)
              .margin({ top: 5, bottom: 5 })

            Text(item.date)
              .fontSize(12)
              .fontColor('#666666')
          }
          .height(200)
          .justifyContent(FlexAlign.End)
          .layoutWeight(1)
        })
      }
      .width('100%')
      .height(200)
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(16)
    .margin({ bottom: 16 })
  }

  @Builder
  FuturePlansChart(plans: HealthPlan[]) {
    Column() {
      Text('未来规划')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      ForEach(plans, (item: HealthPlan) => {
        Column() {
          Row() {
            Column() {
              Text(item.type)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')

              Text(item.period)
                .fontSize(12)
                .fontColor('#666666')
                .margin({ top: 4 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Text(`${item.current}/${item.target}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ bottom: 8 })

          Row() {
            Column()
              .width(`${Math.min((item.current / item.target) * 100, 100)}%`)
              .height(8)
              .backgroundColor('#007DFF')
              .borderRadius(4)

            Column()
              .width(`${Math.max(100 - (item.current / item.target) * 100, 0)}%`)
              .height(8)
              .backgroundColor('#EEEEEE')
              .borderRadius(4)
          }
          .width('100%')
        }
        .width('100%')
        .margin({ bottom: 16 })
      })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(16)
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text('健康报告')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })

      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .margin({ top: 100 })
      } else if (this.report) {
        Scroll() {
          Column({ space: 16 }) {
            // 基本信息卡片
            Column() {
              Text('基本信息')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 })

              Grid() {
                GridItem() {
                  Column() {
                    Text('身高')
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.report.basicInfo.height}cm`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                }

                GridItem() {
                  Column() {
                    Text('体重')
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.report.basicInfo.weight}kg`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                }

                GridItem() {
                  Column() {
                    Text('年龄')
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.report.basicInfo.age}岁`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                }

                GridItem() {
                  Column() {
                    Text('运动次数')
                      .fontSize(14)
                      .fontColor('#666666')
                    Text(`${this.report.basicInfo.workoutCount}次`)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 4 })
                  }
                }
              }
              .columnsTemplate('1fr 1fr')
              .rowsTemplate('1fr 1fr')
              .width('100%')
              .height(120)
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(16)
            .padding(16)

            // 健康分析卡片
            Column() {
              Text('健康分析')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 })

              Column({ space: 12 }) {
                Row() {
                  Text('BMI指数')
                    .fontSize(14)
                    .fontColor('#666666')
                  Text(`${this.report.analysis.bmi.toFixed(1)} (${this.report.analysis.bmiStatus})`)
                    .fontSize(14)
                    .fontColor('#007DFF')
                }

                Text(this.report.analysis.workoutAnalysis)
                  .fontSize(14)
                  .fontColor('#666666')

                Text(this.report.analysis.healthSuggestion)
                  .fontSize(14)
                  .fontColor('#666666')
              }
            }
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(16)
            .padding(16)

            // 运动趋势图表
            this.WorkoutTrendChart(this.report.charts.workoutTrend)

            // 未来规划图表
            this.FuturePlansChart(this.report.charts.plans)

            // 健康计划
            Column() {
              Text('健康计划')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 })

              // 长期规划
              Column() {
                Text('长期规划')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })
                  .fontColor('#666666')
                
                Text('基于您的BMI指数和运动习惯，AI建议您：')
                  .fontSize(14)
                  .margin({ bottom: 8 })
                  .fontColor('#666666')
                
                Text('1. 制定3个月减重计划，目标体重65kg')
                  .fontSize(14)
                  .margin({ bottom: 4 })
                  .fontColor('#666666')
                
                Text('2. 建立每周5次运动的习惯')
                  .fontSize(14)
                  .margin({ bottom: 4 })
                  .fontColor('#666666')
                
                Text('3. 保持每日10000步的运动量')
                  .fontSize(14)
                  .margin({ bottom: 16 })
                  .fontColor('#666666')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin({ bottom: 16 })

              // 短期规划
              Column() {
                Text('短期规划')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })
                  .fontColor('#666666')
                
                Text('未来两周的具体行动计划：')
                  .fontSize(14)
                  .margin({ bottom: 8 })
                  .fontColor('#666666')
                
                Text('1. 每天记录饮食和运动情况')
                  .fontSize(14)
                  .margin({ bottom: 4 })
                  .fontColor('#666666')
                
                Text('2. 每周进行3次力量训练')
                  .fontSize(14)
                  .margin({ bottom: 4 })
                  .fontColor('#666666')
                
                Text('3. 保持每天8000步的基础运动量')
                  .fontSize(14)
                  .margin({ bottom: 16 })
                  .fontColor('#666666')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .margin({ bottom: 16 })

              // 计划列表
              ForEach(this.report.charts.plans, (plan: HealthPlan) => {
                Column() {
                  Row() {
                    Text(plan.type)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                    Blank()
                    Text(plan.period)
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Row() {
                    Text(`${plan.current}/${plan.target}`)
                      .fontSize(14)
                      .fontColor('#666666')
                    Blank()
                    Text(`${Math.round(plan.progress * 100)}%`)
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .width('100%')
                  .margin({ bottom: 8 })

                  Progress({ 
                    value: plan.progress * 100, 
                    total: 100,
                    type: ProgressType.Linear 
                  })
                    .width('100%')
                    .height(4)
                    .color('#007DFF')
                    .backgroundColor('#E5E5E5')
                }
                .width('100%')
                .padding(16)
                .backgroundColor(Color.White)
                .borderRadius(8)
                .margin({ bottom: 16 })
              })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#F5F5F5')
            .borderRadius(16)
          }
          .width('100%')
          .padding({ left: 16, right: 16, bottom: 16 })
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }
} 
import { HealthCharts, HealthReport } from '../models/HealthReportModels';
import { HealthReportService } from '../services/HealthReportService';

@Entry
@Component
struct HealthReportPage {
  @State report: HealthReport | null = null;
  @State isLoading: boolean = true;
  private healthReportService: HealthReportService = HealthReportService.getInstance();
  @State advise: string='';
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
  WorkoutTrendChart(trend: HealthCharts) {
    Column() {
      Text('运动趋势')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })

      Row() {
        ForEach(trend.workoutCount, (item: number, index: number) => {
          Column() {
            Text(item.toString())
              .fontSize(12)
              .fontColor('#666666')

            Column()
              .width(20)
              .height(`${Math.min(item * 20, 100)}%`)
              .backgroundColor('#007DFF')
              .borderRadius(10)
              .margin({ top: 5, bottom: 5 })

            Text(index.toString())
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
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })

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
                    Text(`${this.report.basicInfo.over}次`)
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
            this.WorkoutTrendChart(this.report.charts)


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
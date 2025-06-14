import promptAction from '@ohos.promptAction';
import { InformationData } from '../models/InformationModels';
import { informationService } from '../services/InformationService';
import UserSessionManager from '../common/UserSession';
import router from '@ohos.router';

// 定义健康指标接口
interface HealthMetric {
  date: string;
  weight: number;
  steps: number;
  sleepHours: number;
  waterIntake: number;
}

// 定义选择项接口
interface SelectOption {
  value: string;
}

// 定义运动记录接口
interface WorkoutRecord {
  type: string;
  duration: number;
  calories: number;
  date: string;
  icon: Resource;
}

@Component
export struct ProfilePage {
  @State isRefreshing: boolean = false;
  @State message: string = '个人中心';
  @State profile: InformationData = {};
  @State healthMetrics: HealthMetric[] = [];
  @State isLoading: boolean = false;
  @State selectedMetric: string = '体重';
  @State showHealthReport: boolean = false;
  @State currentUsername: string = '访客';
  @State workoutRecords: WorkoutRecord[] = [
    {
      type: '有氧跑步',
      duration: 45,
      calories: 320,
      date: '今天 08:30',
      icon: $r('app.media.running_icon')
    },
    {
      type: '力量训练',
      duration: 60,
      calories: 280,
      date: '昨天 17:15',
      icon: $r('app.media.strength_icon')
    },
    {
      type: '户外骑行',
      duration: 90,
      calories: 450,
      date: '昨天 10:00',
      icon: $r('app.media.cycling_icon')
    }
  ];
  private metricOptions: SelectOption[] = [
    { value: '体重' },
    { value: '步数' },
    { value: '睡眠' },
    { value: '饮水量' }
  ];

  async aboutToAppear() {
    this.isLoading = true;
    const username = await UserSessionManager.getLoggedInUsername();
    if (username) {
      this.currentUsername = username;
    }
    await this.loadProfileData();
    this.isLoading = false;
  }

  async loadProfileData() {
    try {
      const heightResult = await informationService.getAttribute('height');
      const weightResult = await informationService.getAttribute('weight');
      const ageResult = await informationService.getAttribute('age');
      const infoResult = await informationService.getAttribute('information');
      const targetResult = await informationService.getAttribute('target');

      const newProfile: InformationData = {};
      if (heightResult.code === 200 && heightResult.data) {
        newProfile.height = heightResult.data.height;
      }
      if (weightResult.code === 200 && weightResult.data) {
        newProfile.weight = weightResult.data.weight;
      }
      if (ageResult.code === 200 && ageResult.data) {
        newProfile.age = ageResult.data.age;
      }
      if (infoResult.code === 200 && infoResult.data) {
        newProfile.information = infoResult.data.information;
      }
      if (targetResult.code === 200 && targetResult.data) {
        newProfile.target = targetResult.data.target;
      }

      this.profile = newProfile;
      promptAction.showToast({ message: '个人信息加载成功！' });

    } catch (e) {
      promptAction.showToast({ message: `加载失败: ${e.message}` });
    }
  }

  // 获取指标值和单位的辅助方法
  getMetricInfo(item:
    HealthMetric
  ):
    [number, number, string] {
    let value = 0;
    let maxValue = 100;
    let unit = '';

    if (this.selectedMetric === '体重') {
      value = item.weight;
      maxValue = 100;
      unit = 'kg';
    } else if (this.selectedMetric === '步数') {
      value = item.steps;
      maxValue = 10000;
      unit = '步';
    } else if (this.selectedMetric === '睡眠') {
      value = item.sleepHours;
      maxValue = 10;
      unit = 'h';
    } else if (this.selectedMetric === '饮水量') {
      value = item.waterIntake;
      maxValue = 3000;
      unit = 'ml';
    }

    return [value, maxValue, unit];
  }

  // 修改 @Builder 方法的实现方式
  @
  Builder
  ChartColumnBuilder(item:
    HealthMetric
  ) {
    Column() {
      Text(`${this.getMetricInfo(item)[0]
        .toFixed(this.selectedMetric === '体重' || this.selectedMetric === '睡眠' ? 1 :
          0)}${this.getMetricInfo(item)[2]}`)
        .fontSize(12)
        .fontColor('#666666')

      Column()
        .width(20)
        .height(`${Math.min(this.getMetricInfo(item)[0] / this.getMetricInfo(item)[1] * 100, 100)}%`)
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
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Text(this.message)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Blank()
          .layoutWeight(1)

        Button() {
          Image($r('app.media.settings_icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor('#F0F0F0')
        .borderRadius(20)
        .onClick(() => {
          // 打开设置页面
          promptAction.showDialog({
            title: '设置',
            message: '设置功能正在开发中',
            buttons: [{ text: '确定', color: '#007DFF' }]
          });
        })
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })

      Scroll() {
        Column({ space: 16 }) {
          // 用户信息卡片
          Column() {
            Row() {
              Column() {
                Row() {
                  // Image(this.userInfo.avatar)
                  //   .width(80)
                  //   .height(80)
                  //   .borderRadius(40)

                  Column() {
                    Text(this.currentUsername)
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Text(`目标: ${this.profile.target}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 5 })

                    //用户等级进度条
                    Row() {
                      Text(`LV.1000`)
                        .fontSize(12)
                        .fontColor('#007DFF')
                        .fontWeight(FontWeight.Medium)

                      Row() {
                        Progress({ value: 10000, total: 10000 })
                          .color('#007DFF')
                          .backgroundColor('#EEEEEE')
                          .height(6)
                          .width('100%')
                          .borderRadius(3)
                      }
                      .layoutWeight(1)
                      .margin({ left: 8, right: 8 })

                      Text(`${10000}/${10000}`)
                        .fontSize(12)
                        .fontColor('#999999')
                    }
                    .width('100%')
                    .alignItems(VerticalAlign.Center)
                    .margin({ top: 6 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 15 })
                  .layoutWeight(1)
                }
                .width('100%')

                Button('编辑资料')
                  .width('100%')
                  .height(44)
                  .borderRadius(22)
                  .backgroundColor('#007DFF')
                  .fontColor(Color.White)
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .margin({ top: 16 })
                  .onClick(() => {
                    // 编辑个人信息
                    promptAction.showDialog({
                      title: '编辑个人信息',
                      message: '编辑功能正在开发中',
                      buttons: [{ text: '确定', color: '#007DFF' }]
                    });
                  })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .padding(20)

            Divider()
              .width('100%')
              .color('#EEEEEE')
              .strokeWidth(1)

            // 身体数据
            Grid() {
              // 身高卡片
              GridItem() {
                Column() {
                  Text('身高')
                    .fontSize(14)
                    .fontColor('#666666')

                  Row() {
                    Text(`${this.profile.height}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Text('cm')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 4, bottom: 2 })
                      .alignSelf(ItemAlign.End)
                  }
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .rowStart(0)
              .rowEnd(0)
              .columnStart(0)
              .columnEnd(0)

              // 体重卡片
              GridItem() {
                Column() {
                  Text('体重')
                    .fontSize(14)
                    .fontColor('#666666')

                  Row() {
                    Text(`${this.profile.weight}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Text('kg')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 4, bottom: 2 })
                      .alignSelf(ItemAlign.End)
                  }
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .rowStart(0)
              .rowEnd(0)
              .columnStart(1)
              .columnEnd(1)

              // 年龄卡片
              GridItem() {
                Column() {
                  Text('年龄')
                    .fontSize(14)
                    .fontColor('#666666')

                  Row() {
                    Text(`${this.profile.age}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Text('岁')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 4, bottom: 2 })
                      .alignSelf(ItemAlign.End)
                  }
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .rowStart(0)
              .rowEnd(0)
              .columnStart(2)
              .columnEnd(2)

              // 运动次数卡片
              GridItem() {
                Column() {
                  Text('运动次数')
                    .fontSize(14)
                    .fontColor('#666666')

                  Row() {
                    Text(`${this.profile.age}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')

                    Text('次')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 4, bottom: 2 })
                      .alignSelf(ItemAlign.End)
                  }
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
              .rowStart(0)
              .rowEnd(0)
              .columnStart(3)
              .columnEnd(3)
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .rowsTemplate('80vp')
            .width('100%')
            .height(80)
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // // 健康数据趋势卡片
          // Column() {
          //   Row() {
          //     Text('健康趋势')
          //       .fontSize(16)
          //       .fontWeight(FontWeight.Bold)
          //       .fontColor('#333333')
          //
          //     Blank()
          //       .layoutWeight(1)
          //
          //     Row() {
          //       ForEach(this.metricOptions, (item: SelectOption) => {
          //         Text(item.value)
          //           .fontSize(14)
          //           .fontColor(this.selectedMetric === item.value ? '#007DFF' : '#999999')
          //           .fontWeight(this.selectedMetric === item.value ? FontWeight.Medium : FontWeight.Normal)
          //           .padding({
          //             left: 8,
          //             right: 8,
          //             top: 4,
          //             bottom: 4
          //           })
          //           .borderRadius(12)
          //           .backgroundColor(this.selectedMetric === item.value ? 'rgba(0, 125, 255, 0.1)' : 'transparent')
          //           .margin({ right: 8 })
          //           .onClick(() => {
          //             this.selectedMetric = item.value;
          //           })
          //       })
          //     }
          //   }
          //   .width('100%')
          //   .padding({
          //     top: 16,
          //     bottom: 16,
          //     left: 16,
          //     right: 16
          //   })
          //
          //   if (this.isLoading) {
          //     LoadingProgress()
          //       .color('#007DFF')
          //       .width(50)
          //       .height(50)
          //       .margin({ top: 20, bottom: 20 })
          //   } else {
          //     Row() {
          //       ForEach(this.healthMetrics, (item: HealthMetric) => {
          //         this.ChartColumnBuilder(item)
          //       })
          //     }
          //     .width('100%')
          //     .height(200)
          //     .padding({ left: 16, right: 16, bottom: 16 })
          //   }
          // }
          // .width('90%')
          // .backgroundColor('#FFFFFF')
          // .borderRadius(16)
          // .shadow({
          //   radius: 8,
          //   color: 'rgba(0, 0, 0, 0.05)',
          //   offsetX: 0,
          //   offsetY: 2
          // })

          // 运动记录卡片
          Column({ space: 8 }) {
            Row() {
              Text('最近运动')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')

              Blank()
                .layoutWeight(1)

              Row() {
                Text('查看全部')
                  .fontSize(14)
                  .fontColor('#007DFF')

                Image($r('app.media.arrow_right'))
                  .width(16)
                  .height(16)
                  .margin({ left: 4 })
              }
              .backgroundColor('transparent')
              .height(32)
            }
            .width('100%')
            .padding({ top: 16, left: 16, right: 16 })

            ForEach(this.workoutRecords, (record: WorkoutRecord) => {
              Row() {
                Image(record.icon)
                  .width(50)
                  .height(50)
                  .borderRadius(25)

                Column() {
                  Text(record.type)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')

                  Row() {
                    Text(`${record.duration}分钟`)
                      .fontSize(14)
                      .fontColor('#999999')

                    Text('·')
                      .fontSize(14)
                      .fontColor('#999999')
                      .margin({ left: 6, right: 6 })

                    Text(`${record.calories}千卡`)
                      .fontSize(14)
                      .fontColor('#999999')
                  }
                  .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })

                Column() {
                  Text(record.date)
                    .fontSize(14)
                    .fontColor('#999999')

                  Image($r('app.media.detail_icon'))
                    .width(24)
                    .height(24)
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFFFF')
              .borderRadius(12)
            })

            Button('开始新的运动')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor('#007DFF')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({
                top: 4,
                bottom: 16,
                left: 16,
                right: 16
              })
          }
          .width('90%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // 健康报告按钮
          Button() {
            Row() {
              Image($r('app.media.report_icon'))
                .width(24)
                .height(24)
                .margin({ right: 8 })

              Text('生成健康报告')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .height(56)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/HealthReportPage' });
          })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
    .padding({ bottom: 16 })
  }
}

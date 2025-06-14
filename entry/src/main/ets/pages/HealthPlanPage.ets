import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 定义成就接口
interface Achievement {
  title: string;
  description: string;
  icon: Resource;
  unlocked: boolean;
  progress?: number; // 可选的进度值
}

@Component
export struct HealthPlanPage {
  @State message: string = '健康计划';
  @State selectedDay: number = new Date().getDay() || 7; // 获取当前星期几，周日为0转为7
  @State selectedDate: Date = new Date();
  @State isLoading: boolean = false;
  @State completionRate: number = 65;
  @State achievements: Achievement[] = [
    {
      title: '运动达人',
      description: '连续7天完成运动计划',
      icon: $r('app.media.badge_exercise'),
      unlocked: true,
      progress: 100
    },
    {
      title: '饮食均衡',
      description: '连续5天遵循健康饮食',
      icon: $r('app.media.badge_diet'),
      unlocked: false,
      progress: 60
    },
    {
      title: '水分充足',
      description: '连续3天达成饮水目标',
      icon: $r('app.media.badge_water'),
      unlocked: true,
      progress: 100
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
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')

          Text(`${this.months[this.selectedDate.getMonth()]} ${this.selectedDate.getDate()}, ${this.selectedDate.getFullYear()}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        .alignItems(HorizontalAlign.Start)

        Blank()
          .layoutWeight(1)

        Button() {
          Image($r('app.media.calendar_icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor('#F0F0F0')
        .borderRadius(20)
      }
      .width('100%')
      .padding({
        left: 20,
        right: 20,
        top: 20,
        bottom: 10
      })

      // 周选择器
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.weekDays, (day: string, index: number) => {
            Column() {
              Text(day)
                .fontSize(12)
                .fontColor(this.selectedDay === index + 1 ? '#007DFF' : '#999999')

              Text(`${new Date(this.selectedDate.getTime() -
                ((this.selectedDate.getDay() || 7) - index - 1) * 86400000).getDate()}`)
                .fontSize(20)
                .fontWeight(this.selectedDay === index + 1 ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.selectedDay === index + 1 ? '#FFFFFF' : '#333333')
            }
            .width(48)
            .height(70)
            .padding(5)
            .borderRadius(24)
            .backgroundColor(this.selectedDay === index + 1 ? '#007DFF' : 'transparent')
            .justifyContent(FlexAlign.Center)
            .animation({
              duration: 250,
              curve: Curve.EaseOut
            })
            .onClick(() => {
              this.selectedDay = index + 1;
              // 计算选中日期
              const today = new Date();
              const diff = index + 1 - (today.getDay() || 7);
              this.selectedDate = new Date(today.getTime() + diff * 24 * 60 * 60 * 1000);
            })
          })
        }
      }
      .width('100%')
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .padding({
        left: 20,
        right: 20,
        top: 10,
        bottom: 15
      })

      // 今日计划内容
      Scroll() {
        Column({ space: 16 }) {
          // 进度概览卡片
          Row() {
            Column({ space: 6 }) {
              Row({ space: 8 }) {
                Text('今日完成度')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')

                Text(`${this.completionRate}%`)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#007DFF')
              }

              Progress({ value: this.completionRate, total: 100 })
                .color('#007DFF')
                .backgroundColor('#EEEEEE')
                .width('100%')
                .height(8)
                .borderRadius(4)
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // 数据概览卡片
          Column({ space: 16 }) {
            Text('今日目标')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)

            Row({ space: 16 }) {
              // 步数卡片
              Column() {
                Row() {
                  Image($r('app.media.steps_icon'))
                    .width(24)
                    .height(24)
                    .margin({ right: 8 })

                  Text('步数')
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .alignItems(VerticalAlign.Center)

                Text('10000 步')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .height(100)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .shadow({
                radius: 4,
                color: 'rgba(0, 0, 0, 0.05)',
                offsetX: 0,
                offsetY: 2
              })

              // 卡路里卡片
              Column() {
                Row() {
                  Image($r('app.media.calories_icon'))
                    .width(24)
                    .height(24)
                    .margin({ right: 8 })

                  Text('卡路里')
                    .fontSize(14)
                    .fontColor('#666666')
                }
                .alignItems(VerticalAlign.Center)

                Text('350 千卡')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .height(100)
              .backgroundColor('#FFFFFF')
              .borderRadius(16)
              .padding(12)
              .justifyContent(FlexAlign.Center)
              .shadow({
                radius: 4,
                color: 'rgba(0, 0, 0, 0.05)',
                offsetX: 0,
                offsetY: 2
              })


              Row({ space: 16 }) {
                // 运动时间卡片
                Column() {
                  Row() {
                    Image($r('app.media.time_icon'))
                      .width(24)
                      .height(24)
                      .margin({ right: 8 })

                    Text('运动时间')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .alignItems(VerticalAlign.Center)

                  Text('45 分钟')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 8 })
                }
                .layoutWeight(1)
                .height(100)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .shadow({
                  radius: 4,
                  color: 'rgba(0, 0, 0, 0.05)',
                  offsetX: 0,
                  offsetY: 2
                })

                // 饮水量卡片
                Column() {
                  Row() {
                    Image($r('app.media.water_icon'))
                      .width(24)
                      .height(24)
                      .margin({ right: 8 })

                    Text('饮水量')
                      .fontSize(14)
                      .fontColor('#666666')
                  }
                  .alignItems(VerticalAlign.Center)

                  Text('2000 毫升')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#333333')
                    .margin({ top: 8 })
                }
                .layoutWeight(1)
                .height(100)
                .backgroundColor('#FFFFFF')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .shadow({
                  radius: 4,
                  color: 'rgba(0, 0, 0, 0.05)',
                  offsetX: 0,
                  offsetY: 2
                })
              }
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: 'rgba(0, 0, 0, 0.05)',
              offsetX: 0,
              offsetY: 2
            })
          }

          // 每日计划项
          Column({ space: 8 }) {
            Text('今日计划')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })

            //   ForEach(this.dailyPlanItems, (item: DailyPlanItem) => {
            //     Row() {
            //       Text(item.time)
            //         .fontSize(14)
            //         .fontWeight(FontWeight.Medium)
            //         .fontColor('#666666')
            //         .width(60)
            //
            //       Column() {
            //         Row({ space: 8 }) {
            //           Image(item.icon)
            //             .width(40)
            //             .height(40)
            //             .borderRadius(8)
            //
            //           Column() {
            //             Text(item.title)
            //               .fontSize(16)
            //               .fontWeight(FontWeight.Medium)
            //               .fontColor('#333333')
            //
            //             Text(item.subtitle)
            //               .fontSize(14)
            //               .fontColor('#666666')
            //           }
            //           .alignItems(HorizontalAlign.Start)
            //           .layoutWeight(1)
            //         }
            //       }
            //       .backgroundColor('#FFFFFF')
            //       .borderRadius(12)
            //       .padding({
            //         left: 12,
            //         right: 12,
            //         top: 10,
            //         bottom: 10
            //       })
            //       .layoutWeight(1)
            //
            //       Toggle({ type: ToggleType.Checkbox, isOn: item.completed })
            //         .selectedColor('#007DFF')
            //         .width(24)
            //         .height(24)
            //         .margin({ left: 8 })
            //     }
            //     .width('100%')
            //     .alignItems(VerticalAlign.Center)
            //     .onClick(() => {
            //       item.completed = !item.completed;
            //     })
            //   })
            // }
            // .width('100%')
            // .padding(16)
            // .backgroundColor('#FFFFFF')
            // .borderRadius(16)
            // .shadow({
            //   radius: 8,
            //   color: 'rgba(0, 0, 0, 0.05)',
            //   offsetX: 0,
            //   offsetY: 2
            // })

            // 成就
            Column({ space: 12 }) {
              Text('我的成就')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })

              ForEach(this.achievements, (achievement: Achievement) => {
                Row() {
                  Image(achievement.icon)
                    .width(50)
                    .height(50)
                    .borderRadius(25)
                    .opacity(achievement.unlocked ? 1 : 0.5)

                  Column() {
                    Row() {
                      Text(achievement.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(achievement.unlocked ? '#333333' : '#999999')

                      if (achievement.unlocked) {
                        Image($r('app.media.check_icon'))
                          .width(16)
                          .height(16)
                          .margin({ left: 8 })
                      }
                    }

                    Text(achievement.description)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })

                    if (achievement.progress !== undefined) {
                      Row() {
                        Progress({ value: achievement.progress, total: 100 })
                          .color('#007DFF')
                          .backgroundColor('#EEEEEE')
                          .height(4)
                          .borderRadius(2)
                          .layoutWeight(1)

                        Text(`${achievement.progress}%`)
                          .fontSize(12)
                          .fontColor('#666666')
                          .margin({ left: 8 })
                      }
                      .width('100%')
                      .margin({ top: 8 })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .shadow({
                  radius: 4,
                  color: 'rgba(0, 0, 0, 0.02)',
                  offsetX: 0,
                  offsetY: 1
                })
              })

              Button('查看全部成就')
                .width('100%')
                .height(44)
                .borderRadius(22)
                .backgroundColor('#007DFF')
                .fontColor(Color.White)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .shadow({
              radius: 8,
              color: 'rgba(0, 0, 0, 0.05)',
              offsetX: 0,
              offsetY: 2
            })
          }
          .width('90%')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8F8F8')
      .padding({ bottom: 16 })
    }
  }
}
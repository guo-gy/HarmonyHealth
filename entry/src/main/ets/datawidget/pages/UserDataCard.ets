import router from '@ohos.router';
import formProvider from '@ohos.app.form.formProvider';

// 定义点位置接口
interface DotPosition {
  x: string;
  y: string;
}

// 定义数据卡片参数接口
interface DataCardOptions {
  value: string;
  label: string;
  icon?: Resource;
  unit: string;
}

const localStorage = new LocalStorage();

@Entry(localStorage)
@Component
struct UserDataCard {
  // 卡片数据属性
  @LocalStorageProp('isLoggedIn') isLoggedIn: boolean = false;
  @LocalStorageProp('userName') userName: string = '';
  @LocalStorageProp('userHeight') userHeight: string = '0';
  @LocalStorageProp('weight') weight: string = '0';
  @LocalStorageProp('age') age: string = '0';
  @LocalStorageProp('sportCount') sportCount: string = '0';
  @LocalStorageProp('updateTime') updateTime: string = '';
  @LocalStorageProp('formId') formId: string = '';
  @State refreshing: boolean = false;
  @State rotateAngle: number = 0;
  // 设置默认值而不是使用动画
  @State pulseSize: number = 1.15;
  @State pulseOpacity: number = 0.5;
  @State dotPositions: Array<DotPosition> = [
    { x: '10%', y: '10%' }, { x: '30%', y: '20%' }, { x: '50%', y: '15%' },
    { x: '70%', y: '25%' }, { x: '90%', y: '10%' }, { x: '20%', y: '40%' },
    { x: '40%', y: '35%' }, { x: '60%', y: '45%' }, { x: '80%', y: '30%' },
    { x: '15%', y: '60%' }, { x: '35%', y: '70%' }, { x: '55%', y: '65%' },
    { x: '75%', y: '75%' }, { x: '95%', y: '60%' }, { x: '25%', y: '90%' },
    { x: '45%', y: '85%' }, { x: '65%', y: '95%' }, { x: '85%', y: '80%' }
  ];

  // 刷新卡片数据
  refreshCardData() {
    if (this.refreshing || !this.formId) {
      return;
    }

    // 设置刷新状态
    this.refreshing = true;

    // 旋转刷新图标
    this.rotateAngle = 360;

    // 通过消息事件通知卡片更新
    postCardAction(this, {
      action: 'message',
      params: {
        message: 'refresh'
      }
    });

    // 在实际应用中，应该由FormAbility更新后通知卡片重置状态
    // 由于卡片环境限制，我们通过调用FormAbility来重置状态
    console.log("开始更新");
    postCardAction(this, {
      action: 'call',
      abilityName: 'HealthDataFormAbility',
      params: {
        method: 'updateForm',
        formId: this.formId
      }
    });
    // 直接重置状态，视觉上会有闪烁，但确保功能正常
    this.refreshing = false;
    this.rotateAngle = 0;
  }

  aboutToAppear() {
    // 检查是否需要重置刷新状态
    if (this.refreshing) {
      this.refreshing = false;
      this.rotateAngle = 0;
    }
  }

  build() {
    Stack() {
      // 背景渐变层
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 135,
          colors: [['#0057B8', 0.0], ['#0080FF', 0.5], ['#00A3FF', 1.0]]
        })
        .borderRadius(24)
        .clip(true)

      // 装饰图形 - 多个圆形光晕
      Circle()
        .fill('rgba(150, 200, 255, 0.15)')
        .width('80%')
        .height('80%')
        .position({ x: '65%', y: '-20%' })
        .blur(20)

      Circle()
        .fill('rgba(100, 180, 255, 0.1)')
        .width('60%')
        .height('60%')
        .position({ x: '-20%', y: '70%' })
        .blur(15)

      // 科技感网格背景 - 使用固定位置的点代替Grid
      ForEach(this.dotPositions, (item: DotPosition) => {
        Circle()
          .width(2)
          .height(2)
          .fill('rgba(255, 255, 255, 0.3)')
          .position({ x: item.x, y: item.y })
      })

      // 内容区域
      Column() {
        if (this.isLoggedIn) {
          // 已登录状态 - 显示用户基本信息
          Column({ space: 8 }) {
            // 头部 - 用户名和刷新信息
            Row() {
              Text('个人信息')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')

              Blank()

              // 刷新按钮
              Button({ type: ButtonType.Circle, stateEffect: true }) {
                Image($r('app.media.ic_public_refresh'))
                  .width(20)
                  .height(20)
                  .fillColor('#FFFFFF')
                  .rotate({ angle: this.rotateAngle })
              }
              .width(32)
              .height(32)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .onClick(() => this.refreshCardData())
              .enabled(!this.refreshing)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 12, bottom: 16 })

            // 更新时间
            Row() {
              Text(`更新时间: ${this.updateTime}`)
                .fontSize(12)
                .fontColor('rgba(255, 255, 255, 0.6)')
            }
            .width('100%')
            .justifyContent(FlexAlign.End)
            .padding({ bottom: 8 })

            // 用户数据展示 - 改用Row和Column替代Grid和GridItem
            Column({ space: 12 }) {
              // 第一行：身高和体重
              Row({ space: 10 }) {
                // 身高
                Column() {
                  Text(this.userHeight)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')

                  Text('身高')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')

                  Text('cm')
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .width('48%')

                // 体重
                Column() {
                  Text(this.weight)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')

                  Text('体重')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')

                  Text('kg')
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .width('48%')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)

              // 第二行：年龄和运动次数
              Row({ space: 10 }) {
                // 年龄
                Column() {
                  Text(this.age)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')

                  Text('年龄')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')

                  Text('岁')
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .width('48%')

                // 运动次数
                Column() {
                  Text(this.sportCount)
                    .fontSize(22)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')

                  Text('运动次数')
                    .fontSize(14)
                    .fontColor('rgba(255, 255, 255, 0.8)')

                  Text('次')
                    .fontSize(12)
                    .fontColor('rgba(255, 255, 255, 0.6)')
                }
                .backgroundColor('rgba(255, 255, 255, 0.1)')
                .borderRadius(16)
                .padding(12)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .width('48%')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .padding({ left: 10, right: 10 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })

        } else {
          // 未登录状态 - 显示登录提示
          Column({ space: 16 }) {
            // 动态脉冲效果
            Stack() {
              Circle()
                .width(80)
                .height(80)
                .fill('rgba(255, 255, 255, 0.1)')
                .scale({ x: this.pulseSize, y: this.pulseSize })
                .opacity(this.pulseOpacity)

              Circle()
                .width(70)
                .height(70)
                .fill('rgba(255, 255, 255, 0.2)')

              Image($r('app.media.icon'))
                .width(60)
                .height(60)
                .objectFit(ImageFit.Contain)
            }
            .margin({ top: 10, bottom: 8 })

            Text('请登录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')

            Text('登录后查看您的个人信息')
              .fontSize(14)
              .fontColor('rgba(255, 255, 255, 0.7)')
              .margin({ bottom: 12 })

            Button('立即登录')
              .width(120)
              .height(36)
              .borderRadius(18)
              .backgroundColor('rgba(255, 255, 255, 0.2)')
              .fontColor('#FFFFFF')
              .margin({ bottom: 16 })
              .onClick(() => {
                postCardAction(this, {
                  action: 'router',
                  abilityName: 'EntryAbility',
                  params: {
                    targetPage: 'pages/LoginPage'
                  }
                });
              })

            // 刷新按钮
            Button({ type: ButtonType.Circle, stateEffect: true }) {
              Image($r('app.media.ic_public_refresh'))
                .width(20)
                .height(20)
                .fillColor('#FFFFFF')
                .rotate({ angle: this.rotateAngle })
            }
            .width(36)
            .height(36)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .onClick(() => this.refreshCardData())
            .enabled(!this.refreshing)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .onClick(() => {
      if (!this.refreshing) {
        if (!this.isLoggedIn) {
          // 未登录状态下点击卡片跳转到登录页面
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/LoginPage'
            }
          });
        } else {
          // 已登录状态下点击卡片跳转到个人资料页面
          postCardAction(this, {
            action: 'router',
            abilityName: 'EntryAbility',
            params: {
              targetPage: 'pages/ProfilePage'
            }
          });
        }
      }
    })
  }

  // 数据项构建器
  @Builder
  DataItem(label: string, value: string, unit: string) {
    Column() {
      Text(value)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      Row({ space: 4 }) {
        Text(label)
          .fontSize(13)
          .fontColor('rgba(255, 255, 255, 0.8)')

        Text(unit)
          .fontSize(13)
          .fontColor('rgba(255, 255, 255, 0.6)')
      }
    }
    .backgroundColor('rgba(255, 255, 255, 0.1)')
    .borderRadius(16)
    .padding(12)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }
} 
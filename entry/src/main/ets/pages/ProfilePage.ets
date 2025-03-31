import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 定义用户信息接口
interface UserInfo {
  username: string;
  avatar: Resource;
  height: number;
  weight: number;
  age: number;
  bmi: number;
  goal: string;
}

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

@Component
export struct ProfilePage {
  @State message: string = '个人中心';
  @State userInfo: UserInfo = {
    username: 'admin',
    avatar: $r('app.media.icon'),
    height: 175,
    weight: 68,
    age: 28,
    bmi: 22.2,
    goal: '增肌减脂，提高体能'
  };
  @State healthMetrics: HealthMetric[] = [];
  @State isLoading: boolean = false;
  @State selectedMetric: string = '体重';
  @State showHealthReport: boolean = false;

  private metricOptions: SelectOption[] = [
    { value: '体重' },
    { value: '步数' },
    { value: '睡眠' },
    { value: '饮水量' }
  ];

  aboutToAppear() {
    this.loadHealthData();
  }

  loadHealthData() {
    this.isLoading = true;
    
    // 模拟加载健康数据
    setTimeout(() => {
      // 生成过去7天的健康数据
      const today = new Date();
      this.healthMetrics = [];
      
      for (let i = 6; i >= 0; i--) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);
        const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
        
        this.healthMetrics.push({
          date: dateStr,
          weight: 68 - Math.random() * 0.8,
          steps: Math.floor(5000 + Math.random() * 5000),
          sleepHours: 6 + Math.random() * 2,
          waterIntake: Math.floor(1500 + Math.random() * 1000)
        });
      }
      
      this.isLoading = false;
    }, 1000);
  }

  // 获取指标值和单位的辅助方法
  getMetricInfo(item: HealthMetric): [number, number, string] {
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
  @Builder
  ChartColumnBuilder(item: HealthMetric) {
    Column() {
      Text(`${this.getMetricInfo(item)[0].toFixed(this.selectedMetric === '体重' || this.selectedMetric === '睡眠' ? 1 : 0)}${this.getMetricInfo(item)[2]}`)
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
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
        
        Blank()
          .layoutWeight(1)
        
        Button() {
          Image($r('app.media.icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .backgroundColor('#F5F5F5')
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
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })

      // 用户信息卡片
      Column() {
        Row() {
          Image(this.userInfo.avatar)
            .width(80)
            .height(80)
            .borderRadius(40)
          
          Column() {
            Text(this.userInfo.username)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
            
            Text(`目标: ${this.userInfo.goal}`)
              .fontSize(14)
              .fontColor('#666666')
              .margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 15 })
          .layoutWeight(1)
          
          Button('编辑')
            .width(80)
            .height(36)
            .backgroundColor('#007DFF')
            .borderRadius(18)
            .fontSize(14)
            .onClick(() => {
              // 编辑个人信息
              promptAction.showDialog({
                title: '编辑个人信息',
                message: '编辑功能正在开发中',
                buttons: [{ text: '确定', color: '#007DFF' }]
              });
            })
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        
        Divider()
          .width('100%')
          .color('#E0E0E0')
        
        // 身体数据
        Row() {
          Column() {
            Text('身高')
              .fontSize(14)
              .fontColor('#666666')
            
            Text(`${this.userInfo.height}cm`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          Divider()
            .vertical(true)
            .height('60%')
            .color('#E0E0E0')
          
          Column() {
            Text('体重')
              .fontSize(14)
              .fontColor('#666666')
            
            Text(`${this.userInfo.weight}kg`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          Divider()
            .vertical(true)
            .height('60%')
            .color('#E0E0E0')
          
          Column() {
            Text('BMI')
              .fontSize(14)
              .fontColor('#666666')
            
            Text(`${this.userInfo.bmi.toFixed(1)}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          
          Divider()
            .vertical(true)
            .height('60%')
            .color('#E0E0E0')
          
          Column() {
            Text('年龄')
              .fontSize(14)
              .fontColor('#666666')
            
            Text(`${this.userInfo.age}岁`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 5 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding({ top: 15, bottom: 15 })
      }
      .width('90%')
      .padding({ left: 15, right: 15 })
      .backgroundColor('#F5F5F5')
      .borderRadius(10)
      .margin({ top: 10 })

      // 健康数据可视化
      Column() {
        Row() {
          Text('健康数据趋势')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
          
          Blank()
            .layoutWeight(1)
          
          Select(this.metricOptions)
            .selected(0)
            .value(this.selectedMetric)
            .font({ size: 14 })
            .selectedOptionFont({ size: 14 })
            .optionFont({ size: 14 })
            .onSelect((index: number, value: string) => {
              this.selectedMetric = value;
            })
        }
        .width('100%')
        .padding({ top: 15, bottom: 15 })
        
        if (this.isLoading) {
          LoadingProgress()
            .color('#007DFF')
            .width(50)
            .height(50)
            .margin({ top: 30, bottom: 30 })
        } else {
          // 数据可视化图表
          Column() {
            // 简单的柱状图实现
            Row() {
              ForEach(this.healthMetrics, (item: HealthMetric) => {
                // 直接使用 @Builder 方法作为组件
                this.ChartColumnBuilder(item)
              }, (item: HealthMetric) => item.date)
            }
            .width('100%')
            .height(250)
            .padding({ left: 10, right: 10 })
          }
          .width('100%')
        }
      }
      .width('90%')
      .padding({ left: 15, right: 15 })
      .backgroundColor('#F5F5F5')
      .borderRadius(10)
      .margin({ top: 15 })

      // 健康报告和设备绑定
      Row() {
        Column() {
          Image($r('app.media.icon'))
            .width(40)
            .height(40)
            .margin({ bottom: 10 })
          
          Text('健康报告')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }
        .width('45%')
        .height(120)
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          this.showHealthReport = true;
          promptAction.showDialog({
            title: '健康报告',
            message: '您的健康状况良好，建议继续保持当前的运动和饮食习惯。',
            buttons: [{ text: '确定', color: '#007DFF' }]
          });
        })
        
        Column() {
          Image($r('app.media.icon'))
            .width(40)
            .height(40)
            .margin({ bottom: 10 })
          
          Text('设备绑定')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
        }
        .width('45%')
        .height(120)
        .backgroundColor('#F5F5F5')
        .borderRadius(10)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          promptAction.showDialog({
            title: '设备绑定',
            message: '设备绑定功能正在开发中',
            buttons: [{ text: '确定', color: '#007DFF' }]
          });
        })
      }
      .width('90%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 15, bottom: 20 })
    }
    .width('100%')
    .height('100%')
  }
}
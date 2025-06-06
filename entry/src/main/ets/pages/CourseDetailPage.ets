import router from '@ohos.router';
import { Course, TrainingAction } from '../model/TrainingModels';
import { AppTheme } from '../common/constants/AppTheme';
import { KeepButton } from '../components/common/KeepButton';

@Entry
@Component
export struct CourseDetailPage {
  @State course: Course = null;
  @State isLoading: boolean = true;
  @State isCollected: boolean = false;
  @State showFullDescription: boolean = false;
  @State activeSection: number = 0; // 0: 介绍, 1: 动作, 2: 评价
  
  private courseId: string = '';
  private readonly sections: string[] = ['介绍', '动作', '评价'];
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.courseId) {
      this.courseId = params.courseId as string;
      this.loadCourseData();
    }
  }
  
  // 加载课程数据
  loadCourseData() {
    // 模拟网络请求延迟
    setTimeout(() => {
      // 模拟课程数据
      this.mockCourseData();
      this.isLoading = false;
    }, 1000);
  }
  
  // 模拟课程数据 (实际项目中从API获取)
  mockCourseData() {
    // 创建一些训练动作
    const pushupAction = new TrainingAction(
      '1',
      '标准俯卧撑',
      $r('app.media.icon'),
      $r('app.media.icon'),
      45,
      undefined,
      15,
      '双手与肩同宽，保持身体平直，完成标准俯卧撑',
      ['保持核心收紧', '肘部弯曲至与地面平行', '呼吸节奏：下降时吸气，上升时呼气'],
      ['胸大肌', '三头肌', '三角肌前束'],
      false
    );
    
    const squatAction = new TrainingAction(
      '2',
      '标准深蹲',
      $r('app.media.icon'),
      $r('app.media.icon'),
      45,
      undefined,
      15,
      '双脚与肩同宽，下蹲至大腿与地面平行，然后站起',
      ['保持背部挺直', '膝盖不要超过脚尖', '下蹲时臀部向后坐'],
      ['股四头肌', '臀大肌', '腘绳肌'],
      false
    );
    
    const plankAction = new TrainingAction(
      '3',
      '平板支撑',
      $r('app.media.icon'),
      $r('app.media.icon'),
      60,
      undefined,
      20,
      '前臂撑地，保持身体平直，核心收紧',
      ['保持肩膀在手肘正上方', '不要塌腰或抬臀', '正常呼吸，不要憋气'],
      ['核心肌群', '腹直肌', '竖脊肌'],
      false
    );
    
    const jumpingJackAction = new TrainingAction(
      '4',
      '开合跳',
      $r('app.media.icon'),
      $r('app.media.icon'),
      45,
      undefined,
      15,
      '双脚并拢，双手放在身体两侧，然后跳跃同时张开双臂和双腿',
      ['保持节奏均匀', '完全伸展手臂和双腿', '轻盈落地减少关节压力'],
      ['小腿肌群', '肩部肌群', '心肺功能'],
      false
    );
    
    // 根据ID返回不同的课程
    switch (this.courseId) {
      case '1':
        this.course = new Course(
          '1',
          '30分钟全身燃脂训练',
          $r('app.media.icon'),
          30,
          300,
          'beginner',
          '燃脂',
          ['HIIT', '全身', '初级'],
          '适合初学者的全身燃脂训练，强度适中，短时间高效燃烧脂肪。这套训练结合了有氧和无氧运动，通过高强度间歇训练方式，帮助快速提高心率，增强心肺功能，同时锻炼肌肉力量。训练过程中注重正确姿势和呼吸节奏，减少运动损伤风险。坚持每周3-4次，配合合理饮食，4周后可见明显效果。',
          '王教练',
          $r('app.media.icon'),
          1245,
          4.8,
          [pushupAction, jumpingJackAction, squatAction, plankAction]
        );
        break;
      case '2':
        this.course = new Course(
          '2',
          '45分钟腹肌训练',
          $r('app.media.icon'),
          45,
          400,
          'intermediate',
          '塑形',
          ['腹肌', '核心', '中级'],
          '专注腹部核心训练，打造完美腹肌线条，适合有一定训练基础的人。本课程设计科学合理，全面锻炼腹部各个部位肌肉，包括腹直肌、腹外斜肌和腹内斜肌。通过不同难度的动作组合，循序渐进提高核心力量。注重质量而非数量，每个动作都应保持正确姿势，感受核心肌群的收缩。坚持训练并配合低脂饮食，腹肌线条将逐渐显现。',
          '李教练',
          $r('app.media.icon'),
          986,
          4.7,
          [plankAction, pushupAction, squatAction, jumpingJackAction]
        );
        break;
      default:
        this.course = new Course(
          '3',
          '20分钟上肢力量',
          $r('app.media.icon'),
          20,
          250,
          'beginner',
          '力量',
          ['上肢', '力量', '初级'],
          '针对上肢训练，增强手臂、肩部和背部力量，适合初学者。这套训练主要针对手臂三头肌、二头肌、肩部和背部肌群，通过多组高效率的动作，在短时间内刺激上肢各个部位。训练采用自重方式，无需额外器械，随时随地可以进行。对于初学者来说，应先掌握正确的动作形式，再逐渐增加训练强度和复杂性。每周坚持2-3次，4周后将明显感受到上肢力量提升。',
          '张教练',
          $r('app.media.icon'),
          756,
          4.6,
          [pushupAction, plankAction, jumpingJackAction]
        );
    }
  }
  
  // 开始训练
  startTraining() {
    router.pushUrl({
      url: 'pages/TrainingInProgressPage',
      params: { course: this.course }
    });
  }
  
  // 收藏课程
  toggleCollect() {
    this.isCollected = !this.isCollected;
    // 实际项目中应该调用API保存收藏状态
  }
  
  // 返回上一页
  goBack() {
    router.back();
  }
  
  @Builder HeaderBuilder() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景图
      Image(this.course.coverImage)
        .width('100%')
        .height(260)
        .objectFit(ImageFit.Cover)
      
      // 渐变遮罩
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['rgba(0,0,0,0.1)', 0.0], ['rgba(0,0,0,0.7)', 1.0]]
        })
      
      // 返回按钮
      Row() {
        Image($r('app.media.icon'))
          .width(24)
          .height(24)
          .fillColor(Color.White)
          .onClick(() => this.goBack())
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(0, 0, 0, 0.3)')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16, left: 16 })
      
      // 收藏按钮
      Row() {
        Image($r('app.media.icon'))
          .width(24)
          .height(24)
          .fillColor(this.isCollected ? '#FFC107' : Color.White)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(0, 0, 0, 0.3)')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 16, right: 16 })
      .position({ x: '94%' })
      .onClick(() => this.toggleCollect())
      
      // 底部信息
      Column({ space: 8 }) {
        Text(this.course.title)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
        
        Row({ space: 8 }) {
          // 难度标签
          Text(this.course.getLevelText())
            .fontSize(12)
            .fontColor(Color.White)
            .backgroundColor(this.course.getLevelColor())
            .padding({ left: 8, right: 8, top: 3, bottom: 3 })
            .borderRadius(4)
          
          // 时长
          Text(this.course.getFormattedDuration())
            .fontSize(14)
            .fontColor(Color.White)
          
          // 卡路里
          Text(`${this.course.calories}千卡`)
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 16, bottom: 16 })
      .position({ y: '85%' })
    }
    .width('100%')
    .height(260)
  }
  
  build() {
    Column() {
      if (this.isLoading) {
        // 加载中
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(AppTheme.PRIMARY_COLOR)
          
          Text('加载中...')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (!this.course) {
        // 加载失败
        Column() {
          Image($r('app.media.icon'))
            .width(80)
            .height(80)
          
          Text('课程不存在')
            .fontSize(16)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .margin({ top: 16 })
          
          KeepButton({ 
            text: '返回', 
            type: 'primary', 
            buttonWidth: 160, 
            buttonHeight: 44,
            onButtonClick: () => this.goBack()
          })
            .margin({ top: 24 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 课程详情
        Stack({ alignContent: Alignment.Bottom }) {
          Column() {
            // 头部
            this.HeaderBuilder()
            
            // Tab栏
            Row() {
              ForEach(this.sections, (section: string, index: number) => {
                Column() {
                  Text(section)
                    .fontSize(16)
                    .fontWeight(this.activeSection === index ? FontWeight.Medium : FontWeight.Normal)
                    .fontColor(this.activeSection === index ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
                  
                  Divider()
                    .width(24)
                    .height(2)
                    .backgroundColor(this.activeSection === index ? AppTheme.PRIMARY_COLOR : 'transparent')
                    .margin({ top: 6 })
                }
                .width('33%')
                .height(46)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.activeSection = index;
                })
              })
            }
            .width('100%')
            
            // 内容区
            Swiper() {
              // 介绍页
              Column() {
                // 教练信息
                Row({ space: 12 }) {
                  Row() {
                    Image(this.course.coachAvatar ? this.course.coachAvatar : $r('app.media.icon'))
                      .width(40)
                      .height(40)
                      .borderRadius(20)
                      .objectFit(ImageFit.Cover)
                  }
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor('#F5F5F5')
                  .justifyContent(FlexAlign.Center)
                  
                  Column({ space: 4 }) {
                    Text(this.course.coachName)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(AppTheme.TEXT_PRIMARY)
                    
                    Row({ space: 4 }) {
                      ForEach([1, 2, 3, 4, 5], (item: number) => {
                        Image($r('app.media.icon'))
                          .width(12)
                          .height(12)
                          .fillColor('#FFC107')
                      })
                      
                      Text(`${this.course.rating}`)
                        .fontSize(12)
                        .fontColor(AppTheme.TEXT_SECONDARY)
                        .margin({ left: 4 })
                      
                      Text(`(${this.course.participantsCount})`)
                        .fontSize(12)
                        .fontColor(AppTheme.TEXT_SECONDARY)
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Button() {
                    Text('关注')
                      .fontSize(14)
                      .fontColor(AppTheme.PRIMARY_COLOR)
                  }
                  .height(32)
                  .padding({ left: 16, right: 16 })
                  .borderRadius(16)
                  .backgroundColor('rgba(67, 209, 98, 0.1)')
                }
                .width('100%')
                .padding({ left: 16, right: 16, top: 16, bottom: 16 })
                
                Divider()
                  .width('92%')
                  .height(1)
                  .backgroundColor('#F0F0F0')
                
                // 课程介绍
                Column({ space: 16 }) {
                  Text('课程介绍')
                    .fontSize(18)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(AppTheme.TEXT_PRIMARY)
                  
                  Text(this.course.description)
                    .fontSize(15)
                    .lineHeight(24)
                    .fontColor(AppTheme.TEXT_PRIMARY)
                    .maxLines(this.showFullDescription ? 999 : 3)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  if (this.course.description.length > 120) {
                    Text(this.showFullDescription ? '收起' : '查看更多')
                      .fontSize(14)
                      .fontColor(AppTheme.PRIMARY_COLOR)
                      .onClick(() => {
                        this.showFullDescription = !this.showFullDescription;
                      })
                  }
                  
                  // 标签
                  Wrap({ spacing: 8 }) {
                    ForEach(this.course.tags, (tag: string) => {
                      Text(tag)
                        .fontSize(12)
                        .fontColor(AppTheme.TEXT_SECONDARY)
                        .backgroundColor('#F5F5F5')
                        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                        .borderRadius(16)
                    })
                  }
                  .width('100%')
                  
                  // 训练设备
                  Column({ space: 12 }) {
                    Text('训练设备')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppTheme.TEXT_PRIMARY)
                    
                    Text('无需器械，随时随地可训练')
                      .fontSize(14)
                      .fontColor(AppTheme.TEXT_SECONDARY)
                  }
                  .alignItems(HorizontalAlign.Start)
                  
                  // 目标肌群
                  Column({ space: 12 }) {
                    Text('目标肌群')
                      .fontSize(16)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(AppTheme.TEXT_PRIMARY)
                    
                    Row({ space: 16 }) {
                      Column() {
                        Image($r('app.media.icon'))
                          .width(48)
                          .height(48)
                        
                        Text('胸部')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_SECONDARY)
                          .margin({ top: 8 })
                      }
                      
                      Column() {
                        Image($r('app.media.icon'))
                          .width(48)
                          .height(48)
                        
                        Text('核心')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_SECONDARY)
                          .margin({ top: 8 })
                      }
                      
                      Column() {
                        Image($r('app.media.icon'))
                          .width(48)
                          .height(48)
                        
                        Text('腿部')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_SECONDARY)
                          .margin({ top: 8 })
                      }
                    }
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .padding({ left: 16, right: 16, top: 16, bottom: 80 })
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .height('100%')
              
              // 动作列表
              Column() {
                List() {
                  ForEach(this.course.actions, (action: TrainingAction, index: number) => {
                    ListItem() {
                      Row({ space: 16 }) {
                        // 序号
                        Text(`${index + 1}`)
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                          .fontColor(AppTheme.TEXT_SECONDARY)
                          .width(24)
                          .textAlign(TextAlign.Center)
                        
                        // 动作图片
                        Image(action.image)
                          .width(80)
                          .height(60)
                          .borderRadius(8)
                          .objectFit(ImageFit.Cover)
                        
                        // 动作信息
                        Column({ space: 4 }) {
                          Text(action.name)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.TEXT_PRIMARY)
                          
                          Text(action.getFormattedDuration())
                            .fontSize(14)
                            .fontColor(AppTheme.TEXT_SECONDARY)
                          
                          if (action.rest > 0) {
                            Text(`休息 ${action.rest}秒`)
                              .fontSize(12)
                              .fontColor(AppTheme.PRIMARY_COLOR)
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        .layoutWeight(1)
                      }
                      .width('100%')
                      .padding({ top: 12, bottom: 12 })
                    }
                    .padding({ left: 16, right: 16 })
                  })
                }
                .width('100%')
                .height('100%')
                .divider({ strokeWidth: 1, color: '#F0F0F0', startMargin: 56, endMargin: 16 })
                .padding({ bottom: 80 })
              }
              .width('100%')
              .height('100%')
              
              // 评价列表（模拟）
              Column() {
                List() {
                  ListItem() {
                    Column() {
                      Row({ space: 12 }) {
                        Image($r('app.media.icon'))
                          .width(40)
                          .height(40)
                          .borderRadius(20)
                        
                        Column({ space: 4 }) {
                          Text('用户01')
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.TEXT_PRIMARY)
                          
                          Row({ space: 4 }) {
                            ForEach([1, 2, 3, 4, 5], (item: number) => {
                              Image($r('app.media.icon'))
                                .width(12)
                                .height(12)
                                .fillColor('#FFC107')
                            })
                            
                            Text('5.0')
                              .fontSize(12)
                              .fontColor(AppTheme.TEXT_SECONDARY)
                              .margin({ left: 4 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        
                        Blank()
                          .layoutWeight(1)
                        
                        Text('2023-09-15')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_TERTIARY)
                      }
                      .width('100%')
                      
                      Text('课程非常不错，动作讲解很清晰，强度也适中，很适合初学者。坚持了一个月已经有明显的变化了！')
                        .fontSize(14)
                        .lineHeight(22)
                        .fontColor(AppTheme.TEXT_PRIMARY)
                        .margin({ top: 12 })
                    }
                    .width('100%')
                    .padding(16)
                  }
                  
                  ListItem() {
                    Column() {
                      Row({ space: 12 }) {
                        Image($r('app.media.icon'))
                          .width(40)
                          .height(40)
                          .borderRadius(20)
                        
                        Column({ space: 4 }) {
                          Text('用户02')
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.TEXT_PRIMARY)
                          
                          Row({ space: 4 }) {
                            ForEach([1, 2, 3, 4], (item: number) => {
                              Image($r('app.media.icon'))
                                .width(12)
                                .height(12)
                                .fillColor('#FFC107')
                            })
                            
                            Image($r('app.media.icon'))
                              .width(12)
                              .height(12)
                              .fillColor('#FFC107')
                            
                            Text('4.0')
                              .fontSize(12)
                              .fontColor(AppTheme.TEXT_SECONDARY)
                              .margin({ left: 4 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        
                        Blank()
                          .layoutWeight(1)
                        
                        Text('2023-09-05')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_TERTIARY)
                      }
                      .width('100%')
                      
                      Text('训练很有效果，但是有些动作对于初学者来说难度偏大，希望能加一些替代动作。教练很专业，指导很到位。')
                        .fontSize(14)
                        .lineHeight(22)
                        .fontColor(AppTheme.TEXT_PRIMARY)
                        .margin({ top: 12 })
                    }
                    .width('100%')
                    .padding(16)
                  }
                  
                  ListItem() {
                    Column() {
                      Row({ space: 12 }) {
                        Image($r('app.media.icon'))
                          .width(40)
                          .height(40)
                          .borderRadius(20)
                        
                        Column({ space: 4 }) {
                          Text('用户03')
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(AppTheme.TEXT_PRIMARY)
                          
                          Row({ space: 4 }) {
                            ForEach([1, 2, 3, 4, 5], (item: number) => {
                              Image($r('app.media.icon'))
                                .width(12)
                                .height(12)
                                .fillColor('#FFC107')
                            })
                            
                            Text('5.0')
                              .fontSize(12)
                              .fontColor(AppTheme.TEXT_SECONDARY)
                              .margin({ left: 4 })
                          }
                        }
                        .alignItems(HorizontalAlign.Start)
                        
                        Blank()
                          .layoutWeight(1)
                        
                        Text('2023-08-22')
                          .fontSize(12)
                          .fontColor(AppTheme.TEXT_TERTIARY)
                      }
                      .width('100%')
                      
                      Text('这套训练真的太棒了！每次训练完都感觉特别有收获，时间安排合理，强度刚好，一点不拖沓，非常高效。已经推荐给我的朋友们了！')
                        .fontSize(14)
                        .lineHeight(22)
                        .fontColor(AppTheme.TEXT_PRIMARY)
                        .margin({ top: 12 })
                    }
                    .width('100%')
                    .padding(16)
                  }
                }
                .divider({ strokeWidth: 1, color: '#F0F0F0' })
                .padding({ bottom: 80 })
              }
              .width('100%')
              .height('100%')
            }
            .index(this.activeSection)
            .autoPlay(false)
            .indicator(false)
            .loop(false)
            .onChange((index: number) => {
              this.activeSection = index;
            })
          }
          .width('100%')
          .height('100%')
          
          // 底部操作栏
          Row() {
            Button() {
              Row({ space: 4 }) {
                Image($r('app.media.icon'))
                  .width(20)
                  .height(20)
                  .fillColor(AppTheme.TEXT_PRIMARY)
                
                Text('分享')
                  .fontSize(14)
                  .fontColor(AppTheme.TEXT_PRIMARY)
              }
            }
            .height(44)
            .backgroundColor(Color.White)
            .borderRadius(22)
            .padding({ left: 16, right: 16 })
            
            Blank()
              .width(20)
            
            KeepButton({ 
              text: '开始训练', 
              type: 'primary', 
              buttonWidth: 200, 
              buttonHeight: 44,
              onButtonClick: () => this.startTraining()
            })
          }
          .width('100%')
          .height(80)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Color.White)
          .border({ width: { top: 1 }, color: '#F0F0F0', style: BorderStyle.Solid })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
  }
} 
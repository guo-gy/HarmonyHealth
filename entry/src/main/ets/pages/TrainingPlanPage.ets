import router from '@ohos.router';
import { AppTheme } from '../common/constants/AppTheme';
import { Course, TrainingPlan, TrainingAction } from '../model/TrainingModels';
import { KeepButton } from '../components/common/KeepButton';
import { CourseCard } from '../components/training/CourseCard';

@Entry
@Component
export struct TrainingPlanPage {
  @State activeTabIndex: number = 0;
  @State recommendedCourses: Course[] = [];
  @State popularCourses: Course[] = [];
  @State trainingPlans: TrainingPlan[] = [];
  
  // 滚动控制器
  private tabsController: TabsController = new TabsController();
  private tabTitles: string[] = ['推荐', '热门', '计划'];
  private currentPage: number = 1;
  private pageSize: number = 10;
  private isLoading: boolean = false;
  private hasMore: boolean = true;
  private searchKeyword: string = '';
  private selectedCategory: string = '';
  private sortBy: string = 'recommended';
  
  aboutToAppear() {
    // 初始化示例数据
    this.initMockData();
  }
  
  // 初始化模拟数据
  initMockData() {
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
    
    // 创建一些训练课程
    const course1 = new Course(
      '1',
      '30分钟全身燃脂训练',
      $r('app.media.icon'),
      30,
      300,
      'beginner',
      '燃脂',
      ['HIIT', '全身', '初级'],
      '适合初学者的全身燃脂训练，强度适中，短时间高效燃烧脂肪。',
      '王教练',
      $r('app.media.icon'),
      1245,
      4.8,
      [pushupAction, jumpingJackAction, squatAction, plankAction]
    );
    
    const course2 = new Course(
      '2',
      '45分钟腹肌训练',
      $r('app.media.icon'),
      45,
      400,
      'intermediate',
      '塑形',
      ['腹肌', '核心', '中级'],
      '专注腹部核心训练，打造完美腹肌线条，适合有一定训练基础的人。',
      '李教练',
      $r('app.media.icon'),
      986,
      4.7,
      [plankAction, pushupAction, squatAction, jumpingJackAction]
    );
    
    const course3 = new Course(
      '3',
      '20分钟上肢力量',
      $r('app.media.icon'),
      20,
      250,
      'beginner',
      '力量',
      ['上肢', '力量', '初级'],
      '针对上肢训练，增强手臂、肩部和背部力量，适合初学者。',
      '张教练',
      $r('app.media.icon'),
      756,
      4.6,
      [pushupAction, plankAction, jumpingJackAction]
    );
    
    const course4 = new Course(
      '4',
      '40分钟下肢塑形',
      $r('app.media.icon'),
      40,
      380,
      'intermediate',
      '塑形',
      ['下肢', '臀部', '中级'],
      '针对下半身训练，塑造完美腿部和臀部线条，适合有一定基础的人。',
      '刘教练',
      $r('app.media.icon'),
      1120,
      4.9,
      [squatAction, jumpingJackAction, plankAction]
    );
    
    const course5 = new Course(
      '5',
      '60分钟高强度训练',
      $r('app.media.icon'),
      60,
      600,
      'advanced',
      '挑战',
      ['HIIT', '全身', '高级'],
      '高强度综合训练，全面提升心肺功能和肌肉耐力，适合有丰富训练经验的人。',
      '赵教练',
      $r('app.media.icon'),
      834,
      4.7,
      [pushupAction, squatAction, jumpingJackAction, plankAction]
    );
    
    // 设置推荐课程
    this.recommendedCourses = [course1, course3, course5, course2];
    
    // 设置热门课程
    this.popularCourses = [course4, course2, course1, course5];
    
    // 创建训练计划
    // 这里省略具体实现，后续可以补充
  }
  
  // 切换Tab
  switchTab(index: number) {
    this.activeTabIndex = index;
    this.tabsController.changeIndex(index);
  }
  
  // 进入课程详情
  navigateToCourseDetail(course: Course) {
    router.pushUrl({
      url: 'pages/CourseDetailPage',
      params: { courseId: course.id }
    });
  }
  
  // 开始训练
  startTraining(course: Course) {
    router.pushUrl({
      url: 'pages/TrainingInProgressPage',
      params: { course: course }
    });
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('训练')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
        
        Blank()
          .layoutWeight(1)
        
        Image($r('app.media.icon'))
          .width(24)
          .height(24)
          .fillColor(AppTheme.TEXT_PRIMARY)
          .margin({ right: 16 })
          .onClick((): void => {
            // 跳转到搜索页面
          })
        
        Image($r('app.media.icon'))
          .width(24)
          .height(24)
          .fillColor(AppTheme.TEXT_PRIMARY)
          .onClick((): void => {
            // 跳转到训练历史页面
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      
      // Tab栏
      Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
        ForEach(this.tabTitles, (title: string, index: number) => {
          TabContent() {
            if (index === 0) {
              // 推荐课程内容
              this.buildRecommendedCoursesContent();
            } else if (index === 1) {
              // 热门课程内容
              this.buildPopularCoursesContent();
            } else {
              // 训练计划内容
              this.buildTrainingPlansContent();
            }
          }
          .tabBar(this.TabBuilder(title, index === this.activeTabIndex))
        }, (item: string): string => item)
      }
      .width('100%')
      .layoutWeight(1)
      .barHeight(48)
      .barWidth('100%')
      .barMode(BarMode.Fixed)
      .onChange((index: number): void => {
        this.activeTabIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }
  
  // Tab构建器
  @Builder TabBuilder(title: string, isActive: boolean) {
    Column() {
      Text(title)
        .fontSize(16)
        .fontWeight(isActive ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(isActive ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
      
      Divider()
        .width(24)
        .height(2)
        .backgroundColor(isActive ? AppTheme.PRIMARY_COLOR : 'transparent')
        .margin({ top: 6 })
    }
    .width('100%')
    .height(46)
    .justifyContent(FlexAlign.Center)
    .onClick((): void => {
      this.switchTab(this.tabTitles.indexOf(title));
    })
  }
  
  // 构建推荐课程内容
  @Builder buildRecommendedCoursesContent() {
    Column() {
      // 顶部轮播图
      Swiper() {
        ForEach(this.recommendedCourses.slice(0, 3), (course: Course) => {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image(course.coverImage)
              .width('100%')
              .height('100%')
              .borderRadius(16)
              .objectFit(ImageFit.Cover)
            
            Column() {
              Text(course.title)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              
              Row({ space: 8 }) {
                Text(course.getLevelText())
                  .fontSize(12)
                  .fontColor(Color.White)
                  .backgroundColor(course.getLevelColor())
                  .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                  .borderRadius(4)
                
                Text(course.getFormattedDuration())
                  .fontSize(12)
                  .fontColor(Color.White)
                
                Text(`${course.calories}千卡`)
                  .fontSize(12)
                  .fontColor(Color.White)
              }
              .margin({ top: 8 })
              
              KeepButton({ 
                text: '开始训练', 
                type: 'primary', 
                buttonWidth: 120, 
                buttonHeight: 36,
                onButtonClick: (): void => {
                  this.startTraining(course);
                }
              })
                .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('rgba(0,0,0,0.3)')
          }
          .width('100%')
          .height('100%')
          .onClick((): void => {
            this.navigateToCourseDetail(course);
          })
        }, (item: Course): string => item.id)
      }
      .width('100%')
      .height(200)
      .margin({ top: 16 })
      .loop(true)
      .autoPlay(true)
      .interval(5000)
      .indicator(true)
      .displayCount(1)
      
      // 课程类别
      Row() {
        Text('课程类别')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 24, bottom: 16 })
      
      // 课程分类列表
      Row({ space: 16 }) {
        this.buildCategoryItem('全身训练', $r('app.media.icon'), '#FFC107');
        this.buildCategoryItem('上肢力量', $r('app.media.icon'), '#4CAF50');
        this.buildCategoryItem('核心训练', $r('app.media.icon'), '#2196F3');
        this.buildCategoryItem('下肢塑形', $r('app.media.icon'), '#9C27B0');
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 24 })
      
      // 推荐课程标题
      Row() {
        Text('推荐课程')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.TEXT_PRIMARY)
        
        Blank()
          .layoutWeight(1)
        
        Text('更多')
          .fontSize(14)
          .fontColor(AppTheme.TEXT_SECONDARY)
          .onClick((): void => {
            // 查看更多推荐课程
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      
      // 推荐课程列表
      List() {
        ForEach(this.recommendedCourses, (course: Course) => {
          ListItem() {
            CourseCard({ 
              course: course,
              onCardClick: (): void => this.navigateToCourseDetail(course),
              onStartClick: (): void => this.startTraining(course)
            })
          }
          .padding({ bottom: 16 })
        }, (item: Course): string => item.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }
  
  // 构建热门课程内容
  @Builder buildPopularCoursesContent() {
    Column() {
      // 热门课程过滤选项
      Row({ space: 12 }) {
        Row() {
          Text('难度')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
          
          Image($r('app.media.icon'))
            .width(16)
            .height(16)
            .fillColor(AppTheme.TEXT_SECONDARY)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(16)
        .backgroundColor('#F5F5F5')
        
        Row() {
          Text('部位')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
          
          Image($r('app.media.icon'))
            .width(16)
            .height(16)
            .fillColor(AppTheme.TEXT_SECONDARY)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(16)
        .backgroundColor('#F5F5F5')
        
        Row() {
          Text('时长')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
          
          Image($r('app.media.icon'))
            .width(16)
            .height(16)
            .fillColor(AppTheme.TEXT_SECONDARY)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(16)
        .backgroundColor('#F5F5F5')
        
        Row() {
          Text('更多筛选')
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
          
          Image($r('app.media.icon'))
            .width(16)
            .height(16)
            .fillColor(AppTheme.TEXT_SECONDARY)
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .borderRadius(16)
        .backgroundColor('#F5F5F5')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .justifyContent(FlexAlign.Start)
      
      // 热门课程列表
      List() {
        ForEach(this.popularCourses, (course: Course) => {
          ListItem() {
            CourseCard({ 
              course: course,
              onCardClick: (): void => this.navigateToCourseDetail(course),
              onStartClick: (): void => this.startTraining(course)
            })
          }
          .padding({ bottom: 16 })
        }, (item: Course): string => item.id)
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }
  
  // 构建训练计划内容
  @Builder buildTrainingPlansContent() {
    Column() {
      // 计划类型选择
      Row({ space: 20 }) {
        this.buildPlanTypeItem('减脂', $r('app.media.icon'), true);
        this.buildPlanTypeItem('增肌', $r('app.media.icon'), false);
        this.buildPlanTypeItem('塑形', $r('app.media.icon'), false);
        this.buildPlanTypeItem('力量', $r('app.media.icon'), false);
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      .justifyContent(FlexAlign.SpaceBetween)
      
      // 如果没有训练计划，显示空状态
      if (this.trainingPlans.length === 0) {
        Column() {
          Image($r('app.media.icon'))
            .width(200)
            .height(200)
            .objectFit(ImageFit.Contain)
          
          Text('暂无训练计划')
            .fontSize(16)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .margin({ top: 16 })
          
          KeepButton({ 
            text: '创建计划', 
            type: 'primary', 
            buttonWidth: 160,
            buttonHeight: 44,
            onButtonClick: (): void => {
              // 跳转到创建计划页面
            }
          })
            .margin({ top: 24 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 显示训练计划列表
        List() {
          ForEach(this.trainingPlans, (plan: TrainingPlan) => {
            ListItem() {
              // 训练计划卡片
              // 这里省略实现
            }
            .padding({ bottom: 16 })
          }, (item: TrainingPlan): string => item.id)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
  }
  
  // 构建课程分类项
  @Builder buildCategoryItem(name: string, icon: Resource, color: string) {
    Column() {
      Row() {
        Image(icon)
          .width(24)
          .height(24)
          .fillColor(Color.White)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor(color)
      .justifyContent(FlexAlign.Center)
      
      Text(name)
        .fontSize(14)
        .fontColor(AppTheme.TEXT_PRIMARY)
        .margin({ top: 8 })
    }
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => {
      // 根据分类筛选课程
    })
  }
  
  // 构建计划类型项
  @Builder buildPlanTypeItem(name: string, icon: Resource, isActive: boolean) {
    Column() {
      Image(icon)
        .width(48)
        .height(48)
        .fillColor(isActive ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
      
      Text(name)
        .fontSize(14)
        .fontColor(isActive ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_PRIMARY)
        .fontWeight(isActive ? FontWeight.Medium : FontWeight.Normal)
        .margin({ top: 8 })
      
      Divider()
        .width(16)
        .height(2)
        .backgroundColor(isActive ? AppTheme.PRIMARY_COLOR : 'transparent')
        .margin({ top: 4 })
    }
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => {
      // 切换计划类型
    })
  }
} 
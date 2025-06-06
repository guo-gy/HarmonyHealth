import router from '@ohos.router';
import { Course, TrainingAction } from '../model/TrainingModels';
import { AppTheme } from '../common/constants/AppTheme';
import { KeepButton } from '../components/common/KeepButton';
import { KeepProgressBar } from '../components/common/KeepProgressBar';

@Entry
@Component
export struct TrainingInProgressPage {
  @State currentIndex: number = 0; // 当前动作索引
  @State timeRemaining: number = 0; // 当前动作剩余时间（秒）
  @State totalTime: number = 0; // 总时间（秒）
  @State elapsedTime: number = 0; // 已经过的时间（秒）
  @State isPaused: boolean = false; // 是否暂停
  @State isResting: boolean = false; // 是否正在休息
  @State showActionList: boolean = false; // 是否显示动作列表
  @State isFullscreen: boolean = false; // 是否全屏
  @State isVideoReady: boolean = false; // 视频是否准备就绪
  @State isMuted: boolean = false; // 是否静音
  @State isCelebrating: boolean = false; // 是否显示结束庆祝画面
  @State screenAlwaysOn: boolean = true; // 屏幕是否常亮
  
  private course: Course = null;
  private actions: TrainingAction[] = [];
  private timerInterval: number = -1;
  private videoController: VideoController = new VideoController();
  private countdownAudio: string = 'countdown.mp3'; // 倒计时音频
  private completeAudio: string = 'complete.mp3'; // 完成音频
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as Record<string, Object>;
    if (params && params.course) {
      this.course = params.course as Course;
      this.actions = this.course.actions;
    }
    
    // 初始化时间
    this.initTimer();
    
    // 屏幕常亮
    this.keepScreenOn(this.screenAlwaysOn);
  }
  
  onPageShow() {
    // 页面显示时启动定时器
    this.startTimer();
  }
  
  aboutToDisappear() {
    // 清除定时器
    this.clearTimer();
    
    // 恢复屏幕设置
    this.keepScreenOn(false);
  }
  
  // 初始化计时器
  initTimer() {
    if (!this.actions || this.actions.length === 0) return;
    
    // 计算总时间
    this.totalTime = this.actions.reduce((total, action) => {
      return total + action.duration + (action.rest || 0);
    }, 0);
    
    // 设置当前动作剩余时间
    const currentAction = this.actions[this.currentIndex];
    this.timeRemaining = currentAction.duration;
    this.isResting = false;
    
    // 重置已经过时间
    this.elapsedTime = this.calculateElapsedTime();
  }
  
  // 启动定时器
  startTimer() {
    if (this.timerInterval !== -1) return;
    
    this.timerInterval = setInterval(() => {
      if (this.isPaused) return;
      
      // 减少剩余时间
      this.timeRemaining--;
      this.elapsedTime++;
      
      // 当前动作完成
      if (this.timeRemaining <= 0) {
        this.handleActionComplete();
      }
      
      // 倒计时最后3秒播放提示音
      if (!this.isMuted && this.timeRemaining <= 3 && this.timeRemaining > 0) {
        this.playSound(this.countdownAudio);
      }
    }, 1000);
  }
  
  // 清除定时器
  clearTimer() {
    if (this.timerInterval !== -1) {
      clearInterval(this.timerInterval);
      this.timerInterval = -1;
    }
  }
  
  // 暂停/继续训练
  togglePause() {
    this.isPaused = !this.isPaused;
    
    if (this.isPaused) {
      // 暂停视频
      if (this.videoController) {
        this.videoController.pause();
      }
    } else {
      // 继续播放视频
      if (this.videoController) {
        this.videoController.start();
      }
    }
  }
  
  // 处理动作完成
  handleActionComplete() {
    const currentAction = this.actions[this.currentIndex];
    
    // 播放完成提示音
    if (!this.isMuted) {
      this.playSound(this.completeAudio);
    }
    
    // 如果当前不是休息时间，且有设置休息时间，进入休息状态
    if (!this.isResting && currentAction.rest && currentAction.rest > 0) {
      this.isResting = true;
      this.timeRemaining = currentAction.rest;
      return;
    }
    
    // 切换到下一个动作
    this.moveToNextAction();
  }
  
  // 切换到下一个动作
  moveToNextAction() {
    // 如果是最后一个动作
    if (this.currentIndex >= this.actions.length - 1) {
      this.handleTrainingComplete();
      return;
    }
    
    // 切换到下一个动作
    this.currentIndex++;
    const nextAction = this.actions[this.currentIndex];
    this.timeRemaining = nextAction.duration;
    this.isResting = false;
    
    // 更新视频
    if (this.videoController && !this.isPaused) {
      this.videoController.start();
    }
  }
  
  // 处理训练完成
  handleTrainingComplete() {
    // 清除定时器
    this.clearTimer();
    
    // 显示庆祝画面
    this.isCelebrating = true;
    
    // 延迟返回
    setTimeout(() => {
      router.back();
    }, 3000);
  }
  
  // 计算已经过的总时间
  calculateElapsedTime(): number {
    if (!this.actions || this.currentIndex === 0) return 0;
    
    let elapsed = 0;
    // 计算之前动作的总时间
    for (let i = 0; i < this.currentIndex; i++) {
      elapsed += this.actions[i].duration + (this.actions[i].rest || 0);
    }
    
    // 如果当前是休息状态，加上当前动作的时间
    if (this.isResting) {
      elapsed += this.actions[this.currentIndex].duration;
    }
    
    // 加上当前动作已经过的时间
    const currentActionTotalTime = this.isResting ?
      this.actions[this.currentIndex].rest : this.actions[this.currentIndex].duration;
    
    elapsed += (currentActionTotalTime - this.timeRemaining);
    return elapsed;
  }
  
  // 播放声音
  playSound(soundPath: string) {
    // 实际项目中使用媒体API播放声音
    console.info(`播放声音: ${soundPath}`);
  }
  
  // 控制屏幕常亮
  keepScreenOn(enable: boolean) {
    this.screenAlwaysOn = enable;
    // 实际项目中使用系统API控制屏幕
    console.info(`屏幕常亮: ${enable}`);
  }
  
  // 格式化时间
  formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs < 10 ? '0' : ''}${secs}`;
  }
  
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#000000')
      
      // 主要内容
      Column() {
        // 顶部导航栏
        Row() {
          Image($r('app.media.icon'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .onClick(() => {
              router.back();
            })
          
          Text(this.course ? this.course.title : '训练中')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
          
          Image($r('app.media.icon'))
            .width(24)
            .height(24)
            .fillColor(Color.White)
            .onClick(() => {
              this.isMuted = !this.isMuted;
            })
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        
        // 视频区域
        Stack({ alignContent: Alignment.Center }) {
          if (this.actions.length > 0 && this.currentIndex < this.actions.length) {
            // 视频播放器
            if (this.actions[this.currentIndex].video) {
              Video({
                src: this.actions[this.currentIndex].video,
                controller: this.videoController
              })
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .loop(true)
                .autoPlay(!this.isPaused)
                .controls(false)
                .onPrepared(() => {
                  this.isVideoReady = true;
                })
            } else if (this.actions[this.currentIndex].image) {
              // 如果没有视频，显示图片
              Image(this.actions[this.currentIndex].image)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Contain)
            }
          }
          
          // 休息状态显示
          if (this.isResting) {
            Column() {
              Text('休息时间')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              
              Text(this.formatTime(this.timeRemaining))
                .fontSize(64)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .margin({ top: 16 })
              
              Text('即将进行下一个动作')
                .fontSize(16)
                .fontColor(Color.White)
                .margin({ top: 16 })
            }
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.8)')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
          
          // 暂停状态显示
          if (this.isPaused) {
            Column() {
              Image($r('app.media.icon'))
                .width(80)
                .height(80)
                .fillColor(Color.White)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.6)')
            .justifyContent(FlexAlign.Center)
          }
          
          // 庆祝画面
          if (this.isCelebrating) {
            Column() {
              Text('恭喜完成!')
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
              
              Text('你太棒了!')
                .fontSize(18)
                .fontColor(Color.White)
                .margin({ top: 16 })
              
              Lottie({ 
                src: '/assets/celebration.json',
                autoPlay: true, 
                loop: true 
              })
                .width(200)
                .height(200)
            }
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0, 0, 0, 0.8)')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }
        }
        .width('100%')
        .height('50%')
        .onClick(() => {
          this.togglePause();
        })
        
        // 进度区域
        Column({ space: 16 }) {
          // 进度条
          KeepProgressBar({
            value: this.elapsedTime,
            total: this.totalTime,
            showText: true,
            textPosition: 'top',
            formatText: (value, total) => {
              return `${this.formatTime(value)} / ${this.formatTime(total)}`;
            }
          })
            .width('100%')
            .margin({ top: 20 })
          
          // 动作信息
          Column() {
            if (this.actions.length > 0 && this.currentIndex < this.actions.length) {
              Text(this.isResting ? '休息' : this.actions[this.currentIndex].name)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.TEXT_PRIMARY)
              
              if (!this.isResting) {
                Text(this.actions[this.currentIndex].getFormattedDuration())
                  .fontSize(16)
                  .fontColor(AppTheme.TEXT_SECONDARY)
                  .margin({ top: 4 })
              }
              
              // 倒计时
              Text(this.formatTime(this.timeRemaining))
                .fontSize(48)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.PRIMARY_COLOR)
                .margin({ top: 16 })
            }
          }
          .alignItems(HorizontalAlign.Center)
          
          // 控制按钮
          Row({ space: 24 }) {
            // 动作列表按钮
            Button() {
              Image($r('app.media.icon'))
                .width(24)
                .height(24)
                .fillColor(AppTheme.TEXT_PRIMARY)
            }
            .width(56)
            .height(56)
            .borderRadius(28)
            .backgroundColor(AppTheme.BACKGROUND_COLOR)
            .onClick(() => {
              this.showActionList = !this.showActionList;
            })
            
            // 暂停/播放按钮
            Button() {
              Image($r('app.media.icon'))
                .width(24)
                .height(24)
                .fillColor(Color.White)
            }
            .width(64)
            .height(64)
            .borderRadius(32)
            .backgroundColor(AppTheme.PRIMARY_COLOR)
            .onClick(() => {
              this.togglePause();
            })
            
            // 下一个按钮
            Button() {
              Image($r('app.media.icon'))
                .width(24)
                .height(24)
                .fillColor(AppTheme.TEXT_PRIMARY)
            }
            .width(56)
            .height(56)
            .borderRadius(28)
            .backgroundColor(AppTheme.BACKGROUND_COLOR)
            .onClick(() => {
              this.moveToNextAction();
            })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
          .margin({ top: 16 })
        }
        .width('90%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
      
      // 动作列表面板
      Panel(this.showActionList) {
        Column() {
          // 标题
          Row() {
            Text('动作列表')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppTheme.TEXT_PRIMARY)
            
            Blank()
              .layoutWeight(1)
            
            Image($r('app.media.icon'))
              .width(24)
              .height(24)
              .fillColor(AppTheme.TEXT_SECONDARY)
              .onClick(() => {
                this.showActionList = false;
              })
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          
          // 动作列表
          List() {
            ForEach(this.actions, (action: TrainingAction, index: number) => {
              ListItem() {
                Row() {
                  // 序号
                  Text(`${index + 1}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(index === this.currentIndex ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_SECONDARY)
                    .width(32)
                  
                  // 动作名称
                  Column() {
                    Text(action.name)
                      .fontSize(16)
                      .fontWeight(index === this.currentIndex ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(index === this.currentIndex ? AppTheme.PRIMARY_COLOR : AppTheme.TEXT_PRIMARY)
                    
                    Text(action.getFormattedDuration())
                      .fontSize(14)
                      .fontColor(AppTheme.TEXT_SECONDARY)
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  
                  Blank()
                    .layoutWeight(1)
                  
                  // 当前动作指示
                  if (index === this.currentIndex) {
                    Text('进行中')
                      .fontSize(14)
                      .fontColor(AppTheme.PRIMARY_COLOR)
                  } else if (index < this.currentIndex) {
                    Image($r('app.media.icon'))
                      .width(20)
                      .height(20)
                      .fillColor(AppTheme.PRIMARY_COLOR)
                  }
                }
                .width('100%')
                .padding({ top: 16, bottom: 16, left: 16, right: 16 })
                .borderRadius(12)
                .backgroundColor(index === this.currentIndex ? 'rgba(67, 209, 98, 0.1)' : 'transparent')
                .onClick(() => {
                  this.currentIndex = index;
                  this.isResting = false;
                  this.timeRemaining = this.actions[index].duration;
                  this.elapsedTime = this.calculateElapsedTime();
                  this.showActionList = false;
                })
              }
              .padding({ left: 4, right: 4 })
            })
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('70%')
        .padding({ left: 16, right: 16 })
        .backgroundColor(Color.White)
        .borderRadius({ topLeft: 20, topRight: 20 })
      }
      .type(PanelType.Foldable)
      .mode(PanelMode.Half)
      .dragBar(true)
      .halfHeight(550)
      .onChange((width: number, height: number, mode: PanelMode) => {
        if (mode === PanelMode.Mini) {
          this.showActionList = false;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
} 
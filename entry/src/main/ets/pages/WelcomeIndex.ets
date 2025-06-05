import router from '@ohos.router';
import { UserPrivacyDialog } from '../dialog/UserPrivacyDialog';

interface WelcomeItem {
  title: string;
  description: string;
  image: Resource;
}

@Entry
@Component
struct WelcomeIndex {
  @State currentIndex: number = 0;
  @State showPrivacyDialog: boolean = false;
  private swiperController: SwiperController = new SwiperController();
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: UserPrivacyDialog({
      controller: undefined,
      confirm: () => {},
      cancel: () => {}
    }),
    autoCancel: true
  });

  // 完整定义 welcomeData 属性
  private welcomeData: WelcomeItem[] = [
    {
      title: '智能健康助手',
      description: '基于人工智能的健康管理专家',
      image: $r('app.media.welcome_image1')
    },
    {
      title: '个性化健康计划',
      description: '根据您的身体状况定制专属健康方案',
      image: $r('app.media.welcome_image2')
    },
    {
      title: '全面健康数据',
      description: '记录并分析您的健康数据，提供专业建议',
      image: $r('app.media.welcome_image3')
    }
  ];

  aboutToAppear() {
    // 正确初始化对话框控制器
    this.dialogController = new CustomDialogController({
      builder: UserPrivacyDialog({
        controller: this.dialogController,
        confirm: () => {
          router.pushUrl({ url: 'pages/LoginPage' });
        },
        cancel: () => {
          this.showPrivacyDialog = false;
          this.dialogController.close();
        }
      }),
      cancel: () => {
        this.showPrivacyDialog = false;
      },
      autoCancel: true
    });
  }

  // 添加监听 showPrivacyDialog 变化的方法
  onShowPrivacyDialogChange() {
    if (this.showPrivacyDialog && this.dialogController) {
      this.dialogController.open();
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 背景图层
      Column() {
        Image($r('app.media.welcome_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
      }
      .width('100%')
      .height('100%')
      
      // 内容图层
      Swiper(this.swiperController) {
        ForEach(this.welcomeData, (item: WelcomeItem, index: number) => {
          Column() {
            // 标题和描述
            Column() {
              Text(item.title)
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .opacity(0.95)
                .margin({ bottom: 20 })
              
              Text(item.description)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .opacity(0.85)
                .textAlign(TextAlign.Center)
                .padding({ left: 30, right: 30 })
                .margin({ bottom: 80 })
            }
            .position({ x: 0, y: '10%' })
            
            // 中心图像
            Image(item.image)
              .width('100%')
              .height('50%')
              .objectFit(ImageFit.Contain)
              .animation({
                duration: 800,
                curve: Curve.EaseOut,
                iterations: 1,
                playMode: PlayMode.Normal
              })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .index(this.currentIndex)
      .autoPlay(false)
      .indicator(true)
      .indicatorStyle({
        selectedColor: '#007DFF',
        color: 'rgba(255, 255, 255, 0.6)',
        left: 0,
        right: 0,
        bottom: 160
      })
      .loop(false)
      .onChange((index: number) => {
        this.currentIndex = index;
        animateTo({
          duration: 300,
          curve: Curve.EaseInOut
        }, () => {
          // 动画效果
        })
      })
      .width('100%')
      .height('100%')
      
      // 底部按钮
      Column() {
        if (this.currentIndex === this.welcomeData.length - 1) {
          Button('开始使用')
            .width('80%')
            .height(56)
            .backgroundColor('#007DFF')
            .borderRadius(28)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
            .onClick(() => {
              this.showPrivacyDialog = true;
              this.dialogController.open();
            })
        } else {
          Button('下一步')
            .width('80%')
            .height(56)
            .backgroundColor('#007DFF')
            .borderRadius(28)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .shadow({ radius: 8, color: 'rgba(0, 125, 255, 0.3)', offsetX: 0, offsetY: 4 })
            .onClick(() => {
              this.currentIndex++;
              this.swiperController.showNext();
            })
        }

        Text('跳过')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .opacity(0.8)
          .margin({ top: 20, bottom: 40 })
          .padding(10)
          .onClick(() => {
            // 直接设置index属性跳转到最后一页
            this.currentIndex = this.welcomeData.length - 1;
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .position({ x: '50%', y: '85%' })
      .translate({ x: '-50%' })
    }
    .width('100%')
    .height('100%')
    .onAppear(() => {
      if (this.showPrivacyDialog) {
        this.dialogController.open();
      }
    })
  }

  // 添加生命周期方法监听状态变化
  onPageShow() {
    this.onShowPrivacyDialogChange();
  }

  // 监听状态变化
  aboutToUpdate() {
    this.onShowPrivacyDialogChange();
  }
}
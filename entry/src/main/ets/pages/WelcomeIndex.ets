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
      image: $r('app.media.icon')
    },
    {
      title: '个性化健康计划',
      description: '根据您的身体状况定制专属健康方案',
      image: $r('app.media.icon')
    },
    {
      title: '全面健康数据',
      description: '记录并分析您的健康数据，提供专业建议',
      image: $r('app.media.icon')
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
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.swiperController) {
          ForEach(this.welcomeData, (item: WelcomeItem, index: number) => {
            Column() {
              Image(item.image)
                .width('80%')
                .height('50%')
                .objectFit(ImageFit.Contain)
                .margin({ top: 60 })
              
              Text(item.title)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 40 })
              
              Text(item.description)
                .fontSize(16)
                .fontColor('#666666')
                .margin({ top: 10 })
                .textAlign(TextAlign.Center)
                .padding({ left: 20, right: 20 })
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Start)
            .alignItems(HorizontalAlign.Center)
          })
        }
        .index(this.currentIndex)
        .autoPlay(false)
        .indicator(true)
        .loop(false)
        .onChange((index: number) => {
          this.currentIndex = index;
        })
        .width('100%')
        .height('100%')
        
        // 底部按钮
        Column() {
          if (this.currentIndex === this.welcomeData.length - 1) {
            Button('开始使用')
              .width('80%')
              .height(50)
              .backgroundColor('#007DFF')
              .borderRadius(25)
              .fontSize(18)
              .fontColor(Color.White)
              .onClick(() => {
                this.showPrivacyDialog = true;
                this.dialogController.open();
              })
          } else {
            Button('下一步')
              .width('80%')
              .height(50)
              .backgroundColor('#007DFF')
              .borderRadius(25)
              .fontSize(18)
              .fontColor(Color.White)
              .onClick(() => {
                this.currentIndex++;
                this.swiperController.showNext();
              })
          }

          Text('跳过')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 15, bottom: 40 })
            .onClick(() => {
              this.currentIndex = this.welcomeData.length - 1;
              this.swiperController.showNext(); // Fixed: use showNext instead of showIndex
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
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
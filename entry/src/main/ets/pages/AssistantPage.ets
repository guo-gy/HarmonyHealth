import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

// 定义消息类型
enum MessageType {
  SENT,
  RECEIVED
}

// 定义消息接口
interface ChatMessage {
  content: string;
  type: MessageType;
  timestamp: Date;
}

// 定义健康建议接口
interface HealthTip {
  title: string;
  content: string;
  imageUrl: Resource;
}

@Entry
@Component
struct AssistantPage {
  @State message: string = '智能健康助手';
  @State isLoading: boolean = false;
  @State planContent: string = '';
  @State inputMessage: string = '';
  @State chatMessages: ChatMessage[] = [];
  @State healthTips: HealthTip[] = [
    {
      title: '今日饮食建议',
      content: '多摄入蛋白质和蔬菜，减少碳水化合物摄入',
      imageUrl: $r('app.media.food_icon')
    },
    {
      title: '运动小贴士',
      content: '适量有氧运动可以提高心肺功能，建议每周进行3-5次',
      imageUrl: $r('app.media.exercise_icon')
    },
    {
      title: '睡眠提醒',
      content: '保持规律作息，每晚睡前避免使用电子设备',
      imageUrl: $r('app.media.sleep_icon')
    }
  ];
  @State featuredCategories: string[] = ['饮食建议', '运动计划', '健康数据', '睡眠分析'];

  aboutToAppear() {
    // 初始化欢迎消息
    this.chatMessages.push({
      content: '您好！我是您的智能健康助手，有什么可以帮助您的吗？',
      type: MessageType.RECEIVED,
      timestamp: new Date()
    });
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Button() {
          Image($r('app.media.notification_icon'))
            .width(24)
            .height(24)
        }
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#F0F0F0')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 20, bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      
      // 类别滚动条
      Scroll() {
        Row({ space: 12 }) {
          ForEach(this.featuredCategories, (category: string) => {
            Button(category)
              .height(36)
              .padding({ left: 16, right: 16 })
              .backgroundColor('#007DFF')
              .fontColor(Color.White)
              .borderRadius(18)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: 20, right: 10 })

      // 健康建议轮播
      Swiper() {
        ForEach(this.healthTips, (tip: HealthTip) => {
          Row() {
            Column() {
              Text(tip.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Text(tip.content)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ top: 5 })
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            
            Image(tip.imageUrl)
              .width(60)
              .height(60)
              .borderRadius(12)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: 4 })
        })
      }
      .width('90%')
      .height(120)
      .autoPlay(true)
      .interval(4000)
      .indicator(true)
      .indicatorStyle({
        selectedColor: '#007DFF',
        color: '#DDDDDD',
        left: 0,
        right: 0,
        bottom: 0
      })
      .margin({ top: 16, bottom: 16 })

      // 聊天区域
      List({ space: 10, initialIndex: 0 }) {
        ForEach(this.chatMessages, (msg: ChatMessage) => {
          ListItem() {
            Row() {
              if (msg.type === MessageType.RECEIVED) {
                Image($r('app.media.assistant_avatar'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .margin({ right: 10 })
                
                Text(msg.content)
                  .fontSize(16)
                  .backgroundColor('#FFFFFF')
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .borderRadius(18)
                  .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
                  .constraintSize({ maxWidth: '70%' })
              } else {
                Blank()
                  .layoutWeight(1)
                
                Text(msg.content)
                  .fontSize(16)
                  .backgroundColor('#007DFF')
                  .fontColor(Color.White)
                  .padding({ left: 16, right: 16, top: 12, bottom: 12 })
                  .borderRadius(18)
                  .shadow({ radius: 4, color: 'rgba(0, 0, 0, 0.03)', offsetX: 0, offsetY: 2 })
                  .constraintSize({ maxWidth: '70%' })
                
                Image($r('app.media.user_avatar'))
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .margin({ left: 10 })
              }
            }
            .width('100%')
            .padding({ top: 10, bottom: 10 })
            .alignItems(VerticalAlign.Top)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 15, right: 15 })

      // 加载动画
      if (this.isLoading) {
        LoadingProgress()
          .color('#007DFF')
          .width(50)
          .height(50)
      }

      // 输入区域
      Row() {
        TextInput({ placeholder: '请输入您的问题...' })
          .width('75%')
          .height(50)
          .backgroundColor('#F6F6F6')
          .borderRadius(25)
          .padding({ left: 20, right: 20 })
          .onChange((value: string) => {
            this.inputMessage = value;
          })
        
        Button() {
          Image($r('app.media.send_icon'))
            .width(24)
            .height(24)
        }
        .width(50)
        .height(50)
        .backgroundColor(this.inputMessage.length > 0 ? '#007DFF' : '#DDDDDD')
        .borderRadius(25)
        .margin({ left: 10 })
        .enabled(this.inputMessage.length > 0 && !this.isLoading)
        .onClick(() => {
          this.sendMessage();
        })
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)
      .shadow({ radius: 16, color: 'rgba(0, 0, 0, 0.05)', offsetX: 0, offsetY: -4 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F8F8')
  }

  sendMessage() {
    if (this.inputMessage.trim().length === 0) {
      return;
    }

    // 添加用户消息
    this.chatMessages.push({
      content: this.inputMessage,
      type: MessageType.SENT,
      timestamp: new Date()
    });

    const message = this.inputMessage;
    this.inputMessage = '';
    this.isLoading = true;

    // 模拟AI回复
    setTimeout(() => {
      let response: string = '感谢您的提问。作为您的健康助手，我可以为您提供运动建议、饮食指导和健康计划。请告诉我您需要什么帮助？';
      
      this.chatMessages.push({
        content: response,
        type: MessageType.RECEIVED,
        timestamp: new Date()
      });
      
      this.isLoading = false;
    }, 1000);
  }
}

export { AssistantPage }
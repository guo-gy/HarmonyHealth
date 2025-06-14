import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { chatService, ApiChatMessage } from '../services/ChatService';

// 定义UI上显示的消息类型
enum MessageType {
  SENT,
  RECEIVED
}

// 定义UI上显示的消息接口
interface ChatMessage {
  content: string;
  type: MessageType;
  timestamp: Date;
}

@Entry
@Component
export struct AssistantPage {
  // --- 核心状态变量 ---
  @State message: string = '智能健康助手';
  @State isLoading: boolean = false;
  @State inputMessage: string = '';
  @State chatMessages: ChatMessage[] = []; // 用于UI显示
  @State conversationHistory: ApiChatMessage[] = []; // 用于API交互

  // --- 生命周期函数 ---
  aboutToAppear() {
    // 只有在聊天记录为空时才添加欢迎消息，防止重复添加
    if (this.chatMessages.length === 0) {
      this.chatMessages.push({
        content: '您好！我是您的智能健康助手，有什么可以帮助您的吗？',
        type: MessageType.RECEIVED,
        timestamp: new Date()
      });
    }
  }

  // --- 核心交互逻辑 ---
  async sendMessage(): Promise<void> {
    const userMessageContent = this.inputMessage.trim();
    if (userMessageContent.length === 0 || this.isLoading) {
      return;
    }

    // 步骤 A: 立即更新UI，显示用户发送的消息
    this.chatMessages.push({
      content: userMessageContent,
      type: MessageType.SENT,
      timestamp: new Date()
    });

    // 立即清空输入框并设置加载状态
    const messageToSend = this.inputMessage;
    this.inputMessage = ''; // <-- 清空输入框状态变量
    this.isLoading = true;

    // 步骤 B: 调用 ChatService
    try {
      const result = await chatService.sendMessage({
        message: messageToSend,
        history: this.conversationHistory,
      });

      // 步骤 C: 处理返回结果
      if (result.code === 200 && result.data) {
        const aiReply = result.data.reply;
        const updatedHistory = result.data.history;

        // 在UI中显示AI的回复
        this.chatMessages.push({
          content: aiReply,
          type: MessageType.RECEIVED,
          timestamp: new Date()
        });
        // 更新用于下一次API调用的历史记录
        this.conversationHistory = updatedHistory;
      } else {
        // 处理业务逻辑或网络层面的已知错误
        this.handleError(result.message);
      }
    } catch (err) {
      // 捕获请求过程中的意外JS异常
      this.handleError('发生未知错误，请稍后重试');
      console.error('Unexpected error in sendMessage:', JSON.stringify(err));
    } finally {
      // 无论成功还是失败，最后都结束加载状态
      this.isLoading = false;
    }
  }

  // 辅助函数，用于统一处理错误并在UI上显示
  handleError(errorMessage: string): void {
    this.chatMessages.push({
      content: `发生错误: ${errorMessage}`,
      type: MessageType.RECEIVED,
      timestamp: new Date()
    });
    promptAction.showToast({ message: errorMessage, duration: 3000 });
  }

  // --- UI 构建函数 ---
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message).fontSize(22).fontWeight(FontWeight.Bold)
        Blank()
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.notification_icon')).width(24).height(24)
        }.width(40).height(40).backgroundColor(Color.White)
      }
      .width('100%').padding({ left: 20, right: 20, top: 20, bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)

      // 聊天区域
      List({ space: 12, initialIndex: this.chatMessages.length - 1 }) {
        ForEach(this.chatMessages, (msg: ChatMessage) => {
          ListItem() {
            Row() {
              if (msg.type === MessageType.RECEIVED) {
                Image($r('app.media.assistant_avatar')).width(40).height(40).borderRadius(20)
                Text(msg.content)
                  .fontSize(16).padding(15).borderRadius(18)
                  .backgroundColor(Color.White)
                  .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)' })
                  .constraintSize({ maxWidth: '75%' })
                  .margin({ left: 10 })
              } else {
                Blank()
                Text(msg.content)
                  .fontSize(16).padding(15).borderRadius(18)
                  .backgroundColor('#007DFF').fontColor(Color.White)
                  .shadow({ radius: 4, color: 'rgba(0,100,255,0.2)' })
                  .constraintSize({ maxWidth: '75%' })
                Image($r('app.media.user_avatar')).width(40).height(40).borderRadius(20).margin({ left: 10 })
              }
            }.width('100%').alignItems(VerticalAlign.Top)
          }
        }, (item: ChatMessage) => item.timestamp.getTime().toString()) // 使用时间戳作为唯一key
      }
      .width('100%').layoutWeight(1).padding({ left: 15, right: 15 })
      .edgeEffect(EdgeEffect.None) // 去掉滚动到边缘的效果

      // 加载动画
      if (this.isLoading) {
        Row() {
          LoadingProgress().width(20).height(20).color('#007DFF')
          Text('助手思考中...').fontSize(14).fontColor(Color.Gray).margin({ left: 8 })
        }.padding({ bottom: 10 })
      }

      // 输入区域
      Row({ space: 10 }) {
        TextInput({ placeholder: '请输入您的问题...' ,text: this.inputMessage})
          .layoutWeight(1).height(50)
          .backgroundColor('#F7F7F7').borderRadius(25)
          .padding({ left: 20, right: 20 })
            // 关键：将 value 和 onChange 绑定，以实现双向数据流
          .onChange((value: string) => {
            this.inputMessage = value;
          })
          .onSubmit(() => { // 支持回车键发送
            this.sendMessage();
          })

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.send_icon')).width(24).height(24)
        }
        .width(50).height(50)
        .backgroundColor(this.inputMessage.length > 0 ? '#007DFF' : '#E0E0E0')
        .enabled(this.inputMessage.length > 0 && !this.isLoading)
        .onClick(() => {
          this.sendMessage();
        })
      }
      .width('100%').padding(15).backgroundColor(Color.White)
      .shadow({ radius: 16, color: 'rgba(0,0,0,0.05)', offsetY: -4 })

    }.width('100%').height('100%').backgroundColor('#F0F2F5')
  }
}
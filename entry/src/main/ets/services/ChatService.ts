import http from '@ohos.net.http';
import { AppConfig } from '../common/config';

// 定义API返回的基础结构
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// 定义发送给API的对话历史消息格式
export interface ApiChatMessage {
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  // 其他可能的字段，如 tool_calls
  tool_calls?: any[];
  tool_call_id?: string;
}

// 定义AI回复的数据结构
interface AiReplyData {
  reply: string;
  history: ApiChatMessage[];
}

// 定义请求体结构
interface ChatRequestBody {
  message: string;
  history: ApiChatMessage[];
}

class ChatService {
  // 你的Django后端API地址，请确保手机可以访问到
  // 如果是在电脑上运行模拟器，可以使用 10.0.2.2 指向电脑的 localhost
  private readonly BASE_URL = AppConfig.API_BASE_URL;

  /**
   * 发送聊天消息到后端并获取AI回复
   * @param requestBody 包含用户消息和对话历史的请求体
   * @returns 返回一个Promise，包含处理后的AI回复数据
   */
  async sendMessage(requestBody: ChatRequestBody): Promise<ApiResponse<AiReplyData>> {
    const httpRequest = http.createHttp();
    const url = `${this.BASE_URL}/api/chat/`;

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
        },
        extraData: JSON.stringify(requestBody),
        // 你可以设置连接和读取超时，以防止长时间等待
        connectTimeout: 15000, // 15秒
        readTimeout: 60000,    // 60秒，因为AI生成可能需要时间
      });

      if (response.responseCode >= 200 && response.responseCode < 300) {
        // 请求成功，解析业务数据
        return JSON.parse(response.result as string) as ApiResponse<AiReplyData>;
      } else {
        // HTTP层面出错，构造一个标准的错误返回
        console.error(`HTTP Error: ${response.responseCode}`, response.result);
        return {
          code: response.responseCode,
          message: `网络服务错误，状态码: ${response.responseCode}`,
          data: null,
        };
      }
    } catch (err) {
      // 网络请求过程中发生异常
      console.error('Network request failed', err);
      return {
        code: -1, // 自定义一个错误码表示客户端异常
        message: '无法连接到服务器，请检查网络连接或服务器地址。',
        data: null,
      };
    } finally {
      // 销毁httpRequest对象
      httpRequest.destroy();
    }
  }
}

// 导出一个单例，这样在整个应用中都使用同一个ChatService实例
export const chatService = new ChatService();
import http from '@ohos.net.http';
import { AppConfig } from '../common/config'; // 假设你的API地址在config中
import UserSessionManager from '../common/UserSession';

// ======================================================
// === 类型定义部分 (保持不变) ===
// ======================================================

export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T | null;
}

export interface ApiChatMessage {
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string | null; // content 可能为 null (例如，当 assistant 返回 tool_calls 时)
  tool_calls?: any[];
  tool_call_id?: string;
  name?: string; // tool 角色需要 name 字段
}

export interface AiReplyData {
  reply: string;
  history: ApiChatMessage[];
}

export interface ChatRequestBody {
  message: string;
  history: ApiChatMessage[];
}

// ======================================================
// === Service 类定义部分 ===
// ======================================================

class ChatService {
  private readonly BASE_URL = AppConfig.API_BASE_URL;

  /**
   * 发送聊天消息到后端并获取AI回复
   * @param requestBody 包含用户消息和对话历史的请求体
   * @returns 返回一个Promise，包含处理后的AI回复数据
   */
  async sendMessage(requestBody: ChatRequestBody): Promise<ApiResponse<AiReplyData>> {
    const token = await UserSessionManager.getToken();
    if (!token) {
      return { code: 401, message: '用户未登录或Token已失效', data: null };
    }

    // --- 核心修改：清理和简化 history ---
    // 这个步骤能极大地提高多轮对话的稳定性
    const cleanedHistory = requestBody.history
      .map((msg: ApiChatMessage) => {
        // 创建一个只包含必要字段的新对象
        const newMsg: ApiChatMessage = {
          role: msg.role,
          content: msg.content,
        };

        // 如果是 assistant 角色且有工具调用，则保留 tool_calls
        if (msg.role === 'assistant' && msg.tool_calls) {
          newMsg.tool_calls = msg.tool_calls;
        }

        // 如果是 tool 角色，则保留 tool_call_id 和 name
        if (msg.role === 'tool') {
          newMsg.tool_call_id = msg.tool_call_id;
          newMsg.name = msg.name;
          // 确保 tool 角色的 content 是字符串，即使它是 null
          // OpenAI API 要求 tool 角色的 content 是 string
          newMsg.content = String(msg.content);
        }

        return newMsg;
      })
        // 过滤掉没有 role 的无效消息
      .filter((msg: ApiChatMessage) => msg.role);

    const finalRequestBody = {
      message: requestBody.message,
      history: cleanedHistory,
    };
    // ------------------------------------

    // 打印清理后的请求体，用于调试
    console.info("[ChatService] Sending CLEANED request data:", JSON.stringify(finalRequestBody, null, 2));

    const httpRequest = http.createHttp();
    const url = `${this.BASE_URL}/api/chat/`;

    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json',
        },
        // 发送清理后的请求体
        extraData: JSON.stringify(finalRequestBody),
        connectTimeout: 15000, // 15秒连接超时
        readTimeout: 60000,    // 60秒读取超时，因为AI生成可能需要时间
      });

      if (response.responseCode >= 200 && response.responseCode < 300) {
        return JSON.parse(response.result as string) as ApiResponse<AiReplyData>;
      } else {
        console.error(`HTTP Error: ${response.responseCode}`, response.result);
        return {
          code: response.responseCode,
          message: `网络服务错误，状态码: ${response.responseCode}`,
          data: null,
        };
      }
    } catch (err) {
      console.error('Network request failed', err);
      return {
        code: -1,
        message: '无法连接到服务器，请检查网络连接或服务器地址。',
        data: null,
      };
    } finally {
      httpRequest.destroy();
    }
  }
}

// 导出一个单例
export const chatService = new ChatService();
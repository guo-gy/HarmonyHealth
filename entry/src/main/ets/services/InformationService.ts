// /services/InformationService.ts

import http from '@ohos.net.http';
import { GetInformationResponse, UpdateInformationResponse, InformationAttribute } from '../models/InformationModels';
import {AppConfig} from '../common/config'
import UserSessionManager from '../common/UserSession';

class InformationService {
  private readonly BASE_URL = AppConfig.API_BASE_URL;

  /**
   * 通用更新函数，用于更新指定的单个用户信息属性。
   * @param attributeName - 要更新的属性名 (e.g., 'height', 'weight')
   * @param value - 要设置的新值
   */
  async updateAttribute(attributeName: InformationAttribute, value: string | number): Promise<UpdateInformationResponse> {
    const url = `${this.BASE_URL}/api/information/update/${attributeName}/`;
    const token = await UserSessionManager.getToken();
    console.info(`[InfoService] 发送更新请求到: ${url}`);

    if (!token) {
      // 这里的返回逻辑可以保留
      return { code: 401, message: '用户未登录', data: null };
    }

    // [修复 1]：构建一个固定结构的请求体，键名始终为 'value'
    const requestBody = {
      value: value
    };


    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json', // 依然是必须的
          'Authorization': `Token ${token}`
        },
        extraData: JSON.stringify(requestBody)
      });

      console.info(`[InfoService] 更新 '${attributeName}' 响应码: ${response.responseCode}`);

      // 增加对 400 错误的详细日志记录
      if (response.responseCode >= 400) {
        console.error(`[InfoService] 服务器返回错误: ${response.responseCode}`, response.result);
      }

      const result: UpdateInformationResponse = JSON.parse(response.result as string);
      return result;

    } catch (err) {
      console.error(`[InfoService] 请求 '${attributeName}' 时发生网络或解析错误:`, err);
      // 抛出错误或返回一个表示失败的固定对象
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 通用获取函数，用于获取指定的单个用户信息属性。
   * @param attributeName - 要获取的属性名 (e.g., 'height', 'weight')
   */
  async getAttribute(attributeName: InformationAttribute): Promise<GetInformationResponse> {
    // 根据 attribute_name 构建动态 URL
    const url = `${this.BASE_URL}/api/information/get/${attributeName}/`;
    const token = await UserSessionManager.getToken();
    console.info(`[InfoService] 发送获取请求到: ${url}`);
    if (!token) {
      return { code: 401, message: '用户未登录', data: null };
    }

    const httpRequest = http.createHttp();
    try {
      // http 模块会自动携带 cookie
      // GET 请求通常没有请求体，但我们的后端视图是 @require_POST，所以保持 POST
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {'Authorization': `Token ${token}`},
      });

      console.info(`[InfoService] 获取 '${attributeName}' 响应码: ${response.responseCode}`);
      const result: GetInformationResponse = JSON.parse(response.result as string);
      return result;
    } finally {
      httpRequest.destroy();
    }
  }
}

// 导出一个单例，方便在UI层直接使用
export const informationService = new InformationService();
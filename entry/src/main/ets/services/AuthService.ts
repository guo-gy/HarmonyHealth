// /services/AuthService.ts

import http from '@ohos.net.http';
import { ServiceResult, AuthData } from '../models/AuthModels';
import UserSessionManager from '../common/UserSession';
import {AppConfig} from '../common/config'

class AuthService {

  private readonly BASE_URL = AppConfig.API_BASE_URL;

  /**
   * 发送注册请求
   */
  async register(username: string, password: string): Promise<ServiceResult<AuthData>> {
    const url = `${this.BASE_URL}/api/user/register/`;
    console.info(`[AuthService] 发送注册请求到: ${url}`);

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      });

      console.info(`[AuthService] 注册响应码: ${response.responseCode}`);
      const result: ServiceResult<AuthData> = JSON.parse(response.result as string);
      return result;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送登录请求
   * 成功后，http 模块会自动处理并存储 sessionid cookie
   */
  async login(username: string, password: string): Promise<ServiceResult<AuthData>> {
    const url = `${this.BASE_URL}/api/user/login/`;
    console.info(`[AuthService] 发送登录请求到: ${url}`);

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ username, password })
      });

      console.info(`[AuthService] 登录响应码: ${response.responseCode}`);
      const result: ServiceResult<AuthData> = JSON.parse(response.result as string);

      if (result.code === 200 && result.data && result.data.token) {
        // 登录成功，更新全局会话状态
        UserSessionManager.login(result.data.username,result.data.token);
      }
      return result;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 发送退出登录请求
   * http 模块会自动携带已保存的 cookie
   */
  async logout(): Promise<ServiceResult<null>> {
    const url = `${this.BASE_URL}/api/user/logout/`;
    console.info(`[AuthService] 发送登出请求到: ${url}`);

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST
      });

      console.info(`[AuthService] 登出响应码: ${response.responseCode}`);
      const result: ServiceResult<null> = JSON.parse(response.result as string);

      if (result.code === 200) {
        // 登出成功，清除全局会话状态
        UserSessionManager.logout();
      }
      return result;
    } finally {
      httpRequest.destroy();
    }
  }
}

// 导出一个单例，方便在UI层直接使用
export const authService = new AuthService();
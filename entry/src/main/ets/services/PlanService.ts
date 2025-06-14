import http from '@ohos.net.http';
import { AppConfig } from '../common/config';
import UserSessionManager from '../common/UserSession';
import { NewPlanData,RecentPlan,GetRecentPlansSuccessData,GetOverPlansSuccessData } from '../models/PlanModels';

// ======================================================
// === 类型定义部分 (确保每一个都被导出) ===
// ======================================================
/**
 * API响应的通用基础结构
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T | null;
}

/**
 * 单个计划的数据模型，与后端Plan模型字段对应
 */
export interface Plan {
  id: number;
  title: string;
  description?: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
  is_completed: boolean;
}

/**
 * 获取计划API成功时，data字段的结构
 */
export interface GetPlansSuccessData {
  plans: Plan[];
  count: number;
}

/**
 * 创建或更新计划API成功时，data字段的结构
 */
export interface MutatePlanSuccessData {
  created?: number;
  updated?: number;
  id?: number;
}


// ======================================================
// === Service 类定义部分 ===
// ======================================================

class PlanService {
  private readonly BASE_URL = AppConfig.API_BASE_URL;
  /**
   * 获取用户的周常计划。
   */
  async getPlans(dayOfWeek?: number): Promise<ApiResponse<GetPlansSuccessData>> {
    let url = `${this.BASE_URL}/api/plan/list/`; // 对应后端的 list_plans_view
    if (dayOfWeek) {
      url += `?day_of_week=${dayOfWeek}`;
    }
    const token = await UserSessionManager.getToken();
    if (!token) {
      return { code: 401, message: '用户未登录', data: null };
    }
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Authorization': `Token ${token}` }
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      }
      return { code: response.responseCode, message: '获取计划失败', data: null };
    } catch (err) {
      return { code: -1, message: '网络请求异常', data: null };
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 更新一个已存在的计划。
   */
  async updatePlan(planId: number, dataToUpdate: { is_completed: boolean }): Promise<ApiResponse<MutatePlanSuccessData>> {
    const url = `${this.BASE_URL}/api/plan/manage/`; // 对应后端的 manage_plans_view
    const requestData = { id: planId, ...dataToUpdate };
    return this.sendManageRequest(url, requestData);
  }

  /**
   * 内部私有方法，用于向 'manage/' 端点发送 POST 请求 (创建或更新)
   */
  private async sendManageRequest(url: string, data: object): Promise<ApiResponse<MutatePlanSuccessData>> {
    const token = await UserSessionManager.getToken();
    if (!token) { return { code: 401, message: '用户未登录', data: null }; }
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(data)
      });
      if (response.responseCode >= 200 && response.responseCode < 300) {
        return JSON.parse(response.result as string);
      }
      const result = JSON.parse(response.result as string);
      return { code: response.responseCode, message: result.message || '操作失败', data: null };
    } catch (err) {
      return { code: -1, message: '网络请求异常', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
  async createPlan(planData: NewPlanData): Promise<ApiResponse<MutatePlanSuccessData>> {
    const url = `${this.BASE_URL}plan/manage/`;
    // 后端通过 planData 中是否包含 'id' 来判断是创建还是更新
    return this.sendManageRequest(url, planData);
  }
  async getRecentPlans(limit: number = 5): Promise<ApiResponse<GetRecentPlansSuccessData>> {
    const url = `${this.BASE_URL}/api/plan/recent/?limit=${limit}`;
    const token = await UserSessionManager.getToken();
    if (!token) return { code: 401, message: '用户未登录', data: null };

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Authorization': `Token ${token}` },
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      }
      return { code: response.responseCode, message: '获取最近计划失败', data: null };
    } catch (err) {
      return { code: -1, message: '网络请求异常', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
  async getOverPlans(): Promise<ApiResponse<GetOverPlansSuccessData>> {
    const url = `${this.BASE_URL}/api/plan/over/`;
    const token = await UserSessionManager.getToken();
    if (!token) return { code: 401, message: '用户未登录', data: null };

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: { 'Authorization': `Token ${token}` },
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      }
      return { code: response.responseCode, message: '获取最近完成计划数失败', data: null };
    } catch (err) {
      return { code: -1, message: '网络请求异常', data: null };
    } finally {
      httpRequest.destroy();
    }
  }
}

export const planService = new PlanService();
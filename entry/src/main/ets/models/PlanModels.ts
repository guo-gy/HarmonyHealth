// src/main/ets/models/PlanModels.ts

/**
 * 数据库中 Plan 模型的完整接口
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
 * 用于创建新计划的数据接口，不包含 id 和 is_completed
 */
export interface NewPlanData {
  title: string;
  description: string;
  day_of_week: number;
  start_time: string;
  end_time: string;
}

/**
 * API响应的通用基础结构
 */
export interface ApiResponse<T> {
  code: number;
  message: string;
  data: T | null;
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

export interface RecentPlan {
  id: number;
  title: string;
  description?: string;
  start_time: string;
  is_completed: boolean;
  display_date: string; // 后端格式化好的显示日期
}

export interface GetRecentPlansSuccessData {
  recent_plans: RecentPlan[];
}

export interface GetOverPlansSuccessData {
  recent_plans_count: number;
}

export interface GetWorkoutData {
  recent_plans_count: number[];
}
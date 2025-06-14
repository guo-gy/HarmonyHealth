import { HealthPlan } from '../models/HealthReportModels';
import { DatabaseService } from './DatabaseService';

export class PlanService {
  private static instance: PlanService;
  private dbService: DatabaseService;

  private constructor() {
    this.dbService = DatabaseService.getInstance();
  }

  public static getInstance(): PlanService {
    if (!PlanService.instance) {
      PlanService.instance = new PlanService();
    }
    return PlanService.instance;
  }

  // 获取用户的健康计划
  public async getUserPlans(userId: string): Promise<HealthPlan[]> {
    try {
      const result = await this.dbService.query(
        `SELECT * FROM health_plans 
         WHERE user_id = ? 
         AND status = 'active'
         ORDER BY created_at DESC`,
        [userId]
      );
      
      return result || [];
    } catch (error) {
      console.error('Failed to get user plans:', error);
      throw error;
    }
  }

  // 创建新的健康计划
  public async createPlan(userId: string, plan: Omit<HealthPlan, 'id'>): Promise<void> {
    try {
      await this.dbService.execute(
        `INSERT INTO health_plans 
         (user_id, type, current, target, period, progress, status)
         VALUES (?, ?, ?, ?, ?, ?, 'active')`,
        [
          userId,
          plan.type,
          plan.current,
          plan.target,
          plan.period,
          plan.progress
        ]
      );
    } catch (error) {
      console.error('Failed to create plan:', error);
      throw error;
    }
  }

  // 更新计划进度
  public async updatePlanProgress(planId: string, current: number, progress: number): Promise<void> {
    try {
      await this.dbService.execute(
        `UPDATE health_plans 
         SET current = ?, progress = ?
         WHERE id = ?`,
        [current, progress, planId]
      );
    } catch (error) {
      console.error('Failed to update plan progress:', error);
      throw error;
    }
  }

  // 完成计划
  public async completePlan(planId: string): Promise<void> {
    try {
      await this.dbService.execute(
        `UPDATE health_plans 
         SET status = 'completed', completed_at = CURRENT_TIMESTAMP
         WHERE id = ?`,
        [planId]
      );
    } catch (error) {
      console.error('Failed to complete plan:', error);
      throw error;
    }
  }
} 
import { HealthReport, BasicInfo, HealthAnalysis, WorkoutTrend, HealthCharts, HealthPlan } from '../models/HealthReportModels';
import { InformationService } from './InformationService';
import { WorkoutService } from './WorkoutService';
import { PlanService } from './PlanService';

export class HealthReportService {
  private static instance: HealthReportService;
  private informationService: InformationService;
  private workoutService: WorkoutService;
  private planService: PlanService;

  private constructor() {
    this.informationService = InformationService.getInstance();
    this.workoutService = WorkoutService.getInstance();
    this.planService = PlanService.getInstance();
  }

  public static getInstance(): HealthReportService {
    if (!HealthReportService.instance) {
      HealthReportService.instance = new HealthReportService();
    }
    return HealthReportService.instance;
  }

  private calculateBMI(height: number, weight: number): number {
    const heightInMeters = height / 100;
    return Number((weight / (heightInMeters * heightInMeters)).toFixed(1));
  }

  private getBMIStatus(bmi: number): string {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }

  private getWorkoutAnalysis(workoutCount: number): string {
    if (workoutCount < 3) {
      return '您的运动频率较低，建议增加运动次数以改善健康状况。';
    } else if (workoutCount < 5) {
      return '您的运动频率适中，继续保持！';
    } else {
      return '您的运动频率很高，注意不要过度运动，保持适度。';
    }
  }

  private getHealthSuggestion(bmi: number, workoutCount: number): string {
    let suggestion = '';
    if (bmi < 18.5) {
      suggestion = '建议适当增加营养摄入，进行力量训练以增加肌肉量。';
    } else if (bmi >= 24) {
      suggestion = '建议控制饮食，增加有氧运动，保持健康体重。';
    } else {
      suggestion = '您的体重在健康范围内，继续保持良好的生活习惯。';
    }

    if (workoutCount < 3) {
      suggestion += ' 建议每周至少进行3次运动，每次30分钟以上。';
    }

    return suggestion;
  }

  private async getWorkoutTrends(userId: string): Promise<WorkoutTrend[]> {
    const workouts = await this.workoutService.getRecentWorkouts(userId);
    const today = new Date();
    const trends: WorkoutTrend[] = [];
    
    // 生成最近7天的日期
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const dateStr = `${date.getMonth() + 1}/${date.getDate()}`;
      
      // 计算当天的运动次数
      const count = workouts.filter(w => 
        new Date(w.date).toDateString() === date.toDateString()
      ).length;
      
      trends.push({
        date: dateStr,
        count
      });
    }
    
    return trends;
  }

  public async generateReport(userId: string): Promise<HealthReport> {
    try {
      // 获取用户基本信息
      const userInfo = await this.informationService.getUserInfo(userId);
      const { height, weight, age } = userInfo;

      // 获取运动统计
      const workoutStats = await this.workoutService.getWorkoutStats(userId);
      const workoutCount = workoutStats.totalWorkouts;

      // 计算健康指标
      const bmi = this.calculateBMI(height, weight);
      const bmiStatus = this.getBMIStatus(bmi);
      const workoutAnalysis = this.getWorkoutAnalysis(workoutCount);
      const healthSuggestion = this.getHealthSuggestion(bmi, workoutCount);

      // 获取运动趋势
      const workoutTrends = await this.getWorkoutTrends(userId);

      // 获取健康计划
      const plans = await this.planService.getUserPlans(userId);

      // 构建报告
      const basicInfo: BasicInfo = {
        height,
        weight,
        age,
        workoutCount
      };

      const analysis: HealthAnalysis = {
        bmi,
        bmiStatus,
        workoutAnalysis,
        healthSuggestion
      };

      const charts: HealthCharts = {
        workoutTrend: workoutTrends,
        plans
      };

      return {
        basicInfo,
        analysis,
        charts
      };
    } catch (error) {
      if (error instanceof Error) {
        throw new Error(`Failed to generate health report: ${error.message}`);
      }
      throw new Error('Failed to generate health report');
    }
  }
} 
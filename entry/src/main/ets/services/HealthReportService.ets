import { HealthReport, BasicInfo, HealthAnalysis, WorkoutTrend, HealthCharts, HealthPlan } from '../models/HealthReportModels';
import { informationService } from './InformationService';
import { planService } from './PlanService';

export class HealthReportService {
  private static instance: HealthReportService;

  private constructor() {}

  public static getInstance(): HealthReportService {
    if (!HealthReportService.instance) {
      HealthReportService.instance = new HealthReportService();
    }
    return HealthReportService.instance;
  }

  private calculateBMI(height: number, weight: number): number {
    // 身高转换为米
    const heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
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

  private generateMockWorkoutTrend(): WorkoutTrend[] {
    const today = new Date();
    const trend: WorkoutTrend[] = [];
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      trend.push({
        date: `${date.getMonth() + 1}/${date.getDate()}`,
        count: Math.floor(Math.random() * 3) + 1
      });
    }
    
    return trend;
  }

  private generateMockHealthPlans(): HealthPlan[] {
    return [
      {
        type: '体重目标',
        current: 70,
        target: 65,
        period: '3个月',
        progress: 0.2
      },
      {
        type: '每周运动',
        current: 3,
        target: 5,
        period: '1个月',
        progress: 0.6
      },
      {
        type: '每日步数',
        current: 8000,
        target: 10000,
        period: '2周',
        progress: 0.8
      }
    ];
  }

  public async generateReport(): Promise<HealthReport> {
    try {
      // 获取用户基本信息
      const heightResult = await informationService.getAttribute('height');
      const weightResult = await informationService.getAttribute('weight');
      const ageResult = await informationService.getAttribute('age');

      if (heightResult.code !== 200 || weightResult.code !== 200 || ageResult.code !== 200) {
        throw new Error('Failed to fetch user information');
      }

      const height = heightResult.data?.height || 170;
      const weight = weightResult.data?.weight || 60;
      const age = ageResult.data?.age || 25;
      const workoutCount = Math.floor(Math.random() * 7) + 1; // 模拟运动次数

      const bmi = this.calculateBMI(height, weight);
      const bmiStatus = this.getBMIStatus(bmi);
      const workoutAnalysis = this.getWorkoutAnalysis(workoutCount);
      const healthSuggestion = this.getHealthSuggestion(bmi, workoutCount);

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
        workoutTrend: this.generateMockWorkoutTrend(),
        plans: this.generateMockHealthPlans()
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
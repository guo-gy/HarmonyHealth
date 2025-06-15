import { HealthReport, BasicInfo, HealthAnalysis, HealthCharts } from '../models/HealthReportModels';
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

  public async generateReport(): Promise<HealthReport> {
    try {
      // 获取用户基本信息
      const heightResult = await informationService.getAttribute('height');
      const weightResult = await informationService.getAttribute('weight');
      const ageResult = await informationService.getAttribute('age');
      const overResult  = await planService.getOverPlans();
      const workoutResult  =await planService.getWorkoutPlans();

      if (heightResult.code !== 200 || weightResult.code !== 200 || ageResult.code !== 200) {
        throw new Error('Failed to fetch user information');
      }

      const height = heightResult.data?.height || 170;
      const weight = weightResult.data?.weight || 60;
      const age = ageResult.data?.age || 25;
      const over = overResult.data?.recent_plans_count||0
      const workoutCount = workoutResult.data?.recent_plans_count||[0,0,0,0,0,0,0];
      const bmi = this.calculateBMI(height, weight);
      const bmiStatus = this.getBMIStatus(bmi);
      const workoutAnalysis = this.getWorkoutAnalysis(over);
      const healthSuggestion = this.getHealthSuggestion(bmi, over);

      const basicInfo: BasicInfo = {
        height,
        weight,
        age,
        over
      };

      const analysis: HealthAnalysis = {
        bmi,
        bmiStatus,
        workoutAnalysis,
        healthSuggestion
      };

      const charts: HealthCharts = {
        workoutCount
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
// ===== 健康报告服务 =====
import { HealthReport, BasicInfo, HealthAnalysis, HealthCharts } from '../models/HealthReportModels';
import { informationService } from './InformationService';
import { planService } from './PlanService';

/**
 * 健康报告服务类
 * 采用单例模式，负责生成和处理健康报告
 */
export class HealthReportService {
  private static instance: HealthReportService;

  private constructor() {}

  /**
   * 获取HealthReportService的单例实例
   * @returns HealthReportService实例
   */
  public static getInstance(): HealthReportService {
    if (!HealthReportService.instance) {
      HealthReportService.instance = new HealthReportService();
    }
    return HealthReportService.instance;
  }

  /**
   * 计算BMI指数
   * @param height 身高（厘米）
   * @param weight 体重（千克）
   * @returns BMI指数
   */
  private calculateBMI(height: number, weight: number): number {
    // 身高转换为米
    const heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /**
   * 根据BMI指数获取健康状态
   * @param bmi BMI指数
   * @returns 健康状态描述
   */
  private getBMIStatus(bmi: number): string {
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24) return '正常';
    if (bmi < 28) return '超重';
    return '肥胖';
  }

  /**
   * 分析运动频率并生成建议
   * @param workoutCount 运动次数
   * @returns 运动分析结果
   */
  private getWorkoutAnalysis(workoutCount: number): string {
    if (workoutCount < 3) {
      return '您的运动频率较低，建议增加运动次数以改善健康状况。';
    } else if (workoutCount < 5) {
      return '您的运动频率适中，继续保持！';
    } else {
      return '您的运动频率很高，注意不要过度运动，保持适度。';
    }
  }

  /**
   * 根据BMI和运动次数生成健康建议
   * @param bmi BMI指数
   * @param workoutCount 运动次数
   * @returns 健康建议
   */
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

  /**
   * 生成完整的健康报告
   * 整合用户基本信息、健康分析和图表数据
   * @returns 健康报告对象
   */
  public async generateReport(): Promise<HealthReport> {
    try {
      // 获取用户基本信息
      const heightResult = await informationService.getAttribute('height');
      const weightResult = await informationService.getAttribute('weight');
      const ageResult = await informationService.getAttribute('age');
      const overResult = await planService.getOverPlans();
      const workoutResult = await planService.getWorkoutPlans();

      // 验证数据获取是否成功
      if (heightResult.code !== 200 || weightResult.code !== 200 || ageResult.code !== 200) {
        throw new Error('Failed to fetch user information');
      }

      // 获取并处理数据
      const height = heightResult.data?.height || 170;
      const weight = weightResult.data?.weight || 60;
      const age = ageResult.data?.age || 25;
      const over = overResult.data?.recent_plans_count || 0;
      const workoutCount = workoutResult.data?.recent_plans_count || [0, 0, 0, 0, 0, 0, 0];

      // 计算健康指标
      const bmi = this.calculateBMI(height, weight);
      const bmiStatus = this.getBMIStatus(bmi);
      const workoutAnalysis = this.getWorkoutAnalysis(over);
      const healthSuggestion = this.getHealthSuggestion(bmi, over);

      // 组装基本信息
      const basicInfo: BasicInfo = {
        height,
        weight,
        age,
        over
      };

      // 组装健康分析
      const analysis: HealthAnalysis = {
        bmi,
        bmiStatus,
        workoutAnalysis,
        healthSuggestion
      };

      // 组装图表数据
      const charts: HealthCharts = {
        workoutCount
      };

      // 返回完整的健康报告
      return {
        basicInfo,
        analysis,
        charts
      };
    } catch (error) {
      // 错误处理
      if (error instanceof Error) {
        throw new Error(`Failed to generate health report: ${error.message}`);
      }
      throw new Error('Failed to generate health report');
    }
  }
} 
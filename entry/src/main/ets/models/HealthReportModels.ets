// ===== 健康报告数据模型定义 =====

/**
 * 用户基本信息接口
 * 包含用户的基本身体数据和运动数据
 */
export interface BasicInfo {
  height: number;    // 身高（厘米）
  weight: number;    // 体重（千克）
  age: number;       // 年龄（岁）
  over: number;      // 已完成运动次数
}

/**
 * 健康分析接口
 * 包含BMI相关数据和健康建议
 */
export interface HealthAnalysis {
  bmi: number;                   // BMI指数
  bmiStatus: string;             // BMI状态（偏瘦/正常/超重/肥胖）
  workoutAnalysis: string;       // 运动情况分析
  healthSuggestion: string;      // 健康建议
}

/**
 * 健康图表数据接口
 * 用于展示运动趋势等图表数据
 */
export interface HealthCharts {
  workoutCount: number[];        // 一周运动次数统计数组
}

/**
 * 完整健康报告接口
 * 整合所有健康报告相关的数据
 */
export interface HealthReport {
  basicInfo: BasicInfo;          // 基本信息
  analysis: HealthAnalysis;      // 健康分析
  charts: HealthCharts;          // 图表数据
} 
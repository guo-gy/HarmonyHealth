export interface BasicInfo {
  height: number;
  weight: number;
  age: number;
  workoutCount: number;
}

export interface HealthAnalysis {
  bmi: number;
  bmiStatus: string;
  workoutAnalysis: string;
  healthSuggestion: string;
}

export interface WorkoutTrend {
  date: string;
  count: number;
}

export interface HealthPlan {
  type: string;
  current: number;
  target: number;
  period: string;
  progress: number;
}

export interface HealthCharts {
  workoutTrend: WorkoutTrend[];
  plans: HealthPlan[];
}

export interface HealthReport {
  basicInfo: BasicInfo;
  analysis: HealthAnalysis;
  charts: HealthCharts;
} 
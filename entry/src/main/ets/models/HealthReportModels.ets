export interface BasicInfo {
  height: number;
  weight: number;
  age: number;
  over: number;
}

export interface HealthAnalysis {
  bmi: number;
  bmiStatus: string;
  workoutAnalysis: string;
  healthSuggestion: string;
}

export interface HealthCharts {
  workoutCount: number[];
}

export interface HealthReport {
  basicInfo: BasicInfo;
  analysis: HealthAnalysis;
  charts: HealthCharts;
} 
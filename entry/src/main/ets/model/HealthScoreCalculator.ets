import { HealthData } from '../common/HealthData';
import { WorkoutRecord } from '../common/WorkoutRecord';
import { DietRecord } from '../common/DietRecord';
import { SleepRecord } from '../common/SleepRecord';

/**
 * 健康信用分计算器
 * 健康信用分 = 完成率×0.6 + 历史一致性×0.3 - 疲劳指数×0.1
 */
export class HealthScoreCalculator {
  // 最低分数
  private static readonly MIN_SCORE: number = 0;
  // 最高分数
  private static readonly MAX_SCORE: number = 100;
  // 运动完成率权重
  private static readonly COMPLETION_RATE_WEIGHT: number = 0.6;
  // 历史一致性权重
  private static readonly CONSISTENCY_WEIGHT: number = 0.3;
  // 疲劳指数权重
  private static readonly FATIGUE_WEIGHT: number = 0.1;
  // 计算周期（天）
  private static readonly CALCULATION_PERIOD: number = 30;

  /**
   * 计算健康信用分
   * @param workoutRecords 运动记录数组
   * @param dietRecords 饮食记录数组
   * @param sleepRecords 睡眠记录数组
   * @returns 健康信用分 (0-100)
   */
  public static calculateHealthScore(
    workoutRecords: WorkoutRecord[],
    dietRecords: DietRecord[],
    sleepRecords: SleepRecord[]
  ): number {
    // 1. 计算运动计划完成率 (0-1)
    const completionRate = this.calculateCompletionRate(workoutRecords);
    
    // 2. 计算历史一致性 (0-1)
    const consistency = this.calculateConsistency(workoutRecords, dietRecords, sleepRecords);
    
    // 3. 计算疲劳指数 (0-1)
    const fatigueIndex = this.calculateFatigueIndex(workoutRecords, sleepRecords);
    
    // 4. 计算健康信用分
    let healthScore = 
      completionRate * this.COMPLETION_RATE_WEIGHT +
      consistency * this.CONSISTENCY_WEIGHT -
      fatigueIndex * this.FATIGUE_WEIGHT;
    
    // 将分数转换为0-100范围
    healthScore = healthScore * 100;
    
    // 确保分数在合理范围内
    return Math.max(this.MIN_SCORE, Math.min(this.MAX_SCORE, healthScore));
  }

  /**
   * 计算运动计划完成率
   * @param workoutRecords 运动记录数组
   * @returns 完成率 (0-1)
   */
  private static calculateCompletionRate(workoutRecords: WorkoutRecord[]): number {
    if (!workoutRecords || workoutRecords.length === 0) {
      return 0;
    }
    
    // 获取计算周期内的记录
    const recentRecords = this.getRecentRecords(workoutRecords);
    if (recentRecords.length === 0) {
      return 0;
    }
    
    // 计算完成的任务数和总任务数
    let completedTasks = 0;
    let totalTasks = 0;
    
    recentRecords.forEach(record => {
      // 每个运动记录可能包含多个计划任务
      if (record.plannedTasks && record.completedTasks) {
        totalTasks += record.plannedTasks.length;
        completedTasks += record.completedTasks.length;
      }
    });
    
    // 避免除以零
    if (totalTasks === 0) {
      return 0;
    }
    
    return completedTasks / totalTasks;
  }

  /**
   * 计算历史一致性
   * 评估用户在饮食、运动和睡眠方面的规律性
   * @param workoutRecords 运动记录数组
   * @param dietRecords 饮食记录数组
   * @param sleepRecords 睡眠记录数组
   * @returns 一致性指数 (0-1)
   */
  private static calculateConsistency(
    workoutRecords: WorkoutRecord[],
    dietRecords: DietRecord[],
    sleepRecords: SleepRecord[]
  ): number {
    // 1. 计算运动一致性 (0-1)
    const workoutConsistency = this.calculateWorkoutConsistency(workoutRecords);
    
    // 2. 计算饮食一致性 (0-1)
    const dietConsistency = this.calculateDietConsistency(dietRecords);
    
    // 3. 计算睡眠一致性 (0-1)
    const sleepConsistency = this.calculateSleepConsistency(sleepRecords);
    
    // 综合计算一致性，三项指标权重相等
    return (workoutConsistency + dietConsistency + sleepConsistency) / 3;
  }

  /**
   * 计算运动一致性
   * @param workoutRecords 运动记录数组
   * @returns 运动一致性 (0-1)
   */
  private static calculateWorkoutConsistency(workoutRecords: WorkoutRecord[]): number {
    if (!workoutRecords || workoutRecords.length === 0) {
      return 0;
    }
    
    // 获取计算周期内的记录
    const recentRecords = this.getRecentRecords(workoutRecords);
    if (recentRecords.length < 3) { // 至少需要3条记录才能计算一致性
      return 0;
    }
    
    // 计算每周运动次数的标准差
    const weeklyWorkouts = this.groupRecordsByWeek(recentRecords);
    const workoutCountsPerWeek = weeklyWorkouts.map(week => week.length);
    
    // 计算标准差的归一化值（越低越一致）
    const stdDev = this.calculateStandardDeviation(workoutCountsPerWeek);
    const normalizedStdDev = Math.min(stdDev / 3, 1); // 归一化，标准差超过3视为完全不一致
    
    // 一致性 = 1 - 归一化标准差
    return 1 - normalizedStdDev;
  }

  /**
   * 计算饮食一致性
   * @param dietRecords 饮食记录数组
   * @returns 饮食一致性 (0-1)
   */
  private static calculateDietConsistency(dietRecords: DietRecord[]): number {
    if (!dietRecords || dietRecords.length === 0) {
      return 0;
    }
    
    // 获取计算周期内的记录
    const recentRecords = this.getRecentRecords(dietRecords);
    if (recentRecords.length < 3) {
      return 0;
    }
    
    // 计算每日卡路里摄入的标准差
    const dailyCalories = recentRecords.map(record => record.totalCalories || 0);
    const stdDev = this.calculateStandardDeviation(dailyCalories);
    
    // 计算平均卡路里摄入
    const avgCalories = this.calculateAverage(dailyCalories);
    if (avgCalories === 0) {
      return 0;
    }
    
    // 计算变异系数（标准差/平均值）
    const cv = stdDev / avgCalories;
    
    // 归一化变异系数（变异系数越低越一致）
    const normalizedCV = Math.min(cv / 0.3, 1); // 变异系数超过0.3视为完全不一致
    
    // 一致性 = 1 - 归一化变异系数
    return 1 - normalizedCV;
  }

  /**
   * 计算睡眠一致性
   * @param sleepRecords 睡眠记录数组
   * @returns 睡眠一致性 (0-1)
   */
  private static calculateSleepConsistency(sleepRecords: SleepRecord[]): number {
    if (!sleepRecords || sleepRecords.length === 0) {
      return 0;
    }
    
    // 获取计算周期内的记录
    const recentRecords = this.getRecentRecords(sleepRecords);
    if (recentRecords.length < 3) {
      return 0;
    }
    
    // 1. 睡眠时长一致性
    const sleepDurations = recentRecords.map(record => record.duration || 0);
    const durationStdDev = this.calculateStandardDeviation(sleepDurations);
    const avgDuration = this.calculateAverage(sleepDurations);
    if (avgDuration === 0) {
      return 0;
    }
    const durationCV = durationStdDev / avgDuration;
    const normalizedDurationCV = Math.min(durationCV / 0.2, 1);
    const durationConsistency = 1 - normalizedDurationCV;
    
    // 2. 睡眠时间一致性
    const sleepStartTimes = recentRecords.map(record => {
      const date = new Date(record.startTime);
      // 转换为分钟表示（从午夜开始）
      return date.getHours() * 60 + date.getMinutes();
    });
    
    // 处理跨午夜的情况（例如23:30和00:30应该被视为接近而不是相距23小时）
    const adjustedSleepTimes = this.adjustTimeForCircularData(sleepStartTimes);
    const timeStdDev = this.calculateStandardDeviation(adjustedSleepTimes);
    const normalizedTimeStdDev = Math.min(timeStdDev / 90, 1); // 标准差超过90分钟视为完全不一致
    const timeConsistency = 1 - normalizedTimeStdDev;
    
    // 综合睡眠时长和睡眠时间的一致性
    return (durationConsistency * 0.5) + (timeConsistency * 0.5);
  }

  /**
   * 计算疲劳指数
   * @param workoutRecords 运动记录数组
   * @param sleepRecords 睡眠记录数组
   * @returns 疲劳指数 (0-1)
   */
  private static calculateFatigueIndex(
    workoutRecords: WorkoutRecord[],
    sleepRecords: SleepRecord[]
  ): number {
    if (!workoutRecords || workoutRecords.length === 0 || !sleepRecords || sleepRecords.length === 0) {
      return 0;
    }
    
    // 获取最近7天的记录
    const recentWorkouts = this.getRecentRecordsByDays(workoutRecords, 7);
    const recentSleep = this.getRecentRecordsByDays(sleepRecords, 7);
    
    if (recentWorkouts.length === 0 || recentSleep.length === 0) {
      return 0;
    }
    
    // 1. 计算运动强度累积值
    let totalIntensity = 0;
    recentWorkouts.forEach(workout => {
      totalIntensity += workout.intensity || 0;
    });
    
    // 归一化运动强度（假设最大累积强度为35，相当于每天高强度运动）
    const normalizedIntensity = Math.min(totalIntensity / 35, 1);
    
    // 2. 计算睡眠质量和时长
    let totalSleepQuality = 0;
    let totalSleepDuration = 0;
    
    recentSleep.forEach(sleep => {
      totalSleepQuality += sleep.quality || 0;
      totalSleepDuration += sleep.duration || 0;
    });
    
    // 计算平均睡眠质量（0-1）
    const avgSleepQuality = recentSleep.length > 0 ? totalSleepQuality / recentSleep.length : 0;
    
    // 计算平均睡眠时长（小时）
    const avgSleepDuration = recentSleep.length > 0 ? totalSleepDuration / recentSleep.length : 0;
    
    // 计算睡眠充足度（8小时为理想值）
    const sleepSufficiency = Math.min(avgSleepDuration / 8, 1);
    
    // 综合睡眠指标（质量和充足度）
    const sleepIndex = (avgSleepQuality * 0.5) + (sleepSufficiency * 0.5);
    
    // 3. 计算疲劳指数
    // 疲劳指数 = 运动强度 * (1 - 睡眠指标)
    return normalizedIntensity * (1 - sleepIndex);
  }

  /**
   * 获取计算周期内的记录
   * @param records 记录数组
   * @returns 计算周期内的记录数组
   */
  private static getRecentRecords<T extends { timestamp: string }>(records: T[]): T[] {
    const now = new Date();
    const startDate = new Date();
    startDate.setDate(now.getDate() - this.CALCULATION_PERIOD);
    
    return records.filter(record => {
      const recordDate = new Date(record.timestamp);
      return recordDate >= startDate && recordDate <= now;
    });
  }

  /**
   * 获取指定天数内的记录
   * @param records 记录数组
   * @param days 天数
   * @returns 指定天数内的记录数组
   */
  private static getRecentRecordsByDays<T extends { timestamp: string }>(records: T[], days: number): T[] {
    const now = new Date();
    const startDate = new Date();
    startDate.setDate(now.getDate() - days);
    
    return records.filter(record => {
      const recordDate = new Date(record.timestamp);
      return recordDate >= startDate && recordDate <= now;
    });
  }

  /**
   * 将记录按周分组
   * @param records 记录数组
   * @returns 按周分组的记录数组
   */
  private static groupRecordsByWeek<T extends { timestamp: string }>(records: T[]): T[][] {
    // 按周分组记录
    const weeklyRecords: Map<number, T[]> = new Map();
    
    records.forEach(record => {
      const recordDate = new Date(record.timestamp);
      // 计算周序号（从年初开始的周数）
      const weekNumber = this.getWeekNumber(recordDate);
      
      if (!weeklyRecords.has(weekNumber)) {
        weeklyRecords.set(weekNumber, []);
      }
      
      weeklyRecords.get(weekNumber)?.push(record);
    });
    
    // 转换为数组形式
    return Array.from(weeklyRecords.values());
  }

  /**
   * 获取日期所在的周序号
   * @param date 日期
   * @returns 周序号
   */
  private static getWeekNumber(date: Date): number {
    const firstDayOfYear = new Date(date.getFullYear(), 0, 1);
    const pastDaysOfYear = (date.getTime() - firstDayOfYear.getTime()) / 86400000;
    return Math.ceil((pastDaysOfYear + firstDayOfYear.getDay() + 1) / 7);
  }

  /**
   * 计算数组的标准差
   * @param values 数值数组
   * @returns 标准差
   */
  private static calculateStandardDeviation(values: number[]): number {
    if (!values || values.length === 0) {
      return 0;
    }
    
    const avg = this.calculateAverage(values);
    const squareDiffs = values.map(value => {
      const diff = value - avg;
      return diff * diff;
    });
    
    const avgSquareDiff = this.calculateAverage(squareDiffs);
    return Math.sqrt(avgSquareDiff);
  }

  /**
   * 计算数组的平均值
   * @param values 数值数组
   * @returns 平均值
   */
  private static calculateAverage(values: number[]): number {
    if (!values || values.length === 0) {
      return 0;
    }
    
    const sum = values.reduce((a, b) => a + b, 0);
    return sum / values.length;
  }

  /**
   * 调整时间数据以处理循环特性
   * 例如，23:00和01:00应该被视为相距2小时而不是22小时
   * @param timeValues 时间值数组（以分钟表示）
   * @returns 调整后的时间数组
   */
  private static adjustTimeForCircularData(timeValues: number[]): number[] {
    if (!timeValues || timeValues.length === 0) {
      return [];
    }
    
    // 计算平均时间
    let sumSin = 0;
    let sumCos = 0;
    
    timeValues.forEach(time => {
      // 将时间转换为角度（0-1440分钟映射到0-360度）
      const angle = (time / 1440) * 2 * Math.PI;
      sumSin += Math.sin(angle);
      sumCos += Math.cos(angle);
    });
    
    // 计算平均角度
    const avgAngle = Math.atan2(sumSin / timeValues.length, sumCos / timeValues.length);
    
    // 将平均角度转换回分钟
    const avgTime = ((avgAngle / (2 * Math.PI)) * 1440 + 1440) % 1440;
    
    // 调整数据，使其围绕平均值
    return timeValues.map(time => {
      if (Math.abs(time - avgTime) > 720) {
        // 跨越了午夜，需要调整
        return time < avgTime ? time + 1440 : time - 1440;
      }
      return time;
    });
  }
} 
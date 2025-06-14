import { WorkoutRecord } from '../models/WorkoutModels';
import { DatabaseService } from './DatabaseService';

export class WorkoutService {
  private static instance: WorkoutService;
  private dbService: DatabaseService;

  private constructor() {
    this.dbService = DatabaseService.getInstance();
  }

  public static getInstance(): WorkoutService {
    if (!WorkoutService.instance) {
      WorkoutService.instance = new WorkoutService();
    }
    return WorkoutService.instance;
  }

  // 获取用户最近7天的运动记录
  public async getRecentWorkouts(userId: string): Promise<WorkoutRecord[]> {
    try {
      const result = await this.dbService.query(
        `SELECT * FROM workout_records 
         WHERE user_id = ? 
         AND date >= date('now', '-7 days')
         ORDER BY date DESC`,
        [userId]
      );
      
      return result || [];
    } catch (error) {
      console.error('Failed to get recent workouts:', error);
      throw error;
    }
  }

  // 获取用户运动统计
  public async getWorkoutStats(userId: string): Promise<{
    totalWorkouts: number;
    weeklyAverage: number;
    lastWorkoutDate: string;
  }> {
    try {
      const result = await this.dbService.query(
        `SELECT 
          COUNT(*) as total_workouts,
          ROUND(AVG(daily_count), 1) as weekly_average,
          MAX(date) as last_workout_date
         FROM (
           SELECT date, COUNT(*) as daily_count
           FROM workout_records
           WHERE user_id = ?
           AND date >= date('now', '-7 days')
           GROUP BY date
         )`,
        [userId]
      );
      
      if (result && result.length > 0) {
        return {
          totalWorkouts: result[0].total_workouts,
          weeklyAverage: result[0].weekly_average,
          lastWorkoutDate: result[0].last_workout_date
        };
      }
      
      return {
        totalWorkouts: 0,
        weeklyAverage: 0,
        lastWorkoutDate: ''
      };
    } catch (error) {
      console.error('Failed to get workout stats:', error);
      throw error;
    }
  }

  // 添加运动记录
  public async addWorkoutRecord(record: WorkoutRecord): Promise<void> {
    try {
      await this.dbService.execute(
        `INSERT INTO workout_records 
         (user_id, type, duration, calories, date, notes)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          record.userId,
          record.type,
          record.duration,
          record.calories,
          record.date,
          record.notes
        ]
      );
    } catch (error) {
      console.error('Failed to add workout record:', error);
      throw error;
    }
  }
} 
import { UserInfo } from '../models/UserModels';
import { DatabaseService } from './DatabaseService';

export class InformationService {
  private static instance: InformationService;
  private dbService: DatabaseService;

  private constructor() {
    this.dbService = DatabaseService.getInstance();
  }

  public static getInstance(): InformationService {
    if (!InformationService.instance) {
      InformationService.instance = new InformationService();
    }
    return InformationService.instance;
  }

  // 获取用户基本信息
  public async getUserInfo(userId: string): Promise<UserInfo> {
    try {
      const result = await this.dbService.query(
        'SELECT * FROM user_info WHERE user_id = ?',
        [userId]
      );
      
      if (result && result.length > 0) {
        return result[0];
      }
      
      throw new Error('User information not found');
    } catch (error) {
      console.error('Failed to get user information:', error);
      throw error;
    }
  }

  // 更新用户基本信息
  public async updateUserInfo(userId: string, info: Partial<UserInfo>): Promise<void> {
    try {
      const fields = Object.keys(info);
      const values = Object.values(info);
      
      const setClause = fields.map(field => `${field} = ?`).join(', ');
      const query = `UPDATE user_info SET ${setClause} WHERE user_id = ?`;
      
      await this.dbService.execute(query, [...values, userId]);
    } catch (error) {
      console.error('Failed to update user information:', error);
      throw error;
    }
  }

  // 获取特定属性
  public async getAttribute(userId: string, attribute: string): Promise<any> {
    try {
      const result = await this.dbService.query(
        `SELECT ${attribute} FROM user_info WHERE user_id = ?`,
        [userId]
      );
      
      if (result && result.length > 0) {
        return result[0][attribute];
      }
      
      return null;
    } catch (error) {
      console.error(`Failed to get ${attribute}:`, error);
      throw error;
    }
  }
} 
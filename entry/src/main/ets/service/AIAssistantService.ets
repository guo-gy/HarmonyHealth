import http from '@ohos.net.http';
import { HealthData } from '../common/HealthData';
import { WorkoutRecord } from '../common/WorkoutRecord';
import { DietRecord } from '../common/DietRecord';
import { SleepRecord } from '../common/SleepRecord';
import { UserProfile } from '../common/UserProfile';

/**
 * DeepSeek API接口服务
 * 负责与DeepSeek API通信，生成健康和运动建议
 */
export class AIAssistantService {
  // DeepSeek API密钥
  private static readonly API_KEY: string = 'YOUR_DEEPSEEK_API_KEY';
  // DeepSeek API端点
  private static readonly API_ENDPOINT: string = 'https://api.deepseek.com/v1/chat/completions';
  // 请求超时时间（毫秒）
  private static readonly REQUEST_TIMEOUT: number = 20000;
  // 模型名称
  private static readonly MODEL_NAME: string = 'deepseek-chat';
  // 最大重试次数
  private static readonly MAX_RETRIES: number = 3;

  /**
   * 生成个性化运动计划
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param workoutHistory 运动历史记录
   * @param dietHistory 饮食历史记录
   * @returns 生成的运动计划
   */
  public static async generateWorkoutPlan(
    userProfile: UserProfile,
    healthData: HealthData,
    workoutHistory: WorkoutRecord[],
    dietHistory: DietRecord[]
  ): Promise<string> {
    try {
      // 构建请求体
      const requestBody = this.buildWorkoutPlanRequestBody(userProfile, healthData, workoutHistory, dietHistory);
      
      // 发送请求
      const response = await this.sendRequest(requestBody);
      
      // 解析响应
      if (response && response.choices && response.choices.length > 0) {
        return response.choices[0].message.content;
      } else {
        throw new Error('无法解析AI响应');
      }
    } catch (error) {
      console.error('生成运动计划失败:', error);
      return '无法生成运动计划，请稍后再试。';
    }
  }

  /**
   * 生成饮食建议
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param dietHistory 饮食历史记录
   * @returns 生成的饮食建议
   */
  public static async generateDietSuggestions(
    userProfile: UserProfile,
    healthData: HealthData,
    dietHistory: DietRecord[]
  ): Promise<string> {
    try {
      // 构建请求体
      const requestBody = this.buildDietSuggestionsRequestBody(userProfile, healthData, dietHistory);
      
      // 发送请求
      const response = await this.sendRequest(requestBody);
      
      // 解析响应
      if (response && response.choices && response.choices.length > 0) {
        return response.choices[0].message.content;
      } else {
        throw new Error('无法解析AI响应');
      }
    } catch (error) {
      console.error('生成饮食建议失败:', error);
      return '无法生成饮食建议，请稍后再试。';
    }
  }

  /**
   * 分析健康数据关联性
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param workoutHistory 运动历史记录
   * @param dietHistory 饮食历史记录
   * @param sleepHistory 睡眠历史记录
   * @returns 健康数据分析结果
   */
  public static async analyzeHealthCorrelations(
    userProfile: UserProfile,
    healthData: HealthData,
    workoutHistory: WorkoutRecord[],
    dietHistory: DietRecord[],
    sleepHistory: SleepRecord[]
  ): Promise<string> {
    try {
      // 构建请求体
      const requestBody = this.buildHealthCorrelationsRequestBody(
        userProfile, healthData, workoutHistory, dietHistory, sleepHistory
      );
      
      // 发送请求
      const response = await this.sendRequest(requestBody);
      
      // 解析响应
      if (response && response.choices && response.choices.length > 0) {
        return response.choices[0].message.content;
      } else {
        throw new Error('无法解析AI响应');
      }
    } catch (error) {
      console.error('分析健康数据关联性失败:', error);
      return '无法分析健康数据关联性，请稍后再试。';
    }
  }

  /**
   * 处理语音输入
   * @param voiceText 语音识别文本
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @returns AI助手响应
   */
  public static async processVoiceInput(
    voiceText: string,
    userProfile: UserProfile,
    healthData: HealthData
  ): Promise<string> {
    try {
      // 构建请求体
      const requestBody = this.buildVoiceInputRequestBody(voiceText, userProfile, healthData);
      
      // 发送请求
      const response = await this.sendRequest(requestBody);
      
      // 解析响应
      if (response && response.choices && response.choices.length > 0) {
        return response.choices[0].message.content;
      } else {
        throw new Error('无法解析AI响应');
      }
    } catch (error) {
      console.error('处理语音输入失败:', error);
      return '无法处理您的问题，请稍后再试。';
    }
  }

  /**
   * 构建运动计划请求体
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param workoutHistory 运动历史记录
   * @param dietHistory 饮食历史记录
   * @returns 请求体对象
   */
  private static buildWorkoutPlanRequestBody(
    userProfile: UserProfile,
    healthData: HealthData,
    workoutHistory: WorkoutRecord[],
    dietHistory: DietRecord[]
  ): object {
    // 获取最近的运动记录
    const recentWorkouts = workoutHistory
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 5);
    
    // 格式化运动记录
    const formattedWorkoutHistory = recentWorkouts.map(workout => ({
      date: new Date(workout.timestamp).toISOString().split('T')[0],
      type: workout.type,
      duration: workout.duration,
      intensity: workout.intensity,
      caloriesBurned: workout.caloriesBurned
    }));
    
    // 构建系统提示信息
    const systemPrompt = `
      你是一位专业的健身教练和健康顾问，精通根据用户的健康数据、体型特征和运动偏好制定个性化的运动计划。
      请根据以下用户信息和健康数据，制定一个为期7天的个性化运动计划。
      计划应该考虑用户的目标、健康状况、以往运动习惯和饮食情况。
      请确保计划中的运动强度适中，循序渐进，避免运动损伤。
      计划必须包含每天具体的运动项目、时长、强度以及预期消耗的卡路里。
      对于每个运动项目，提供详细的动作描述和注意事项。
      回复格式请使用清晰的日期分段，每个运动项目单独列出，并添加表情符号增强可读性。
    `;
    
    // 构建用户提示信息
    const userPrompt = `
      请为我制定一个个性化的7天运动计划，以下是我的信息：
      
      个人资料：
      - 年龄：${userProfile.age}岁
      - 性别：${userProfile.gender}
      - 身高：${userProfile.height}厘米
      - 体重：${userProfile.weight}公斤
      - BMI：${(userProfile.weight / Math.pow(userProfile.height / 100, 2)).toFixed(1)}
      - 运动目标：${userProfile.fitnessGoal}
      - 运动偏好：${userProfile.exercisePreference}
      - 每周可运动时间：${userProfile.availableTimePerWeek}小时
      - 健康状况：${userProfile.healthConditions || '无特殊健康问题'}
      
      当前健康数据：
      - 静息心率：${healthData.restingHeartRate}次/分钟
      - 平均步数：${healthData.averageSteps}步/天
      - 每日活动量：${healthData.dailyActivityLevel}
      - 睡眠质量：${healthData.sleepQuality}
      
      最近的运动记录：
      ${JSON.stringify(formattedWorkoutHistory, null, 2)}
      
      要求：
      1. 根据我的健康数据和目标，制定科学有效的运动计划
      2. 计划需要有合理的休息日安排
      3. 每天的运动时间控制在${Math.round(userProfile.availableTimePerWeek / 7)}小时左右
      4. 考虑我的运动偏好，但也可以适当增加其他类型的运动
      5. 提供具体的运动时长、组数、重量建议等详细信息
    `;
    
    // 构建完整请求体
    return {
      model: this.MODEL_NAME,
      messages: [
        {
          role: "system",
          content: systemPrompt
        },
        {
          role: "user",
          content: userPrompt
        }
      ],
      temperature: 0.7,
      max_tokens: 2000
    };
  }

  /**
   * 构建饮食建议请求体
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param dietHistory 饮食历史记录
   * @returns 请求体对象
   */
  private static buildDietSuggestionsRequestBody(
    userProfile: UserProfile,
    healthData: HealthData,
    dietHistory: DietRecord[]
  ): object {
    // 获取最近的饮食记录
    const recentDiet = dietHistory
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 5);
    
    // 格式化饮食记录
    const formattedDietHistory = recentDiet.map(diet => ({
      date: new Date(diet.timestamp).toISOString().split('T')[0],
      meals: diet.meals,
      totalCalories: diet.totalCalories,
      macronutrients: diet.macronutrients
    }));
    
    // 构建系统提示信息
    const systemPrompt = `
      你是一位专业的营养师和健康饮食顾问，精通根据用户的健康数据、体型特征和饮食偏好制定个性化的饮食建议。
      请根据以下用户信息和健康数据，提供个性化的饮食建议和一周的膳食计划。
      建议应该考虑用户的目标、健康状况、饮食偏好和过往的饮食习惯。
      请确保饮食计划营养均衡，符合用户的卡路里需求，并且考虑用户的饮食限制或过敏原。
      计划必须包含每日三餐的具体食物建议、分量以及大致的卡路里含量。
      对于推荐的食物，提供简单的制备方法和营养价值说明。
      回复格式请使用清晰的日期分段，每餐单独列出，并添加表情符号增强可读性。
    `;
    
    // 构建用户提示信息
    const userPrompt = `
      请为我提供个性化的饮食建议和一周的膳食计划，以下是我的信息：
      
      个人资料：
      - 年龄：${userProfile.age}岁
      - 性别：${userProfile.gender}
      - 身高：${userProfile.height}厘米
      - 体重：${userProfile.weight}公斤
      - BMI：${(userProfile.weight / Math.pow(userProfile.height / 100, 2)).toFixed(1)}
      - 饮食目标：${userProfile.dietGoal}
      - 饮食偏好：${userProfile.dietPreference}
      - 饮食限制/过敏原：${userProfile.dietaryRestrictions || '无特殊限制'}
      - 健康状况：${userProfile.healthConditions || '无特殊健康问题'}
      
      当前健康数据：
      - 基础代谢率：${healthData.basalMetabolicRate}卡路里/天
      - 每日活动量：${healthData.dailyActivityLevel}
      - 每日消耗卡路里：${healthData.dailyCaloriesBurned}卡路里
      
      最近的饮食记录：
      ${JSON.stringify(formattedDietHistory, null, 2)}
      
      要求：
      1. 根据我的健康数据和目标，制定科学有效的饮食计划
      2. 计划需要营养均衡，满足我的卡路里需求
      3. 考虑我的饮食偏好和限制
      4. 提供具体的食物建议、分量和制备方法
      5. 建议一些可以替代的食物选项，增加饮食多样性
    `;
    
    // 构建完整请求体
    return {
      model: this.MODEL_NAME,
      messages: [
        {
          role: "system",
          content: systemPrompt
        },
        {
          role: "user",
          content: userPrompt
        }
      ],
      temperature: 0.7,
      max_tokens: 2000
    };
  }

  /**
   * 构建健康数据关联性分析请求体
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @param workoutHistory 运动历史记录
   * @param dietHistory 饮食历史记录
   * @param sleepHistory 睡眠历史记录
   * @returns 请求体对象
   */
  private static buildHealthCorrelationsRequestBody(
    userProfile: UserProfile,
    healthData: HealthData,
    workoutHistory: WorkoutRecord[],
    dietHistory: DietRecord[],
    sleepHistory: SleepRecord[]
  ): object {
    // 获取最近的记录
    const recentWorkouts = workoutHistory
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 10);
    
    const recentDiet = dietHistory
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 10);
    
    const recentSleep = sleepHistory
      .sort((a, b) => new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime())
      .slice(0, 10);
    
    // 构建系统提示信息
    const systemPrompt = `
      你是一位专业的健康数据分析师，精通分析用户的健康数据之间的相关性，并提供科学的健康建议。
      请根据以下用户的运动记录、饮食记录和睡眠记录，分析这三者之间的相关性和影响关系。
      特别关注：
      1. 饮食习惯如何影响运动表现和恢复
      2. 运动对睡眠质量的影响
      3. 睡眠质量对次日运动表现和饮食习惯的影响
      4. 饮食模式对睡眠质量的影响
      
      请基于数据分析提供具体的、可操作的建议，帮助用户优化健康习惯。
      分析应该科学、客观，避免过度解读数据。
      回复格式请使用清晰的分段，突出关键发现和建议，并提供具体的改进措施。
    `;
    
    // 构建用户提示信息
    const userPrompt = `
      请分析我的健康数据之间的相关性，并提供改进建议，以下是我的信息：
      
      个人资料：
      - 年龄：${userProfile.age}岁
      - 性别：${userProfile.gender}
      - 身高：${userProfile.height}厘米
      - 体重：${userProfile.weight}公斤
      - 健康目标：${userProfile.healthGoal}
      - 健康状况：${userProfile.healthConditions || '无特殊健康问题'}
      
      最近的运动记录：
      ${JSON.stringify(recentWorkouts.map(workout => ({
        date: new Date(workout.timestamp).toISOString().split('T')[0],
        type: workout.type,
        duration: workout.duration,
        intensity: workout.intensity,
        caloriesBurned: workout.caloriesBurned,
        performanceRating: workout.performanceRating
      })), null, 2)}
      
      最近的饮食记录：
      ${JSON.stringify(recentDiet.map(diet => ({
        date: new Date(diet.timestamp).toISOString().split('T')[0],
        totalCalories: diet.totalCalories,
        macronutrients: diet.macronutrients,
        waterIntake: diet.waterIntake,
        saltIntake: diet.saltIntake,
        sugarIntake: diet.sugarIntake
      })), null, 2)}
      
      最近的睡眠记录：
      ${JSON.stringify(recentSleep.map(sleep => ({
        date: new Date(sleep.timestamp).toISOString().split('T')[0],
        duration: sleep.duration,
        quality: sleep.quality,
        deepSleepPercentage: sleep.deepSleepPercentage,
        remSleepPercentage: sleep.remSleepPercentage,
        wakeCount: sleep.wakeCount
      })), null, 2)}
      
      要求：
      1. 分析数据之间的相关性和影响关系
      2. 特别关注饮食-运动-睡眠之间的互相影响
      3. 找出我健康习惯中的优点和需要改进的地方
      4. 提供具体的、可操作的建议
      5. 如发现明显的健康风险模式，请特别指出
    `;
    
    // 构建完整请求体
    return {
      model: this.MODEL_NAME,
      messages: [
        {
          role: "system",
          content: systemPrompt
        },
        {
          role: "user",
          content: userPrompt
        }
      ],
      temperature: 0.5,
      max_tokens: 2500
    };
  }

  /**
   * 构建语音输入请求体
   * @param voiceText 语音识别文本
   * @param userProfile 用户资料
   * @param healthData 健康数据
   * @returns 请求体对象
   */
  private static buildVoiceInputRequestBody(
    voiceText: string,
    userProfile: UserProfile,
    healthData: HealthData
  ): object {
    // 构建系统提示信息
    const systemPrompt = `
      你是一位专业的健康和健身助手，可以回答用户关于健康、运动、饮食和生活方式的问题。
      请根据用户的问题提供准确、科学、有帮助的回答。
      如果用户询问的是关于健康建议的问题，请基于提供的用户信息和健康数据来个性化你的回答。
      如果用户询问的是关于特定运动或饮食的问题，请提供科学的建议和具体的指导。
      如果用户想要了解健康知识，请提供简洁但全面的解释。
      回答应该友好、鼓励性，但要避免过度承诺健康效果。
      当用户的问题超出你的能力范围或需要医疗专业知识时，请建议用户咨询医疗专业人士。
    `;
    
    // 构建用户上下文信息
    const userContext = `
      以下是我的基本信息和健康数据，请在回答中参考这些信息：
      
      个人资料：
      - 年龄：${userProfile.age}岁
      - 性别：${userProfile.gender}
      - 身高：${userProfile.height}厘米
      - 体重：${userProfile.weight}公斤
      - BMI：${(userProfile.weight / Math.pow(userProfile.height / 100, 2)).toFixed(1)}
      - 健康目标：${userProfile.healthGoal}
      - 运动偏好：${userProfile.exercisePreference}
      - 饮食偏好：${userProfile.dietPreference}
      - 健康状况：${userProfile.healthConditions || '无特殊健康问题'}
      
      当前健康数据：
      - 静息心率：${healthData.restingHeartRate}次/分钟
      - 平均步数：${healthData.averageSteps}步/天
      - 每日活动量：${healthData.dailyActivityLevel}
      - 睡眠质量：${healthData.sleepQuality}
      - 基础代谢率：${healthData.basalMetabolicRate}卡路里/天
    `;
    
    // 构建完整的用户提问
    const userPrompt = `${userContext}\n\n我的问题是：${voiceText}`;
    
    // 构建完整请求体
    return {
      model: this.MODEL_NAME,
      messages: [
        {
          role: "system",
          content: systemPrompt
        },
        {
          role: "user",
          content: userPrompt
        }
      ],
      temperature: 0.7,
      max_tokens: 1000
    };
  }

  /**
   * 发送请求到DeepSeek API
   * @param requestBody 请求体
   * @returns API响应
   */
  private static async sendRequest(requestBody: object, retryCount: number = 0): Promise<any> {
    try {
      // 创建HTTP请求对象
      const httpRequest = http.createHttp();
      
      // 发送POST请求
      const response = await httpRequest.request(
        this.API_ENDPOINT,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${this.API_KEY}`
          },
          extraData: JSON.stringify(requestBody),
          readTimeout: this.REQUEST_TIMEOUT,
          connectTimeout: this.REQUEST_TIMEOUT
        }
      );
      
      // 检查响应状态
      if (response.responseCode === 200) {
        // 解析响应体
        return JSON.parse(response.result as string);
      } else {
        // 处理错误响应
        console.error('API请求失败:', response.responseCode, response.result);
        
        // 尝试重试
        if (retryCount < this.MAX_RETRIES) {
          console.info(`重试请求 (${retryCount + 1}/${this.MAX_RETRIES})...`);
          return await this.sendRequest(requestBody, retryCount + 1);
        } else {
          throw new Error(`API请求失败: ${response.responseCode}`);
        }
      }
    } catch (error) {
      console.error('发送请求失败:', error);
      
      // 尝试重试
      if (retryCount < this.MAX_RETRIES) {
        console.info(`重试请求 (${retryCount + 1}/${this.MAX_RETRIES})...`);
        // 指数退避策略
        await new Promise(resolve => setTimeout(resolve, 1000 * Math.pow(2, retryCount)));
        return await this.sendRequest(requestBody, retryCount + 1);
      } else {
        throw error;
      }
    }
  }
} 
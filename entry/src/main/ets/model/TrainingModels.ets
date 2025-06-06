/**
 * 训练相关的数据模型
 */

// 训练课程
export class Course {
  id: string;
  title: string;
  coverImage: Resource;
  duration: number; // 分钟
  calories: number; // 消耗卡路里
  level: 'beginner' | 'intermediate' | 'advanced';
  category: string;
  tags: string[];
  description: string;
  coachName: string;
  coachAvatar?: Resource;
  participantsCount: number;
  rating: number;
  actions: TrainingAction[];

  constructor(id: string, title: string, coverImage: Resource, duration: number, 
              calories: number, level: 'beginner' | 'intermediate' | 'advanced',
              category: string, tags: string[], description: string, 
              coachName: string, coachAvatar: Resource | undefined,
              participantsCount: number, rating: number, actions: TrainingAction[]) {
    this.id = id;
    this.title = title;
    this.coverImage = coverImage;
    this.duration = duration;
    this.calories = calories;
    this.level = level;
    this.category = category;
    this.tags = tags;
    this.description = description;
    this.coachName = coachName;
    this.coachAvatar = coachAvatar;
    this.participantsCount = participantsCount;
    this.rating = rating;
    this.actions = actions;
  }

  // 获取难度文本
  getLevelText(): string {
    switch (this.level) {
      case 'beginner': return '初级';
      case 'intermediate': return '中级';
      case 'advanced': return '高级';
      default: return '初级';
    }
  }
  
  // 获取难度颜色
  getLevelColor(): string {
    switch (this.level) {
      case 'beginner': return '#67C23A';
      case 'intermediate': return '#F5A623';
      case 'advanced': return '#F56C6C';
      default: return '#67C23A';
    }
  }
  
  // 获取格式化时长
  getFormattedDuration(): string {
    if (this.duration < 60) {
      return `${this.duration}分钟`;
    }
    const hours = Math.floor(this.duration / 60);
    const minutes = this.duration % 60;
    return `${hours}小时${minutes > 0 ? ` ${minutes}分钟` : ''}`;
  }
}

// 训练动作
export class TrainingAction {
  id: string;
  name: string;
  image?: Resource; // 动作图片
  video?: Resource; // 动作视频
  duration: number; // 单位:秒 (如果是计时动作)
  count?: number; // 如果是计数动作
  rest?: number; // 休息时间(秒)
  description: string;
  tips: string[]; // 动作要点
  targetMuscle: string[]; // 目标肌肉群
  isRest: boolean; // 是否是休息时间
  
  constructor(id: string, name: string, image: Resource | undefined, video: Resource | undefined,
              duration: number, count: number | undefined, rest: number | undefined,
              description: string, tips: string[], targetMuscle: string[], isRest: boolean = false) {
    this.id = id;
    this.name = name;
    this.image = image;
    this.video = video;
    this.duration = duration;
    this.count = count;
    this.rest = rest;
    this.description = description;
    this.tips = tips;
    this.targetMuscle = targetMuscle;
    this.isRest = isRest;
  }
  
  // 获取动作类型
  getActionType(): 'time' | 'count' {
    return this.count ? 'count' : 'time';
  }
  
  // 获取格式化时长
  getFormattedDuration(): string {
    if (this.getActionType() === 'time') {
      return `${this.duration}秒`;
    } else {
      return `${this.count}次`;
    }
  }
}

// 训练计划
export class TrainingPlan {
  id: string;
  title: string;
  coverImage: Resource;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  duration: number; // 计划总天数
  description: string;
  targetArea: string[]; // 目标区域
  dailyWorkouts: DailyWorkout[];
  
  constructor(id: string, title: string, coverImage: Resource, 
              difficulty: 'beginner' | 'intermediate' | 'advanced', 
              duration: number, description: string, targetArea: string[], 
              dailyWorkouts: DailyWorkout[]) {
    this.id = id;
    this.title = title;
    this.coverImage = coverImage;
    this.difficulty = difficulty;
    this.duration = duration;
    this.description = description;
    this.targetArea = targetArea;
    this.dailyWorkouts = dailyWorkouts;
  }
}

// 每日训练
export class DailyWorkout {
  day: number;
  title: string;
  courses: Course[];
  isRest: boolean;
  completed: boolean;
  
  constructor(day: number, title: string, courses: Course[], isRest: boolean = false, completed: boolean = false) {
    this.day = day;
    this.title = title;
    this.courses = courses;
    this.isRest = isRest;
    this.completed = completed;
  }
  
  // 计算总时长(分钟)
  getTotalDuration(): number {
    if (this.isRest) return 0;
    return this.courses.reduce((total, course) => total + course.duration, 0);
  }
  
  // 计算总卡路里消耗
  getTotalCalories(): number {
    if (this.isRest) return 0;
    return this.courses.reduce((total, course) => total + course.calories, 0);
  }
}

// 用户训练记录
export class TrainingRecord {
  id: string;
  userId: string;
  courseId: string;
  courseName: string;
  date: Date;
  duration: number; // 实际训练时间(秒)
  calories: number; // 实际消耗卡路里
  completed: boolean; // 是否完成
  
  constructor(id: string, userId: string, courseId: string, courseName: string, 
              date: Date, duration: number, calories: number, completed: boolean) {
    this.id = id;
    this.userId = userId;
    this.courseId = courseId;
    this.courseName = courseName;
    this.date = date;
    this.duration = duration;
    this.calories = calories;
    this.completed = completed;
  }
  
  // 获取格式化日期
  getFormattedDate(): string {
    return `${this.date.getFullYear()}-${this.date.getMonth() + 1}-${this.date.getDate()}`;
  }
  
  // 获取格式化时长
  getFormattedDuration(): string {
    const minutes = Math.floor(this.duration / 60);
    const seconds = this.duration % 60;
    return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
  }
} 
/**
 * 全局主题配置文件 - Keep风格
 */

export class AppTheme {
  // 主色调
  static readonly PRIMARY_COLOR: string = '#43D162';  // Keep主绿色
  static readonly SECONDARY_COLOR: string = '#333333';  // 深色辅助色
  
  // 背景色
  static readonly BACKGROUND_COLOR: string = '#FFFFFF';  // 主背景色
  static readonly BACKGROUND_COLOR_SECONDARY: string = '#F5F5F5';  // 次级背景色
  
  // 文本颜色
  static readonly TEXT_PRIMARY: string = '#333333';  // 主要文本颜色
  static readonly TEXT_SECONDARY: string = '#999999';  // 次要文本颜色
  static readonly TEXT_HIGHLIGHT: string = '#43D162';  // 突出文本颜色
  static readonly TEXT_HINT: string = '#BBBBBB';  // 提示文本颜色
  
  // 功能色
  static readonly SUCCESS_COLOR: string = '#67C23A';  // 成功色
  static readonly WARNING_COLOR: string = '#FF9E2D';  // 警告色 
  static readonly ERROR_COLOR: string = '#F56C6C';  // 错误色
  
  // 渐变色
  static readonly GRADIENT_PRIMARY: string = 'linear-gradient(135deg, #43D162 0%, #2AB549 100%)';  // 主渐变
  
  // 卡片阴影
  static readonly CARD_SHADOW: string = '0px 2px 10px rgba(0, 0, 0, 0.05)';
  
  // 动画时间
  static readonly ANIMATION_DURATION_FAST: number = 200;  // 快速动画
  static readonly ANIMATION_DURATION_NORMAL: number = 300;  // 普通动画
  static readonly ANIMATION_DURATION_SLOW: number = 500;  // 慢速动画
} 
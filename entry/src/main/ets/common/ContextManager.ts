import common from '@ohos.app.ability.common';

/**
 * 全局上下文管理器
 * 用于在应用中共享Context对象
 */
class ContextManager {
  private static instance: ContextManager;
  private appContext: common.Context | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ContextManager {
    if (!ContextManager.instance) {
      ContextManager.instance = new ContextManager();
    }
    return ContextManager.instance;
  }

  /**
   * 设置应用上下文
   * 
   * @param context 应用上下文
   */
  public setContext(context: common.Context): void {
    this.appContext = context;
    console.info('[ContextManager] 应用上下文已设置');
  }

  /**
   * 获取应用上下文
   * 
   * @returns 应用上下文
   */
  public getContext(): common.Context {
    if (!this.appContext) {
      console.error('[ContextManager] 应用上下文未设置');
      throw new Error('应用上下文未设置');
    }
    return this.appContext;
  }
}

export default ContextManager.getInstance(); 
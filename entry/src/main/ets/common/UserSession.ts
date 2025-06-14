// /common/UserSession.ts

// 定义持久化存储中使用的键
const IS_LOGGED_IN_KEY = 'isUserLoggedIn_persistent';
const LOGGED_IN_USERNAME_KEY = 'loggedInUsername_persistent';
const AUTH_TOKEN_KEY = 'authToken_persistent';
class UserSessionManager {
  /**
   * 用户登录后，更新全局状态
   * @param username 登录的用户名
   */
  static login(username: string,token: string): void {
    AppStorage.SetOrCreate(IS_LOGGED_IN_KEY, true);
    AppStorage.SetOrCreate(LOGGED_IN_USERNAME_KEY, username);
    AppStorage.SetOrCreate(AUTH_TOKEN_KEY, token);
    console.info(`[UserSession] 用户 ${username} 已登录，全局状态已更新。`);
  }

  /**
   * 用户退出登录后，清除全局状态
   */
  static logout(): void {
    AppStorage.Set(IS_LOGGED_IN_KEY, false);
    AppStorage.Delete(LOGGED_IN_USERNAME_KEY);
    console.info('[UserSession] 用户已退出登录，全局状态已清除。');
  }

  /**
   * 检查用户是否已登录
   */
  static isUserLoggedIn(): boolean {
    return AppStorage.Get<boolean>(IS_LOGGED_IN_KEY) ?? false;
  }

  /**
   * 获取当前登录的用户名
   */
  static getLoggedInUsername(): string | undefined {
    return AppStorage.Get<string>(LOGGED_IN_USERNAME_KEY);
  }

  static getToken(): string | undefined {
    return AppStorage.Get<string>(AUTH_TOKEN_KEY);
  }
}

export default UserSessionManager;
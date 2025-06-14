// /models/AuthModels.ts

/**
 * 对应后端 core/types.py 中的 ServiceResult 泛型接口
 */
export interface ServiceResult<T> {
  code: number;
  message: string;
  data: T | null;
}

/**
 * 登录或注册成功后，data 字段的数据结构
 */
export interface AuthData {
  token: string;
  username: string;
}
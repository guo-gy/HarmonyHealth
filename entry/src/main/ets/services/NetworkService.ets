import http from '@ohos.net.http';

class BaseResponse {
  code: number;
  message: string;

  constructor(code: number, message: string) {
    this.code = code;
    this.message = message;
  }
}

class LoginData {
  user_id: string;
  token?: string;

  constructor(user_id: string, token?: string) {
    this.user_id = user_id;
    this.token = token;
  }
}

class LoginResponse extends BaseResponse {
  data?: LoginData;

  constructor(code: number, message: string, data?: LoginData) {
    super(code, message);
    this.data = data;
  }
}

class RegisterData {
  user_id: string;

  constructor(user_id: string) {
    this.user_id = user_id;
  }
}

class RegisterResponse extends BaseResponse {
  data?: RegisterData;

  constructor(code: number, message: string, data?: RegisterData) {
    super(code, message);
    this.data = data;
  }
}

class RawLoginData {
  user_id: string;
  token?: string;

  constructor(user_id: string, token?: string) {
    this.user_id = user_id;
    this.token = token;
  }
}

class RawLoginResponse {
  code: number;
  message: string;
  data?: RawLoginData;

  constructor(code: number, message: string, data?: RawLoginData) {
    this.code = code;
    this.message = message;
    this.data = data;
  }
}

class RawRegisterData {
  user_id: string;

  constructor(user_id: string) {
    this.user_id = user_id;
  }
}

class RawRegisterResponse {
  code: number;
  message: string;
  data?: RawRegisterData;

  constructor(code: number, message: string, data?: RawRegisterData) {
    this.code = code;
    this.message = message;
    this.data = data;
  }
}

class NetworkService {
  private static instance: NetworkService;
  private baseUrl: string = 'http://localhost:8000';

  private constructor() {
    console.info('[NetworkService] 服务实例已初始化');
  }

  public static getInstance(): NetworkService {
    if (!NetworkService.instance) {
      console.info('[NetworkService] 创建新的服务实例');
      NetworkService.instance = new NetworkService();
    }
    return NetworkService.instance;
  }

  async login(user_id: string, password: string): Promise<LoginResponse> {
    console.info('[NetworkService] 开始处理登录请求');
    let httpRequest = http.createHttp();
    try {
      console.info(`[NetworkService] 发送登录请求到 ${this.baseUrl}/api/user/login/`);
      let response = await httpRequest.request(
        this.baseUrl + '/api/user/login/',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            user_id: user_id,
            password: password
          })
        }
      );
      console.info('[NetworkService] 收到登录响应');
      const result = JSON.parse(response.result as string) as RawLoginResponse;
      console.info(`[NetworkService] 登录响应状态码: ${result.code}`);
      
      const loginResponse = new LoginResponse(
        result.code,
        result.message,
        result.data ? new LoginData(result.data.user_id, result.data.token) : undefined
      );
      
      if (result.code === 200) {
        console.info('[NetworkService] 登录请求处理成功');
      } else {
        console.warn(`[NetworkService] 登录请求处理失败: ${result.message}`);
      }
      
      return loginResponse;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkService] 登录请求发生错误: ${errorMsg}`);
      throw new Error(errorMsg);
    } finally {
      httpRequest.destroy();
      console.info('[NetworkService] 登录请求已完成，HTTP连接已释放');
    }
  }

  async register(user_id: string, password: string): Promise<RegisterResponse> {
    console.info('[NetworkService] 开始处理注册请求');
    let httpRequest = http.createHttp();
    try {
      console.info(`[NetworkService] 发送注册请求到 ${this.baseUrl}/api/user/register/`);
      let response = await httpRequest.request(
        this.baseUrl + '/api/user/register/',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify({
            user_id: user_id,
            password: password,
          })
        }
      );
      console.info('[NetworkService] 收到注册响应');
      const result = JSON.parse(response.result as string) as RawRegisterResponse;
      console.info(`[NetworkService] 注册响应状态码: ${result.code}`);
      
      const registerResponse = new RegisterResponse(
        result.code,
        result.message,
        result.data ? new RegisterData(result.data.user_id) : undefined
      );
      
      if (result.code === 200) {
        console.info('[NetworkService] 注册请求处理成功');
      } else {
        console.warn(`[NetworkService] 注册请求处理失败: ${result.message}`);
      }
      
      return registerResponse;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      console.error(`[NetworkService] 注册请求发生错误: ${errorMsg}`);
      throw new Error(errorMsg);
    } finally {
      httpRequest.destroy();
      console.info('[NetworkService] 注册请求已完成，HTTP连接已释放');
    }
  }
}

export default NetworkService.getInstance(); 
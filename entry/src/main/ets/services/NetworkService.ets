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
  private useMockData: boolean = true; // 添加标志来控制是否使用模拟数据
  private mockUsers: Map<string, string> = new Map(); // 存储模拟用户数据

  private constructor() {
    console.info('[NetworkService] 服务实例已初始化');
    // 添加默认用户
    this.mockUsers.set('admin', 'admin');
  }

  public static getInstance(): NetworkService {
    if (!NetworkService.instance) {
      console.info('[NetworkService] 创建新的服务实例');
      NetworkService.instance = new NetworkService();
    }
    return NetworkService.instance;
  }

  // 添加模拟登录响应方法
  private mockLoginResponse(user_id: string, password: string): LoginResponse {
    console.info('[NetworkService] 使用模拟数据进行登录');
    // 检查用户是否存在且密码是否匹配
    if (this.mockUsers.has(user_id) && this.mockUsers.get(user_id) === password) {
      return new LoginResponse(
        200,
        '登录成功',
        new LoginData(user_id, 'mock-token-' + Math.random().toString(36).substring(2, 10))
      );
    } else {
      return new LoginResponse(
        401,
        '用户名或密码错误',
        undefined
      );
    }
  }

  private mockRegisterResponse(user_id: string, password: string): RegisterResponse {
    console.info('[NetworkService] 使用模拟数据进行注册');
    // 检查用户是否已存在
    if (this.mockUsers.has(user_id)) {
      return new RegisterResponse(
        400,
        '用户ID已存在',
        undefined
      );
    }
    
    // 检查用户名和密码是否符合要求
    if (user_id && password && password.length > 5) {
      // 存储新用户
      this.mockUsers.set(user_id, password);
      console.info(`[NetworkService] 模拟注册成功，用户数: ${this.mockUsers.size}`);
      
      return new RegisterResponse(
        200,
        '注册成功',
        new RegisterData(user_id)
      );
    } else {
      return new RegisterResponse(
        400,
        '用户名不能为空且密码长度必须大于5',
        undefined
      );
    }
  }

  async login(user_id: string, password: string): Promise<LoginResponse> {
    console.info('[NetworkService] 开始处理登录请求');
    
    // 如果启用了模拟数据，直接返回模拟响应
    if (this.useMockData) {
      return this.mockLoginResponse(user_id, password);
    }
    
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
    
    // 如果启用了模拟数据，直接返回模拟响应
    if (this.useMockData) {
      return this.mockRegisterResponse(user_id, password);
    }
    
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
            password: password
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
      // 修改这里的错误处理逻辑
      let errorMsg: string;
      if (error instanceof Error) {
        errorMsg = error.message;
      } else if (typeof error === 'object' && error !== null) {
        errorMsg = JSON.stringify(error); // 将对象转为JSON字符串
      } else {
        errorMsg = String(error);
      }
      console.error(`[NetworkService] 注册请求发生错误: ${errorMsg}`);
      
      // 返回错误响应
      return new RegisterResponse(
        500,
        `注册失败: ${errorMsg}`,
        undefined
      );
    } finally {
      httpRequest.destroy();
      console.info('[NetworkService] 注册请求已完成，HTTP连接已释放');
    }
  }
}

export default NetworkService.getInstance();
# HarmonyHealth API 文档

## 用户模块 API

### 1. 用户注册

- **接口地址**：`/api/user/register/`
- **请求方法**：`POST`
- **请求体格式**：
```json
{
    "user_id": "用户ID",
    "password": "密码"
}
```
- **响应格式**：
  - 成功响应 (200)：
    ```json
    {
        "code": 200,
        "message": "注册成功",
        "data": {
            "user_id": "用户ID"
        }
    }
    ```
  - 错误响应 (400)：
    ```json
    {
        "code": 400,
        "message": "用户ID已存在"
    }
    ```
    或
    ```json
    {
        "code": 400,
        "message": "用户ID和密码不能为空"
    }
    ```
  - 服务器错误 (500)：
    ```json
    {
        "code": 500,
        "message": "错误信息"
    }
    ```

### 2. 用户登录

- **接口地址**：`/api/user/login/`
- **请求方法**：`POST`
- **请求体格式**：
```json
{
    "user_id": "用户ID",
    "password": "密码"
}
```
- **响应格式**：
  - 成功响应 (200)：
    ```json
    {
        "code": 200,
        "message": "登录成功",
        "data": {
            "user_id": "用户ID"
        }
    }
    ```
  - 认证失败 (401)：
    ```json
    {
        "code": 401,
        "message": "用户ID或密码错误"
    }
    ```
  - 请求错误 (400)：
    ```json
    {
        "code": 400,
        "message": "用户ID和密码不能为空"
    }
    ```
  - 服务器错误 (500)：
    ```json
    {
        "code": 500,
        "message": "错误信息"
    }
    ```

## 通用说明

1. **请求格式要求**：
   - Content-Type: application/json
   - 请求体必须是合法的 JSON 格式

2. **响应码说明**：
   - 200: 请求成功
   - 400: 请求参数错误
   - 401: 认证失败
   - 500: 服务器内部错误

3. **响应格式说明**：
   - code: 响应状态码
   - message: 响应消息
   - data: 响应数据（可选） 
// entry/src/main/ets/common/config.ts
export interface AppConfigType {
  API_BASE_URL: string;
  USE_MOCK_DATA: boolean;
}
export const AppConfig = {
  API_BASE_URL: 'http://192.168.184.254:8000',
  USE_MOCK_DATA: false
};
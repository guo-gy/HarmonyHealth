import { ServiceResult } from './AuthModels';

// 后端 Information 模型中允许的字段
export type InformationAttribute = 'height' | 'weight' | 'age' | 'information' | 'target';

// Information 对象的数据结构
export interface InformationData {
  height?: number;
  weight?: number;
  age?: number;
  information?: string;
  target?: string;
}

// 定义获取和更新操作的响应类型
export type GetInformationResponse = ServiceResult<InformationData>;
export type UpdateInformationResponse = ServiceResult<InformationData>;
import formInfo from '@ohos.app.form.formInfo';
import formBindingData from '@ohos.app.form.formBindingData';
import FormExtensionAbility from '@ohos.app.form.FormExtensionAbility';
import formProvider from '@ohos.app.form.formProvider';
import hilog from '@ohos.hilog';
import dataPreferences from '@ohos.data.preferences';
import type common from '@ohos.app.ability.common';
import { BusinessError } from '@ohos.base';
import Want from '@ohos.app.ability.Want';

// 健康数据卡片服务实现
export default class HealthDataFormAbility extends FormExtensionAbility {
  // 记录日志的TAG
  private readonly TAG = 'HealthDataFormAbility';
  // 日志域
  private readonly DOMAIN_CODE = 0x00201;

  /**
   * 卡片被添加时触发
   *
   * @param want Want信息
   * @returns 卡片绑定数据
   */
  onAddForm(want) {
    hilog.info(this.DOMAIN_CODE, this.TAG, 'onAddForm, want: %{public}s', JSON.stringify(want));

    // 获取卡片ID
    const formId = want.parameters?.[formInfo.FormParam.IDENTITY_KEY]?.toString() || '';

    // 先返回一个默认的未登录状态数据
    const defaultData = this.getDefaultFormData(formId);

    // 异步获取更多数据并更新卡片
    this.updateCardData(formId);

    return formBindingData.createFormBindingData(defaultData);
  }

  /**
   * 卡片更新时触发
   *
   * @param formId 卡片ID
   */
  onUpdateForm(formId) {
    hilog.info(this.DOMAIN_CODE, this.TAG, `onUpdateForm, formId: ${formId}`);
    this.updateCardData(formId);
  }

  /**
   * 处理卡片消息事件
   *
   * @param formId 卡片ID
   * @param message 消息内容
   */
  onFormEvent(formId, message) {
    hilog.info(this.DOMAIN_CODE, this.TAG, `onFormEvent, formId: ${formId}, message: ${message}`);

    try {
      // 解析消息内容
      const msgObj = JSON.parse(message);

      // 处理刷新消息
      if (msgObj && msgObj.message === 'refresh') {
        hilog.info(this.DOMAIN_CODE, this.TAG, `Received refresh message for formId: ${formId}`);
        this.updateCardData(formId);
      }
    } catch (error) {
      hilog.error(this.DOMAIN_CODE, this.TAG, `onFormEvent parse error: ${JSON.stringify(error)}`);

      // 如果消息就是简单的字符串，直接判断
      if (message === 'refresh') {
        this.updateCardData(formId);
      }
    }
  }

  /**
   * 获取用户数据并更新卡片
   *
   * @param formId 卡片ID
   */
  private async updateCardData(formId: string) {
    try {
      // 检查登录状态 - 使用preferences检查
      const isLoggedIn = await this.checkLoginStatus();
      hilog.info(this.DOMAIN_CODE, this.TAG, `updateCardData, isLoggedIn: ${isLoggedIn}`);

      let formData;
      if (isLoggedIn) {
        // 已登录，获取用户数据
        const userData = await this.getUserProfileData();
        formData = {
          isLoggedIn: true,
          formId: formId,
          userName: userData.userName,
          userHeight: userData.userHeight,
          weight: userData.weight,
          age: userData.age,
          sportCount: userData.sportCount,
          updateTime: this.getFormattedTime()
        };
        hilog.info(this.DOMAIN_CODE, this.TAG, `信息装进去了: ${formData.userHeight}`);
      } else {
        // 未登录，使用默认数据
        formData = this.getDefaultFormData(formId);
      }

      // 更新卡片数据
      const bindingData = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, bindingData)
        .then(() => {
          hilog.info(this.DOMAIN_CODE, this.TAG, `updateCardData success, formId: ${formId}`);
        })
        .catch((err) => {
          hilog.error(this.DOMAIN_CODE, this.TAG, `updateCardData failed, formId: ${formId}, err: ${JSON.stringify(err)}`);
        });
    } catch (error) {
      hilog.error(this.DOMAIN_CODE, this.TAG, `updateCardData error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * 检查用户登录状态
   *
   * @returns 是否已登录
   */
  private async checkLoginStatus(): Promise<boolean> {
    try {
      const context = this.context as common.Context;
      // 使用preferences检查登录状态
      const pref = await dataPreferences.getPreferences(context, 'user_profile_prefs');
      const isLogin = await pref.get('isLoggedIn', false) as boolean;

      hilog.info(this.DOMAIN_CODE, this.TAG, `checkLoginStatus: ${isLogin}`);
      await pref.flush();
      return isLogin;
    } catch (error) {
      hilog.error(this.DOMAIN_CODE, this.TAG, `checkLoginStatus error: ${JSON.stringify(error)}`);
      return false;
    }
  }

  /**
   * 获取用户个人资料数据
   *
   * @returns 用户个人资料数据
   */
  private async getUserProfileData(): Promise<UserProfileData> {
    try {
      const context = this.context as common.Context;
      // 获取用户信息
      const userPref = await dataPreferences.getPreferences(context, 'user_profile_prefs');
      const userName = await userPref.get('userName', '用户') as string;
      hilog.info(this.DOMAIN_CODE, this.TAG, `getUserProfileData, userName: ${userName}`);

      // 获取个人资料数据
      const profilePref = await dataPreferences.getPreferences(context, 'user_profile_prefs');
      const userHeight = await profilePref.get('userHeight', '180') as string;
      hilog.info(this.DOMAIN_CODE, this.TAG, `getUserProfileData, userHeight: ${userHeight}`);
      const weight = await profilePref.get('weight', '50') as string;
      hilog.info(this.DOMAIN_CODE, this.TAG, `getUserProfileData, weight: ${weight}`);
      const age = await profilePref.get('age', '20') as string;
      hilog.info(this.DOMAIN_CODE, this.TAG, `getUserProfileData, age: ${age}`);
      const sportCount = await profilePref.get('sportCount', '0') as string;

      await userPref.flush();
      await profilePref.flush();

      return {
        userName,
        userHeight,
        weight,
        age,
        sportCount
      };
    } catch (error) {
      hilog.error(this.DOMAIN_CODE, this.TAG, `getUserProfileData error: ${JSON.stringify(error)}`);
      return {
        userName: '用户',
        userHeight: '180',
        weight: '50',
        age: '20',
        sportCount: '0'
      };
    }
  }

  /**
   * 获取默认卡片数据（未登录状态）
   *
   * @param formId 卡片ID
   * @returns 默认卡片数据
   */
  private getDefaultFormData(formId: string): DefaultFormData {
    return {
      isLoggedIn: false,
      formId: formId,
      userName: '',
      userHeight: '0',
      weight: '0',
      age: '0',
      sportCount: '0',
      updateTime: this.getFormattedTime()
    };
  }

  /**
   * 获取格式化的当前时间
   *
   * @returns 格式化的时间字符串
   */
  private getFormattedTime(): string {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  /**
   * 卡片被移除时触发
   *
   * @param formId 卡片ID
   */
  onRemoveForm(formId) {
    hilog.info(this.DOMAIN_CODE, this.TAG, `onRemoveForm, formId: ${formId}`);
  }

  /**
   * 卡片状态查询
   */
  onAcquireFormState(want) {
    return formInfo.FormState.READY;
  }
}

/**
 * 用户个人资料数据接口
 */
interface UserProfileData {
  userName: string;
  userHeight: string;
  weight: string;
  age: string;
  sportCount: string;
}

/**
 * 默认卡片数据接口
 */
interface DefaultFormData extends UserProfileData {
  isLoggedIn: boolean;
  formId: string;
  updateTime: string;
}
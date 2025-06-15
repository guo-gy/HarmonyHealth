import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want) {
    // Called to return a FormBindingData object.
    const formData = '';
    return formBindingData.createFormBindingData(formData);
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    this.refreshCardData(formId);
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
    console.info(`EntryFormAbility onFormEvent, formId: ${formId}, message: ${message}`);
    
    try {
      // 尝试解析消息
      const msgObj = JSON.parse(message);
      if (msgObj && msgObj.message === 'refresh') {
        console.info(`EntryFormAbility received refresh message for formId: ${formId}`);
        this.refreshCardData(formId);
      }
    } catch (error) {
      // 如果消息是简单字符串
      if (message === 'refresh') {
        this.refreshCardData(formId);
      }
    }
  }

  // 更新卡片数据的方法
  private async refreshCardData(formId: string) {
    try {
      // 检查登录状态
      const isLoggedIn = await this.checkLoginStatus();
      console.info(`EntryFormAbility refreshCardData, isLoggedIn: ${isLoggedIn}`);
      
      // 获取当前时间
      const currentTime = new Date();
      const hours = currentTime.getHours().toString().padStart(2, '0');
      const minutes = currentTime.getMinutes().toString().padStart(2, '0');
      
      let formData;
      if (isLoggedIn) {
        // 已登录状态 - 获取用户数据
        const userData = await this.getUserProfileData();
        formData = {
          isLoggedIn: true,
          formId: formId,
          userName: userData.userName,
          userHeight: userData.userHeight,
          weight: userData.weight,
          age: userData.age,
          sportCount: userData.sportCount,
          updateTime: `${hours}:${minutes}`
        };
      } else {
        // 未登录状态 - 使用默认数据
        formData = {
          isLoggedIn: false,
          formId: formId,
          userName: '',
          userHeight: '0',
          weight: '0',
          age: '0',
          sportCount: '0',
          updateTime: `${hours}:${minutes}`
        };
      }
      
      // 更新卡片
      const bindingData = formBindingData.createFormBindingData(formData);
      formProvider.updateForm(formId, bindingData)
        .then(() => {
          console.info(`EntryFormAbility updateForm success, formId: ${formId}`);
        })
        .catch((err: Error) => {
          console.error(`EntryFormAbility updateForm failed, formId: ${formId}, err: ${err.message}`);
        });
    } catch (error) {
      console.error(`EntryFormAbility refreshCardData error: ${error instanceof Error ? error.message : String(error)}`);
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
      const pref = await dataPreferences.getPreferences(context, 'user_info');
      const isLogin = await pref.get('isLogin', false) as boolean;
      
      console.info(`EntryFormAbility checkLoginStatus: ${isLogin}`);
      await pref.flush();
      return isLogin;
    } catch (error) {
      console.error(`EntryFormAbility checkLoginStatus error: ${error instanceof Error ? error.message : String(error)}`);
      return false;
    }
  }
  
  /**
   * 获取用户个人资料数据
   */
  private async getUserProfileData(): Promise<any> {
    try {
      const context = this.context as common.Context;
      // 获取用户信息
      const userPref = await dataPreferences.getPreferences(context, 'user_info');
      const userName = await userPref.get('userName', '用户') as string;
      
      // 获取个人资料数据
      const profilePref = await dataPreferences.getPreferences(context, 'profile_data');
      const userHeight = await profilePref.get('userHeight', '180') as string;
      const weight = await profilePref.get('weight', '50') as string;
      const age = await profilePref.get('age', '20') as string;
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
      console.error(`EntryFormAbility getUserProfileData error: ${error instanceof Error ? error.message : String(error)}`);
      return {
        userName: '用户',
        userHeight: '180',
        weight: '50',
        age: '20',
        sportCount: '0'
      };
    }
  }

  onRemoveForm(formId: string) {
    // Called to notify the form provider that a specified form has been destroyed.
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
}
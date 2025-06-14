// pages/Survey.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { informationService } from '../services/InformationService';
import { InformationAttribute, UpdateInformationResponse } from '../models/InformationModels';

// 数据接口
interface SurveyData {
  age: string;
  height: string;
  weight:string;
  target: string;
  information: string;
}

// 错误接口
interface SurveyErrors {
  age?: string;
  height?: string;
  weight?: string;
  target?: string;
}

// 为提交任务创建接口
interface SubmissionTask {
  attribute: InformationAttribute;
  value: string;
}

// 辅助函数：用于创建延迟
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

@Entry
@Component
struct SurveyPage {
  @State currentStep: number = 0
  @State surveyData: SurveyData = {
    age: '',
    height: '',
    weight: '',
    target: '',
    information: ''
  }
  @State errors: SurveyErrors = {}
  @State isSubmitting: boolean = false

  private targets: string[] = ['减脂塑形', '增肌增重', '提高心肺', '改善体态', '缓解压力', '其他']

  // 验证逻辑
  validateCurrentStep(): boolean {
    const newErrors: SurveyErrors = {};
    let isValid = true;

    if (this.currentStep === 1) {
      if (!this.surveyData.age) {
        newErrors.age = '请输入年龄';
        isValid = false;
      } else if (isNaN(Number(this.surveyData.age)) || Number(this.surveyData.age) <= 0) {
        newErrors.age = '请输入有效的年龄';
        isValid = false;
      }

      if (!this.surveyData.height) {
        newErrors.height = '请输入身高';
        isValid = false;
      } else if (isNaN(Number(this.surveyData.height)) || Number(this.surveyData.height) <= 0) {
        newErrors.height = '请输入有效的身高';
        isValid = false;
      }

      if (!this.surveyData.weight) {
        newErrors.weight = '请输入体重';
        isValid = false;
      } else if (isNaN(Number(this.surveyData.weight)) || Number(this.surveyData.weight) <= 0) {
        newErrors.weight = '请输入有效的体重';
        isValid = false;
      }
    } else if (this.currentStep === 2) {
      if (!this.surveyData.target) {
        newErrors.target = '必选';
        isValid = false;
      }
    }

    this.errors = newErrors;
    return isValid;
  }

  // 提交逻辑 (已添加日志)
  async submitSurveyData() {
    console.info('[SurveyPage] 进入 submitSurveyData 函数。');
    this.isSubmitting = true;
    const tasks: SubmissionTask[] = [];

    if (this.surveyData.age) tasks.push({ attribute: 'age', value: this.surveyData.age });
    if (this.surveyData.height) tasks.push({ attribute: 'height', value: this.surveyData.height });
    if (this.surveyData.weight) tasks.push({ attribute: 'weight', value: this.surveyData.weight });
    if (this.surveyData.target) tasks.push({ attribute: 'target', value: this.surveyData.target });
    if (this.surveyData.information) tasks.push({ attribute: 'information', value: this.surveyData.information });

    console.info('[SurveyPage] 生成的提交任务列表:', JSON.stringify(tasks));

    try {
      console.info('[SurveyPage] 进入 try 块，准备开始循环提交...');
      for (const task of tasks) {
        console.info(`[SurveyPage] 正在提交任务: ${task.attribute} = ${task.value}`);
        await informationService.updateAttribute(task.attribute, task.value);
        console.info(`[SurveyPage] 任务 ${task.attribute} 提交成功。`); // 如果这行没出现，说明 await 卡住了
        await sleep(100);
      }
      console.info('[SurveyPage] 所有任务提交成功！准备显示Toast并跳转。');
      promptAction.showToast({ message: '所有信息提交成功！' });
      router.pushUrl({ url: "pages/Index" });
    } catch (error) {
      console.error('[SurveyPage] 提交过程中发生严重错误:', error);
      promptAction.showToast({ message: '提交过程中发生错误，请重试' });
      // 失败后暂时不跳转，以便观察错误日志
      // router.pushUrl({ url: "pages/Index" });
    } finally {
      console.info('[SurveyPage] 进入 finally 块，重置 isSubmitting 状态为 false。');
      this.isSubmitting = false;
    }
  }

  // 导航逻辑 (已添加日志)
  handleNext() {
    console.info('[SurveyPage] 进入 handleNext，准备验证...');
    const isValid = this.validateCurrentStep();
    console.info(`[SurveyPage] 验证结果: ${isValid}。错误信息:`, JSON.stringify(this.errors));

    if (isValid) {
      if (this.currentStep < 2) {
        this.currentStep++;
      } else {
        console.info('[SurveyPage] 验证通过，准备调用 submitSurveyData...');
        this.submitSurveyData();
      }
    } else {
      console.warn('[SurveyPage] 验证失败，流程中断。');
    }
  }

  // --- UI 构建器 ---

  @Builder InputField(label: string, value: string, placeholder: string, error: string | undefined, onInput: (val: string) => void) {
    Column() {
      Text(label).fontSize(16).fontWeight(FontWeight.Bold).alignSelf(ItemAlign.Start)
      TextInput({ placeholder: placeholder, text: value })
        .type(InputType.Number)
        .onChange((val: string) => onInput(val))
        .borderColor(error ? Color.Red : '#CCCCCC')
        .borderWidth(1).borderRadius(8).padding(10).width('100%').margin({ top: 8 })
      if (error) {
        Text(error).fontSize(14).fontColor(Color.Red).margin({ top: 4 }).alignSelf(ItemAlign.Start)
      }
    }.width('100%').margin({ bottom: 24 })
  }

  @Builder InfoTextArea(label: string, value: string, placeholder: string, onInput: (val: string) => void) {
    Column() {
      Text(label).fontSize(16).fontWeight(FontWeight.Bold).alignSelf(ItemAlign.Start)
      TextArea({ placeholder: placeholder, text: value })
        .onChange((val: string) => onInput(val))
        .borderColor('#CCCCCC')
        .borderWidth(1).borderRadius(8).padding(10).width('100%').height(120).margin({ top: 8 })
    }.width('100%').margin({ bottom: 24 })
  }

  @Builder OptionButton(text: string, isSelected: boolean, onClick: () => void) {
    Button(text)
      .backgroundColor(isSelected ? '#007DFF' : '#F0F0F0')
      .fontColor(isSelected ? Color.White : Color.Black)
      .height(44).flexGrow(1).margin(4)
      .onClick(onClick)
  }

  @Builder QuestionGroup(title: string, options: string[], selectedValue: string, error: string | undefined, onSelect: (value: string) => void) {
    Column() {
      Row() {
        Text(title).fontSize(18).fontWeight(FontWeight.Bold)
        if (error) {
          Text(error).fontSize(14).fontColor(Color.Red).margin({ left: 10 })
        }
      }.alignSelf(ItemAlign.Start)
      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
        ForEach(options, (item: string) => {
          this.OptionButton(item, selectedValue === item, () => onSelect(item))
        })
      }.width('100%')
    }.width('100%').margin({ bottom: 24 })
  }

  build() {
    Column() {
      Row() {
        Text(
          this.currentStep === 0 ? '健康评估' :
            this.currentStep === 1 ? '1/2 个人信息' : '2/2 目标与补充信息'
        ).fontSize(24).fontWeight(FontWeight.Bold)
        Blank()
        if (this.currentStep > 0) {
          Button("跳过")
            .type(ButtonType.Normal).backgroundColor('transparent')
            .fontColor('#007DFF')
            .onClick(() => router.pushUrl({ url: "pages/Index" }))
        }
      }.width('100%').height(56).padding({ left: 16, right: 16 })

      Scroll() {
        Column() {
          if (this.currentStep === 0) {
            Text('为了您的健康计划更加个性化，我们会询问您一系列问题。')
              .fontSize(16).margin({ top: 40, bottom: 40 })
          } else if (this.currentStep === 1) {
            this.InputField('年龄', this.surveyData.age, '请输入您的年龄', this.errors.age,
              (val) => { this.surveyData.age = val; if (this.errors.age) this.errors.age = undefined; })

            this.InputField('身高 (cm)', this.surveyData.height, '请输入您的身高', this.errors.height,
              (val) => { this.surveyData.height = val; if (this.errors.height) this.errors.height = undefined; })

            this.InputField('体重 (kg)', this.surveyData.weight, '请输入您的体重', this.errors.weight,
              (val) => { this.surveyData.weight = val; if (this.errors.weight) this.errors.weight = undefined; })
          } else if (this.currentStep === 2) {
            this.QuestionGroup('您的主要健康目标是？', this.targets, this.surveyData.target, this.errors.target,
              (v) => {
                this.surveyData.target = v;
                if (this.errors.target) {
                  this.errors.target = undefined;
                }
              })

            this.InfoTextArea(
              '其他信息 (可选)',
              this.surveyData.information,
              '例如：有无伤病史、每周可锻炼时间、特殊饮食要求等。',
              (val) => {
                this.surveyData.information = val;
              }
            )
          }
        }.padding(16).width('100%').alignItems(HorizontalAlign.Start)
      }.layoutWeight(1)

      Button(this.currentStep === 0 ? '开始评估' : (this.currentStep === 2 ? '提交' : '继续'))
        .width('90%').height(50).fontSize(18)
        .backgroundColor('#007DFF').enabled(!this.isSubmitting)
        .margin({ bottom: 20 })
        .onClick(() => {
          console.info(`[SurveyPage] 提交/继续按钮被点击！当前步骤: ${this.currentStep}, isSubmitting: ${this.isSubmitting}`);
          if (this.currentStep === 0) {
            this.currentStep = 1;
          } else {
            this.handleNext();
          }
        })
    }.width('100%').height('100%')
  }
}
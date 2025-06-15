import promptAction from '@ohos.promptAction';
import { InformationData } from '../models/InformationModels';
import { informationService } from '../services/InformationService';
import UserSessionManager from '../common/UserSession';
import { RecentPlan} from '../models/PlanModels';
import { planService } from '../services/PlanService';
import { router } from '@kit.ArkUI';
import { authService } from '../services/AuthService'
@Component
@Entry
export struct ProfilePage {
  @State isRefreshing: boolean = false;
  @State message: string = '个人中心';
  @State profile: InformationData = {};
  @State isLoading: boolean = true; // 初始状态为 true，以便显示全屏加载
  @State selectedMetric: string = '体重';
  @State showHealthReport: boolean = false;
  @State currentUsername: string = '访客';
  @State recentPlanRecords: RecentPlan[] = [];
  @State isManualRefreshing: boolean = false; // 控制刷新按钮的状态
  @State over: number=0;

  // --- 生命周期函数 ---

  // 页面每次从后台切换到前台时触发，适合用于加载数据
  aboutToAppear(): void {
    this.loadAllData(false);
  }

  // --- 数据加载核心函数 ---

  /**
   * 统一加载所有页面数据
   * @param isManual - 标识是否为用户手动点击刷新按钮触发
   */
  async loadAllData(isManual: boolean = false): Promise<void> {
    // 根据刷新类型设置加载状态
    if (isManual) {
      if (this.isManualRefreshing) {
        return;
      } // 防止重复点击
      this.isManualRefreshing = true;
    } else {
      this.isLoading = true;
    }

    // 统一获取用户名
    const username = await UserSessionManager.getLoggedInUsername();
    if (username) {
      this.currentUsername = username;
    }

    // 并行加载个人资料和最近计划，提升效率
    try {
      await Promise.all([
        this.loadProfileData(),
        this.loadRecentPlans()
      ]);
      // 仅在手动刷新成功时给予提示
      if (isManual) {
        promptAction.showToast({ message: "信息已刷新" });
      }
    } catch (e) {
      // 统一处理并行加载中出现的任何错误
      promptAction.showToast({ message: `刷新失败: ${(e as Error).message}` });
    } finally {
      // 无论成功或失败，最后都重置所有加载状态
      this.isLoading = false;
      this.isManualRefreshing = false;
    }
  }
  async handleLogout() {
    console.info('用户确认退出，开始执行登出流程...');

    // 等待登出操作完成
    await authService.logout();

    // 清空页面栈
    router.clear();

    // 跳转到登录页
    router.pushUrl({
      url: 'pages/LoginPage' // 确保这是正确的登录页路径
    });

    promptAction.showToast({ message: '已退出登录' });
  }
  // 加载个人资料的独立函数
  async loadProfileData() {
    const heightResult = await informationService.getAttribute('height');
    const weightResult = await informationService.getAttribute('weight');
    const ageResult = await informationService.getAttribute('age');
    const infoResult = await informationService.getAttribute('information');
    const targetResult = await informationService.getAttribute('target');
    const overResult = await planService.getOverPlans();

    const newProfile: InformationData = {};
    if (heightResult.code === 200 && heightResult.data) {
      newProfile.height = heightResult.data.height;
    }
    if (weightResult.code === 200 && weightResult.data) {
      newProfile.weight = weightResult.data.weight;
    }
    if (ageResult.code === 200 && ageResult.data) {
      newProfile.age = ageResult.data.age;
    }
    if (infoResult.code === 200 && infoResult.data) {
      newProfile.information = infoResult.data.information;
    }
    if (targetResult.code === 200 && targetResult.data) {
      newProfile.target = targetResult.data.target;
    }
    if (overResult.code === 200 && overResult.data) {
      this.over = overResult.data.recent_plans_count;
    }


    this.profile = newProfile;
  }

  // 加载最近计划的独立函数
  async loadRecentPlans() {
    const result = await planService.getRecentPlans(5);
    if (result.code === 200 && result.data) {
      this.recentPlanRecords = result.data.recent_plans;
    } else {
      // 抛出错误，由上层 loadAllData 的 catch 块统一处理
      throw new Error(result.message || '加载最近运动记录失败');
    }
  }

  // --- UI 构建函数 ---
  build() {
    // 如果是初始加载，显示一个全屏的 Loading 界面
    if (this.isLoading) {
      Column() {
        LoadingProgress().width(50).height(50)
        Text('正在加载您的数据...').margin({ top: 20 }).fontColor(Color.Gray)
      }
      .width('100%').height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F0F2F5')
    } else {
      // 加载完成后，显示主内容
      Scroll() {
        Column({ space: 16 }) {
          // 顶部标题和设置按钮
          Row() {
            Text(this.message).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333')
            Blank()
            Button() {
              Image($r('app.media.settings_icon')).width(24).height(24)
            }
            .width(40)
            .height(40)
            .backgroundColor('#F0F0F0')
            .borderRadius(20)
            .onClick(() => {
              promptAction.showDialog({
                title: '退出登录',
                message: '您确定要退出当前账号吗？',
                buttons: [
                  { text: '取消', color: '#666666' },
                  { text: '确认退出', color: '#FF3B30' }
                ]
              }).then(result => {
                // 如果用户点击了"确认退出"（索引为 1）
                if (result.index === 1) {
                  this.handleLogout();
                }
              });
            })
          }
          .width('100%')
          .padding({
            left: 20,
            right: 20,
            top: 20,
            bottom: 10
          })

          // 用户信息卡片
          Column() {
            Row() {
              Column() {
                // 用户名、目标、等级
                Row() {
                  Column() {
                    Text(this.currentUsername).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#333333')
                    Text(`目标: ${this.profile.target || '未设置'}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 5 })
                  }.alignItems(HorizontalAlign.Start).margin({ left: 15 }).layoutWeight(1)
                }.width('100%')

                // 刷新信息按钮
                Button() {
                  if (this.isManualRefreshing) {
                    Row({ space: 8 }) {
                      LoadingProgress().width(20).height(20).color(Color.White)
                      Text('正在刷新...').fontSize(16).fontColor(Color.White)
                    }
                  } else {
                    Text('刷新信息').fontSize(16).fontColor(Color.White)
                  }
                }
                .width('100%')
                .height(44)
                .borderRadius(22)
                .backgroundColor('#007DFF')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 16 })
                .onClick(() => {
                  this.loadAllData(true)
                })
                .enabled(!this.isManualRefreshing) // 刷新时禁用按钮
              }
              .layoutWeight(1)
            }
            .width('100%').padding(20)

            Divider().width('100%').color('#EEEEEE').strokeWidth(1)

            // 身体数据网格
            Grid() {
              GridItem() {
                Column() {
                  Text('身高').fontSize(14).fontColor('#666666');
                  Row() {
                    Text(`${this.profile.height || '--'}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');
                    Text('cm').fontSize(14).fontColor('#999999').margin({ left: 4, bottom: 2 }).alignSelf(ItemAlign.End)
                  }
                }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }

              GridItem() {
                Column() {
                  Text('体重').fontSize(14).fontColor('#666666');
                  Row() {
                    Text(`${this.profile.weight || '--'}`)
                      .fontSize(22)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333');
                    Text('kg').fontSize(14).fontColor('#999999').margin({ left: 4, bottom: 2 }).alignSelf(ItemAlign.End)
                  }
                }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }

              GridItem() {
                Column() {
                  Text('年龄').fontSize(14).fontColor('#666666');
                  Row() {
                    Text(`${this.profile.age || '--'}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333');
                    Text('岁').fontSize(14).fontColor('#999999').margin({ left: 4, bottom: 2 }).alignSelf(ItemAlign.End)
                  }
                }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }

              GridItem() {
                Column() {
                  Text('运动次数').fontSize(14).fontColor('#666666');
                  Row() {
                    Text(`${this.over || '--'}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#333333');
                    Text('次').fontSize(14).fontColor('#999999').margin({ left: 4, bottom: 2 }).alignSelf(ItemAlign.End)
                  }
                }.width('100%').height('100%').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              }
            }
            .columnsTemplate('1fr 1fr 1fr 1fr').rowsTemplate('80vp').width('100%').height(80)
          }
          .width('90%').backgroundColor('#FFFFFF').borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // 运动记录卡片
          Column({ space: 12 }) {
            Row() {
              Text('最近计划记录').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#333333')
            }

            if (this.recentPlanRecords.length === 0) {
              Text('暂无最近计划记录')
                .fontSize(14)
                .fontColor(Color.Gray)
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding({ top: 40, bottom: 40 })
            } else {
              ForEach(this.recentPlanRecords, (record: RecentPlan) => {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(record.title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#333333')
                    Text(record.description || '无详细描述')
                      .fontSize(14)
                      .fontColor('#999999')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                  }.alignItems(HorizontalAlign.Start).layoutWeight(1)

                  Text(record.display_date).fontSize(12).fontColor('#999999').flexShrink(0)
                }
                .width('100%')
                .padding({
                  top: 12,
                  bottom: 12,
                  left: 10,
                  right: 10
                })
                .alignItems(VerticalAlign.Center)
              }, (record: RecentPlan) => record.id.toString())
            }
          }
          .width('90%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })

          // 开始新的运动按钮
          Button('开始新的运动')
            .width('90%')
            .height(44)
            .borderRadius(22)
            .backgroundColor('#007DFF')
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 20 })
            .onClick(() => {
              console.info('开始新的运动 按钮被点击，准备跳转到 WorkoutPage');
              router.pushUrl({
                url: 'pages/WorkoutPage'
              });
            })

          // 健康报告按钮
          Button() {
            Row() {
              Image($r('app.media.report_icon'))
                .width(24)
                .height(24)
                .margin({ right: 8 })

              Text('生成健康报告')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
          }
          .width('90%')
          .height(56)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({
            radius: 8,
            color: 'rgba(0, 0, 0, 0.05)',
            offsetX: 0,
            offsetY: 2
          })
          // 点击跳转到健康报告页面
          .onClick(() => {
            router.pushUrl({ url: 'pages/HealthReportPage' });
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .backgroundColor('#F0F2F5')
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
import router from '@ohos.router';
import formProvider from '@ohos.app.form.formProvider';
import formBindingData from '@ohos.app.form.formBindingData';
import geoLocationManager from '@ohos.geoLocationManager';
import sensor from '@ohos.sensor';
import weather from '@ohos.weather';
import http from '@ohos.net.http';

// 卡片类型枚举
enum CardType {
  DATA_CARD = 'data_card',  // 数据卡片
  CONTROL_CARD = 'control_card', // 控制卡片
  SCENE_CARD = 'scene_card'  // 情景卡片
}

// 天气类型枚举
enum WeatherType {
  SUNNY = 'sunny',
  RAINY = 'rainy',
  CLOUDY = 'cloudy',
  SNOWY = 'snowy'
}

// 位置信息接口
interface LocationInfo {
  latitude: number;
  longitude: number;
  accuracy?: number;
}

// 健康数据接口
interface HealthData {
  steps: number;        // 步数
  heartRate: number;    // 心率
  calories: number;     // 消耗卡路里
  lastUpdate: string;   // 最后更新时间
}

@Component
export struct HealthCard {
  // 卡片标识ID
  private formId: string = "";
  // 卡片类型
  @State cardType: CardType = CardType.DATA_CARD;
  // 健康数据
  @State healthData: HealthData = {
    steps: 0,
    heartRate: 0,
    calories: 0,
    lastUpdate: new Date().toISOString()
  };
  // 当前位置
  @State location: LocationInfo = {
    latitude: 0,
    longitude: 0
  };
  // 当前天气
  @State currentWeather: WeatherType = WeatherType.SUNNY;
  // 加载状态
  @State isLoading: boolean = true;
  // 是否为雨天
  @State isRainyDay: boolean = false;

  // 组件即将出现时触发
  aboutToAppear() {
    // 初始化时获取卡片类型
    this.getCardType();
    // 获取健康数据
    this.fetchHealthData();
    // 获取位置信息
    this.getLocation();
  }

  // 获取卡片类型
  getCardType() {
    try {
      // 从路由参数中获取卡片类型
      const params = router.getParams();
      if (params && params['cardType']) {
        this.cardType = params['cardType'] as CardType;
      }
    } catch (error) {
      console.error('获取卡片类型失败:', error);
      // 默认为数据卡片
      this.cardType = CardType.DATA_CARD;
    }
  }

  // 获取健康数据
  async fetchHealthData() {
    try {
      // 模拟获取步数传感器数据
      const stepSensor = await sensor.getSensor(sensor.SensorType.SENSOR_TYPE_PEDOMETER);
      const stepData = await sensor.getSensorData(stepSensor);
      this.healthData.steps = stepData.steps || 0;

      // 模拟获取心率数据
      const heartRateSensor = await sensor.getSensor(sensor.SensorType.SENSOR_TYPE_HEART_RATE);
      const heartRateData = await sensor.getSensorData(heartRateSensor);
      this.healthData.heartRate = heartRateData.heartRate || 0;

      // 计算消耗卡路里（简单估算）
      this.healthData.calories = Math.floor(this.healthData.steps * 0.04);
      this.healthData.lastUpdate = new Date().toISOString();

      // 更新卡片数据
      this.updateCardData();
    } catch (error) {
      console.error('获取健康数据失败:', error);
      // 使用模拟数据
      this.healthData = {
        steps: 6520,
        heartRate: 72,
        calories: 260,
        lastUpdate: new Date().toISOString()
      };
      this.updateCardData();
    } finally {
      this.isLoading = false;
    }
  }

  // 获取位置信息
  async getLocation() {
    try {
      // 请求位置权限
      await geoLocationManager.requestEnableLocation();
      
      // 获取当前位置
      const locationRequest = {
        priority: 0x203, // 高精度定位
        scenario: 0x300, // 运动场景
        timeInterval: 0, // 一次性请求
        distanceInterval: 0 // 一次性请求
      };
      
      const locationData = await geoLocationManager.getCurrentLocation(locationRequest);
      this.location = {
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        accuracy: locationData.accuracy
      };
      
      // 获取位置后获取天气
      this.getWeatherInfo();
    } catch (error) {
      console.error('获取位置失败:', error);
      // 使用默认位置（北京）
      this.location = {
        latitude: 39.9042,
        longitude: 116.4074
      };
      this.getWeatherInfo();
    }
  }

  // 获取天气信息
  async getWeatherInfo() {
    try {
      // 构建天气请求
      const weatherRequest = {
        latitude: this.location.latitude,
        longitude: this.location.longitude,
        locale: "zh_CN",
        days: 1 // 只需要当天天气
      };
      
      // 获取天气数据
      const weatherData = await weather.getWeather(weatherRequest);
      
      // 判断天气类型
      if (weatherData && weatherData.dailyWeather && weatherData.dailyWeather.length > 0) {
        const today = weatherData.dailyWeather[0];
        
        // 判断是否下雨
        if (today.weatherCode >= 300 && today.weatherCode < 400) {
          this.currentWeather = WeatherType.RAINY;
          this.isRainyDay = true;
        } else if (today.weatherCode >= 400 && today.weatherCode < 500) {
          this.currentWeather = WeatherType.SNOWY;
        } else if (today.weatherCode >= 500 && today.weatherCode < 600) {
          this.currentWeather = WeatherType.CLOUDY;
        } else {
          this.currentWeather = WeatherType.SUNNY;
        }
      }
      
      // 如果是情景卡片，更新卡片数据
      if (this.cardType === CardType.SCENE_CARD) {
        this.updateSceneCardData();
      }
    } catch (error) {
      console.error('获取天气失败:', error);
      // 默认为晴天
      this.currentWeather = WeatherType.SUNNY;
      this.isRainyDay = false;
      
      if (this.cardType === CardType.SCENE_CARD) {
        this.updateSceneCardData();
      }
    }
  }

  // 更新卡片数据
  updateCardData() {
    try {
      // 根据卡片类型构建数据
      let formData: any = {};
      
      switch (this.cardType) {
        case CardType.DATA_CARD:
          formData = {
            steps: this.healthData.steps,
            heartRate: this.healthData.heartRate,
            calories: this.healthData.calories,
            lastUpdate: this.healthData.lastUpdate
          };
          break;
          
        case CardType.CONTROL_CARD:
          formData = {
            canStartWorkout: true,
            canMarkWater: true,
            lastUpdate: this.healthData.lastUpdate
          };
          break;
          
        case CardType.SCENE_CARD:
          this.updateSceneCardData();
          return;
      }
      
      // 创建卡片绑定数据
      const formBindData = formBindingData.createFormBindingData(formData);
      
      // 更新卡片
      formProvider.updateForm(this.formId, formBindData).then(() => {
        console.info('卡片数据更新成功');
      }).catch((error) => {
        console.error('卡片数据更新失败:', error);
      });
    } catch (error) {
      console.error('更新卡片数据失败:', error);
    }
  }

  // 更新情景卡片数据
  updateSceneCardData() {
    try {
      // 构建情景卡片数据
      const sceneData: any = {
        weatherType: this.currentWeather,
        isRainyDay: this.isRainyDay,
        indoorWorkoutRecommended: this.isRainyDay,
        workoutRecommendation: this.getWorkoutRecommendation(),
        lastUpdate: new Date().toISOString()
      };
      
      // 创建卡片绑定数据
      const formBindData = formBindingData.createFormBindingData(sceneData);
      
      // 更新卡片
      formProvider.updateForm(this.formId, formBindData).then(() => {
        console.info('情景卡片数据更新成功');
      }).catch((error) => {
        console.error('情景卡片数据更新失败:', error);
      });
    } catch (error) {
      console.error('更新情景卡片数据失败:', error);
    }
  }

  // 根据天气获取运动建议
  getWorkoutRecommendation(): string {
    // 根据天气类型返回运动建议
    switch (this.currentWeather) {
      case WeatherType.RAINY:
        return "雨天室内训练推荐：\n1. 家庭HIIT训练 20分钟\n2. 瑜伽拉伸 15分钟\n3. 核心力量训练 10分钟";
      case WeatherType.SNOWY:
        return "雪天室内训练推荐：\n1. 力量训练 25分钟\n2. 室内有氧操 15分钟\n3. 柔韧性训练 10分钟";
      case WeatherType.CLOUDY:
        return "阴天户外/室内训练推荐：\n1. 慢跑 30分钟\n2. 力量训练 20分钟\n3. 拉伸 10分钟";
      case WeatherType.SUNNY:
      default:
        return "晴天户外训练推荐：\n1. 户外跑步 30分钟\n2. 户外徒手训练 20分钟\n3. 户外拉伸 10分钟";
    }
  }

  // 启动运动
  startWorkout() {
    try {
      // 路由到运动页面
      router.pushUrl({
        url: "pages/WorkoutPage",
      });
    } catch (error) {
      console.error('启动运动失败:', error);
    }
  }

  // 饮水打卡
  markWaterIntake() {
    try {
      // TODO: 实现饮水打卡逻辑
      console.info('饮水打卡成功');
    } catch (error) {
      console.error('饮水打卡失败:', error);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      // 加载状态
      if (this.isLoading) {
        Loading()
          .width('100%')
          .height('100%')
      } else {
        // 根据卡片类型构建不同UI
        if (this.cardType === CardType.DATA_CARD) {
          this.DataCardBuilder()
        } else if (this.cardType === CardType.CONTROL_CARD) {
          this.ControlCardBuilder()
        } else {
          this.SceneCardBuilder()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
  }

  // 数据卡片构建器
  @Builder
  DataCardBuilder() {
    Column() {
      // 卡片标题
      Text("健康数据")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: 12, bottom: 8, left: 16, right: 16 })
      
      // 数据区域
      Row() {
        // 步数
        Column() {
          Text(this.healthData.steps.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#007DFF')
          
          Text("步数")
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        // 分隔线
        Divider()
          .vertical(true)
          .height('60%')
          .color('#EEEEEE')
        
        // 心率
        Column() {
          Row() {
            Text(this.healthData.heartRate.toString())
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FF4D4F')
            
            Text("bpm")
              .fontSize(12)
              .fontColor('#666666')
              .margin({ left: 2, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          
          Text("心率")
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        
        // 分隔线
        Divider()
          .vertical(true)
          .height('60%')
          .color('#EEEEEE')
        
        // 卡路里
        Column() {
          Text(this.healthData.calories.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9500')
          
          Text("卡路里")
            .fontSize(12)
            .fontColor('#666666')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 8, bottom: 12 })
      
      // 更新时间
      Text("更新于: " + new Date(this.healthData.lastUpdate).toLocaleTimeString())
        .fontSize(10)
        .fontColor('#999999')
        .width('100%')
        .textAlign(TextAlign.Center)
        .padding({ bottom: 4 })
    }
    .width('100%')
    .height('100%')
  }

  // 控制卡片构建器
  @Builder
  ControlCardBuilder() {
    Column() {
      // 卡片标题
      Text("快捷操作")
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: 12, bottom: 8, left: 16, right: 16 })
      
      // 按钮区域
      Row() {
        // 开始运动按钮
        Button("开始运动", { type: ButtonType.Capsule })
          .backgroundColor('#007DFF')
          .fontSize(14)
          .fontColor(Color.White)
          .height(36)
          .onClick(() => this.startWorkout())
        
        // 饮水打卡按钮
        Button("饮水打卡", { type: ButtonType.Capsule })
          .backgroundColor('#36CFC9')
          .fontSize(14)
          .fontColor(Color.White)
          .height(36)
          .onClick(() => this.markWaterIntake())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ left: 8, right: 8, top: 8, bottom: 12 })
    }
    .width('100%')
    .height('100%')
  }

  // 情景卡片构建器
  @Builder
  SceneCardBuilder() {
    Column() {
      // 卡片标题
      Row() {
        // 天气图标
        if (this.currentWeather === WeatherType.RAINY) {
          Image($r('app.media.icon_rainy'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
        } else if (this.currentWeather === WeatherType.SNOWY) {
          Image($r('app.media.icon_snowy'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
        } else if (this.currentWeather === WeatherType.CLOUDY) {
          Image($r('app.media.icon_cloudy'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
        } else {
          Image($r('app.media.icon_sunny'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
        }
        
        // 天气标题
        Text(this.isRainyDay ? "雨天训练建议" : "今日训练建议")
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding({ top: 12, bottom: 8, left: 16, right: 16 })
      
      // 推荐内容
      Text(this.getWorkoutRecommendation())
        .fontSize(14)
        .fontColor('#333333')
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 12 })
        .textAlign(TextAlign.Start)
      
      // 开始运动按钮
      Button({ type: ButtonType.Capsule }) {
        Row() {
          Text("查看详细计划")
            .fontColor(Color.White)
            .fontSize(14)
          
          Image($r('app.media.icon_arrow'))
            .width(16)
            .height(16)
            .margin({ left: 4 })
            .fillColor(Color.White)
        }
      }
      .backgroundColor('#007DFF')
      .width('90%')
      .height(36)
      .margin({ top: 8, bottom: 12 })
      .onClick(() => this.startWorkout())
    }
    .width('100%')
    .height('100%')
  }
} 
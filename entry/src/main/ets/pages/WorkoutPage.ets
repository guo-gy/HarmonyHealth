import http from '@ohos.net.http';
import geoLocationManager from '@ohos.geoLocationManager';
import prompt from '@ohos.prompt';
import preferences from '@ohos.data.preferences';
import webview from '@ohos.web.webview';

// 百度地图密钥
const BAIDU_MAP_KEY = 'SvUW8XXSzg9kbzOOcjL2Uic3GSifwLA6';

// 用户体重(kg)，理想情况下应从用户资料获取
const USER_WEIGHT = 70;

// 卡路里消耗系数
const CALORIE_FACTOR = 1.036;

// 存储器名
const PREFERENCES_NAME = 'workout_records';

// 运动记录类型
interface WorkoutRecord {
  startTime: number; // 开始时间戳
  endTime: number; // 结束时间戳
  duration: number; // 持续时间(秒)
  distance: number; // 距离(米)
  averagePace: number; // 平均配速(秒/公里)
  calories: number; // 卡路里消耗
  trackPoints: TrackPoint[]; // 轨迹点
}

// 轨迹点类型
interface TrackPoint {
  latitude: number; // 纬度
  longitude: number; // 经度
  timestamp: number; // 时间戳
  altitude?: number; // 海拔(可选)
  speed?: number; // 速度(可选)
}

// 百度地图点位类型
interface BMapPoint {
  lng: number;
  lat: number;
}

// 定义位置请求接口
interface LocationRequest {
  priority: number;
  scenario: number;
  timeInterval: number;
  distanceInterval: number;
}

// 定义位置信息接口
interface LocationInfo {
  latitude: number;
  longitude: number;
}

// 定义消息提示接口
interface ToastOptions {
  message: string;
}

// 定义按钮类型
interface ButtonOptions {
  type: ButtonType;
}

// 定义确认按钮接口
interface ConfirmButton {
  value: string;
  action: () => void;
}

// 定义AlertDialog参数接口
class AlertOptions {
  title: string = '';
  message: string = '';
  confirm: ConfirmButton = {
    value: 'OK',
    action: () => {
    }
  };
  cancel: () => void = () => {
  };

  constructor(title: string, message: string, confirmValue: string, confirmAction: () => void, cancel: () => void) {
    this.title = title;
    this.message = message;
    this.confirm = {
      value: confirmValue,
      action: confirmAction
    };
    this.cancel = cancel;
  }
}

@Component
export struct WorkoutPage {
  // 地图相关
  @State isMapInitialized: boolean = false;
  private mapWebView = new webview.WebviewController();
  private points: BMapPoint[] = [];
  private isMapLoaded: boolean = false;
  // 运动状态
  @State isRunning: boolean = false; // 是否在运行
  @State isPaused: boolean = false; // 是否暂停
  @State workoutStarted: boolean = false; // 是否开始运动
  // 运动数据
  @State duration: number = 0; // 运动时长(秒)
  @State distance: number = 0; // 距离(米)
  @State currentPace: number = 0; // 当前配速(秒/公里)
  @State calories: number = 0; // 卡路里
  @State currentLocation: LocationInfo = { latitude: 0, longitude: 0 };
  // 轨迹点
  private trackPoints: TrackPoint[] = [];
  // 计时器
  private timer: number = 0;
  // 定位器
  private locationListener: number = 0;
  // 存储实例
  private storagePreferences: preferences.Preferences | null = null;
  private storageAvailable: boolean = false;

  // 组件即将出现时执行
  aboutToAppear() {
    // 创建存储器 - 异步但不阻塞UI
    this.createPreferences();

    // 直接初始化地图 - 不等待存储器初始化
    setTimeout(() => {
      this.initMapUI();
    }, 500);
  }

  // 组件消失时执行
  aboutToDisappear() {
    this.stopWorkout(false);
  }

  // 创建存储器
  async createPreferences() {
    try {
      this.storagePreferences = await preferences.getPreferences(getContext(this), PREFERENCES_NAME);
      this.storageAvailable = true;
      console.info('获取存储实例成功');
    } catch (error) {
      this.storageAvailable = false;
      console.error(`获取存储实例失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '存储初始化失败，记录将不会保存' };
      prompt.showToast(toastOpts);
    }
  }

  // 初始化地图UI
  initMapUI() {
    // 直接初始化地图，不依赖存储
    this.initMap();
  }

  // 初始化地图
  initMap() {
    // 在鸿蒙环境中，我们需要使用WebView加载百度地图
    const mapHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <meta charset="utf-8">
        <style>
          html, body, #map {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
          }
        </style>
        <script type="text/javascript" src="https://api.map.baidu.com/api?v=3.0&ak=${BAIDU_MAP_KEY}"></script>
      </head>
      <body>
        <div id="map"></div>
        <script type="text/javascript">
          var map = null;
          var polyline = null;
          var marker = null;
          var points = [];
          
          // 初始化地图
          function initMap(lat, lng) {
            try {
              map = new BMap.Map("map");
              var point = new BMap.Point(lng || 116.404, lat || 39.915); // 默认北京坐标
              map.centerAndZoom(point, 18);
              map.enableScrollWheelZoom();
              map.addControl(new BMap.ScaleControl());
              map.addControl(new BMap.NavigationControl({type: BMAP_NAVIGATION_CONTROL_SMALL}));
              
              // 添加定位标记
              var myIcon = new BMap.Icon("https://api.map.baidu.com/images/marker_red.png", new BMap.Size(23, 25));
              marker = new BMap.Marker(point, {icon: myIcon});
              map.addOverlay(marker);
              
              // 告诉原生代码地图已加载
              window.mapLoaded = true;
              if (window.OnMapLoaded) {
                window.OnMapLoaded();
              }
            } catch(e) {
              console.error("Map initialization failed:", e);
            }
          }
          
          // 更新位置
          function updateLocation(lat, lng) {
            if (!map) return;
            
            var point = new BMap.Point(lng, lat);
            points.push(point);
            
            // 更新标记位置
            marker.setPosition(point);
            
            // 更新轨迹线
            if (points.length > 1) {
              if (polyline) {
                map.removeOverlay(polyline);
              }
              polyline = new BMap.Polyline(points, {strokeColor:"#FF0000", strokeWeight:5, strokeOpacity:1});
              map.addOverlay(polyline);
            }
            
            // 居中地图
            map.panTo(point);
          }
          
          // 清除轨迹
          function clearTrack() {
            if (!map) return;
            
            if (polyline) {
              map.removeOverlay(polyline);
              polyline = null;
            }
            
            points = [];
            
            // 重设标记位置（如果存在）
            if (marker && points.length > 0) {
              marker.setPosition(points[0]);
            }
          }
          
          // 监听定位变化
          function handleLocationUpdate(lat, lng) {
            updateLocation(lat, lng);
          }
          
          // 初始化时自动调用一次
          initMap();
          
          // 暴露给原生调用的方法
          window.handleLocationUpdate = handleLocationUpdate;
          window.clearTrack = clearTrack;
        </script>
      </body>
      </html>
    `;

    try {
      // 设置WebView加载HTML
      this.mapWebView.loadData(mapHtml, 'text/html', 'UTF-8');

      // 使用延迟来模拟地图加载完成
      setTimeout(() => {
        this.isMapInitialized = true;
        this.isMapLoaded = true;
        console.info('地图初始化成功');
        // 地图加载成功后请求位置权限
        this.requestLocationPermission();
      }, 1000);
    } catch (error) {
      console.error(`地图初始化失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '地图初始化失败，请重试' };
      prompt.showToast(toastOpts);
    }
  }

  // 请求位置权限
  async requestLocationPermission() {
    try {
      // 直接获取当前位置，如果需要会提示用户启用位置服务
      this.getCurrentLocation();
    } catch (error) {
      console.error(`请求位置权限失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '无法获取位置权限，请在设置中授权' };
      prompt.showToast(toastOpts);

      // 即使没有位置权限，仍然使用模拟数据
      this.simulateLocation();
    }
  }

  // 获取当前位置
  async getCurrentLocation() {
    try {
      const locationRequest: LocationRequest = {
        priority: 0x203, // 高精度定位
        scenario: 0x300, // 运动场景
        timeInterval: 0, // 一次性请求
        distanceInterval: 0 // 一次性请求
      };

      // TODO: 需添加权限 ohos.permission.APPROXIMATELY_LOCATION
      const location = await geoLocationManager.getCurrentLocation(locationRequest);

      this.currentLocation = {
        latitude: location.latitude,
        longitude: location.longitude
      };

      // 更新地图位置
      if (this.isMapLoaded) {
        this.updateMapLocation(location.latitude, location.longitude);
      }

    } catch (error) {
      console.error(`获取当前位置失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '获取位置失败，使用模拟位置' };
      prompt.showToast(toastOpts);

      // 使用默认位置
      this.simulateLocation();
    }
  }

  // 模拟位置
  simulateLocation() {
    // 北京天安门坐标作为默认位置
    const defaultLocation: LocationInfo = {
      latitude: 39.9087,
      longitude: 116.3976
    };

    this.currentLocation = defaultLocation;

    // 更新地图位置
    if (this.isMapLoaded) {
      this.updateMapLocation(defaultLocation.latitude, defaultLocation.longitude);
    }
  }

  // 更新地图位置
  updateMapLocation(latitude: number, longitude: number) {
    if (!this.isMapLoaded) {
      return;
    }

    const point: BMapPoint = { lat: latitude, lng: longitude };
    this.points.push(point);

    // 调用JS方法更新地图
    try {
      this.mapWebView.runJavaScript(
        `handleLocationUpdate(${latitude}, ${longitude});`
      );
    } catch (e) {
      console.error(`更新地图位置失败: ${JSON.stringify(e)}`);
    }
  }

  // 清除地图轨迹
  clearMapTrack() {
    if (!this.isMapLoaded) {
      return;
    }

    this.points = [];

    // 调用JS方法清除轨迹
    try {
      this.mapWebView.runJavaScript('clearTrack();');
    } catch (e) {
      console.error(`清除地图轨迹失败: ${JSON.stringify(e)}`);
    }
  }

  // 启动位置监听
  startLocationListener() {
    if (this.locationListener !== 0) {
      return;
    }

    try {
      // 模拟位置监听
      this.locationListener = setInterval(() => {
        if (!this.isRunning || this.isPaused) {
          return;
        }

        // 模拟位置变化
        const randomLat = (Math.random() - 0.5) * 0.0001;
        const randomLng = (Math.random() - 0.5) * 0.0001;

        const newLocation: LocationInfo = {
          latitude: this.currentLocation.latitude + randomLat,
          longitude: this.currentLocation.longitude + randomLng
        };

        // 记录新的轨迹点
        const newPoint: TrackPoint = {
          latitude: newLocation.latitude,
          longitude: newLocation.longitude,
          timestamp: new Date().getTime()
        };

        // 更新当前位置
        this.currentLocation = newLocation;

        // 记录轨迹点
        this.trackPoints.push(newPoint);

        // 更新地图
        this.updateMapLocation(newLocation.latitude, newLocation.longitude);

        // 计算距离
        this.updateDistance();
      }, 3000) as number;
    } catch (error) {
      console.error(`启动位置监听失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '启动位置监听失败' };
      prompt.showToast(toastOpts);
    }
  }

  // 停止位置监听
  stopLocationListener() {
    if (this.locationListener === 0) {
      return;
    }

    try {
      clearInterval(this.locationListener);
      this.locationListener = 0;
    } catch (error) {
      console.error(`停止位置监听失败: ${JSON.stringify(error)}`);
    }
  }

  // 开始运动
  startWorkout() {
    if (!this.isMapInitialized) {
      const toastOpts: ToastOptions = { message: '地图尚未初始化，请稍后再试' };
      prompt.showToast(toastOpts);
      return;
    }

    this.isRunning = true;
    this.isPaused = false;
    this.workoutStarted = true;

    // 重置数据
    this.duration = 0;
    this.distance = 0;
    this.currentPace = 0;
    this.calories = 0;
    this.trackPoints = [];

    // 记录开始时间的轨迹点
    const startPoint: TrackPoint = {
      latitude: this.currentLocation.latitude,
      longitude: this.currentLocation.longitude,
      timestamp: new Date().getTime()
    };

    this.trackPoints.push(startPoint);

    // 启动计时器
    this.startTimer();

    // 启动位置监听
    this.startLocationListener();
  }

  // 暂停运动
  pauseWorkout() {
    this.isPaused = true;

    // 停止计时器
    this.stopTimer();
  }

  // 继续运动
  resumeWorkout() {
    this.isPaused = false;

    // 重新启动计时器
    this.startTimer();
  }

  // 结束运动
  stopWorkout(showSummary: boolean = true) {
    if (!this.workoutStarted) {
      return;
    }

    this.isRunning = false;
    this.isPaused = false;
    this.workoutStarted = false;

    // 停止计时器
    this.stopTimer();

    // 停止位置监听
    this.stopLocationListener();

    if (showSummary && this.trackPoints.length > 1) {
      // 保存运动记录
      this.saveWorkoutRecord();

      // 显示运动总结
      this.showWorkoutSummary();
    }

    // 清除地图轨迹
    this.clearMapTrack();
  }

  // 启动计时器
  startTimer() {
    if (this.timer !== 0) {
      return;
    }

    this.timer = setInterval(() => {
      if (this.isRunning && !this.isPaused) {
        this.duration += 1;

        // 更新卡路里
        this.updateCalories();

        // 更新配速
        this.updatePace();
      }
    }, 1000) as number;
  }

  // 停止计时器
  stopTimer() {
    if (this.timer === 0) {
      return;
    }

    clearInterval(this.timer);
    this.timer = 0;
  }

  // 更新距离
  updateDistance() {
    if (this.trackPoints.length < 2) {
      return;
    }

    const lastPoint = this.trackPoints[this.trackPoints.length - 1];
    const prevPoint = this.trackPoints[this.trackPoints.length - 2];

    // 计算两点之间的距离（使用球面法计算）
    const distance = this.calculateDistance(
      prevPoint.latitude, prevPoint.longitude,
      lastPoint.latitude, lastPoint.longitude
    );

    // 累加总距离（米）
    this.distance += distance;
  }

  // 更新卡路里
  updateCalories() {
    // 卡路里 = 距离(公里) × 体重(kg) × 系数
    this.calories = Math.round((this.distance / 1000) * USER_WEIGHT * CALORIE_FACTOR);
  }

  // 更新配速
  updatePace() {
    if (this.distance <= 0) {
      return;
    }

    // 配速 = 时间(秒) / 距离(千米) = 秒/千米
    this.currentPace = this.duration / (this.distance / 1000);
  }

  // 计算两点之间的距离（球面距离，单位：米）
  calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371000; // 地球半径，单位米
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(this.deg2rad(lat1)) * Math.cos(this.deg2rad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // 角度转弧度
  deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }

  // 格式化时间 (秒 -> HH:MM:SS)
  formatTime(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor((seconds % 3600) / 60);
    const s = Math.floor(seconds % 60);

    return [
      h.toString().padStart(2, '0'),
      m.toString().padStart(2, '0'),
      s.toString().padStart(2, '0')
    ].join(':');
  }

  // 格式化距离 (米 -> 公里，保留2位小数)
  formatDistance(meters: number): string {
    return (meters / 1000).toFixed(2);
  }

  // 格式化配速 (秒/公里 -> MM'SS"/km)
  formatPace(secondsPerKm: number): string {
    if (!isFinite(secondsPerKm) || secondsPerKm <= 0) {
      return "0'00\"/km";
    }

    const minutes = Math.floor(secondsPerKm / 60);
    const seconds = Math.floor(secondsPerKm % 60);

    return `${minutes}'${seconds.toString().padStart(2, '0')}\"/km`;
  }

  // 保存运动记录
  async saveWorkoutRecord() {
    // 如果存储不可用，显示提示并退出
    if (!this.storageAvailable || !this.storagePreferences || this.trackPoints.length < 2) {
      if (!this.storageAvailable) {
        const toastOpts: ToastOptions = { message: '存储不可用，无法保存记录' };
        prompt.showToast(toastOpts);
      }
      return;
    }

    try {
      // 创建运动记录
      const record: WorkoutRecord = {
        startTime: this.trackPoints[0].timestamp,
        endTime: this.trackPoints[this.trackPoints.length - 1].timestamp,
        duration: this.duration,
        distance: this.distance,
        averagePace: this.currentPace,
        calories: this.calories,
        trackPoints: this.trackPoints
      };

      // 获取已有记录
      const recordsStr = await this.storagePreferences.get('records', '[]');
      const records: WorkoutRecord[] = JSON.parse(recordsStr as string);

      // 添加新记录
      records.push(record);

      // 保存记录
      await this.storagePreferences.put('records', JSON.stringify(records));
      await this.storagePreferences.flush();

      console.info('保存运动记录成功');
    } catch (error) {
      console.error(`保存运动记录失败: ${JSON.stringify(error)}`);
      const toastOpts: ToastOptions = { message: '保存运动记录失败' };
      prompt.showToast(toastOpts);
    }
  }

  // 显示运动总结
  showWorkoutSummary() {
    const alertOptions = new AlertOptions(
      '运动总结',
      `运动时间: ${this.formatTime(this.duration)}\n距离: ${this.formatDistance(this.distance)}公里\n配速: ${this.formatPace(this.currentPace)}\n卡路里: ${this.calories}kcal`,
      '确定',
      () => {
        console.info('运动总结确认');
      },
      () => {
        console.info('运动总结取消');
      }
    );

    try {
      AlertDialog.show(alertOptions);
    } catch (e) {
      console.error(`显示运动总结失败: ${JSON.stringify(e)}`);
      const toastOpts: ToastOptions = { message: '运动完成！' };
      prompt.showToast(toastOpts);
    }
  }

  build() {
    Scroll() {
      Stack() {
        // 地图容器
        Web({ src: '', controller: this.mapWebView })
          .width('100%')
          .height('100%')
          .onPageBegin(() => {
            // 地图页面开始加载
            console.info('地图页面开始加载');
          })
          .onPageEnd(() => {
            // 地图页面加载完成
            console.info('地图页面加载完成');
          })

        // 运动数据面板（半透明）
        Column() {
          // 数据面板
          Column() {
            // 运动时间
            Row() {
              Text("运动时间")
                .fontSize(14)
                .fontColor('#FFFFFF')

              Text(this.formatTime(this.duration))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 8, bottom: 8 })

            // 分隔线
            Divider()
              .color('#FFFFFF66')
              .width('100%')
              .margin({ top: 4, bottom: 4 })

            // 距离与配速
            Row() {
              Column() {
                Text("距离")
                  .fontSize(14)
                  .fontColor('#FFFFFF')

                Text(`${this.formatDistance(this.distance)}公里`)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column() {
                Text("实时配速")
                  .fontSize(14)
                  .fontColor('#FFFFFF')

                Text(this.formatPace(this.currentPace))
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
              }
              .alignItems(HorizontalAlign.End)
              .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 8, bottom: 8 })

            // 分隔线
            Divider()
              .color('#FFFFFF66')
              .width('100%')
              .margin({ top: 4, bottom: 4 })

            // 卡路里
            Row() {
              Text("卡路里")
                .fontSize(14)
                .fontColor('#FFFFFF')

              Text(`${this.calories} kcal`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ left: 8 })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .padding({ top: 8, bottom: 8 })
          }
          .width('90%')
          .padding(16)
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(16)
        }
        .width('100%')
        .padding({ top: 48 })
        .zIndex(100)

        // 控制按钮（底部）
        Column() {
          // 控制按钮
          Row() {
            // 未开始运动时显示开始按钮
            if (!this.workoutStarted) {
              Button("开始运动")
                .width('80%')
                .height(50)
                .fontSize(18)
                .backgroundColor('#007DFF')
                .onClick(() => this.startWorkout())
            } else {
              // 运行中状态显示暂停和结束按钮
              Button(this.isPaused ? "继续" : "暂停")
                .width('40%')
                .height(50)
                .fontSize(18)
                .backgroundColor(this.isPaused ? '#32CD32' : '#FFA500')
                .onClick(() => {
                  if (this.isPaused) {
                    this.resumeWorkout();
                  } else {
                    this.pauseWorkout();
                  }
                })

              Button("结束")
                .width('40%')
                .height(50)
                .fontSize(18)
                .backgroundColor('#FF4D4F')
                .onClick(() => this.stopWorkout())
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ left: 16, right: 16, bottom: 16 })
        }
        .width('100%')
        .position({ y: '90%' })
        .zIndex(100)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#F0F2F5')
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Auto)
    .edgeEffect(EdgeEffect.Spring)
  }
}
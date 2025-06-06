import { AppTheme } from '../../common/constants/AppTheme';

@Component
export struct KeepProgressBar {
  value: number = 0; // 当前值 (0-100)
  total: number = 100; // 总值
  height: number = 8; // 进度条高度
  showText: boolean = false; // 是否显示文本
  textPosition: 'left' | 'right' | 'top' = 'right'; // 文本位置
  formatText: (value: number, total: number) => string = (value, total) => `${Math.round((value / total) * 100)}%`; // 格式化文本
  color: string = AppTheme.PRIMARY_COLOR;
  backgroundColor: string = '#EEEEEE';
  
  build() {
    Column() {
      // 文本显示在进度条上方
      if (this.showText && this.textPosition === 'top') {
        Row() {
          Text(this.formatText(this.value, this.total))
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
        }
        .width('100%')
        .justifyContent(FlexAlign.FlexEnd)
        .margin({ bottom: 4 })
      }
      
      Row() {
        // 文本显示在进度条左侧
        if (this.showText && this.textPosition === 'left') {
          Text(this.formatText(this.value, this.total))
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .margin({ right: 8 })
        }
        
        // 进度条
        Stack({ alignContent: Alignment.Start }) {
          // 背景
          Row()
            .width('100%')
            .height(this.height)
            .backgroundColor(this.backgroundColor)
            .borderRadius(this.height / 2)
          
          // 进度
          Row()
            .width(`${Math.min(Math.max((this.value / this.total) * 100, 0), 100)}%`)
            .height(this.height)
            .backgroundColor(this.color)
            .borderRadius(this.height / 2)
            .animation({
              duration: 300,
              curve: Curve.EaseOut
            })
        }
        .width('100%')
        .height(this.height)
        
        // 文本显示在进度条右侧
        if (this.showText && this.textPosition === 'right') {
          Text(this.formatText(this.value, this.total))
            .fontSize(14)
            .fontColor(AppTheme.TEXT_SECONDARY)
            .margin({ left: 8 })
        }
      }
      .width('100%')
    }
  }
} 
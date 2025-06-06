import { Course } from '../../model/TrainingModels';
import { AppTheme } from '../../common/constants/AppTheme';

@Component
export struct CourseCard {
  course!: Course;
  onCardClick?: () => void;
  onStartClick?: () => void;
  
  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 背景图
      Image(this.course.coverImage)
        .width('100%')
        .height('100%')
        .borderRadius(12)
        .objectFit(ImageFit.Cover)
      
      // 暗色渐变蒙版
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(12)
        .linearGradient({
          angle: 90,
          colors: [['rgba(0,0,0,0.1)', 0.0], ['rgba(0,0,0,0.7)', 1.0]]
        })
      
      // 内容区域
      Column() {
        // 课程信息
        Column({ space: 4 }) {
          // 课程标题
          Text(this.course.title)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          // 教练信息
          Row({ space: 4 }) {
            Text(this.course.coachName)
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.9)')
            
            Text('·')
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.7)')
            
            Text(`${this.course.participantsCount}人参与`)
              .fontSize(12)
              .fontColor('rgba(255, 255, 255, 0.7)')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        
        // 标签区域
        Row({ space: 6 }) {
          // 难度标签
          Text(this.course.getLevelText())
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor(this.course.getLevelColor())
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          
          // 时长标签
          Text(this.course.getFormattedDuration())
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          
          // 卡路里标签
          Text(`${this.course.calories}千卡`)
            .fontSize(10)
            .fontColor(Color.White)
            .backgroundColor('rgba(255, 255, 255, 0.2)')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        }
        .margin({ top: 8 })
        
        // 开始训练按钮
        if (this.onStartClick) {
          Button() {
            Text('开始训练')
              .fontSize(12)
              .fontColor(Color.White)
          }
          .width(100)
          .height(32)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .borderRadius(16)
          .margin({ top: 8 })
          .onClick(() => {
            if (this.onStartClick) {
              this.onStartClick();
            }
          })
        }
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height('120vp')
    .borderRadius(12)
    .onClick(() => {
      if (this.onCardClick) {
        this.onCardClick();
      }
    })
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.1)',
      offsetX: 0,
      offsetY: 2
    })
  }
} 
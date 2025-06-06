import { AppTheme } from '../../common/constants/AppTheme';

@Component
export struct KeepCard {
  title: string = '';
  subtitle: string = '';
  showHeader: boolean = true;
  showActions: boolean = false;
  rightText: string = '';
  onRightTextClick: () => void = () => {};
  
  @BuilderParam content: () => void = () => {};
  @BuilderParam actions: () => void = () => {};
  
  build() {
    Column() {
      if(this.showHeader) {
        Row() {
          Column() {
            if(this.title) {
              Text(this.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppTheme.TEXT_PRIMARY)
            }
            
            if(this.subtitle) {
              Text(this.subtitle)
                .fontSize(14)
                .fontColor(AppTheme.TEXT_SECONDARY)
                .margin({top: 4})
            }
          }
          .alignItems(HorizontalAlign.Start)
          
          Blank()
            .layoutWeight(1)
          
          if(this.rightText) {
            Text(this.rightText)
              .fontSize(14)
              .fontColor(AppTheme.PRIMARY_COLOR)
              .onClick(() => this.onRightTextClick())
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({top: 16, bottom: 16, left: 16, right: 16})
        
        // 如果有标题和内容，添加分隔线
        Divider()
          .opacity(0.1)
          .color('#000000')
          .margin({left: 16, right: 16})
          .visibility(this.content ? Visibility.Visible : Visibility.None)
      }
      
      // 卡片内容
      Column() {
        this.content()
      }
      .width('100%')
      .padding({top: 16, bottom: 16, left: 16, right: 16})
      
      // 卡片底部操作区
      if(this.showActions) {
        Divider()
          .opacity(0.1)
          .color('#000000')
          .margin({left: 16, right: 16})
        
        Row() {
          this.actions()
        }
        .width('100%')
        .padding({top: 12, bottom: 12, left: 16, right: 16})
        .justifyContent(FlexAlign.SpaceAround)
      }
    }
    .width('100%')
    .backgroundColor(AppTheme.BACKGROUND_COLOR)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: 'rgba(0, 0, 0, 0.05)',
      offsetX: 0,
      offsetY: 2
    })
  }
} 
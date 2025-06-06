import { AppTheme } from '../../common/constants/AppTheme';

@Component
export struct KeepButton {
  text: string = '按钮';
  type: 'primary' | 'secondary' | 'text' = 'primary';
  sizeType: 'large' | 'medium' | 'small' = 'medium';
  disabled: boolean = false;
  buttonWidth?: Length;
  buttonHeight?: Length;
  onButtonClick?: () => void;
  
  build() {
    Button({ type: ButtonType.Normal }) {
      Text(this.text)
        .fontSize(this.getFontSize())
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getFontColor())
    }
    .width(this.buttonWidth ? this.buttonWidth : this.getWidth())
    .height(this.buttonHeight ? this.buttonHeight : this.getHeight())
    .backgroundColor(this.getBackgroundColor())
    .borderRadius(this.getBorderRadius())
    .opacity(this.disabled ? 0.6 : 1)
    .enabled(!this.disabled)
    .onClick(() => {
      if (this.onButtonClick) {
        this.onButtonClick();
      }
    })
    .animation({
      duration: AppTheme.ANIMATION_DURATION_FAST,
      curve: Curve.EaseOut
    })
  }
  
  private getWidth(): Length {
    if (this.type === 'text') return 'auto';
    return this.sizeType === 'large' ? '100%' : this.sizeType === 'medium' ? 200 : 120;
  }
  
  private getHeight(): Length {
    return this.sizeType === 'large' ? 50 : this.sizeType === 'medium' ? 44 : 36;
  }
  
  private getFontSize(): number {
    return this.sizeType === 'large' ? 18 : this.sizeType === 'medium' ? 16 : 14;
  }
  
  private getBorderRadius(): number {
    return this.sizeType === 'large' ? 25 : this.sizeType === 'medium' ? 22 : 18;
  }
  
  private getBackgroundColor(): ResourceColor {
    if (this.type === 'primary') return AppTheme.PRIMARY_COLOR;
    if (this.type === 'secondary') return '#FFFFFF';
    return 'transparent'; // 文本按钮
  }
  
  private getFontColor(): ResourceColor {
    if (this.type === 'primary') return '#FFFFFF';
    return AppTheme.PRIMARY_COLOR; // 次要按钮和文本按钮字体颜色
  }
} 
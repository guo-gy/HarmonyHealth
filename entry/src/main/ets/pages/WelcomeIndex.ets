import UserPrivacyDialog from '../dialog/UserPrivacyDialog'
import { common } from '@kit.AbilityKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct WelcomeIndex {
  dialogController: CustomDialogController = new CustomDialogController({
    builder:UserPrivacyDialog({
      confirm : () => {this.dialog_confirm()},
      cancel: () => {this.dialog_cancel()},
    })
  })

  dialog_confirm(){
    this.jumpToMain()
  }

  dialog_cancel(){
    this.exit_app()
  }

  aboutToAppear(){
    this.dialogController.open()
  }

  exit_app(){
    (getContext(this) as common.UIAbilityContext)?.terminateSelf();
  }
  jumpToMain(){
    setTimeout(()=>{
      router.pushUrl({
        url: 'pages/Home',
      });
      10000;
    })
  }
  build() {
    Column(){
      Image($r('app.media.logo'))
        .width(100)
        .height(100)
        .margin({top:100})
      Text('欢迎来到智能健康助手')
        .fontSize(30)
        .fontColor('#182431')
        .fontWeight(700)
        .letterSpacing(0.1)
        .opacity(0.8)
        .margin({top:20,left:20})
    }
    .margin({top:-50})
    .width('100%')
    .height('150%')
    .backgroundImage($r('app.media.WelcomeBg'))
    .backgroundImageSize({height:'100%',width:'100%'})
    .backgroundImagePosition({x:0,y:0})
  }
}
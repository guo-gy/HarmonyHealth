@Entry
@Component
struct DatePickerDialogExample {
  @State selectTime: Date = new Date('2023-12-25T08:30:00');
  build() {
    Column() {
      Button('showDatePickerDialog')
        .margin(30)
        .onClick(() => {
          this.getUIContext().showDatePickerDialog({
            start: new Date("2000-1-1"),
            end: new Date("2100-12-31"),
            selected: this.selectTime,
            textStyle: { color: '#2787d9', font: { size: '14fp', weight: FontWeight.Normal } },
            selectedTextStyle: { color: '#004aaf', font: { size: '18fp', weight: FontWeight.Regular } },
            acceptButtonStyle: {
              fontColor: '#2787d9',
              fontSize: '16fp',
              backgroundColor: '#f7f7f7',
              borderRadius: 10
            },
            cancelButtonStyle: {
              fontColor: Color.Red,
              fontSize: '16fp',
              backgroundColor: '#f7f7f7',
              borderRadius: 10
            }
          })
        })
    }.width('100%').margin({ top: 5 })
  }
}
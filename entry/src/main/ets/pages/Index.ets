@Entry
@Component
struct Index {
  @State startYear: number = 2001
  confirm?: (year: number, month: number) => void
  cancel?: () => void
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogContent({
      startYear: 2001,
      confirm: (year: number, month: number) => {
        this.confirm?.(year, month)
        console.info("===========>回调 Year = " + year + " Month = " + month)
      },
      cancel: () => {
        this.cancel?.()
        console.info("===========> 取消")
      }
    }),
    cancel: this.onCancel,
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason == DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss()
      }
      if (dismissDialogAction.reason == DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss()
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 20,
    width: 300,
    height: 350,
    borderWidth: 1,
    borderStyle: BorderStyle.Dashed, //使用borderStyle属性，需要和borderWidth属性一起使用
    borderColor: Color.Blue, //使用borderColor属性，需要和borderWidth属性一起使用
    backgroundColor: Color.White,
    shadow: ({
      radius: 20,
      color: Color.Grey,
      offsetX: 50,
      offsetY: 0
    }),
  })

  // 在自定义组件即将析构销毁时将dialogController置空
  aboutToDisappear() {
    console.info('===========> 组件即将销毁')
    this.dialogController = null // 将dialogController置空
  }

  onCancel() {
    this.cancel?.()
    console.info('===========> Click the callback in the blank area')
  }

  build() {
    Column() {
      Button('click me')
        .onClick(() => {
          if (this.dialogController != null) {
            this.dialogController.open()
          }
        })
    }
    .width('100%')
    .margin({ top: 5 })
  }
}

@CustomDialog
struct CustomDialogContent {
  controller?: CustomDialogController
  @State startYear: number = 2000
  @State curYear: number = 2024
  @State curMonth: number = 8
  @State selectedYear: number = 0
  @State selectedMonth: number = 0
  @State title: string = '2024年8月'
  @State generateYearMonth: TextCascadePickerRangeContent [] = []
  cancel?: () => void
  confirm?: (year: number, month: number) => void

  generateYearMonthRange(startYear: number, endYear: number): TextCascadePickerRangeContent[] {
    const range: TextCascadePickerRangeContent[] = [];
    for (let year = startYear; year <= endYear; year++) {
      const months: TextCascadePickerRangeContent[] = [];
      for (let month = 1; month <= 12; month++) {
        months.push({
          text: `${month.toString().padStart(2, '0')}月` // 确保月份是两位数
        });
      }
      // 只有当月份数组不为空时，才添加到range中
      if (months.length > 0) {
        range.push({
          text: `${year}年`, // 使用年份作为文本
          children: months // 只有当月份不为空时，才设置children属性
        });
      }
    }
    return range; // 返回一维数组
  }

  aboutToAppear(): void {
    const date: Date = new Date()
    this.curYear = date.getUTCFullYear()
    this.curMonth = date.getUTCMonth() + 1
    console.info("===========>curYear = " + this.curYear + " curMonth = " + this.curMonth)
    this.generateYearMonth = this.generateYearMonthRange(this.startYear, this.curYear)
    this.title = this.curYear + "年" + this.curMonth + "月"
    this.selectedYear = this.curYear
    this.selectedMonth = this.curMonth
  }

  build() {
    Column() {
      Text(this.title).fontSize(20).fontWeight(FontWeight.Bold).margin({ top: 20 })
      TextPicker({ range: this.generateYearMonth })
        .margin({ top: 20 })
        .selectedIndex([this.curYear - this.startYear, this.curMonth - 1])
        .onChange((value: string | string[], index: number | number[]) => {
          console.info("===========>" + value[0] + value[1])
          //更新title
          this.title = value[0] + value[1]
          //更新选中时间
          console.info("===========> index = " + index)
          this.updateDate(index)
        })
      Row() {
        Button("取消").backgroundColor(Color.Gray).width(100).onClick(() => {
          //todo:关闭dialog
          this.cancel?.()
          this.controller?.close()
        })
        Blank().width(30)
        Button("确定").width(100).onClick(() => {
          //todo:回调结果,关闭dialog
          this.confirm?.(this.selectedYear, this.selectedMonth)
          this.controller?.close()
        })
      }.margin({ top: 20 })
    }
    .height('100%')
    .width('100%')
    .padding({ left: 20, right: 20 })
  }

  updateDate(index: number | number[]) {
    const array = index as number[]
    if (array.length == 2) {
      this.selectedYear = this.startYear + array[0]
      this.selectedMonth = array[1] + 1
      console.info("===========> selectedYear = " + this.selectedYear + " selectedMonth = " + this.selectedMonth)
    }
  }
}
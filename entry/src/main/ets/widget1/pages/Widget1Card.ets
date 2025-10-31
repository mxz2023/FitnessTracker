const localStorage = new LocalStorage()

@Entry(localStorage)
@Component
struct Widget1Card {
  @LocalStorageProp("title")
  readonly title: string = '坚持记录';

  @LocalStorageProp("dimension")
  readonly dimension: string = '1';

  /*
   * The action type.
   */
  readonly actionType: string = 'router';
  /*
   * The ability name.
   */
  readonly abilityName: string = 'EntryAbility';
  /*
   * The message.
   */
  readonly message: string = 'add detail';
  /*
   * The width percentage setting.
   */
  readonly fullWidthPercent: string = '100%';
  /*
   * The height percentage setting.
   */
  readonly fullHeightPercent: string = '100%';

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        message: this.message
      }
    }) {
      RelativeContainer() {
        if (this.dimension == '1') {
          Row({space: $r('app.integer.view_space')}) {
            Image($r('app.media.bgImg')).height('100%').aspectRatio(1)
            Text(this.title)
              .fontSize($r('app.float.font_size_medium'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        } else {
          Column() {
            Image($r('app.media.bgImg')).width('60%').aspectRatio(1)
            Text(this.title)
              .fontSize($r('app.float.font_size_medium'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font'))
            Text('健康需要去关注')
              .fontSize($r('app.float.font_size_normal'))
              .fontWeight(FontWeight.Normal)
              .fontColor($r('app.color.text_999'))
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.Center)
        }
      }
      .padding($r('app.integer.view_space'))
      .width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .backgroundColor($r('sys.color.comp_background_primary'))
    }
  }
}
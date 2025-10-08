/**
 * 基本信息输入（Figma 48_31 对齐实现）
 * 灰背景(参考 310x621)、居中白色卡片(265x345, 圆角5)、底部绿色胶囊按钮(224x28)
 */
import { MButton } from "../../commonui/MButton";
import { MLable } from "../../commonui/MLable";
import { MRadio } from "../../commonui/MRadio";
import { MTextInput } from "../../commonui/MTextInput";
import { formatDate } from "../../utils/HealthUtils";

interface BasicInfoFormData {
  nickname: string;
  gender: string;
  birthTimestamp: number;
  heightCm: number;
}

@Preview
@ComponentV2
export struct BaseInputView {
  // 本地状态
  @Local private nickname: string = '';
  @Local private gender: string = '未知'; // 备选：未知/男/女
  @Local private birthDate: Date = new Date(1990, 0, 1);
  @Local private heightCm: number = 0;
  @Event onSubmitBlock: (data: BasicInfoFormData) => void = (data: BasicInfoFormData) => {
  };

  aboutToAppear(): void {

  }

  private async loadData() {

  }

  private async saveData() {
    this.onSubmitBlock({
      nickname: this.nickname?.trim() ?? '',
      gender: this.gender,
      birthTimestamp: this.birthDate.getTime(),
      heightCm: Number(this.heightCm) || 0
    });
  }

  build() {
    Column({ space: $r('app.integer.view_space') }) {
      Column({ space: $r('app.integer.view_content_space') }) {
        // 昵称
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '昵称:' })

          MTextInput({
            text: this.nickname,
            placeholder: '请输入昵称',
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (v: string) => {
              this.nickname = v;
            }
          }).layoutWeight(1)
        }

        // 性别
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '性别:' })

          Row({ space: $r('app.integer.view_space') }) {
            MRadio({
              titles: "男",
              groupName: "genderGroup"
            })
            MRadio({
              titles: "女",
              groupName: "genderGroup"
            })
          }.layoutWeight(1)
        }

        // 出生日期
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '出生日期:' })

          MLable({ lable: formatDate(this.birthDate.getTime(), 'YYYY-MM-DD') })
            .layoutWeight(1)
        }

        // 身高（cm）
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '身高:' })

          MTextInput({
            text: this.nickname,
            placeholder: '请输入身高（cm）',
            type: InputType.NUMBER_DECIMAL,
            onChangeBlock: (value: string) => {
              let res = value;
              if (!/^\d*\.?\d*$/.test(res)) {
                return;
              }
              const parts = res.split('.');
              if (parts.length > 1 && parts[1].length > 2) {
                res = `${parts[0]}.${parts[1].substring(0, 2)}`;
              }
              this.heightCm = Number(res) || 0;
            }
          }).layoutWeight(1)

          MLable({ lable: 'cm' })
        }
      }

      // 底部居中按钮
      Row() {
        MButton({
          text: '保存记录',
          bgColor: $r('app.color.green'),
          onClickBlock: () => {
            this.saveData();
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .onAppear(() => {
      this.loadData();
    })
    .width('100%')
    .height('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
    .alignSelf(ItemAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
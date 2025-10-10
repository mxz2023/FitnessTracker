/**
 * 基本信息输入（Figma 48_31 对齐实现）
 * 灰背景(参考 310x621)、居中白色卡片(265x345, 圆角5)、底部绿色胶囊按钮(224x28)
 */
import { MButton } from "../../components/MButton";
import { MLable } from "../../components/MLable";
import { MRadio } from "../../components/MRadio";
import { MTextInput } from "../../components/MTextInput";
import { UserDataModel, Gender } from "../../models/UserDataModel";


@Preview
@ComponentV2
export struct BaseInputView {
  @Param @Require initData: UserDataModel
  @Event onSubmit: (data?: UserDataModel) => void
  // 本地状态
  @Local private nickname: string = '';
  @Local private gender: Gender = Gender.UNKNOWN; // 备选：未知/男/女
  @Local private year: number = 1983
  @Local private heightCm: number = 0;

  aboutToAppear(): void {
    this.nickname = this.initData.nickname
    this.gender = this.initData.gender
    this.heightCm = this.initData.heightCm
    const year = new Date().getFullYear()
    if (this.initData.age > 0) {
      this.year = year - this.initData.age
    }
  }

  buildYears(): string[] {
    const startYear: number = 1983;
    const currentYear: number = new Date().getFullYear();
    const years: string[] = [];
    for (let y: number = startYear; y <= currentYear; y++) {
      years.push(`${y}年`);
    }
    return years;
  }

  private async saveData() {
    this.onSubmit({
      nickname: this.nickname?.trim() ?? '',
      gender: this.gender,
      age: (new Date().getFullYear() - this.year),
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
            type: InputType.USER_NAME,
            text: this.nickname,
            onText: (v: string) => {
              this.nickname = v;
            },
            placeholder: '请输入昵称',
          }).layoutWeight(1)
        }

        // 性别
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '性别:' })

          Row({ space: $r('app.integer.view_space') }) {
            MRadio({
              titles: "男",
              isChecked: this.gender == Gender.MALE,
              groupName: "genderGroup",
              onChange: (isCheck: boolean) => {
                if (isCheck) {
                  this.gender = Gender.MALE
                }
              }
            })
            MRadio({
              titles: "女",
              isChecked: this.gender == Gender.FEMALE,
              groupName: "genderGroup",
              onChange: (isCheck: boolean) => {
                if (isCheck) {
                  this.gender = Gender.FEMALE
                }
              }
            })
          }.layoutWeight(1)
        }

        // 出生日期
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '出生:' })

          MLable({ lable: `${this.year}年` })
            .layoutWeight(1)
        }.onClick(() => {
          // 显示日期选择器设置日期
          this.getUIContext().showTextPickerDialog({
            range: this.buildYears(),
            selected: this.buildYears().length,
            defaultPickerItemHeight: 40,
            onAccept: (value: TextPickerResult) => {
              this.year = Number(value.value.slice(0, -1));
            },
            onCancel: () => {
              console.info("TextPickerDialog:onCancel()");
            },
            onChange: (value: TextPickerResult) => {
              console.info("TextPickerDialog:onChange()" + JSON.stringify(value));
            },
            onScrollStop: (value: TextPickerResult) => {
              console.info("TextPickerDialog:onScrollStop()" + JSON.stringify(value));
            },
            onDidAppear: () => {
              console.info("TextPickerDialog:onDidAppear()");
            },
            onDidDisappear: () => {
              console.info("TextPickerDialog:onDidDisappear()");
            },
            onWillAppear: () => {
              console.info("TextPickerDialog:onWillAppear()");
            },
            onWillDisappear: () => {
              console.info("TextPickerDialog:onWillDisappear()");
            }
          });
        })

        // 身高（cm）
        Row({ space: $r('app.integer.view_content_space') }) {
          MLable({ lable: '身高:' })

          MTextInput({
            type: InputType.NUMBER_DECIMAL,
            text: `${this.heightCm}`,
            onText: (value: string) => {
              let res = value;
              if (!/^\d*\.?\d*$/.test(res)) {
                return;
              }
              const parts = res.split('.');
              if (parts.length > 1 && parts[1].length > 2) {
                res = `${parts[0]}.${parts[1].substring(0, 2)}`;
              }
              this.heightCm = Number(res) || 0;
            },
            placeholder: '请输入身高（cm）',
          }).layoutWeight(1)

          MLable({ lable: 'cm' })
        }
      }

      // 底部
      Row({ space: $r('app.integer.view_space') }) {
        MButton({
          text: '保存记录',
          bgColor: $r('app.color.green'),
          onClickBlock: () => {
            this.saveData();
          }
        }).layoutWeight(1)

        MButton({
          text: '取消',
          bgColor: $r('app.color.gray'),
          onClickBlock: () => {
            this.onSubmit();
          }
        }).layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor('view_background_color')
    .borderRadius($r('app.integer.view_radius'))
    .alignSelf(ItemAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
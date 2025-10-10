/**
 * 健康数据概览页面
 * 基于 Figma 设计实现的健康指标卡片式布局
 */
import { KeyboardAvoidMode } from '@kit.ArkUI';

import {
  HealthStatus,
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData,
  MeasurementType,
  HealthCardData,
  HealthCardDataType
} from '../models/HealthDataModel';
import { HealthStatusIndicator } from './HealthStatusIndicator';
import {
  formatDate,
  evaluateWeightStatus,
  evaluateBloodPressureStatus,
  evaluateBloodSugarStatus,
  evaluateUricAcidStatus,
  evaluateBloodLipidStatus,
  getHealthStatusText,
  getHealthStatusColor,
} from '../utils/HealthUtils';
import { BaseInputView } from './subs/BaseInputView';
import { WeightInputView } from './subs/WeightInputView';
import { BloodPressureInputView } from './subs/BloodPressureInputView';
import { BloodSugarInputView } from './subs/BloodSugarInputView';
import { UricAcidInputView } from './subs/UricAcidInputView';
import { BloodLipidInputView } from './subs/BloodLipidInputView';
import { HealthValueDashBoard } from './HealthValueDashBoard';
import { UserDataModel, Gender } from '../models/UserDataModel';
import { UserViewModel } from '../viewmodels/UserViewModel';
import { showToast } from '../utils/ToastUtils';
import { MLable } from '../components/MLable';
import { WeightViewModel } from '../viewmodels/WeightViewModel';


@Preview
@ComponentV2
export struct HealthOverview {
  @Local private nickName: string = ""
  @Local private nAge: number = 0; // 年龄
  @Local private nGender: Gender = Gender.UNKNOWN;
  @Local private nHeight: number = 0; // 身高，单位:cm
  @Local private nWeight: number = 0; // 体重，单位:g
  @Local private nBloodSugar: number = 0; // 血糖，单位:mmol/L
  @Local private nBloodPressureSystolic: number = 0; // 收缩压
  @Local private nBloodPressureDiastolic: number = 0; // 舒张压
  @Local private nUricAcid: number = 0; // 尿酸，单位:μmol/L
  @Local private nTotalCholesterol: number = 0; // 总胆固醇，单位:mmol/L
  @Local private showType: HealthCardDataType = HealthCardDataType.Unknown;
  private userViewModel?: UserViewModel
  private weightViewModel?: WeightViewModel

  async aboutToAppear(): Promise<void> {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);

    const context = this.getUIContext().getHostContext()
    if (!context) {
      return
    }

    // 用户信息
    this.userViewModel = new UserViewModel()
    await this.userViewModel.initDataService(context)
    await this.userViewModel.loadUserData()
    const userData = this.userViewModel.getUserData()
    if (userData) {
      this.nickName = userData.nickname
      this.nAge = userData.age
      this.nGender = userData.gender
      this.nHeight = userData.heightCm
    }

    // 体重信息
    this.weightViewModel = new WeightViewModel(this.nWeight, this.nHeight)
    await this.weightViewModel.initDataService(context)
    const weightData = await this.weightViewModel.getWeightData()
    if (weightData) {
      this.nWeight = (weightData as WeightData).value
    }
  }

  // 将数值转换为显示字符串，0 则显示 N/A
  private toDisplay(value: number): string {
    return value !== 0 ? `${value}` : 'N/A';
  }

  // 判断数值是否有效（非 0）
  private isValid(value: number): boolean {
    return value !== 0;
  }

  // 血压专用显示与校验
  private isValidBP(systolic: number, diastolic: number): boolean {
    return systolic !== 0 && diastolic !== 0;
  }

  private toDisplayBP(systolic: number, diastolic: number): string {
    return this.isValidBP(systolic, diastolic) ? `${systolic}/${diastolic}` : 'N/A';
  }

  // 获取健康卡片数据
  private getHealthCardData(): HealthCardData[] {
    const currentDate = formatDate(Date.now(), 'MM-DD');
    return [
      {
        title: '体重',
        type: HealthCardDataType.WeightInfo,
        value: this.toDisplay(this.nWeight),
        unit: 'kg',
        status: this.isValid(this.nWeight) ? evaluateWeightStatus(this.nWeight, this.nHeight / 100) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血糖',
        type: HealthCardDataType.BloodSugarInfo,
        value: this.toDisplay(this.nBloodSugar),
        unit: 'mmol/L',
        status: this.isValid(this.nBloodSugar) ? evaluateBloodSugarStatus(this.nBloodSugar, MeasurementType.FASTING) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血脂',
        type: HealthCardDataType.BloodLipidInfo,
        value: this.toDisplay(this.nTotalCholesterol),
        unit: 'mmol/L',
        status: this.isValid(this.nTotalCholesterol) ? this.nTotalCholesterol <= 5.2 ? HealthStatus.EXCELLENT :
          this.nTotalCholesterol <= 5.7 ? HealthStatus.GOOD :
            this.nTotalCholesterol <= 6.5 ? HealthStatus.MODERATE : HealthStatus.POOR : HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '尿酸',
        type: HealthCardDataType.UricAcidInfo,
        value: this.toDisplay(this.nUricAcid),
        unit: 'μmol/L',
        status: this.isValid(this.nUricAcid) ? evaluateUricAcidStatus(this.nUricAcid, Gender.MALE) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      {
        title: '血压',
        type: HealthCardDataType.BloodPressureInfo,
        value: this.toDisplayBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic),
        unit: 'mmHg',
        status: this.isValidBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic) ?
          this.nBloodPressureSystolic <= 120 && this.nBloodPressureDiastolic <= 80 ? HealthStatus.EXCELLENT :
            this.nBloodPressureSystolic <= 130 && this.nBloodPressureDiastolic <= 85 ? HealthStatus.GOOD :
              this.nBloodPressureSystolic <= 140 && this.nBloodPressureDiastolic <= 90 ? HealthStatus.MODERATE :
                HealthStatus.POOR : HealthStatus.UNKNOWN,
        date: currentDate
      }
    ];
  }

  // 更新用户基本信息
  private updateUserInfo(data: UserDataModel) {
    this.nickName = data.nickname
    this.nHeight = data.heightCm
    this.nGender = data.gender
    this.nAge = data.age

    if (!this.userViewModel) {
      return
    }

    let res = this.userViewModel.setNickname(data.nickname)
    if (!res) {
      showToast(this.getUIContext(), "请输入正确的昵称")
      return
    }
    res = this.userViewModel.setGender(data.gender)
    if (!res) {
      showToast(this.getUIContext(), "请输选择一个性别")
      return
    }
    res = this.userViewModel.setAge(data.age)
    if (!res) {
      showToast(this.getUIContext(), "请输选择出生年份")
      return
    }
    res = this.userViewModel.setHeightCm(data.heightCm)
    if (!res) {
      showToast(this.getUIContext(), "请输输入你的身高")
      return
    }
    this.userViewModel.saveUserData().then((isOK: boolean) => {
      if (isOK) {
        this.showType = HealthCardDataType.Unknown
        showToast(this.getUIContext(), "保存数据成功")
      } else {
        showToast(this.getUIContext(), "保存数据失败")
      }
    })
  }

  // 更新体重信息
  private async updateWeight(data: WeightData) {
    this.nWeight = data.value
    if (!this.weightViewModel) {
      return
    }

    this.weightViewModel.weight = data.value
    const res = await this.weightViewModel?.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }

  }

  // 健康指标卡片组件
  @Builder
  HealthCard(cardData: HealthCardData) {
    Column() {
      // 卡片头部 - 标题和状态指示器
      Row() {
        Text(cardData.title)
          .fontSize($r('app.float.font_size_medium'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        Blank()

        HealthStatusIndicator({
          status: cardData.status,
          showText: true,
        })
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })

      // 仪表盘视图
      if (cardData.type === HealthCardDataType.WeightInfo || cardData.type === HealthCardDataType.BloodSugarInfo ||
        cardData.type === HealthCardDataType.UricAcidInfo) {
        // 单值圆形仪表
        HealthValueDashBoard({
          data: cardData
        })
      } else if (cardData.type === HealthCardDataType.BloodPressureInfo ||
        cardData.type === HealthCardDataType.BloodLipidInfo) {
        // 多值线条仪表
      } else {
        // 默认仪表
      }

      Row() {
        // 日期信息
        if (cardData.date) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.time_inerval'))
              .fontSize($r('app.float.font_size_normal'))
              .fontColor([$r('app.color.text_999')])

            Text(`${cardData.date}`)
              .fontSize($r('app.float.font_size_normal'))
              .fontColor($r('app.color.text_999'))
              .alignSelf(ItemAlign.Start)
          }
        }

        Column() {
          SymbolGlyph($r('sys.symbol.plus_circle_fill'))
            .fontSize(18)
            .fontColor([$r('app.color.red')])
        }
        .onClick(() => {
          this.showType = cardData.type
        })
        // .backgroundColor("#00FF00")
        .width(30)
        .height(30)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height(230)
    .padding($r('app.integer.view_padding'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.integer.view_radius'))
    .shadow({
      radius: $r('app.integer.view_radius'),
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
  }

  // 身高体重信息卡片
  @Builder
  BasicInfoCard() {
    Column({ space: $r('app.integer.view_content_space') }) {
      Row() {
        Text(this.nickName.length > 0 ? this.nickName : "请设置基本信息")
          .fontSize($r('app.float.font_size_large_title'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_333'))

        SymbolGlyph($r('sys.symbol.doc_plaintext_and_pencil'))
          .fontSize(24)
          .fontColor([$r('app.color.text_666')])
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })
      .alignItems(VerticalAlign.Bottom)
      .justifyContent(FlexAlign.SpaceBetween)

      Row() {
        Row() {
          Row({ space: $r('app.integer.view_space') }) {
            Row() {
              MLable({ lable: "性别:" })

              Text(`${this.nGender}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))
            }.alignItems(VerticalAlign.Bottom)

            Row() {
              MLable({ lable: "年龄:" })

              Text(`${this.nAge}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))

              if (this.isValid(this.nAge)) {
                MLable({ lable: " 岁" })
              }
            }.alignItems(VerticalAlign.Bottom)

            Row() {
              MLable({ lable: "身高:" })

              Text(`${this.nHeight}`)
                .fontSize($r('app.float.font_size_large'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_333'))

              if (this.isValid(this.nHeight)) {
                MLable({ lable: " cm" })
              }
            }.alignItems(VerticalAlign.Bottom)
          }.alignItems(VerticalAlign.Bottom)
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .layoutWeight(1)
      }
      .width('100%')
    }
    .width('100%')
    .padding($r('app.integer.view_padding'))
    .backgroundColor($r('app.color.white'))
    .borderRadius($r('app.integer.view_radius'))
    .shadow({
      radius: $r('app.integer.view_radius'),
      color: '#1a000000',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.showType = HealthCardDataType.BaseInfo
    })
  }

  build() {
    Stack() {
      Column() {
        // 滚动容器
        Scroll() {
          Column({ space: $r('app.integer.view_space') }) {
            // 基本信息卡片
            this.BasicInfoCard()

            // 健康指标网格
            Grid() {
              ForEach(this.getHealthCardData(), (cardData: HealthCardData, index: number) => {
                GridItem() {
                  this.HealthCard(cardData)
                }
              })
            }
            .width('100%')
            .layoutWeight(1)
            .columnsTemplate('1fr 1fr')
            .rowsGap($r('app.integer.view_space'))
            .columnsGap($r('app.integer.view_space'))
            .scrollBar(BarState.Off)
          }
          .height('100%')
          .padding($r('app.integer.view_padding'))
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.view_background_color'))

      // 遮罩背景半透明
      Column() {
        // 半弹层背景白色
        Column() {
          if (this.showType === HealthCardDataType.BaseInfo) {
            BaseInputView({
              initData: {
                nickname: this.nickName,
                gender: this.nGender,
                heightCm: this.nHeight,
                age: this.nAge,
              } as UserDataModel,
              onSubmit: (data?: UserDataModel) => {
                if (data) {
                  this.updateUserInfo(data)
                }
              }
            })
          } else if (this.showType === HealthCardDataType.WeightInfo) {
            WeightInputView({
              weight: this.nWeight,
              onSubmit: (data?: WeightData) => {
                if (data) {
                  this.updateWeight(data)
                }
              }
            })
          } else if (this.showType === HealthCardDataType.BloodPressureInfo) {
            BloodPressureInputView()
          } else if (this.showType === HealthCardDataType.BloodSugarInfo) {
            BloodSugarInputView()
          } else if (this.showType === HealthCardDataType.UricAcidInfo) {
            UricAcidInputView()
          } else if (this.showType === HealthCardDataType.BloodLipidInfo) {
            BloodLipidInputView()
          }
        }
        .width('100%')
        .height(300)
        .backgroundColor($r('app.color.white'))
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
      .visibility(this.showType === HealthCardDataType.Unknown ? Visibility.Hidden : Visibility.Visible)
      .backgroundColor($r('app.color.view_mask'))
    }

  }
}
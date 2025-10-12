/**
 * 健康数据概览页面
 * 基于 Figma 设计实现的健康指标卡片式布局
 */
import { KeyboardAvoidMode } from '@kit.ArkUI';

import { MLable, MStatusLable } from '../components/MLable';
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
import {
  formatDate,
  evaluateWeightStatus,
  evaluateBloodPressureStatus,
  evaluateBloodSugarStatus,
  evaluateUricAcidStatus,
  evaluateBloodLipidStatus,
  getHealthStatusText,
  getHealthStatusColor,
  getHealthStatusColors,
  getHealthStatusRang,
} from '../utils/HealthUtils';
import { BaseInputView } from './subs/BaseInputView';
import { WeightInputView } from './subs/WeightInputView';
import { BloodPressureInputView } from './subs/BloodPressureInputView';
import { BloodSugarInputView } from './subs/BloodSugarInputView';
import { UricAcidInputView } from './subs/UricAcidInputView';
import { BloodLipidInputView } from './subs/BloodLipidInputView';
import { UserDataModel, Gender } from '../models/UserDataModel';
import { UserViewModel } from '../viewmodels/UserViewModel';
import { WeightViewModel } from '../viewmodels/WeightViewModel';
import { BloodSugarViewModel } from '../viewmodels/BloodSugarViewModel';
import { BloodPressureViewModel } from '../viewmodels/BloodPressureViewModel';
import { UricAcidViewModel } from '../viewmodels/UricAcidViewModel';
import { BloodLipidViewModel } from '../viewmodels/BloodLipidViewModel';

import { TypeUtils } from '../utils/TypeUtils'
import { showToast } from '../utils/ToastUtils';
import { MDashBoard } from '../components/MDashBoard';


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
  @Local private triglycerides: number = 0;
  @Local private hdlCholesterol: number = 0;
  @Local private ldlCholesterol: number = 0;
  @Local private showType: HealthCardDataType = HealthCardDataType.Unknown;
  // ViewModel
  private userInfoVM?: UserViewModel
  private weightDataVM?: WeightViewModel
  private bloodSugarVM?: BloodSugarViewModel
  private bloodPressVM?: BloodPressureViewModel
  private uricAcidVM ?: UricAcidViewModel
  private bloodLipidVM?: BloodLipidViewModel

  async aboutToAppear(): Promise<void> {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);

    const context = this.getUIContext().getHostContext()
    if (!context) {
      return
    }

    // 用户信息
    this.userInfoVM = new UserViewModel()
    await this.userInfoVM.initDataService(context)
    await this.userInfoVM.loadUserData()
    const userData = this.userInfoVM.getUserData()
    if (userData) {
      this.nickName = userData.nickname
      this.nAge = userData.age
      this.nGender = userData.gender
      this.nHeight = userData.heightCm
    }

    // 体重信息
    this.weightDataVM = new WeightViewModel(this.nWeight, this.nHeight)
    await this.weightDataVM.initDataService(context)
    const weightData = await this.weightDataVM.getWeightData()
    if (weightData) {
      this.nWeight = (weightData as WeightData).value
    }

    // 血糖信息
    this.bloodSugarVM = new BloodSugarViewModel(this.nBloodSugar, MeasurementType.FASTING)
    await this.bloodSugarVM.initDataService(context)
    const bloodSugarData = await this.bloodSugarVM.getBloodSugarData()
    if (bloodSugarData) {
      this.nBloodSugar = (bloodSugarData as BloodSugarData).value
    }

    // 血压信息
    this.bloodPressVM = new BloodPressureViewModel(this.nBloodPressureSystolic, this.nBloodPressureDiastolic)
    await this.bloodPressVM.initDataService(context)
    const bloodPressureData = await this.bloodPressVM.getBloodPressureData()
    if (bloodPressureData) {
      this.nBloodPressureSystolic = (bloodPressureData as BloodPressureData).systolic
      this.nBloodPressureDiastolic = (bloodPressureData as BloodPressureData).diastolic
    }

    // 尿酸信息
    this.uricAcidVM = new UricAcidViewModel(this.nUricAcid, this.nGender)
    await this.uricAcidVM.initDataService(context)
    const uricAcidData = await this.uricAcidVM.getUricAcidData()
    if (uricAcidData) {
      this.nUricAcid = (uricAcidData as UricAcidData).value
    }

    // 血脂信息
    this.bloodLipidVM =
      new BloodLipidViewModel(this.nTotalCholesterol, this.triglycerides, this.hdlCholesterol, this.ldlCholesterol)
    await this.bloodLipidVM.initDataService(context)
    const bloodLipidData = await this.bloodLipidVM.getBloodLipidData()
    if (bloodLipidData) {
      this.nTotalCholesterol = (bloodLipidData as BloodLipidData).totalCholesterol
      this.triglycerides = (bloodLipidData as BloodLipidData).triglycerides
      this.hdlCholesterol = (bloodLipidData as BloodLipidData).hdlCholesterol
      this.ldlCholesterol = (bloodLipidData as BloodLipidData).ldlCholesterol
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
        title: '尿酸',
        type: HealthCardDataType.UricAcidInfo,
        value: this.toDisplay(this.nUricAcid),
        unit: 'μmol/L',
        status: this.isValid(this.nUricAcid) ? evaluateUricAcidStatus(this.nUricAcid, Gender.MALE) :
          HealthStatus.UNKNOWN,
        date: currentDate
      },
      // {
      //   title: '血压',
      //   type: HealthCardDataType.BloodPressureInfo,
      //   value: this.toDisplayBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic),
      //   unit: 'mmHg',
      //   status: this.isValidBP(this.nBloodPressureSystolic, this.nBloodPressureDiastolic) ?
      //     this.nBloodPressureSystolic <= 120 && this.nBloodPressureDiastolic <= 80 ? HealthStatus.EXCELLENT :
      //       this.nBloodPressureSystolic <= 130 && this.nBloodPressureDiastolic <= 85 ? HealthStatus.GOOD :
      //         this.nBloodPressureSystolic <= 140 && this.nBloodPressureDiastolic <= 90 ? HealthStatus.MODERATE :
      //           HealthStatus.POOR : HealthStatus.UNKNOWN,
      //   date: currentDate
      // },
      // {
      //   title: '血脂',
      //   type: HealthCardDataType.BloodLipidInfo,
      //   value: this.toDisplay(this.nTotalCholesterol),
      //   unit: 'mmol/L',
      //   status: this.isValid(this.nTotalCholesterol) ? this.nTotalCholesterol <= 5.2 ? HealthStatus.EXCELLENT :
      //     this.nTotalCholesterol <= 5.7 ? HealthStatus.GOOD :
      //       this.nTotalCholesterol <= 6.5 ? HealthStatus.MODERATE : HealthStatus.POOR : HealthStatus.UNKNOWN,
      //   date: currentDate
      // },
    ];
  }

  // 更新用户基本信息
  private updateUserInfo(data: UserDataModel) {
    this.nickName = data.nickname
    this.nHeight = data.heightCm
    this.nGender = data.gender
    this.nAge = data.age

    if (!this.userInfoVM) {
      return
    }

    let res = this.userInfoVM.setNickname(data.nickname)
    if (!res) {
      showToast(this.getUIContext(), "请输入正确的昵称")
      return
    }
    res = this.userInfoVM.setGender(data.gender)
    if (!res) {
      showToast(this.getUIContext(), "请输选择一个性别")
      return
    }
    res = this.userInfoVM.setAge(data.age)
    if (!res) {
      showToast(this.getUIContext(), "请输选择出生年份")
      return
    }
    res = this.userInfoVM.setHeightCm(data.heightCm)
    if (!res) {
      showToast(this.getUIContext(), "请输输入你的身高")
      return
    }
    this.userInfoVM.saveUserData().then((isOK: boolean) => {
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
    if (!this.weightDataVM) {
      return
    }

    this.weightDataVM.weight = data.value
    const res = await this.weightDataVM?.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }
  }

  // 更新血压信息
  private async updateBloodPressure(data: BloodPressureData) {
    this.nBloodPressureSystolic = data.systolic
    this.nBloodPressureDiastolic = data.diastolic
    if (!this.bloodPressVM) {
      return
    }
    this.bloodPressVM.systolic = data.systolic
    this.bloodPressVM.diastolic = data.diastolic
    const res = await this.bloodPressVM.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }
  }

  // 更新血糖信息
  private async updateBloodSugar(data: BloodSugarData) {
    this.nBloodSugar = data.value
    if (!this.bloodSugarVM) {
      return
    }
    this.bloodSugarVM.value = data.value
    this.bloodSugarVM.measurementType = data.measurementType
    const res = await this.bloodSugarVM.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }
  }

  // 更新尿酸信息
  private async updateUricAcid(data: UricAcidData) {
    this.nUricAcid = data.value
    if (!this.uricAcidVM) {
      return
    }
    this.uricAcidVM.value = data.value
    this.uricAcidVM.gender = data.gender
    const res = await this.uricAcidVM.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }
  }

  // 更新血脂信息
  private async updateBloodLipid(data: BloodLipidData) {
    this.nTotalCholesterol = data.totalCholesterol
    this.triglycerides = data.triglycerides
    this.hdlCholesterol = data.hdlCholesterol
    this.ldlCholesterol = data.ldlCholesterol
    if (!this.bloodLipidVM) {
      return
    }
    this.bloodLipidVM.totalCholesterol = data.totalCholesterol
    this.bloodLipidVM.triglycerides = data.triglycerides
    this.bloodLipidVM.hdlCholesterol = data.hdlCholesterol
    this.bloodLipidVM.ldlCholesterol = data.ldlCholesterol
    const res = await this.bloodLipidVM.saveData()
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

        MStatusLable({
          title: {
            text: getHealthStatusText(cardData.status),
            color: getHealthStatusColor(cardData.status)
          },
          status: true,
        })
      }
      .width('100%')
      .margin({ bottom: $r('app.integer.view_margin') })

      // 仪表盘视图
      if (cardData.type === HealthCardDataType.WeightInfo || cardData.type === HealthCardDataType.BloodSugarInfo ||
        cardData.type === HealthCardDataType.UricAcidInfo) {
        // 单值圆形仪表
        MDashBoard({
          value: Number(cardData.value),
          colors: getHealthStatusColors(cardData.type),
          range: getHealthStatusRang(cardData.type),
          title: {
            text: cardData.value,
            color: getHealthStatusColor(cardData.status)
          },
          subTitle: {
            text: cardData.unit,
            color: getHealthStatusColor(cardData.status)
          },
          note: {
            text: TypeUtils.isEmptyString(cardData.other) ? getHealthStatusText(cardData.status) : cardData.other,
            color: getHealthStatusColor(cardData.status)
          },
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
            BloodPressureInputView({
              systolicValue: this.nBloodPressureSystolic,
              diastolicValue: this.nBloodPressureDiastolic,
              onSubmit: (data?: BloodPressureData) => {
                if (data) {
                  this.updateBloodPressure(data)
                }
              }
            })
          } else if (this.showType === HealthCardDataType.BloodSugarInfo) {
            BloodSugarInputView({
              bloodSugarValue: this.nBloodSugar,
              measurementType: MeasurementType.FASTING,
              onSubmit: (data?: BloodSugarData) => {
                if (data) {
                  this.updateBloodSugar(data)
                }
              }
            })
          } else if (this.showType === HealthCardDataType.UricAcidInfo) {
            UricAcidInputView({
              inputValue: this.nUricAcid,
              gender: this.nGender,
              onSubmit: (data?: UricAcidData) => {
                if (data) {
                  this.updateUricAcid(data)
                }
              }
            })
          } else if (this.showType === HealthCardDataType.BloodLipidInfo) {
            BloodLipidInputView({
              totalCholesterol: this.nTotalCholesterol,
              triglycerides: this.triglycerides,
              hdlCholesterol: this.hdlCholesterol,
              ldlCholesterol: this.ldlCholesterol,
              onSubmit: (data?: BloodLipidData) => {
                if (data) {
                  this.updateBloodLipid(data)
                }
              }
            })
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

/**
 * 健康数据概览页面
 * 基于 Figma 设计实现的健康指标卡片式布局
 */
import { KeyboardAvoidMode } from '@kit.ArkUI';

import { BaseInputView } from './subs/BaseInputView';
import { WeightInputView } from './subs/WeightInputView';
import { BloodPressureInputView } from './subs/BloodPressureInputView';
import { BloodSugarInputView } from './subs/BloodSugarInputView';
import { UricAcidInputView } from './subs/UricAcidInputView';
import { BloodLipidInputView } from './subs/BloodLipidInputView';
import {
  WeightData,
  BloodPressureData,
  BloodSugarData,
  UricAcidData,
  BloodLipidData,
  MeasurementType,
  HealthCardData,
  HealthCardDataType
} from '../models/HealthDataModel';
import { UserDataModel } from '../models/UserDataModel';
import { UserViewModel } from '../viewmodels/UserViewModel';
import { WeightViewModel } from '../viewmodels/WeightViewModel';
import { BloodSugarViewModel } from '../viewmodels/BloodSugarViewModel';
import { BloodPressureViewModel } from '../viewmodels/BloodPressureViewModel';
import { UricAcidViewModel } from '../viewmodels/UricAcidViewModel';
import { BloodLipidViewModel } from '../viewmodels/BloodLipidViewModel';

import { HealthInfoCard } from './HealthInfoCard';
import { UserInfoCard } from './UserInfoCard';

import { showToast } from '../utils/ToastUtils';
import { getAppPathStack } from '../utils/PathStackUtils';


@Preview
@ComponentV2
export struct HealthOverview {
  @Local private showType: HealthCardDataType = HealthCardDataType.Unknown;
  @Local private isLoading: boolean = true
  @Local private columnsTemplate: string = '1fr 1fr'
  private userInfoVM?: UserViewModel
  private weightDataVM?: WeightViewModel
  private bloodSugarVM?: BloodSugarViewModel
  private bloodPressVM?: BloodPressureViewModel
  private uricAcidVM?: UricAcidViewModel
  private bloodLipidVM?: BloodLipidViewModel

  async aboutToAppear(): Promise<void> {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);

    await this.loadLastData()
  }

  /**
   * 加载数据
   */
  private async loadLastData() {
    const context = this.getUIContext().getHostContext()
    if (!context) {
      return
    }
    this.isLoading = true

    // 用户信息
    this.userInfoVM = new UserViewModel()
    await this.userInfoVM.initDataService(context)
    await this.userInfoVM.loadUserData()

    // 体重信息
    this.weightDataVM = new WeightViewModel(this.userInfoVM.heightCm)
    await this.weightDataVM.initDataService(context)
    await this.weightDataVM.getHealthData()

    // 血糖信息
    this.bloodSugarVM = new BloodSugarViewModel()
    await this.bloodSugarVM.initDataService(context)
    await this.bloodSugarVM.getHealthData()

    // 尿酸信息
    this.uricAcidVM = new UricAcidViewModel()
    await this.uricAcidVM.initDataService(context)
    await this.uricAcidVM.getHealthData()

    // 血压信息
    this.bloodPressVM = new BloodPressureViewModel()
    await this.bloodPressVM.initDataService(context)
    await this.bloodPressVM.getHealthData()

    // 血脂信息
    this.bloodLipidVM = new BloodLipidViewModel()
    await this.bloodLipidVM.initDataService(context)
    await this.bloodLipidVM.getHealthData()

    this.isLoading = false
  }

  // 获取健康卡片数据
  private getHealthCardData(): HealthCardData[] {
    if (this.userInfoVM == undefined || this.weightDataVM == undefined || this.bloodSugarVM == undefined ||
      this.uricAcidVM == undefined || this.bloodPressVM == undefined || this.bloodLipidVM == undefined) {
      return []
    }
    return [
      {
        title: '体重',
        type: HealthCardDataType.WeightInfo,
        value: this.weightDataVM.value,
        unit: 'kg',
        status: this.weightDataVM.getHealthStatus(),
        date: this.weightDataVM.dateStr,
        // other: this.weightDataVM.getHealthAdvice()
      },
      {
        title: '血糖',
        type: HealthCardDataType.BloodSugarInfo,
        value: this.bloodSugarVM.value,
        unit: 'mmol/L',
        status: this.bloodSugarVM.getHealthStatus(),
        date: this.bloodSugarVM.dateStr,
        // other: this.bloodSugarVM.getHealthAdvice()
      },
      {
        title: '尿酸',
        type: HealthCardDataType.UricAcidInfo,
        value: this.uricAcidVM.value,
        unit: 'μmol/L',
        status: this.uricAcidVM.getHealthStatus(),
        date: this.uricAcidVM.dateStr,
        // other: this.uricAcidVM.getHealthAdvice()
      },
    ];
  }

  // 更新用户基本信息
  private updateUserInfo(data: UserDataModel) {
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

        // 用户信息更新后，更新一下体重VM中的身高
        if (this.weightDataVM && this.userInfoVM) {
          this.weightDataVM.height = this.userInfoVM.heightCm
        }
        showToast(this.getUIContext(), "保存数据成功")
      } else {
        showToast(this.getUIContext(), "保存数据失败")
      }
    })
  }

  // 更新体重信息
  private async updateWeight(data: WeightData) {
    if (!this.weightDataVM) {
      return
    }

    this.weightDataVM.value = data.value
    const res = await this.weightDataVM.saveData()
    if (res) {
      this.showType = HealthCardDataType.Unknown
      showToast(this.getUIContext(), "保存数据成功")
    } else {
      showToast(this.getUIContext(), "保存数据失败")
    }
  }

  // 更新血压信息
  private async updateBloodPressure(data: BloodPressureData) {
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

  getTextByType(type: HealthCardDataType) {
    switch (type) {
      case HealthCardDataType.WeightInfo: {
        return "weight"
      }
      case HealthCardDataType.BloodSugarInfo: {
        return "bloodSugar"
      }
      case HealthCardDataType.UricAcidInfo: {
        return "uricAcid"
      }
      case HealthCardDataType.BloodPressureInfo: {
        return "bloodPressure"
      }
      case HealthCardDataType.BloodLipidInfo: {
        return "bloodLipid"
      }
      default: {
        return ""
      }
    }
  }

  build() {
    Stack() {
      Column() {
        // 滚动容器
        Scroll() {
          Column({ space: $r('app.integer.view_space') }) {
            // 基本信息卡片
            UserInfoCard({
              nickName: this.userInfoVM?.nickname,
              nAge: this.userInfoVM?.age,
              nGender: this.userInfoVM?.gender,
              nHeight: this.userInfoVM?.heightCm,
              handleClick: (type: HealthCardDataType) => {
                this.showType = type
              }
            })

            if (!this.isLoading) {
              // 健康指标网格
              Grid() {
                ForEach(this.getHealthCardData(), (cardData: HealthCardData, index: number) => {
                  GridItem() {
                    HealthInfoCard({
                      data: cardData,
                      handleClick: (type) => {
                        const res = this.userInfoVM?.validateUserData()
                        if (res?.isValid) {
                          this.showType = type
                        } else {
                          showToast(this.getUIContext(), "请先输入用户信息")
                        }
                      }
                    })
                  }.onClick(() => {
                    const res = this.userInfoVM?.validateUserData()
                    if (res?.isValid) {
                      const data: Record<string, string> = {
                        "data": this.getTextByType(cardData.type)
                      }
                      getAppPathStack().pushPathByName("history", data)
                    } else {
                      showToast(this.getUIContext(), "请先输入用户信息")
                    }
                  })
                })
              }
              .width('100%')
              .layoutWeight(1)
              .columnsTemplate(this.columnsTemplate)
              .rowsGap($r('app.integer.view_space'))
              .columnsGap($r('app.integer.view_space'))
              .scrollBar(BarState.Off)
              .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
                const curWidth = newValue.width
                if (curWidth == undefined) {
                  return
                }
                // https://developer.huawei.com/consumer/cn/doc/design-guides/design-layout-basics-0000001795579413#section6149141345712
                // P60: 374x826
                // X5: 346x802 / 712x798
                // PuraX: 326x326 / 440x706
                // MatePad: 1280x800
                if (curWidth > 1000) {
                  this.columnsTemplate = '1fr 1fr 1fr 1fr'
                } else if (curWidth > 600) {
                  this.columnsTemplate = '1fr 1fr 1fr'
                } else {
                  this.columnsTemplate = '1fr 1fr'
                }
              })
            }
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
          if (this.userInfoVM && this.showType === HealthCardDataType.BaseInfo) {
            BaseInputView({
              initData: {
                nickname: this.userInfoVM.nickname,
                gender: this.userInfoVM.gender,
                heightCm: this.userInfoVM.heightCm,
                age: this.userInfoVM.age,
              } as UserDataModel,
              onSubmit: (data?: UserDataModel) => {
                if (data) {
                  this.updateUserInfo(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(350)
          } else if (this.weightDataVM && this.showType === HealthCardDataType.WeightInfo) {
            WeightInputView({
              weightKg: this.weightDataVM.value,
              onSubmit: (data?: WeightData) => {
                if (data) {
                  this.updateWeight(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(250)
          } else if (this.bloodPressVM && this.showType === HealthCardDataType.BloodPressureInfo) {
            BloodPressureInputView({
              systolicValue: this.bloodPressVM.systolic,
              diastolicValue: this.bloodPressVM.diastolic,
              onSubmit: (data?: BloodPressureData) => {
                if (data) {
                  this.updateBloodPressure(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(300)
          } else if (this.bloodSugarVM && this.showType === HealthCardDataType.BloodSugarInfo) {
            BloodSugarInputView({
              bloodSugarValue: this.bloodSugarVM.value,
              measurementType: MeasurementType.FASTING,
              onSubmit: (data?: BloodSugarData) => {
                if (data) {
                  this.updateBloodSugar(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(300)
          } else if (this.userInfoVM && this.uricAcidVM && this.showType === HealthCardDataType.UricAcidInfo) {
            UricAcidInputView({
              inputValue: this.uricAcidVM.value,
              gender: this.userInfoVM.gender,
              onSubmit: (data?: UricAcidData) => {
                if (data) {
                  this.updateUricAcid(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(300)
          } else if (this.bloodLipidVM && this.showType === HealthCardDataType.BloodLipidInfo) {
            BloodLipidInputView({
              totalCholesterol: this.bloodLipidVM.totalCholesterol,
              triglycerides: this.bloodLipidVM.triglycerides,
              hdlCholesterol: this.bloodLipidVM.hdlCholesterol,
              ldlCholesterol: this.bloodLipidVM.ldlCholesterol,
              onSubmit: (data?: BloodLipidData) => {
                if (data) {
                  this.updateBloodLipid(data)
                }
              }
            }).height(400)
          }
        }
        .width('100%')
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

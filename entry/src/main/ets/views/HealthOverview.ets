/**
 * 健康数据概览页面
 * 基于 Figma 设计实现的健康指标卡片式布局
 */
import { KeyboardAvoidMode } from '@kit.ArkUI';

import { MIconButton } from '../components/MButton';
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

import { ColorConstants } from '../common/CommonDefine';
import { UnitConstants } from '../common/HealthTypeDefine';
import { MDashBoardStyle } from '../components/MDashBoard';


const TAG = "HealthOverview"

interface ToolItem {
  name: ResourceStr,
  x: number,
  y: number,
  handleClick: Function
}


@Preview
@ComponentV2
export struct HealthOverview {
  @Local private showType: HealthCardDataType = HealthCardDataType.Unknown;
  @Local private isLoading: boolean = true
  @Local private columnsTemplate: string = '1fr 1fr'
  @Local private showQuick: boolean = true // 显示快速入口
  @Local private showExpandedButtons: boolean = false // 是否展开了
  @Local private buttonScale: number = 0
  @Local private buttonOpacity: number = 0
  @Provider("DashBoardStyle") dashBoardStyle: MDashBoardStyle = MDashBoardStyle.DashBoardNormal
  private userInfoVM?: UserViewModel
  private weightDataVM?: WeightViewModel
  private bloodSugarVM?: BloodSugarViewModel
  private bloodPressVM?: BloodPressureViewModel
  private uricAcidVM?: UricAcidViewModel
  private bloodLipidVM?: BloodLipidViewModel
  private quickTools: Array<ToolItem> = []

  @Monitor('showType')
  onShowTypeChange(monitor: IMonitor) {
    // console.info(`path: ${monitor.value()?.path} change from ${monitor.value()?.before} to ${monitor.value()?.now}`);
    const value = monitor.value()?.now as HealthCardDataType
    if (value == HealthCardDataType.Unknown) {
      this.showQuick = true
    } else {
      this.showQuick = false
      this.hideExpandedButtons()
    }
  }

  async aboutToAppear(): Promise<void> {
    this.getUIContext().setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE);
    this.quickTools = [
      {
        name: $r('app.media.weight'),
        x: -200,
        y: 0,
        handleClick: () => {
          this.showType = HealthCardDataType.WeightInfo
        }
      },
      {
        name: $r('app.media.blood_sugar'),
        x: -130,
        y: -130,
        handleClick: () => {
          this.showType = HealthCardDataType.BloodSugarInfo
        }
      },
      {
        name: $r('app.media.uric_acid'),
        x: 0,
        y: -200,

        handleClick: () => {
          this.showType = HealthCardDataType.UricAcidInfo
        }
      },
      {
        name: $r('app.media.blood_pressure'),
        x: 130,
        y: -130,
        handleClick: () => {
          this.showType = HealthCardDataType.BloodPressureInfo
        }
      },
      {
        name: $r('app.media.blood_lipid'),
        x: 200,
        y: 0,
        handleClick: () => {
          this.showType = HealthCardDataType.BloodLipidInfo
        }
      }
    ]

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
        value1: this.weightDataVM.value,
        unit: UnitConstants.WEIGHT_UNIT,
        status: this.weightDataVM.getHealthStatus(),
        date: this.weightDataVM.dateStr,
        // other: this.weightDataVM.getHealthAdvice()
      },
      {
        title: '血糖',
        type: HealthCardDataType.BloodSugarInfo,
        value1: this.bloodSugarVM.value,
        unit: UnitConstants.BLOOD_SUGAR_UNIT,
        status: this.bloodSugarVM.getHealthStatus(),
        date: this.bloodSugarVM.dateStr,
        // other: this.bloodSugarVM.getHealthAdvice()
      },
      {
        title: '尿酸',
        type: HealthCardDataType.UricAcidInfo,
        value1: this.uricAcidVM.value,
        unit: UnitConstants.URIC_ACID_UNIT,
        status: this.uricAcidVM.getHealthStatus(),
        date: this.uricAcidVM.dateStr,
        // other: this.uricAcidVM.getHealthAdvice()
      },
      {
        title: '血压',
        type: HealthCardDataType.BloodPressureInfo,
        value1: this.bloodPressVM.systolic,
        value2: this.bloodPressVM.diastolic,
        unit: UnitConstants.BLOOD_PRESSURE_UNIT,
        status: this.uricAcidVM.getHealthStatus(),
        date: this.uricAcidVM.dateStr,
        // other: this.uricAcidVM.getHealthAdvice()
      },
      {
        title: '血脂',
        type: HealthCardDataType.BloodLipidInfo,
        value1: this.bloodLipidVM.totalCholesterol,
        value2: this.bloodLipidVM.triglycerides,
        value3: this.bloodLipidVM.hdlCholesterol,
        value4: this.bloodLipidVM.ldlCholesterol,
        unit: UnitConstants.CHOLESTEROL_UNIT,
        status: this.bloodLipidVM.getHealthStatus(),
        date: this.bloodLipidVM.dateStr,
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

  // 隐藏扩展按钮
  private hideExpandedButtons() {
    this.buttonScale = 0
    this.buttonOpacity = 0
    this.showExpandedButtons = false
  }

  build() {
    RelativeContainer() {
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
                }
                .clickEffect({
                  level: ClickEffectLevel.HEAVY,
                  scale: 0.8
                })
                .onClick(() => {
                  const res = this.userInfoVM?.validateUserData()
                  if (res?.isValid) {
                    const data: Record<string, string> = {
                      "data": this.getTextByType(cardData.type)
                    }
                    getAppPathStack().pushPathByName("history", data, (res) => {
                      switch (res.result) {
                        case 'weight': {
                          this.showType = HealthCardDataType.WeightInfo;
                          break;
                        }
                        case 'bloodSugar': {
                          this.showType = HealthCardDataType.BloodSugarInfo;
                          break;
                        }
                        case 'uricAcid': {
                          this.showType = HealthCardDataType.UricAcidInfo;
                          break;
                        }
                        case 'bloodPressure': {
                          this.showType = HealthCardDataType.BloodPressureInfo;
                          break;
                        }
                        case 'bloodLipid': {
                          this.showType = HealthCardDataType.BloodLipidInfo;
                          break;
                        }
                        default: {
                          this.showType = HealthCardDataType.Unknown;
                          break;
                        }
                      }
                    })
                  } else {
                    showToast(this.getUIContext(), "请先输入用户信息")
                  }
                })
              })
            }
            .width('100%')
            .height('100%')
            .nestedScroll({
              scrollForward:NestedScrollMode.PARENT_FIRST,
              scrollBackward: NestedScrollMode.SELF_FIRST
            })
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
                this.dashBoardStyle = MDashBoardStyle.DashBoardBig
              } else if (curWidth > 600) {
                this.columnsTemplate = '1fr 1fr 1fr'
                this.dashBoardStyle = MDashBoardStyle.DashBoardBig
              } else if (curWidth > 350) {
                this.columnsTemplate = '1fr 1fr'
                this.dashBoardStyle = MDashBoardStyle.DashBoardNormal
              } else {
                this.columnsTemplate = '1fr 1fr'
                this.dashBoardStyle = MDashBoardStyle.DashBoardSmall
              }
            })
          }
        }
        .padding($r('app.integer.view_padding'))
      }
      .backgroundColor($r('app.color.view_background_color'))
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End }
      })

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
          } else if (this.bloodLipidVM && this.showType === HealthCardDataType.BloodLipidInfo) {
            BloodLipidInputView({
              totalCholesterol: this.bloodLipidVM.totalCholesterol,
              triglycerides: this.bloodLipidVM.triglycerides,
              hdlCholesterol: this.bloodLipidVM.hdlCholesterol,
              ldlCholesterol: this.bloodLipidVM.ldlCholesterol,
              onSubmit: (data?: BloodLipidData) => {
                if (data) {
                  this.updateBloodLipid(data)
                } else {
                  this.showType = HealthCardDataType.Unknown
                }
              }
            }).height(400)
          }
        }
        .width('100%')
        .backgroundColor($r('app.color.white'))
      }
      .justifyContent(FlexAlign.End)
      .visibility(this.showType === HealthCardDataType.Unknown ? Visibility.Hidden : Visibility.Visible)
      .backgroundColor($r('app.color.view_mask'))
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        right: { anchor: '__container__', align: HorizontalAlign.End }
      })

      // 遮罩背景半透明
      Column()
        .visibility(this.showExpandedButtons ? Visibility.Visible : Visibility.Hidden)
        .backgroundColor($r('app.color.view_mask'))
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .clickEffect({
          level: ClickEffectLevel.HEAVY,
          scale: 0.8
        })
        .onClick(() => {
          this.hideExpandedButtons()
        })

      // 发布按钮
      MIconButton({
        iconName: this.showExpandedButtons ? "x" : "+",
        iconColor: this.showExpandedButtons ? ColorConstants.Blue : ColorConstants.Red,
        handleClick: () => {
          if (this.showExpandedButtons) {
            // 关闭扩展按钮
            this.buttonScale = 0
            this.buttonOpacity = 0
            setTimeout(() => {
              this.showExpandedButtons = false
            }, 200)
          } else {
            // 显示扩展按钮
            this.showExpandedButtons = true
            setTimeout(() => {
              this.buttonScale = 1
              this.buttonOpacity = 1
            }, 10)
          }
        }
      })
        .visibility(this.showQuick ? Visibility.Visible : Visibility.Hidden)
        .id("__add_btn__")
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })

      ForEach(this.quickTools, (item: ToolItem, index) => {
        MIconButton({
          iconName: "",
          srcName: item.name,
          iconColor: ColorConstants.Blue,
          handleClick: () => {
            item.handleClick()
          }
        })
          .alignRules({
            center: { anchor: '__add_btn__', align: VerticalAlign.Center },
            middle: { anchor: '__add_btn__', align: HorizontalAlign.Center }
          })
          .margin({
            left: item.x,
            top: item.y,
          })
          .scale({ x: this.buttonScale, y: this.buttonScale })
          .opacity(this.buttonOpacity)
          .visibility(this.showExpandedButtons ? Visibility.Visible : Visibility.Hidden)
          .animation({
            duration: 300,
            curve: Curve.EaseOut
          })
      })
    }
  }
}
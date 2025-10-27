/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file CommonDefine.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-09-25
 * @desc
 */

/**
 * 默认颜色常量
 */
export class ColorConstants {
  static readonly White = "#ffffff";
  static readonly Black = "#151515";
  static readonly Blue = "#618dff";
  static readonly Red = "#f6685d";
  static readonly Orange = "#e37318";
  static readonly Green = "#2ba471";
  static readonly Cyan = "#41b8f2";
  static readonly Purple = "#c69cff";
  static readonly Yellow = "#f5ba18";
  static readonly Pink = "#ff79cd";
  static readonly Gray = "#c6c6c6";
  static readonly Gray1 = "#f3f3f3";
  static readonly Gray5 = "#c6c6c6";
  static readonly Gray10 = "#4b4b4b";

  static readonly Primary_Color = "#f6685d";
  static readonly Second_Color = "#c6c6c6";

  static readonly View_Background_Color = "#f4f2f8";
  static readonly View_Mask = "#66000000";
  static readonly Line_Color = "#c6c6c6"

  static readonly Text_333 = "#333333"
  static readonly Text_666 = "#666666"
  static readonly Text_999 = "#999999"
}

/**
 * 默认字体大小常量
 */
export class FontSizeConstants {
  static readonly Small = 12;
  static readonly Normal = 14;
  static readonly Medium = 18;
  static readonly Large = 20;
  static readonly NavTitle = 22;
  static readonly LargeTitle = 28;
}

export class AppConstants {
  /**
   * 状态栏高度
   */
  static readonly STATUS_HEIGHT: number = 48;
  /**
   * 导航默认高度
   */
  static readonly NAV_BAR_HEIGHT: number = 36;
  /**
   * 导航栏高度
   */
  static readonly NAV_HEIGHT: number = 84;
  /**
   * 底部TabBar高度
   */
  static readonly TAB_BAR_HEIGHT: number = 50
  /**
   * TabBar底部安全高度
   */
  static readonly TAB_BAR_BOTTOM_SAVE_HEIGHT: number = 30
  /**
   * 页面的padding
   */
  static readonly VIEW_PADDING: number = 16
  /**
   * 页面的margin
   */
  static readonly VIEW_MARGIN: number = 12
  /**
   * 页面的间距
   */
  static readonly VIEW_SPACE: number = 8
  /**
   * 页面的圆角
   */
  static readonly VIEW_RADIUS: number = 8
  /**
   * 通用按钮高度
   */
  static readonly BTN_HEIGHT: number = 48
  /**
   * 通用输入框高度
   */
  static readonly INPUT_HEIGHT: number = 48
}


export class CommonDefine {
  static globalPathStackName: string = "kGlobalPathStack"
}

/**
 * 用户相关常量定义
 */
export class UserConstants {
  /**
   * 用户数据存储键名
   */
  static readonly USER_DATA_KEY: string = 'user_data';
  
  /**
   * 用户昵称最大长度
   */
  static readonly NICKNAME_MAX_LENGTH: number = 20;
  
  /**
   * 用户年龄最小值
   */
  static readonly AGE_MIN_VALUE: number = 1;
  
  /**
   * 用户年龄最大值
   */
  static readonly AGE_MAX_VALUE: number = 150;
  
  /**
   * 默认用户昵称
   */
  static readonly DEFAULT_NICKNAME: string = '用户';
  
  /**
   * 默认用户年龄
   */
  static readonly DEFAULT_AGE: number = 25;
  
  /**
   * 默认用户身高（厘米）
   */
  static readonly DEFAULT_HEIGHT_CM: number = 170;
}

export type HealthDataType = 'weight' | 'bloodPressure' | 'bloodLipid' | 'bloodSugar' | 'uricAcid';

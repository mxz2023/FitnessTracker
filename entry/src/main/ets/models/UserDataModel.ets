/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file UserDataModel.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-09
 * @desc
 */

// 性别枚举
export enum Gender {
  UNKNOWN = '未知', // 未知/不参与计算
  MALE = '男',
  FEMALE = '女'
}


// 基本信息表单数据
export interface UserDataModel {
  nickname: string;
  gender: Gender;
  age: number;
  heightCm: number;
}
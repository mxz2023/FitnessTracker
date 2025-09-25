/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file PathStackUtils.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-09-25
 * @desc
 */
import { CommonDefine } from "../common/CommonDefine";

// system

// module

// inner

const TAG = 'PathStackUtils.ets'

export function getAppPathStack() {
    return AppStorage.get(CommonDefine.globalPathStackName) as NavPathStack;
}
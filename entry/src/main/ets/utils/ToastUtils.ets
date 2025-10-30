/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file ToastUtils.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-09-25
 * @desc
 */
import { logger } from "./Logger"

const TAG = 'ToastUtils.ets'

export function showToast(uiContext: UIContext, message: string) {
  try {
    uiContext.getPromptAction().showToast({
      message: message
    })
  } catch (error) {
    logger.exception(TAG, error)
  }
}
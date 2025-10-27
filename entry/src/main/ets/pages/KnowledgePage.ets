/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file KnowledgePage.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-10-27
 * @desc
 */
import { Markdown } from '@luvi/lv-markdown-in'

import { AppConstants, HealthDataType } from '../common/CommonDefine'
import { NavigationTitleBuilder } from '../components/MNavigationTitle'
import { getAppPathStack } from '../utils/PathStackUtils'

const TAG = 'KnowledgePage.ets'


@ComponentV2
struct KnowledgePage {
  @Param @Require dataType: HealthDataType
  @Local rawFileName: string = ""

  aboutToAppear(): void {
    this.rawFileName = `${this.dataType}.md`
  }

  build() {
    NavDestination() {
      Scroll() {
        Markdown({
          mode: "rawfile",
          context: getContext(), // 资源文件模式必填参数
          rawfilePath: this.rawFileName, // 资源文件地址
          callback: {
            // callback 可省略
            complete: () => {
              console.log("Markdown component load success.")
            },
            fail: (code: number, message: string) => {
              console.error("Markdown component load error. code: " + code + ", message: " + message)
            }
          }
        })
      }
      .width('100%')
      .height('100%')
      .padding(AppConstants.VIEW_PADDING)
    }.title({
      builder: NavigationTitleBuilder(getAppPathStack(), {
        title: {
          text: "常识",
          fontColor: "#000000"
        },
        height: 45
      }),
      height: 58
    })
    .width('100%')
    .height('100%')
    .onReady((ctx: NavDestinationContext) => {

    })
  }
}

@Builder
export function PageBuilder(_: string, param: Record<string, Object>) {
  KnowledgePage({
    dataType: param.data as HealthDataType
  });
}
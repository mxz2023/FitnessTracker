/**
 * Copyright (c) 2023-2025 Mxz Co., Ltd.
 *
 * @file MChart.ets
 * @project FitnessTracker
 * @author vincent_gemini
 * @crateTime 2025-09-27
 * @desc
 */

import { HmInitChart } from './EChart/InitChart'
import { ChartOptions } from './EChart/EChartOption'


export declare class MChartType {
  constructor(context: CanvasRenderingContext2D);

  setOption(options: ChartOptions | null): void;

  onTouchEvent(options: TouchEvent | ClickEvent, call?: Function): void;
}


@ComponentV2
export struct MChart {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @Local myChart?: MChartType;
  @Param options?: ChartOptions = undefined;

  // 子组件的方法
  updateMessage(Options: ChartOptions) {
    if (this.myChart) {
      this.myChart.setOption(Options);
    }
  }

  build() {
    Column() {
      Canvas(this.context)
        .onReady(() => {
          this.myChart = new HmInitChart(this.context) as MChartType;
          if (this.options) {
            this.myChart.setOption(this.options);
          }
        })
        .onTouch((event: TouchEvent) => {
          if (this.myChart) {
            this.myChart.onTouchEvent(event);
          }
        })
    }
    .width('100%')
    .height('100%')
  }
}

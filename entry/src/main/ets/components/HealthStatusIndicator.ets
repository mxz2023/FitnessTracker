/**
 * 健康状态指示器组件
 */

import { HealthStatus } from '../model/HealthDataModel';
import { getHealthStatusColor, getHealthStatusText } from '../utils/HealthUtils';

@Component
export struct HealthStatusIndicator {
  @Prop status: HealthStatus = HealthStatus.EXCELLENT;
  @Prop showText: boolean = true;
  @Prop indicatorSize: number = 24;

  build() {
    Row({ space: 4 }) {
      Circle()
        .width(this.indicatorSize)
        .height(this.indicatorSize)
        .fill(getHealthStatusColor(this.status))

      if (this.showText) {
        Text(getHealthStatusText(this.status))
          .fontSize(Math.floor(this.indicatorSize * 0.7))
          .fontColor(getHealthStatusColor(this.status))
      }
    }
  }
}
/**
 * 健康状态指示器组件
 */

import { HealthStatus } from '../model/HealthDataModel';
import { getHealthStatusColor, getHealthStatusText } from '../utils/HealthUtils';

@Component
export struct HealthStatusIndicator {
  @Prop status: HealthStatus = HealthStatus.EXCELLENT;
  @Prop showText: boolean = true;

  build() {
    Row({ space: 4 }) {
      if (this.showText) {
        Text(getHealthStatusText(this.status))
          .fontSize($r('app.float.font_size_small'))
          .fontColor(getHealthStatusColor(this.status))
      }
      SymbolGlyph($r('sys.symbol.circle_inset_filled'))
        .fontSize($r('app.float.font_size_normal'))
        .fontColor([getHealthStatusColor(this.status)])
    }
  }
}
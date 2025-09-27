
import * as chart from './echarts.js';
export class HmInitChart{
  constructor(ctx) {
    this.myCharts= chart.init(ctx)

  }
  setOption(option){
    this.myCharts.setOption({animation: false,...option })

  }
  onTouchEvent(event,fun){
    //0 按下 1 释放 2 移动
    this._initEvent(event)
    this.myCharts.on('click', {dataType: 'node'},(params)=>{
      console.log('params',params.type)
      console.log('paramsseriesIndex',params.seriesIndex)

    });
  }
  // 处理事件机制
  _initEvent(event) {
    const eventNames = [{
      type: '0',
      ecName: 'mousedown'
    }, {
      type: '2',
      ecName: 'mousemove'
    }, {
      type: '1',
      ecName: 'mouseup'
    }, {
      type: '1',
      ecName: 'click'
    }];
    eventNames.forEach(name => {
      if(event.type==name.type){
        const touch = event.touches[0];
        this.myCharts.getZr().handler.dispatch(name.ecName, {
          zrX: name.type === 'tap' ? touch.screenX : touch.x,
          zrY: name.type === 'tap' ? touch.screenY : touch.y,
          preventDefault: () => {},
          stopImmediatePropagation: () => {},
          stopPropagation: () => {}
        });
      }

    });
  }


}

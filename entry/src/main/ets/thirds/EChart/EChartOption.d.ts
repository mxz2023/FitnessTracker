


interface Title {
    text: string;
    subtext?: string;
    left?: string;
    top?: string;
    right?: string;
    bottom?: string;
    textAlign?: string;
    backgroundColor?: string;
    borderColor?: string;
    borderWidth?: number;
    padding?: number | number[];
    itemGap?: number;
    textStyle?: TextStyleType;
    subtextStyle?: TextStyleType;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

interface TextStyleType {
  color?: string;
  fontStyle?: string;
  fontWeight?: string | number;
  fontFamily?: string;
  fontSize?: number;
  lineHeight?: number;
  backgroundColor?: string | object;
  borderColor?: string;
  borderWidth?: number;
  borderRadius?: number | number[];
  padding?: number | number[];
  shadowColor?: string;
  shadowBlur?: number;
  shadowOffsetX?: number;
  shadowOffsetY?: number;
  width?: number | string;
  height?: number | string;
  textBorderColor?: string;
  textBorderWidth?: number;
  textShadowColor?: string;
  textShadowBlur?: number;
  textShadowOffsetX?: number;
  textShadowOffsetY?: number;
  overflow?: string;
  ellipsis?: string;
  [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
}


  interface Tooltip {
    trigger: string;
    axisPointer?: {
      type: string;
      [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
    };
    formatter?: string | Function;
    backgroundColor?: string;
    borderColor?: string;
    borderWidth?: number;
    padding?: number | number[];
    textStyle?: TextStyleType;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface Legend {
    data: string[];
    left?: string;
    top?: string;
    right?: string;
    bottom?: string;
    orient?: string;
    backgroundColor?: string;
    borderColor?: string;
    borderWidth?: number;
    padding?: number | number[];
    itemGap?: number;
    itemWidth?: number;
    itemHeight?: number;
    textStyle?: TextStyleType;
    formatter?: string | Function;
    selectedMode?: boolean | string;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface Grid {
    left: string;
    right: string;
    bottom: string;
    top?: string;
    containLabel: boolean;
    backgroundColor?: string;
    borderColor?: string;
    borderWidth?: number;
    shadowBlur?: number;
    shadowColor?: string;
    shadowOffsetX?: number;
    shadowOffsetY?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface XAxis {
    type: string;
    boundaryGap?: boolean;
    data: string[];
    name?: string;
    nameLocation?: string;
    nameTextStyle?: TextStyleType;
    nameGap?: number;
    nameRotate?: number;
    inverse?: boolean;
    position?: string;
    offset?: number;
    axisLine?: AxisLine;
    axisTick?: AxisTick;
    axisLabel?: AxisLabel;
    splitLine?: SplitLine;
    splitArea?: SplitArea;
    min?: string | number;
    max?: string | number;
    scale?: boolean;
    gridIndex?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface YAxis {
    type: string;
    name?: string;
    nameLocation?: string;
    nameTextStyle?: TextStyleType;
    nameGap?: number;
    nameRotate?: number;
    inverse?: boolean;
    position?: string;
    offset?: number;
    axisLine?: AxisLine;
    axisTick?: AxisTick;
    axisLabel?: AxisLabel;
    splitLine?: SplitLine;
    splitArea?: SplitArea;
    min?: string | number;
    max?: string | number;
    scale?: boolean;
    gridIndex?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface AxisLine {
    show?: boolean;
    onZero?: boolean;
    lineStyle?: LineStyle;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface AxisTick {
    show?: boolean;
    alignWithLabel?: boolean;
    interval?: number | Function;
    inside?: boolean;
    length?: number;
    lineStyle?: LineStyle;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface AxisLabel {
    show?: boolean;
    interval?: number | Function;
    inside?: boolean;
    rotate?: number;
    margin?: number;
    formatter?: string | Function;
    showMinLabel?: boolean;
    showMaxLabel?: boolean;
    color?: string;
    fontStyle?: string;
    fontWeight?: string | number;
    fontFamily?: string;
    fontSize?: number;
    align?: string;
    verticalAlign?: string;
    lineHeight?: number;
    backgroundColor?: string | object;
    borderColor?: string;
    borderWidth?: number;
    borderRadius?: number | number[];
    padding?: number | number[];
    shadowColor?: string;
    shadowBlur?: number;
    shadowOffsetX?: number;
    shadowOffsetY?: number;
    width?: number | string;
    height?: number | string;
    textBorderColor?: string;
    textBorderWidth?: number;
    textShadowColor?: string;
    textShadowBlur?: number;
    textShadowOffsetX?: number;
    textShadowOffsetY?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface SplitLine {
    show?: boolean;
    interval?: number | Function;
    lineStyle?: LineStyle;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface SplitArea {
    show?: boolean;
    interval?: number | Function;
    areaStyle?: AreaStyle;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface LineStyle {
    color?: string;
    width?: number;
    type?: string;
    shadowBlur?: number;
    shadowColor?: string;
    shadowOffsetX?: number;
    shadowOffsetY?: number;
    opacity?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface AreaStyle {
    color?: string | object;
    opacity?: number;
    shadowBlur?: number;
    shadowColor?: string;
    shadowOffsetX?: number;
    shadowOffsetY?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
  }

  interface Series {
    name?: string;
    type: string;
    stack?: string;
    smooth?: boolean;
    data?: number[];
    label?: {
      show?: boolean;
      position?: string;
      distance?: number;
      rotate?: number;
      offset?: [number, number];
      formatter?: string | Function;
      color?: string;
      fontStyle?: string;
      fontWeight?: string | number;
      fontFamily?: string;
      fontSize?: number;
      align?: string;
      verticalAlign?: string;
      lineHeight?: number;
      backgroundColor?: string | object;
      borderColor?: string;
      borderWidth?: number;
      borderRadius?: number | number[];
      padding?: number | number[];
      shadowColor?: string;
      shadowBlur?: number;
      shadowOffsetX?: number;
      shadowOffsetY?: number;
      width?: number | string;
      height?: number | string;
      textBorderColor?: string;
      textBorderWidth?: number;
      textShadowColor?: string;
      textShadowBlur?: number;
      textShadowOffsetX?: number;
      textShadowOffsetY?: number;
      [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
    };
    itemStyle?: {
      color?: string;
      borderColor?: string;
      borderWidth?: number;
      borderType?: string;
      shadowBlur?: number;
      shadowColor?: string;
      shadowOffsetX?: number;
      shadowOffsetY?: number;
      opacity?: number;
      [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
    };
    lineStyle?: LineStyle;
    areaStyle?: AreaStyle;
    radius?: number[] | string[];
    center?: number[] | string[];
    roseType?: boolean;
    selectedMode?:'single' |'multiple';
    selectedOffset?: number;
    barWidth?: number | string;
    barMaxWidth?: number;
    barMinWidth?: number;
    barGap?: '30%' | '0%';
    barCategoryGap?: '20%' | '0%';
    indicator?: {
      name: string;
      max?: number;
    }[];
    step?: 'tart' | 'iddle' | 'end';
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;

  }
export  interface NestedObject {
  [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>
}
 export  interface ChartOptions {
    title?: Title;
    tooltip?: Tooltip;
    legend?: Legend;
    grid?: Grid;
    xAxis?: XAxis | XAxis[];
    yAxis?: YAxis | YAxis[];
    series?: Series[];
    backgroundColor?: string;
    color?: string[];
    textStyle?: TextStyleType;
    animation?: boolean;
    animationThreshold?: number;
    animationDuration?: number;
    [key: string]: string | number|Function |object| boolean | NestedObject | NestedObject[] | Array<string | number | boolean | NestedObject>;
    animationEasing?: 'linear' | 'quadraticIn' | 'quadraticOut' | 'quadraticInOut' | 'inusoidalIn' | 'inusoidalOut' | 'inusoidalInOut' | 'exponentialIn' | 'exponentialOut' | 'exponentialInOut' | 'circularIn' | 'circularOut' | 'circularInOut'
  }



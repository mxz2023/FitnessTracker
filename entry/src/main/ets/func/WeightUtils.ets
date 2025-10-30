/**
 * 体重参考范围与分类工具（ArkTS）
 * - 成人/老年：使用中国成人BMI阈值，按身高换算体重区间
 * - 儿童/青少年：支持按“性别×月龄”的BMI百分位（P5、P85、P95）进行线性插值
 * - 数据加载：可从 JSON/CSV 加载 WHO 或中国大陆正式表，优先使用月龄数据；未加载时回退到内置整岁示例表
 * - ArkTS 规范：不使用映射类型、不用变量索引对象属性、不返回字符串给 number、不使用 any/unknown
 */
/**
 * 性别类型
 * - male：男
 * - female：女
 */
type Sex = 'male' | 'female';

/**
 * 体重范围结构
 * label：范围标签（偏瘦/标准/偏胖/超重）
 * bmiMin/bmiMax：对应范围的 BMI 下限/上限（可选，部分范围只有单边）
 * weightMin/weightMax：按身高换算后的体重下限/上限（kg）
 */
interface Range {
  label: '偏瘦' | '标准' | '偏胖' | '超重';
  bmiMin?: number; // 含下限
  bmiMax?: number; // 含上限
  weightMin?: number;
  weightMax?: number;
}

/**
 * 成人/老年 BMI 阈值集合
 * under：偏瘦上限
 * normalMin/normalMax：标准区间的下限/上限
 * overweightMin/overweightMax：偏胖区间的下限/上限
 * obeseMin：超重下限
 */
interface Thresholds {
  under: number;
  normalMin: number;
  normalMax: number;
  overweightMin: number;
  overweightMax: number;
  obeseMin: number;
}

/**
 * 中国成人（18–64岁）BMI 阈值常量
 * 用于成人阶段分类与范围换算
 */
const ADULT_THRESHOLDS: Thresholds = {
  under: 18.5,
  normalMin: 18.5,
  normalMax: 23.9,
  overweightMin: 24.0,
  overweightMax: 27.9,
  obeseMin: 28.0
};

// 可加载的儿童BMI百分位（按月龄）数据结构与加载函数
/**
 * 儿童/青少年 BMI 百分位数据点（按月龄）
 * ageMonths：月龄（例如 36 表示 3 岁）
 * p5/p85/p95：对应百分位的 BMI 值
 */
interface ChildBMIPercentilePoint {
  ageMonths: number;
  p5: number;
  p85: number;
  p95: number;
}

/**
 * 已加载的儿童 BMI 百分位数据（按月龄）
 * male/female：男/女的百分位数组（需按 ageMonths 升序）
 * source：数据来源标记（'WHO' 或 'CN'）
 */
interface ChildBMILoaded {
  male: ChildBMIPercentilePoint[];
  female: ChildBMIPercentilePoint[];
  source?: string; // 'WHO' 或 'CN'
}

/**
 * 运行时加载的儿童 BMI 百分位数据（优先用于插值）
 * 未加载时为 undefined，会回退使用内置整岁示例表
 */
let LOADED_CHILD_BMI: ChildBMILoaded | undefined;


/**
 * 计算 BMI（体重指数）
 * @param weightKg 体重（kg）
 * @param heightCm 身高（cm）
 * @returns BMI 数值（不做四舍五入）
 */
export function bmi(weightKg: number, heightCm: number): number {
  const h = heightCm / 100;
  return weightKg / (h * h);
}

export function bmiRanges(): number[] {
  return rangesByHeightForAdult(42, 185).map((item: Range) => {
    if (item.bmiMin) {
      return item.bmiMin;
    } else if (item.bmiMax) {
      return item.bmiMax;
    } else {
      return 0;
    }
  })
}


// 按月龄线性插值（数组需按 ageMonths 升序）
/**
 * 按月龄进行线性插值，获取指定百分位的 BMI
 * @param points 已加载的百分位数据点（需按 ageMonths 升序）
 * @param ageMonths 月龄（整数或小数，内部按区间线性插值）
 * @param percentile 百分位选择（5/85/95）
 * @returns 插值得到的 BMI 数值（按 0.1 精度四舍五入）
 */
function interpolateByMonths(points: ChildBMIPercentilePoint[], ageMonths: number, percentile: Percentile): number {
  if (points.length === 0) {
    // 无加载数据时不使用该路径
    return NaN;
  }
  // 边界钳制
  let first = points[0];
  let last = points[points.length - 1];
  let pick = (p: ChildBMIPercentilePoint): number => {
    switch (percentile) {
      case 5:
        return p.p5;
      case 85:
        return p.p85;
      case 95:
      default:
        return p.p95;
    }
  };

  if (ageMonths <= first.ageMonths) {
    return pick(first);
  }
  if (ageMonths >= last.ageMonths) {
    return pick(last);
  }

  // 命中点或区间插值
  for (let i = 0; i < points.length; i++) {
    if (ageMonths === points[i].ageMonths) {
      return pick(points[i]);
    }
  }
  for (let i = 0; i < points.length - 1; i++) {
    const a0 = points[i].ageMonths;
    const a1 = points[i + 1].ageMonths;
    if (ageMonths > a0 && ageMonths < a1) {
      const y0 = pick(points[i]);
      const y1 = pick(points[i + 1]);
      const v = linearInterpolate(ageMonths, a0, y0, a1, y1);
      return Math.round(v * 10) / 10;
    }
  }
  return pick(last);
}

// 从 JSON 加载（数组项格式：{sex:'male'|'female', ageMonths:number, p5:number, p85:number, p95:number}）
/**
 * 从 JSON 字符串加载儿童 BMI 百分位表（按月龄）
 * JSON 格式：数组，每项为 { sex:'male'|'female', ageMonths:number, p5:number, p85:number, p95:number }
 * @param json JSON 字符串
 * @param source 数据来源标记（'WHO' 或 'CN'）
 * @throws JSON解析失败或格式不合法时抛错
 */
export function loadChildBMITableFromJSON(json: string, source?: string): void {
  interface JsonRow {
    sex: 'male' | 'female';
    ageMonths: number | string;
    p5: number | string;
    p85: number | string;
    p95: number | string;
  }

  let rows = JSON.parse(json) as JsonRow[];
  if (!rows || !Array.isArray(rows)) {
    throw new Error('JSON格式应为数组');
  }

  const male: ChildBMIPercentilePoint[] = [];
  const female: ChildBMIPercentilePoint[] = [];
  for (let i = 0; i < rows.length; i++) {
    const row = rows[i];
    if (!row) {
      continue;
    }
    const sexVal = row.sex;
    const point: ChildBMIPercentilePoint = {
      ageMonths: typeof row.ageMonths === 'string' ? Number(row.ageMonths) : row.ageMonths,
      p5: typeof row.p5 === 'string' ? Number(row.p5) : row.p5,
      p85: typeof row.p85 === 'string' ? Number(row.p85) : row.p85,
      p95: typeof row.p95 === 'string' ? Number(row.p95) : row.p95
    };
    if (sexVal === 'male') {
      male.push(point);
    } else if (sexVal === 'female') {
      female.push(point);
    }
  }

  male.sort((a, b) => a.ageMonths - b.ageMonths);
  female.sort((a, b) => a.ageMonths - b.ageMonths);
  LOADED_CHILD_BMI = { male, female, source };
}

// 从 CSV 加载，默认表头：sex,ageMonths,p5,p85,p95
/**
 * 从 CSV 字符串加载儿童 BMI 百分位表（按月龄）
 * CSV 格式（包含表头）：sex,ageMonths,p5,p85,p95
 * @param csv CSV 字符串
 * @param source 数据来源标记（'WHO' 或 'CN'）
 * @throws 当数据不足或行格式不合法时抛错
 */
export function loadChildBMITableFromCSV(csv: string, source?: string): void {
  const lines = csv.split(/\r?\n/).filter(l => l.trim().length > 0);
  if (lines.length <= 1) {
    throw new Error('CSV数据不足');
  }
  // 跳过首行表头
  const male: ChildBMIPercentilePoint[] = [];
  const female: ChildBMIPercentilePoint[] = [];
  for (let i = 1; i < lines.length; i++) {
    const cols = lines[i].split(',').map(s => s.trim());
    if (cols.length < 5) {
      continue;
    }
    const sexVal = cols[0];
    const point: ChildBMIPercentilePoint = {
      ageMonths: Number(cols[1]),
      p5: Number(cols[2]),
      p85: Number(cols[3]),
      p95: Number(cols[4])
    };
    if (sexVal === 'male') {
      male.push(point);
    } else if (sexVal === 'female') {
      female.push(point);
    }
  }
  male.sort((a, b) => a.ageMonths - b.ageMonths);
  female.sort((a, b) => a.ageMonths - b.ageMonths);
  LOADED_CHILD_BMI = { male, female, source };
}

/**
 * 老年（≥65岁）BMI 阈值常量
 * 为减少老年营养不良风险，适度抬升“标准”下限
 */
const SENIOR_THRESHOLDS: Thresholds = {
  under: 20.0,
  normalMin: 20.0,
  normalMax: 27.0,
  overweightMin: 27.0,
  overweightMax: 30.0,
  obeseMin: 30.0
};

/**
 * 获取成人/老年 BMI 阈值
 * @param age 年龄（岁）
 * @returns 对应年龄段的 BMI 阈值集合
 * 说明：未成年人不在此函数处理
 */
function adultThresholds(age: number): Thresholds {
  // 成人与老年阈值；未成年人不在此函数处理
  return age >= 65 ? SENIOR_THRESHOLDS : ADULT_THRESHOLDS;
}

/**
 * 依据身高计算成人/老年的体重参考范围（四档）
 * @param age 年龄（岁）
 * @param heightCm 身高（cm）
 * @returns Range 数组，包含偏瘦/标准/偏胖/超重的体重区间（kg）
 */
function rangesByHeightForAdult(age: number, heightCm: number): Range[] {
  const H = heightCm / 100;
  const t = adultThresholds(age);
  const toW = (bmiVal: number) => +(bmiVal * H * H);

  return [
    {
      label: '偏瘦',
      bmiMax: t.under,
      weightMax: toW(t.under)
    },
    {
      label: '标准',
      bmiMin: t.normalMin,
      bmiMax: t.normalMax,
      weightMin: toW(t.normalMin),
      weightMax: toW(t.normalMax)
    },
    {
      label: '偏胖',
      bmiMin: t.overweightMin,
      bmiMax: t.overweightMax,
      weightMin: toW(t.overweightMin),
      weightMax: toW(t.overweightMax)
    },
    { label: '超重', bmiMin: t.obeseMin, weightMin: toW(t.obeseMin) },
  ];
}

// 占位：从性别/年龄获取BMI百分位（例如P5、P85、P95）
/**
 * 儿童/青少年使用的 BMI 百分位类型
 * 目前支持：P5、P85、P95
 */
type Percentile = 5 | 85 | 95;

/**
 * 内置整岁示例表的数据序列（用于无月龄数据时的回退）
 * ages：整岁年龄列表（如 3–17 岁）
 * values：与 ages 对应的 BMI 值
 */
interface PercentileSeries {
  ages: number[]; // 整岁年龄列表（例如 6..17）
  values: number[]; // 与 ages 对应的BMI值
}

/**
 * 百分位序列集合（内置整岁示例表）
 * p5/p85/p95：对应百分位的序列
 */
interface PercentileSeriesSet {
  p5: PercentileSeries;
  p85: PercentileSeries;
  p95: PercentileSeries;
}

/**
 * 内置儿童 BMI 百分位表（整岁示例）
 * male/female：按性别的百分位序列集合
 */
interface ChildBMITable {
  male: PercentileSeriesSet;
  female: PercentileSeriesSet;
}

// 示例数据（6–17岁），用于演示与插值；可替换为WHO/中国标准完整表
/**
 * 内置儿童 BMI 百分位整岁示例表
 * 注意：为演示数据，已扩展至 3–17 岁；正式项目请加载 WHO/中国大陆月龄数据替换
 */
const CHILD_BMI_TABLE: ChildBMITable = {
  male: {
    // 扩展至3–5岁，占位数据（请后续替换为WHO/中国标准正式表）
    p5: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [14.0, 13.9, 13.8, 13.7, 13.9, 14.2, 14.6, 15.0, 15.3, 15.7, 16.1, 16.5, 16.8, 17.0, 17.1]
    },
    p85: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [16.8, 16.9, 17.0, 17.1, 17.6, 18.1, 18.7, 19.4, 20.1, 20.9, 21.7, 22.5, 23.3, 24.0, 24.4]
    },
    p95: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [18.3, 18.4, 18.5, 18.6, 19.2, 19.9, 20.7, 21.6, 22.6, 23.6, 24.6, 25.5, 26.3, 27.0, 27.4]
    }
  },
  female: {
    p5: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [13.9, 13.8, 13.7, 13.5, 13.8, 14.1, 14.5, 14.9, 15.3, 15.6, 15.9, 16.2, 16.5, 16.7, 16.9]
    },
    p85: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [16.7, 16.8, 16.9, 17.0, 17.5, 18.0, 18.6, 19.2, 19.9, 20.6, 21.3, 22.0, 22.7, 23.3, 23.8]
    },
    p95: {
      ages: [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
      values: [18.1, 18.2, 18.3, 18.4, 19.0, 19.7, 20.5, 21.4, 22.4, 23.3, 24.2, 25.0, 25.8, 26.5, 27.1]
    }
  }
};

/**
 * 通用线性插值函数
 * @param x 当前自变量
 * @param x0 区间起点自变量
 * @param y0 区间起点因变量
 * @param x1 区间终点自变量
 * @param y1 区间终点因变量
 * @returns 线性插值结果
 */
function linearInterpolate(x: number, x0: number, y0: number, x1: number, y1: number): number {
  if (x1 === x0) {
    return y0;
  }
  return y0 + (y1 - y0) * ((x - x0) / (x1 - x0));
}

/**
 * 获取儿童/青少年在指定百分位的 BMI
 * 逻辑：
 * 1) 若已加载“月龄数据”（WHO/中国大陆），按月龄进行线性插值（优先路径）
 * 2) 否则回退到内置的“整岁示例表”，按年龄进行线性插值
 * ArkTS 约束规避：
 * - 显式按性别分支（male/female），不用 CHILD_BMI_TABLE[sex] 的变量索引
 * - 百分位采用 switch 显式分支（p5/p85/p95），不使用映射键访问
 * @param sex 性别（male/female）
 * @param ageYears 年龄（岁）
 * @param percentile 百分位（5/85/95）
 * @returns 对应百分位的 BMI 数值（按 0.1 精度四舍五入）
 */
function getChildPercentileBMI(sex: Sex, ageYears: number, percentile: Percentile): number {
  // 若已加载月龄数据，优先使用
  if (LOADED_CHILD_BMI) {
    const ageMonths = Math.round(ageYears * 12);
    if (sex === 'male') {
      return interpolateByMonths(LOADED_CHILD_BMI.male, ageMonths, percentile);
    } else {
      return interpolateByMonths(LOADED_CHILD_BMI.female, ageMonths, percentile);
    }
  }

  // 回退：使用内置整岁示例表（不含月龄）
  let set: PercentileSeriesSet;
  if (sex === 'male') {
    set = CHILD_BMI_TABLE.male;
  } else {
    set = CHILD_BMI_TABLE.female;
  }

  let series: PercentileSeries;
  switch (percentile) {
    case 5:
      series = set.p5;
      break;
    case 85:
      series = set.p85;
      break;
    case 95:
    default:
      series = set.p95;
      break;
  }

  const ages = series.ages;
  const vals = series.values;

  // 边界钳制：低于最小年龄取最小点，高于最大年龄取最大点
  if (ageYears <= ages[0]) {
    return +(vals[0]);
  }
  if (ageYears >= ages[ages.length - 1]) {
    return +(vals[vals.length - 1]);
  }

  // 若正好命中年龄点，直接返回
  for (let i = 0; i < ages.length; i++) {
    if (ageYears === ages[i]) {
      return +(vals[i]);
    }
  }

  // 在线性区间插值
  for (let i = 0; i < ages.length - 1; i++) {
    const a0 = ages[i];
    const a1 = ages[i + 1];
    if (ageYears > a0 && ageYears < a1) {
      const v = linearInterpolate(ageYears, a0, vals[i], a1, vals[i + 1]);
      return Math.round(v * 10) / 10;
    }
  }

  // 理论上不会到达这里，返回最后一个点
  return +(vals[vals.length - 1]);
}

/**
 * 依据身高与“性别×年龄”的 BMI 百分位，计算儿童/青少年的体重参考范围
 * - 输入：性别、年龄（年）、身高（cm）
 * - 计算：先获取 P5/P85/P95 的 BMI，再按 BMI×身高² 换算为体重区间
 * - 输出：偏瘦/标准/偏胖/超重四档的体重范围
 * @param sex 性别（male/female）
 * @param ageYears 年龄（岁）
 * @param heightCm 身高（cm）
 * @returns Range 数组（四档体重区间，单位 kg）
 */
function rangesByHeightForChild(sex: Sex, ageYears: number, heightCm: number): Range[] {
  const H = heightCm / 100;
  const p5 = getChildPercentileBMI(sex, ageYears, 5);
  const p85 = getChildPercentileBMI(sex, ageYears, 85);
  const p95 = getChildPercentileBMI(sex, ageYears, 95);
  const toW = (b: number) => +(b * H * H);
  return [
    { label: '偏瘦', bmiMax: p5, weightMax: toW(p5) },
    {
      label: '标准',
      bmiMin: p5,
      bmiMax: p85,
      weightMin: toW(p5),
      weightMax: toW(p85)
    },
    {
      label: '偏胖',
      bmiMin: p85,
      bmiMax: p95,
      weightMin: toW(p85),
      weightMax: toW(p95)
    },
    { label: '超重', bmiMin: p95, weightMin: toW(p95) },
  ];
}

/**
 * 体型分类
 * - 未成年（<18岁）：按“性别×年龄”的 P5/P85/P95 比较 BMI，返回偏瘦/标准/偏胖/超重
 * - 成年（≥18岁）：按中国成人 BMI 阈值分类；老年（≥65岁）使用抬升下限的阈值
 * 注意：成人阶段性别不改变 BMI 阈值，但可在产品层面叠加腰围/体脂率等性别化风险提示
 * @param age 年龄（岁）
 * @param sex 性别（male/female）
 * @param heightCm 身高（cm）
 * @param weightKg 体重（kg）
 * @returns 分类标签（偏瘦/标准/偏胖/超重）
 */
function classify(age: number, sex: Sex, heightCm: number, weightKg: number): '偏瘦' | '标准' | '偏胖' | '超重' {
  const v = bmi(weightKg, heightCm);
  if (age < 18) {
    const p5 = getChildPercentileBMI(sex, age, 5);
    const p85 = getChildPercentileBMI(sex, age, 85);
    const p95 = getChildPercentileBMI(sex, age, 95);
    if (v < p5) {
      return '偏瘦';
    }
    if (v < p85) {
      return '标准';
    }
    if (v < p95) {
      return '偏胖';
    }
    return '超重';
  } else {
    const t = adultThresholds(age);
    if (v < t.under) {
      return '偏瘦';
    }
    if (v <= t.normalMax) {
      return '标准';
    }
    if (v <= t.overweightMax) {
      return '偏胖';
    }
    return '超重';
  }
}
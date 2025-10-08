# FitnessTracker

## 概述

这是一个健康监测和评估的应用， 架构提供了完整的健康数据评估和持久化功能，包括：

- 健康状态评估
- 健康建议生成
- 健康评分计算
- 数据加载和保存
- 数据管理（增删查改）

## 架构设计

### commonui 通用UI，包括
- MButton 按钮
- MIcon 图标
- MLable 提示文案
- MLoading 加载中
- MMenu 菜单
- MNavigationTitle 导航栏
- MRadio 单选框
- MSelectButton 下拉菜单选择列表
- MTextInput 输入框

### views 子View组件
- HealthOverviewView 健康半弹层UI，包括

### thirds 三方组件
- MChart 图标组件，对EChart的二次封装

### ViewModel

### 1. HealthViewModel（抽象基类）
定义所有健康评估ViewModel的核心接口。

### 2. BaseHealthViewModel（通用基类）
- 继承自HealthViewModel
- 封装通用的健康状态处理方法
- 提供数据持久化功能

### 3. 具体实现类
- WeightViewModel（体重）
- BloodPressureViewModel（血压）
- BloodSugarViewModel（血糖）
- UricAcidViewModel（尿酸）
- BloodLipidViewModel（血脂）

<template>
  <div class="cockpit-container">
    <a-card class="mb-4">
      <div class="title-container">
        <span class="cockpit-title">驾驶舱</span>
        <div class="title-desc">
          驾驶舱展示主要经营指标行业的数据表现，并提供趋势和对比预警。主要部分可以根据卡片预置主题展示不同的图表。
        </div>
      </div>
      
      <!-- 筛选条件区域 -->
      <div class="filter-container mb-4">
        <a-radio-group v-model:value="timeFilter" button-style="solid" @change="handleFilterChange">
          <a-radio-button value="日">日</a-radio-button>
          <a-radio-button value="周">周</a-radio-button>
          <a-radio-button value="月">月</a-radio-button>
          <a-radio-button value="年">年</a-radio-button>
        </a-radio-group>
        
        <a-dropdown class="ml-3">
          <a-button>
            {{ regionFilter }}
            <down-outlined />
          </a-button>
          <template #overlay>
            <a-menu @click="handleRegionChange">
              <a-menu-item key="所有区域">所有区域</a-menu-item>
              <a-menu-item key="华东">华东</a-menu-item>
              <a-menu-item key="华南">华南</a-menu-item>
              <a-menu-item key="华北">华北</a-menu-item>
              <a-menu-item key="华西">华西</a-menu-item>
            </a-menu>
          </template>
        </a-dropdown>
      </div>
      
      <!-- 指标卡片区域 -->
      <div class="card-grid-container">
        <div class="indicator-card">
          <div class="indicator-title">客户数量</div>
          <div class="indicator-value">4.7K</div>
          <div class="indicator-compare negative">
            <span>vs PY</span>
            <span>-2.1%</span>
          </div>
        </div>
        
        <div class="indicator-card">
          <div class="indicator-title">有效订单</div>
          <div class="indicator-value">5.0K</div>
          <div class="indicator-compare positive">
            <span>vs PY</span>
            <span>+8.4%</span>
          </div>
        </div>
        
        <div class="indicator-card">
          <div class="indicator-title">交易金额</div>
          <div class="indicator-value">591.4M</div>
          <div class="indicator-compare positive">
            <span>vs PY</span>
            <span>+12.7%</span>
          </div>
        </div>
        
        <div class="indicator-card">
          <div class="indicator-title">订单均值</div>
          <div class="indicator-value">7.5K</div>
          <div class="indicator-compare negative">
            <span>vs PY</span>
            <span>-4.7%</span>
          </div>
        </div>
        
        <div class="indicator-card">
          <div class="indicator-title">客户交易率</div>
          <div class="indicator-value">36.0%</div>
          <div class="indicator-compare positive">
            <span>vs PY</span>
            <span>+0.8%</span>
          </div>
        </div>
      </div>
    </a-card>

    <div class="charts-container">
      <a-row :gutter="16">
        <a-col :span="12">
          <a-card title="指标趋势" class="chart-card">
            <div class="trend-container">
              <div class="filter-buttons">
                <a-radio-group v-model:value="trendType" button-style="solid" size="small" @change="handleTrendTypeChange">
                  <a-radio-button value="同比">同比</a-radio-button>
                  <a-radio-button value="环比">环比</a-radio-button>
                  <a-radio-button value="对比走势">对比走势</a-radio-button>
                </a-radio-group>
              </div>
              <div class="chart-container">
                <v-chart class="chart" :option="trendChartOption" autoresize />
              </div>
            </div>
          </a-card>
        </a-col>
        <a-col :span="12">
          <a-card title="区域分布" class="chart-card">
            <div class="chart-container">
              <v-chart class="chart" :option="regionChartOption" autoresize />
            </div>
          </a-card>
        </a-col>
      </a-row>

      <a-row :gutter="16" class="mt-4">
        <a-col :span="8">
          <a-card title="区域TOP/BOTTOM N" class="chart-card">
            <div class="rank-tabs">
              <div class="tab-header">
                <div 
                  class="tab-item" 
                  :class="{ active: activeRankTab === 'top' }" 
                  @click="activeRankTab = 'top'"
                >
                  <span class="tab-text">TOP区域</span>
                </div>
                <div 
                  class="tab-item" 
                  :class="{ active: activeRankTab === 'bottom' }" 
                  @click="activeRankTab = 'bottom'"
                >
                  <span class="tab-text">BOTTOM区域</span>
                </div>
              </div>
              <transition name="fade" mode="out-in">
                <div class="rank-list" v-if="activeRankTab === 'top'" key="top">
                  <div v-for="(item, index) in topRegions" :key="index" class="rank-item">
                    <div class="rank-medal" v-if="index < 3">
                      {{ medalIcons[index] }}
                    </div>
                    <div class="rank-number" v-else>{{ index + 1 }}</div>
                    <div class="rank-name">{{ item.name }}</div>
                    <div class="rank-value">{{ item.value }}</div>
                    <div class="rank-change" :class="item.change.includes('-') ? 'negative' : 'positive'">{{ item.change }}</div>
                  </div>
                </div>
                <div class="rank-list" v-else key="bottom">
                  <div v-for="(item, index) in bottomRegions" :key="index" class="rank-item">
                    <div class="rank-number">{{ index + 1 }}</div>
                    <div class="rank-name">{{ item.name }}</div>
                    <div class="rank-value">{{ item.value }}</div>
                    <div class="rank-change" :class="item.change.includes('-') ? 'negative' : 'positive'">{{ item.change }}</div>
                  </div>
                </div>
              </transition>
            </div>
          </a-card>
        </a-col>
        <a-col :span="16">
          <a-card title="大区达成" class="chart-card">
            <a-table
              :columns="areaColumns"
              :data-source="areaData"
              :pagination="false"
              size="middle"
            >
              <template #bodyCell="{ column, text, record }">
                <template v-if="column.dataIndex === 'comparison'">
                  <span :class="record.comparison < 0 ? 'down-text' : 'up-text'">
                    {{ record.comparison }}%
                  </span>
                </template>
                <template v-if="column.dataIndex === 'currentValue'">
                  <div class="progress-cell">
                    <a-progress
                      :percent="record.progressPercent"
                      :stroke-color="getProgressColor(record.progressPercent)"
                      :format="(percent) => `${percent.toFixed(1)}%`"
                    />
                  </div>
                </template>
              </template>
            </a-table>
          </a-card>
        </a-col>
      </a-row>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, reactive, onMounted } from 'vue';
import { use } from 'echarts/core';
import { CanvasRenderer } from 'echarts/renderers';
import { LineChart, BarChart } from 'echarts/charts';
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  MarkLineComponent,
} from 'echarts/components';
import VChart from 'vue-echarts';
import * as echarts from 'echarts/core';
import { DownOutlined } from '@ant-design/icons-vue';

// 注册必须的组件
use([
  CanvasRenderer,
  LineChart,
  BarChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent,
  MarkLineComponent,
]);

const timeFilter = ref('月');
const regionFilter = ref('所有区域');
const trendType = ref('同比');
const activeRankTab = ref('top');

// 筛选条件变化处理
const handleFilterChange = () => {
  // 模拟数据变化
  const randomChange = () => {
    return (Math.random() > 0.5 ? '+' : '-') + (Math.random() * 10).toFixed(1) + '%';
  };
  
  // 简单模拟数值变化
  trendChartOption.series[0].data = Array.from({ length: 12 }, () => Math.floor(Math.random() * 4000) + 2000);
  trendChartOption.series[1].data = Array.from({ length: 12 }, () => Math.floor(Math.random() * 3500) + 1500);
  
  // 区域图表数据更新
  regionChartOption.series[0].data = [
    Math.floor(Math.random() * 250) + 150,
    Math.floor(Math.random() * 300) + 200,
    Math.floor(Math.random() * 250) + 150,
    Math.floor(Math.random() * 300) + 250,
    Math.floor(Math.random() * 200) + 100,
    Math.floor(Math.random() * 200) + 100,
    Math.floor(Math.random() * 200) + 100,
  ];
  
  // 更新排名数据
  topRegions.forEach((item, index) => {
    item.value = Math.floor(Math.random() * 100) + 250;
    item.change = randomChange();
  });
  
  bottomRegions.forEach((item, index) => {
    item.value = Math.floor(Math.random() * 100) + 50;
    item.change = randomChange();
  });
};

const handleRegionChange = (e: any) => {
  regionFilter.value = e.key;
  handleFilterChange();
};

const handleTrendTypeChange = () => {
  handleFilterChange();
};

// 指标趋势图配置
const trendChartOption = reactive({
  tooltip: {
    trigger: 'axis',
  },
  legend: {
    data: ['实际', '上年同期'],
    top: 0,
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '8%',
    top: '15%',
    containLabel: true,
  },
  xAxis: {
    type: 'category',
    boundaryGap: false,
    data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
  },
  yAxis: {
    type: 'value',
  },
  series: [
    {
      name: '实际',
      type: 'line',
      stack: '总量',
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 3,
        color: '#7546C9',
      },
      itemStyle: {
        color: '#7546C9',
      },
      data: [4500, 5000, 6800, 7500, 8900, 9500, 9200, 8700, 7800, 6900, 7200, 8500],
    },
    {
      name: '上年同期',
      type: 'line',
      stack: '总量',
      symbol: 'circle',
      symbolSize: 6,
      lineStyle: {
        width: 3,
        type: 'dashed',
        color: '#B4B4B4',
      },
      itemStyle: {
        color: '#B4B4B4',
      },
      data: [4000, 4500, 5900, 6800, 8100, 8700, 8400, 7900, 7100, 6300, 6500, 7800],
    },
  ],
});

// 区域柱状图数据
const regionChartOption = reactive({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  legend: {
    data: ['交易额']
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '3%',
    containLabel: true
  },
  xAxis: {
    type: 'value',
    boundaryGap: [0, 0.01]
  },
  yAxis: {
    type: 'category',
    data: ['华北', '华东', '华南', '华西', '东北', '西北', '西南']
  },
  series: [
    {
      name: '交易额',
      type: 'bar',
      data: [288, 336, 211, 349, 156, 185, 156],
      itemStyle: {
        color: function(params) {
          // 根据数据大小定义一个颜色渐变
          const colorList = [
            '#E0F2FE', '#BAE6FD', '#7DD3FC', '#38BDF8', 
            '#0EA5E9', '#0284C7', '#0369A1'
          ];
          const index = Math.floor(params.value / 50);
          return index < colorList.length ? colorList[index] : colorList[colorList.length - 1];
        }
      }
    }
  ]
});

// TOP区域数据
const medalIcons = [
  '🥇', // 金牌
  '🥈', // 银牌
  '🥉', // 铜牌
];

const topRegions = reactive([
  {
    name: '华东',
    value: 349,
    change: '+8.2%',
  },
  {
    name: '浙江',
    value: 336,
    change: '-1.7%',
  },
  {
    name: '青海',
    value: 334,
    change: '+6.6%',
  },
  {
    name: '河北',
    value: 330,
    change: '-6.9%',
  },
  {
    name: '北京',
    value: 288,
    change: '+6.8%',
  },
]);

// BOTTOM区域数据
const bottomRegions = reactive([
  {
    name: '西藏',
    value: 95,
    change: '-3.2%',
  },
  {
    name: '宁夏',
    value: 104,
    change: '+1.9%',
  },
  {
    name: '新疆',
    value: 95,
    change: '-8.5%',
  },
  {
    name: '甘肃',
    value: 99,
    change: '+4.3%',
  },
  {
    name: '内蒙古',
    value: 114,
    change: '-2.1%',
  },
]);

// 大区达成表格数据
const areaColumns = [
  {
    title: '大区',
    dataIndex: 'area',
    key: 'area',
    width: 100,
  },
  {
    title: '当前达成',
    dataIndex: 'currentValue',
    key: 'currentValue',
    width: 250,
  },
  {
    title: '同比',
    dataIndex: 'comparison',
    key: 'comparison',
    width: 100,
  },
];

const areaData = [
  {
    key: '1',
    area: '华西',
    currentValue: 1775,
    progressPercent: 70.5,
    comparison: -5.5,
  },
  {
    key: '2',
    area: '华南',
    currentValue: 1702,
    progressPercent: 65.2,
    comparison: -3.0,
  },
  {
    key: '3',
    area: '华东',
    currentValue: 1359,
    progressPercent: 58.7,
    comparison: -3.4,
  },
  {
    key: '4',
    area: '华北',
    currentValue: 1345,
    progressPercent: 52.3,
    comparison: -3.7,
  },
];

// 根据百分比获取进度条颜色
const getProgressColor = (percent: number) => {
  if (percent < 60) return '#f5222d';
  if (percent < 80) return '#faad14';
  return '#52c41a';
};

onMounted(() => {
  // 模拟初始数据加载
  handleFilterChange();
});
</script>

<style lang="less" scoped>
.cockpit-container {
  padding: 0 15px;
  
  .mb-4 {
    margin-bottom: 16px;
  }
  
  .ml-3 {
    margin-left: 12px;
  }

  .title-container {
    display: flex;
    flex-direction: column;
    margin-bottom: 16px;

    .cockpit-title {
      font-size: 20px;
      font-weight: 600;
      margin-bottom: 8px;
    }

    .title-desc {
      font-size: 14px;
      color: rgba(0, 0, 0, 0.45);
    }
  }
  
  .filter-container {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
  }

  .card-grid-container {
    display: flex;
    justify-content: space-between;
    flex-wrap: wrap;
    margin: 0 -8px;

    .indicator-card {
      flex: 1;
      min-width: 180px;
      background-color: #fff;
      border-radius: 4px;
      padding: 16px;
      margin: 0 8px;
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);

      .indicator-title {
        font-size: 14px;
        color: rgba(0, 0, 0, 0.45);
        margin-bottom: 8px;
      }

      .indicator-value {
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 8px;
      }

      .indicator-compare {
        display: flex;
        justify-content: space-between;
        font-size: 12px;

        &.positive {
          color: #52c41a;
        }

        &.negative {
          color: #f5222d;
        }
      }
    }
  }

  .chart-card {
    height: 100%;
    
    .trend-container {
      position: relative;
      height: 380px;
      
      .filter-buttons {
        position: absolute;
        top: 0;
        right: 0;
        z-index: 1;
      }
      
      .chart-container {
        height: 100%;
        width: 100%;
      }
    }
    
    .chart-container {
      height: 350px;
      width: 100%;
    }
    
    .chart {
      height: 100%;
      width: 100%;
    }
  }
  
  .rank-tabs {
    .tab-header {
      display: flex;
      border-bottom: 1px solid #f0f0f0;
      margin-bottom: 16px;

      .tab-item {
        padding: 8px 16px;
        cursor: pointer;
        font-size: 14px;
        color: rgba(0, 0, 0, 0.65);
        position: relative;
        transition: all 0.3s;

        &:hover {
          color: #1890ff;
        }

        &.active {
          color: #1890ff;
          
          &:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background-color: #1890ff;
          }
        }
      }
    }

    .rank-list {
      .rank-item {
        display: flex;
        align-items: center;
        padding: 8px 0;
        border-bottom: 1px solid #f0f0f0;
        transition: all 0.3s;
        
        &:hover {
          background-color: rgba(0, 0, 0, 0.02);
          transform: translateX(4px);
        }

        &:last-child {
          border-bottom: none;
        }

        .rank-medal {
          width: 24px;
          height: 24px;
          line-height: 24px;
          text-align: center;
          margin-right: 16px;
          font-size: 16px;
        }

        .rank-number {
          width: 24px;
          height: 24px;
          line-height: 24px;
          text-align: center;
          margin-right: 16px;
          font-size: 14px;
          border-radius: 12px;
          background-color: #f5f5f5;
        }

        .rank-name {
          flex: 1;
          font-size: 14px;
        }

        .rank-value {
          font-weight: bold;
          margin-right: 12px;
        }
        
        .rank-change {
          font-weight: bold;
          min-width: 50px;
          text-align: right;
          
          &.positive {
            color: #52c41a;
          }
          
          &.negative {
            color: #f5222d;
          }
        }
      }
    }
  }

  .progress-container {
    margin-top: 16px;

    .progress-item {
      margin-bottom: 16px;

      .progress-header {
        display: flex;
        justify-content: space-between;
        margin-bottom: 4px;

        .left {
          font-size: 14px;
          color: rgba(0, 0, 0, 0.65);
        }

        .right {
          display: flex;
          align-items: center;

          .percent {
            font-size: 14px;
            font-weight: 500;
            margin-right: 8px;
          }

          .change {
            font-size: 12px;
            
            &.positive {
              color: #52c41a;
            }
            
            &.negative {
              color: #f5222d;
            }
          }
        }
      }
    }
  }
  
  /* 过渡动画 */
  .fade-enter-active,
  .fade-leave-active {
    transition: opacity 0.3s, transform 0.3s;
  }
  .fade-enter-from,
  .fade-leave-to {
    opacity: 0;
    transform: translateY(10px);
  }
}
</style>

<template>
  <div class="chart-card">
    <Bar :data="chartData" :options="chartOptions" />
  </div>
</template>

<script setup lang="ts">
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale
} from 'chart.js'
import { Bar } from 'vue-chartjs'
import { computed } from 'vue'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const props = defineProps<{
  report: any[]
}>()

const chartData = computed(() => ({
  labels: props.report.map((item) => item.label),
  datasets: [
    {
      label: 'Total Profit',
      data: props.report.map((item) => Number(item.total_profit))
    }
  ]
}))

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false
}
</script>

<style scoped>
.chart-card {
  height: 350px;
  background: white;
  border-radius: 20px;
  padding: 20px;
}
</style>
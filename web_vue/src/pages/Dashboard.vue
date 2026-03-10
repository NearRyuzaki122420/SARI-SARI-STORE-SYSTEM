<template>
  <div :class="['dashboard-page', { dark: isDark }]">
    <div class="top-glow top-glow-1"></div>
    <div class="top-glow top-glow-2"></div>

    <header class="hero">
      <div class="hero-left">
        <p class="badge">Store Management Dashboard</p>
        <h1>Sari-Sari Store Overview</h1>
        <p class="hero-subtitle">
          Track your products, monitor sold items, and view profit reports in a clean modern dashboard.
        </p>
      </div>

      <div class="hero-actions">
        <button class="mode-btn" @click="toggleDarkMode">
          {{ isDark ? 'Light Mode' : 'Dark Mode' }}
        </button>
        <router-link to="/inventory" class="inventory-btn">Go to Inventory</router-link>
        <button class="logout-btn" @click="logout">Sign Out</button>
      </div>
    </header>

    <section class="stats-grid">
      <div class="stat-card">
        <span class="stat-label">Total Products</span>
        <h2>{{ products.length }}</h2>
      </div>
      <div class="stat-card">
        <span class="stat-label">Available Stocks</span>
        <h2>{{ totalStocks }}</h2>
      </div>
      <div class="stat-card">
        <span class="stat-label">Total Profit</span>
        <h2>₱{{ totalProfit }}</h2>
      </div>
    </section>

    <section class="panel">
      <div class="panel-title-row">
        <h2>Profit Report</h2>
        <span class="panel-tag">Sales Summary</span>
      </div>

      <div class="filters">
        <button @click="loadProfitReport('day')">By Day</button>
        <button @click="loadProfitReport('week')">By Week</button>
        <button @click="loadProfitReport('month')">By Month</button>
      </div>

      <div class="table-wrap" v-if="profitReport.length">
        <table>
          <thead>
            <tr>
              <th>Period</th>
              <th>Total Sales</th>
              <th>Total Profit</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in profitReport" :key="item.label">
              <td>{{ item.label }}</td>
              <td>₱{{ Number(item.total_sales).toFixed(2) }}</td>
              <td>₱{{ Number(item.total_profit).toFixed(2) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <p v-if="error" class="error">{{ error }}</p>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'

const products = ref<any[]>([])
const sales = ref<any[]>([])
const profitReport = ref<any[]>([])
const error = ref('')
const isDark = ref(localStorage.getItem('darkMode') === 'true')
const router = useRouter()

const fetchData = async () => {
  try {
    const productRes = await api.get('/products')
    const salesRes = await api.get('/sales')
    products.value = productRes.data
    sales.value = salesRes.data
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to load dashboard data'
  }
}

onMounted(fetchData)

const totalStocks = computed(() =>
  products.value.reduce((sum, p) => sum + Number(p.quantity), 0)
)

const totalProfit = computed(() =>
  sales.value.reduce((sum, s) => sum + Number(s.profit), 0).toFixed(2)
)

const loadProfitReport = async (filter: string) => {
  try {
    const res = await api.get(`/sales/profit-report?filter=${filter}`)
    profitReport.value = res.data
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to load report'
  }
}

const toggleDarkMode = () => {
  isDark.value = !isDark.value
  localStorage.setItem('darkMode', String(isDark.value))
}

const logout = () => {
  localStorage.removeItem('token')
  router.push('/')
}
</script>

<style scoped>
.dashboard-page {
  min-height: 100vh;
  padding: 28px;
  background:
    radial-gradient(circle at top left, rgba(56, 189, 248, 0.25), transparent 22%),
    radial-gradient(circle at top right, rgba(129, 140, 248, 0.24), transparent 24%),
    linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%);
  position: relative;
  transition: all 0.3s ease;
}

.dashboard-page.dark {
  background:
    radial-gradient(circle at top left, rgba(56, 189, 248, 0.12), transparent 22%),
    radial-gradient(circle at top right, rgba(129, 140, 248, 0.12), transparent 24%),
    linear-gradient(180deg, #0f172a 0%, #111827 100%);
  color: white;
}

.top-glow {
  position: absolute;
  border-radius: 999px;
  filter: blur(60px);
  opacity: 0.22;
  pointer-events: none;
}

.top-glow-1 {
  width: 220px;
  height: 220px;
  background: #38bdf8;
  top: 0;
  left: 0;
}

.top-glow-2 {
  width: 260px;
  height: 260px;
  background: #8b5cf6;
  top: 0;
  right: 0;
}

.hero {
  position: relative;
  z-index: 1;
  margin-bottom: 24px;
  padding: 28px;
  border-radius: 28px;
  background: linear-gradient(135deg, #0f172a, #1d4ed8, #06b6d4);
  color: white;
  box-shadow: 0 18px 40px rgba(29, 78, 216, 0.22);
  display: flex;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
}

.hero-left {
  max-width: 700px;
}

.hero-actions {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  flex-wrap: wrap;
}

.badge {
  display: inline-block;
  margin: 0 0 12px;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  font-size: 13px;
  font-weight: 600;
}

.hero h1 {
  margin: 0;
  font-size: 36px;
  font-weight: 800;
}

.hero-subtitle {
  margin-top: 10px;
  line-height: 1.6;
  color: rgba(255, 255, 255, 0.9);
}

.mode-btn,
.inventory-btn,
.filters button {
  padding: 12px 16px;
  border-radius: 14px;
  border: none;
  background: linear-gradient(135deg, #2563eb, #06b6d4);
  color: white;
  font-weight: 700;
  cursor: pointer;
  text-decoration: none;
  box-shadow: 0 10px 22px rgba(37, 99, 235, 0.22);
}

.logout-btn {
  padding: 12px 16px;
  border-radius: 14px;
  border: none;
  background: linear-gradient(135deg, #dc2626, #f97316);
  color: white;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 10px 22px rgba(220, 38, 38, 0.22);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 18px;
  margin-bottom: 24px;
  position: relative;
  z-index: 1;
}

.stat-card,
.panel {
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: blur(14px);
  border: 1px solid rgba(255, 255, 255, 0.68);
  box-shadow: 0 12px 32px rgba(15, 23, 42, 0.08);
}

.dashboard-page.dark .stat-card,
.dashboard-page.dark .panel {
  background: rgba(30, 41, 59, 0.78);
  border: 1px solid rgba(71, 85, 105, 0.6);
  color: white;
}

.stat-card {
  padding: 22px;
  border-radius: 24px;
}

.stat-label {
  display: block;
  font-size: 14px;
  color: #64748b;
  margin-bottom: 10px;
  font-weight: 600;
}

.dashboard-page.dark .stat-label {
  color: #cbd5e1;
}

.stat-card h2 {
  margin: 0;
  font-size: 30px;
  color: #0f172a;
}

.dashboard-page.dark .stat-card h2 {
  color: white;
}

.panel {
  position: relative;
  z-index: 1;
  margin-top: 24px;
  padding: 22px;
  border-radius: 26px;
}

.panel-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
  gap: 12px;
  flex-wrap: wrap;
}

.panel-title-row h2 {
  margin: 0;
  font-size: 24px;
}

.panel-tag {
  padding: 8px 14px;
  border-radius: 999px;
  background: linear-gradient(135deg, #dbeafe, #e0e7ff);
  color: #1d4ed8;
  font-size: 13px;
  font-weight: 700;
}

.table-wrap {
  overflow-x: auto;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 8px;
}

thead tr {
  background: linear-gradient(135deg, #eff6ff, #eef2ff);
}

.dashboard-page.dark thead tr {
  background: linear-gradient(135deg, #1e293b, #334155);
}

th, td {
  padding: 14px 12px;
  text-align: left;
}

td {
  border-bottom: 1px solid #eef2f7;
}

.dashboard-page.dark td {
  border-bottom: 1px solid #334155;
}

.error {
  margin-top: 14px;
  color: #dc2626;
  font-weight: 600;
}
</style>
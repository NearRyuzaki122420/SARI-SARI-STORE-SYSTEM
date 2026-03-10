<template>
  <div :class="['inventory-page', { dark: isDark }]">
    <header class="hero">
      <div>
        <p class="badge">Inventory Management</p>
        <h1>Store Inventory</h1>
        <p class="hero-subtitle">
          Add new items, restock existing products, mark products as sold, or remove phased-out products.
        </p>
      </div>

      <div class="hero-actions">
        <button class="mode-btn" @click="toggleDarkMode">
          {{ isDark ? 'Light Mode' : 'Dark Mode' }}
        </button>
        <router-link to="/dashboard" class="back-btn">Back to Dashboard</router-link>
      </div>
    </header>

    <section class="panel">
      <div class="panel-title-row">
        <h2>Add Product</h2>
        <span class="panel-tag">New Item</span>
      </div>

      <form class="product-form" @submit.prevent="addProduct">
        <input v-model="addForm.product_code" placeholder="Product Code" required />
        <input v-model="addForm.product_name" placeholder="Product Name" required />
        <input v-model="addForm.product_type" placeholder="Product Type" required />
        <input v-model.number="addForm.quantity" type="number" min="1" placeholder="Quantity" required />
        <input v-model.number="addForm.cost_price" type="number" step="0.01" min="0" placeholder="Cost Price" required />
        <input v-model.number="addForm.selling_price" type="number" step="0.01" min="0" placeholder="Selling Price" required />
        <button type="submit">Add Product</button>
      </form>
    </section>

    <section class="panel">
      <div class="panel-title-row">
        <h2>Restock Product</h2>
        <span class="panel-tag">Existing Item</span>
      </div>

      <form class="product-form" @submit.prevent="restockProduct">
        <select v-model="restockForm.product_id" required>
          <option disabled value="">Select Product</option>
          <option v-for="product in products" :key="product.id" :value="product.id">
            {{ product.product_name }} - {{ product.product_type }}
          </option>
        </select>

        <input v-model.number="restockForm.quantity" type="number" min="1" placeholder="Restock Quantity" required />
        <input v-model.number="restockForm.cost_price" type="number" step="0.01" min="0" placeholder="Updated Cost Price (optional)" />
        <input v-model.number="restockForm.selling_price" type="number" step="0.01" min="0" placeholder="Updated Selling Price (optional)" />
        <button type="submit">Restock Product</button>
      </form>

      <p v-if="message" class="success">{{ message }}</p>
      <p v-if="error" class="error">{{ error }}</p>
    </section>

    <section class="panel">
      <div class="panel-title-row">
        <h2>Inventory List</h2>
        <span class="panel-tag">Stock View</span>
      </div>

      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Product Code</th>
              <th>Name</th>
              <th>Type</th>
              <th>Quantity</th>
              <th>Cost Price</th>
              <th>Selling Price</th>
              <th>Status</th>
              <th>Sell</th>
              <th>Delete</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="product in products" :key="product.id">
              <td>{{ product.id }}</td>
              <td>{{ product.product_code }}</td>
              <td>{{ product.product_name }}</td>
              <td>{{ product.product_type }}</td>
              <td>{{ product.quantity }}</td>
              <td>₱{{ Number(product.cost_price).toFixed(2) }}</td>
              <td>₱{{ Number(product.selling_price).toFixed(2) }}</td>
              <td>
                <span :class="product.status === 'Sold' ? 'status sold' : 'status available'">
                  {{ product.status }}
                </span>
              </td>
              <td>
                <div class="sell-box">
                  <input
                    type="number"
                    min="1"
                    :max="product.quantity"
                    v-model.number="sellQty[product.id]"
                    placeholder="Qty"
                  />
                  <button @click="sellProduct(product.id)" :disabled="product.quantity <= 0">
                    Sold
                  </button>
                </div>
              </td>
              <td>
                <button class="delete-btn" @click="deleteProduct(product.id)">
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import api from '../services/api'

const products = ref<any[]>([])
const message = ref('')
const error = ref('')
const sellQty = ref<Record<number, number>>({})
const isDark = ref(localStorage.getItem('darkMode') === 'true')

const addForm = ref({
  product_code: '',
  product_name: '',
  product_type: '',
  quantity: 1,
  cost_price: 0,
  selling_price: 0
})

const restockForm = ref({
  product_id: '',
  quantity: 1,
  cost_price: null as number | null,
  selling_price: null as number | null
})

const fetchProducts = async () => {
  try {
    const res = await api.get('/products')
    products.value = res.data
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to load products'
  }
}

onMounted(fetchProducts)

const addProduct = async () => {
  message.value = ''
  error.value = ''

  try {
    const res = await api.post('/products', addForm.value)
    message.value = res.data.message

    addForm.value = {
      product_code: '',
      product_name: '',
      product_type: '',
      quantity: 1,
      cost_price: 0,
      selling_price: 0
    }

    await fetchProducts()
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to add product'
  }
}

const restockProduct = async () => {
  message.value = ''
  error.value = ''

  if (!restockForm.value.product_id) {
    error.value = 'Please select a product to restock'
    return
  }

  try {
    const payload: any = {
      quantity: restockForm.value.quantity
    }

    if (restockForm.value.cost_price !== null && restockForm.value.cost_price !== 0) {
      payload.cost_price = restockForm.value.cost_price
    }

    if (restockForm.value.selling_price !== null && restockForm.value.selling_price !== 0) {
      payload.selling_price = restockForm.value.selling_price
    }

    const res = await api.put(`/products/restock/${restockForm.value.product_id}`, payload)
    message.value = res.data.message

    restockForm.value = {
      product_id: '',
      quantity: 1,
      cost_price: null,
      selling_price: null
    }

    await fetchProducts()
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to restock product'
  }
}

const sellProduct = async (id: number) => {
  message.value = ''
  error.value = ''

  const qty = sellQty.value[id]

  if (!qty || qty <= 0) {
    error.value = 'Enter a valid quantity to sell'
    return
  }

  try {
    await api.put(`/products/sold/${id}`, {
      quantity_sold: qty
    })

    message.value = 'Product marked as sold'
    sellQty.value[id] = 0
    await fetchProducts()
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to sell product'
  }
}

const deleteProduct = async (id: number) => {
  message.value = ''
  error.value = ''

  const confirmed = window.confirm('Are you sure you want to delete this product?')
  if (!confirmed) return

  try {
    const res = await api.delete(`/products/${id}`)
    message.value = res.data.message
    await fetchProducts()
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to delete product'
  }
}

const toggleDarkMode = () => {
  isDark.value = !isDark.value
  localStorage.setItem('darkMode', String(isDark.value))
}
</script>

<style scoped>
.inventory-page {
  min-height: 100vh;
  padding: 28px;
  background:
    radial-gradient(circle at top left, rgba(56, 189, 248, 0.25), transparent 22%),
    radial-gradient(circle at top right, rgba(129, 140, 248, 0.24), transparent 24%),
    linear-gradient(180deg, #f8fbff 0%, #eef4ff 100%);
  transition: all 0.3s ease;
}

.inventory-page.dark {
  background: linear-gradient(180deg, #0f172a 0%, #111827 100%);
  color: white;
}

.hero {
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

.hero-actions {
  display: flex;
  gap: 12px;
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
.back-btn,
.product-form button,
.sell-box button {
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

.delete-btn {
  padding: 10px 14px;
  border-radius: 12px;
  border: none;
  background: linear-gradient(135deg, #dc2626, #f97316);
  color: white;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 10px 22px rgba(220, 38, 38, 0.22);
}

.panel {
  margin-top: 24px;
  padding: 22px;
  border-radius: 26px;
  background: rgba(255, 255, 255, 0.82);
  backdrop-filter: blur(14px);
  border: 1px solid rgba(255, 255, 255, 0.68);
  box-shadow: 0 12px 32px rgba(15, 23, 42, 0.08);
}

.inventory-page.dark .panel {
  background: rgba(30, 41, 59, 0.78);
  border: 1px solid rgba(71, 85, 105, 0.6);
  color: white;
}

.panel-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 18px;
  gap: 12px;
  flex-wrap: wrap;
}

.panel-tag {
  padding: 8px 14px;
  border-radius: 999px;
  background: linear-gradient(135deg, #dbeafe, #e0e7ff);
  color: #1d4ed8;
  font-size: 13px;
  font-weight: 700;
}

.product-form {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 14px;
}

.product-form input,
.product-form select,
.sell-box input {
  padding: 13px 14px;
  border-radius: 14px;
  border: 1px solid #dbe4f0;
  background: #f8fbff;
  outline: none;
  font-size: 14px;
}

.inventory-page.dark .product-form input,
.inventory-page.dark .product-form select,
.inventory-page.dark .sell-box input {
  background: #0f172a;
  border: 1px solid #334155;
  color: white;
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

.inventory-page.dark thead tr {
  background: linear-gradient(135deg, #1e293b, #334155);
}

th, td {
  padding: 14px 12px;
  text-align: left;
}

td {
  border-bottom: 1px solid #eef2f7;
}

.inventory-page.dark td {
  border-bottom: 1px solid #334155;
}

.sell-box {
  display: flex;
  gap: 8px;
  align-items: center;
}

.status {
  display: inline-block;
  padding: 7px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.status.available {
  background: #dcfce7;
  color: #15803d;
}

.status.sold {
  background: #fee2e2;
  color: #dc2626;
}

.success {
  margin-top: 14px;
  color: #15803d;
  font-weight: 600;
}

.error {
  margin-top: 14px;
  color: #dc2626;
  font-weight: 600;
}
</style>
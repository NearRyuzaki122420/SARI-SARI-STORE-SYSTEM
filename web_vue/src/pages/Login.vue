<template>
  <div class="auth-page">
    <div class="bg-shape shape-1"></div>
    <div class="bg-shape shape-2"></div>

    <div class="auth-card">
      <div class="brand">Sari-Sari Store</div>
      <h1>Welcome Back</h1>
      <p class="subtitle">Login to manage your inventory, sales, and profits.</p>

      <form @submit.prevent="login" class="auth-form">
        <div class="input-group">
          <label>Email</label>
          <input v-model="email" type="email" placeholder="Enter your email" required />
        </div>

        <div class="input-group">
          <label>Password</label>
          <input v-model="password" type="password" placeholder="Enter your password" required />
        </div>

        <button type="submit" class="primary-btn">Login</button>
      </form>

      <p v-if="error" class="error">{{ error }}</p>

      <p class="switch-link">
        Don’t have an account?
        <router-link to="/register">Create one</router-link>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '../services/api'
import { useRouter } from 'vue-router'

const email = ref('')
const password = ref('')
const error = ref('')
const router = useRouter()

const login = async () => {
  error.value = ''

  try {
    const res = await api.post('/auth/login', {
      email: email.value,
      password: password.value
    })

    localStorage.setItem('token', res.data.token)
    router.push('/dashboard')
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Invalid login credentials'
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 45%, #38bdf8 100%);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 24px;
  position: relative;
  overflow: hidden;
}

.bg-shape {
  position: absolute;
  border-radius: 999px;
  filter: blur(60px);
  opacity: 0.35;
}

.shape-1 {
  width: 280px;
  height: 280px;
  background: #60a5fa;
  top: 5%;
  left: 8%;
}

.shape-2 {
  width: 320px;
  height: 320px;
  background: #a78bfa;
  bottom: 8%;
  right: 10%;
}

.auth-card {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 430px;
  padding: 32px;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.14);
  backdrop-filter: blur(18px);
  -webkit-backdrop-filter: blur(18px);
  border: 1px solid rgba(255, 255, 255, 0.22);
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.18);
  color: white;
}

.brand {
  display: inline-block;
  padding: 8px 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  font-size: 13px;
  font-weight: 600;
  margin-bottom: 18px;
}

.auth-card h1 {
  font-size: 34px;
  margin: 0 0 8px;
  font-weight: 800;
}

.subtitle {
  margin: 0 0 24px;
  color: rgba(255, 255, 255, 0.82);
  line-height: 1.5;
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.input-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.input-group label {
  font-size: 14px;
  font-weight: 600;
}

.input-group input {
  padding: 14px 16px;
  border-radius: 16px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  outline: none;
  background: rgba(255, 255, 255, 0.12);
  color: white;
  font-size: 15px;
}

.input-group input::placeholder {
  color: rgba(255, 255, 255, 0.68);
}

.primary-btn {
  margin-top: 8px;
  padding: 14px;
  border: none;
  border-radius: 16px;
  background: linear-gradient(135deg, #facc15, #f97316);
  color: white;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 12px 24px rgba(249, 115, 22, 0.28);
}

.primary-btn:hover {
  transform: translateY(-1px);
}

.error {
  margin-top: 14px;
  color: #fecaca;
  font-size: 14px;
}

.switch-link {
  margin-top: 20px;
  text-align: center;
  color: rgba(255, 255, 255, 0.88);
}

.switch-link a {
  color: #fde68a;
  font-weight: 700;
  text-decoration: none;
}
</style>
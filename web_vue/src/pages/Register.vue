<template>
  <div class="auth-page">
    <div class="bg-shape shape-1"></div>
    <div class="bg-shape shape-2"></div>

    <div class="auth-card">
      <div class="brand">Create Account</div>
      <h1>Join the Store System</h1>
      <p class="subtitle">Register your account to start managing products and sales.</p>

      <form @submit.prevent="registerUser" class="auth-form">
        <div class="input-group">
          <label>Full Name</label>
          <input v-model="name" type="text" placeholder="Enter your full name" required />
        </div>

        <div class="input-group">
          <label>Email</label>
          <input v-model="email" type="email" placeholder="Enter your email" required />
        </div>

        <div class="input-group">
          <label>Password</label>
          <input v-model="password" type="password" placeholder="Create a password" required />
        </div>

        <button type="submit" class="primary-btn">Register</button>
      </form>

      <p v-if="message" class="success">{{ message }}</p>
      <p v-if="error" class="error">{{ error }}</p>

      <p class="switch-link">
        Already have an account?
        <router-link to="/">Login</router-link>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import api from '../services/api'

const name = ref('')
const email = ref('')
const password = ref('')
const error = ref('')
const message = ref('')
const router = useRouter()

const registerUser = async () => {
  error.value = ''
  message.value = ''

  try {
    const res = await api.post('/auth/register', {
      name: name.value,
      email: email.value,
      password: password.value
    })

    message.value = res.data.message || 'Registered successfully'

    setTimeout(() => {
      router.push('/')
    }, 1000)
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Registration failed'
  }
}
</script>

<style scoped>
.auth-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #111827 0%, #2563eb 45%, #06b6d4 100%);
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
  filter: blur(65px);
  opacity: 0.35;
}

.shape-1 {
  width: 280px;
  height: 280px;
  background: #22d3ee;
  top: 8%;
  left: 7%;
}

.shape-2 {
  width: 340px;
  height: 340px;
  background: #c084fc;
  bottom: 8%;
  right: 8%;
}

.auth-card {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 440px;
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
  font-size: 32px;
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
  background: linear-gradient(135deg, #34d399, #14b8a6);
  color: white;
  font-size: 15px;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 12px 24px rgba(20, 184, 166, 0.28);
}

.success {
  margin-top: 14px;
  color: #bbf7d0;
}

.error {
  margin-top: 14px;
  color: #fecaca;
}

.switch-link {
  margin-top: 20px;
  text-align: center;
  color: rgba(255, 255, 255, 0.88);
}

.switch-link a {
  color: #bfdbfe;
  font-weight: 700;
  text-decoration: none;
}
</style>
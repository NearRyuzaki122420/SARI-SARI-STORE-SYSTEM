<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="brand">Password Recovery</div>
      <h1>Forgot Password</h1>
      <p class="subtitle">Enter your email address and we’ll send you a reset link.</p>

      <form @submit.prevent="submitForgotPassword" class="auth-form">
        <div class="input-group">
          <label>Email</label>
          <input v-model="email" type="email" placeholder="Enter your email" required />
        </div>

        <button type="submit" class="primary-btn">Send Reset Link</button>
      </form>

      <p v-if="message" class="success">{{ message }}</p>
      <p v-if="error" class="error">{{ error }}</p>

      <p class="switch-link">
        <router-link to="/">Back to Login</router-link>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import api from '../services/api'

const email = ref('')
const message = ref('')
const error = ref('')

const submitForgotPassword = async () => {
  message.value = ''
  error.value = ''

  try {
    const res = await api.post('/auth/forgot-password', {
      email: email.value
    })

    message.value = res.data.message || 'Password reset email sent successfully'
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to send reset email'
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
}

.auth-card {
  width: 100%;
  max-width: 430px;
  padding: 32px;
  border-radius: 28px;
  background: rgba(255, 255, 255, 0.14);
  backdrop-filter: blur(18px);
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
}

.switch-link a {
  color: #bfdbfe;
  font-weight: 700;
  text-decoration: none;
}
</style>
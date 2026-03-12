<template>
  <div class="auth-page">
    <div class="auth-card">
      <div class="brand">Set New Password</div>
      <h1>Reset Password</h1>
      <p class="subtitle">Enter your new password below.</p>

      <form @submit.prevent="submitResetPassword" class="auth-form">
        <div class="input-group">
          <label>New Password</label>
          <input v-model="newPassword" type="password" placeholder="Enter new password" required />
        </div>

        <button type="submit" class="primary-btn">Reset Password</button>
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
import { useRoute, useRouter } from 'vue-router'
import api from '../services/api'

const route = useRoute()
const router = useRouter()
const token = route.query.token as string

const newPassword = ref('')
const message = ref('')
const error = ref('')

const submitResetPassword = async () => {
  message.value = ''
  error.value = ''

  try {
    const res = await api.post('/auth/reset-password', {
      token,
      newPassword: newPassword.value
    })

    message.value = res.data.message || 'Password reset successfully'

    setTimeout(() => {
      router.push('/')
    }, 1500)
  } catch (err: any) {
    error.value = err.response?.data?.message || 'Failed to reset password'
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
  background: linear-gradient(135deg, #facc15, #f97316);
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
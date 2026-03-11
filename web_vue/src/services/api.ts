import axios from 'axios'

const api = axios.create({
  baseURL: 'https://9b00-49-145-37-4.ngrok-free.app/api'
})

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  config.headers['ngrok-skip-browser-warning'] = 'true'
  return config
})

export default api
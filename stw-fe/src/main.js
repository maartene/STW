import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'

import { createApp } from 'vue'
import App from './App.vue'

const app = createApp(App)
app.mount('#app')

app.config.globalProperties.STW_API_ENDPOINT = process.env.VUE_APP_STW_API_URL || "http://localhost:8000"
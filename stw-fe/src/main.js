
import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css'

import { createApp } from 'vue'
import App from './App.vue'
import store from './store';

const app = createApp(App)
app.use(store);
app.mount('#app')

app.config.globalProperties.STW_API_ENDPOINT = process.env.VUE_APP_STW_API_URL || "http://localhost:8000"

//app.config.devtools = true;
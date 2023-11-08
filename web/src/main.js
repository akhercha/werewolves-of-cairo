import '@/assets/styles/index.scss'

import { createApp } from 'vue'

import App from '@/App.vue'
import i18n from '@/i18n'
import router from '@/router'
import store from '@/store'

const app = createApp(App).use(i18n).use(router).use(store)

app.mount('#root')

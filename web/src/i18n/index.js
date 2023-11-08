import { createI18n } from 'vue-i18n'

import messages from '@intlify/unplugin-vue-i18n/messages'

const datetimeFormats = {
  fr: {
    short: {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    },
    long: {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    },
    time: {
      hour: 'numeric',
      minute: 'numeric',
    },
  },
}

const numberFormats = {
  fr: {
    currency: {
      style: 'currency',
      currency: 'EUR',
      notation: 'standard',
    },
    percent: {
      style: 'percent',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    },
  },
}

const i18n = createI18n({
  locale: 'fr',
  fallbackLocale: 'fr',
  messages,
  datetimeFormats,
  numberFormats,
})

export default i18n

import { defineConfig } from 'cypress'

const frontendBaseUrl = process.env.CYPRESS_BASE_URL || 'http://127.0.0.1:5173'
const apiBaseUrl = process.env.CYPRESS_API_BASE_URL || 'http://127.0.0.1:8000'

export default defineConfig({
  e2e: {
    baseUrl: frontendBaseUrl,
    env: {
      API_BASE_URL: apiBaseUrl,
    },
    setupNodeEvents() {},
    specPattern: 'cypress/e2e/**/*.cy.{js,ts}',
  },
  video: true,
  videosFolder: 'cypress/videos',
  reporter: 'mocha-multi-reporters',
  reporterOptions: {
    reporterEnabled: 'mochawesome, mocha-junit-reporter',
    mochawesomeReporterOptions: {
      reportDir: 'cypress/cypress-report',
      overwrite: false,
      html: true,
      json: true,
    },
    mochaJunitReporterReporterOptions: {
      mochaFile: 'cypress/cypress-report/junit-[hash].xml',
      toConsole: false,
    },
  },
})

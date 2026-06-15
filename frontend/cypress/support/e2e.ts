import './commands'
import 'cypress-file-upload'

before(() => {
  const baseUrl = Cypress.config().baseUrl
  const apiBaseUrl = Cypress.env('API_BASE_URL') as string | undefined

  if (baseUrl) {
    cy.request('GET', baseUrl).its('status').should('eq', 200)
  }

  if (apiBaseUrl) {
    cy.request('GET', `${apiBaseUrl}/health`).its('status').should('eq', 200)
  }
})

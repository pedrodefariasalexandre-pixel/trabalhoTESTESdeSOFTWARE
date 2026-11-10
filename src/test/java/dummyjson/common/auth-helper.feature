# Helper reutilizável de autenticação (NÃO é um teste: a tag @ignore impede que rode sozinho).
# Uso em qualquer feature:
#   * def auth = callonce read('classpath:dummyjson/common/auth-helper.feature')
#   * header Authorization = 'Bearer ' + auth.token
@ignore
Feature: Helper - obter token de acesso na DummyJSON

  Scenario: Login e extração do accessToken
    # Permite sobrescrever as credenciais na chamada; se não vierem, usa as do karate-config.js
    * def user = karate.get('username', credentials.username)
    * def pass = karate.get('password', credentials.password)

    Given url baseUrl
    And path 'auth', 'login'
    And request { username: '#(user)', password: '#(pass)', expiresInMins: 30 }
    When method post
    Then status 200

    # Variável exportada para quem chamou este helper
    * def token = response.accessToken

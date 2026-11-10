@auth @login
Feature: Autenticação - POST /auth/login
  Como consumidor da API
  Quero me autenticar com usuário e senha
  Para receber um token de acesso (JWT)

  Background:
    # Arrange comum a todos os cenários deste arquivo
    Given url baseUrl
    And path 'auth', 'login'

  @smoke
  Scenario: Login válido retorna 200, token JWT e dados do usuário
    # Arrange
    And request { username: '#(credentials.username)', password: '#(credentials.password)' }
    # Act
    When method post
    # Assert: status + campos do corpo + contrato (schema)
    Then status 200
    And match response.username == credentials.username
    And match response.accessToken == '#string'
    And match response == read('classpath:dummyjson/common/schemas/login-response.json')

  Scenario Outline: Login inválido (<caso>) retorna 400 com mensagem de erro
    # Arrange
    And request { username: '<username>', password: '<password>' }
    # Act
    When method post
    # Assert
    Then status 400
    And match response == { message: '<mensagem>' }
    And match response !contains { accessToken: '#notnull' }

    Examples:
      | caso                | username        | password    | mensagem                         |
      | senha errada        | emilys          | senhaErrada | Invalid credentials              |
      | usuário inexistente | usuario_que_nao | qualquer    | Invalid credentials              |
      | campos vazios       |                 |             | Username and password required   |

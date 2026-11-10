@auth @me
Feature: Usuário autenticado - GET /auth/me
  Endpoint protegido: só responde com os dados do usuário dono do token.

  Background:
    # Reutiliza o helper: faz login UMA vez para todos os cenários deste arquivo
    * def auth = callonce read('classpath:dummyjson/common/auth-helper.feature')
    Given url baseUrl
    And path 'auth', 'me'

  @smoke
  Scenario: GET autenticado retorna 200 e os dados do usuário logado
    # Arrange
    And header Authorization = 'Bearer ' + auth.token
    # Act
    When method get
    # Assert: status, campos específicos e contrato
    Then status 200
    And match response.username == credentials.username
    And match response.id == '#number'
    And match response.email contains '@'
    # "contains deep": valida o subconjunto do contrato inclusive dentro de objetos aninhados (address)
    And match response contains deep read('classpath:dummyjson/common/schemas/user.json')

  Scenario: GET sem token retorna 401 e mensagem de token obrigatório
    # Arrange: nenhum header Authorization é enviado
    # Act
    When method get
    # Assert
    Then status 401
    And match response == { message: 'Access Token is required' }

  @defeito-conhecido
  Scenario: GET com token de assinatura inválida é rejeitado (API responde 500, o esperado seria 401)
    # Arrange: troca a assinatura (3ª parte do JWT) por um valor falso
    * def tokenAdulterado = auth.token.substring(0, auth.token.lastIndexOf('.')) + '.assinaturaFalsa'
    And header Authorization = 'Bearer ' + tokenAdulterado
    # Act
    When method get
    # Assert: o acesso é negado e nenhum dado de usuário vaza.
    # DEFEITO ENCONTRADO: a DummyJSON devolve 500 "invalid signature" em vez de 401.
    # O teste documenta o comportamento atual; quando a API for corrigida, trocar para "status 401".
    Then status 500
    And match response == { message: 'invalid signature' }
    And match response !contains { username: '#present' }

@products
Feature: Produtos - POST /auth/products/add (autenticado)
  A DummyJSON simula a criação: devolve o produto com um id novo, mas não persiste.

  Background:
    * def auth = callonce read('classpath:dummyjson/common/auth-helper.feature')
    Given url baseUrl
    And path 'auth', 'products', 'add'
    And header Authorization = 'Bearer ' + auth.token

  Scenario: Criar produto autenticado retorna 201 e ecoa os dados enviados
    # Arrange: massa de teste fictícia
    * def novoProduto = { title: 'Teclado Mecânico QA', price: 199.9, category: 'accessories' }
    And request novoProduto
    # Act
    When method post
    # Assert: status, campos e contrato
    Then status 201
    And match response contains novoProduto
    And match response.id == '#number'
    And match response == read('classpath:dummyjson/common/schemas/product.json')

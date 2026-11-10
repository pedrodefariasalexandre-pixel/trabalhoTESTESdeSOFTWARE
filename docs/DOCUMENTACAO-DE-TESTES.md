# Documentação de testes

## 1. Escopo

| Item | Descrição |
|---|---|
| Sistema testado | API pública DummyJSON (`https://dummyjson.com`) |
| Tipo de teste | Funcional automatizado de API (caixa-preta), com validação de contrato |
| Ferramenta | Karate 2.1.4 + JUnit 6, executado com Maven |
| Dentro do escopo | Autenticação (`POST /auth/login`), recurso protegido (`GET /auth/me`), criação autenticada (`POST /auth/products/add`) |
| Fora do escopo | Performance, segurança aprofundada, demais endpoints (carts, posts, users...) |
| Dados de teste | Credenciais públicas da documentação da DummyJSON (`emilys` / `emilyspass`) e massa fictícia. Nenhum dado pessoal ou real |
| Critério de aprovação | 100% dos cenários passando; qualquer falha deixa o pipeline vermelho |

## 2. Estratégia

- **Cenários positivos e negativos** para cada endpoint.
- **Três níveis de validação:** status HTTP, campos do corpo e contrato (schema).
- **Padrão AAA** em todos os cenários (Arrange, Act, Assert).
- **Dados fora do teste:** URL e credenciais vêm de variáveis de ambiente (`karate-config.js`).
- **Execução:** local (`./mvnw test` ou `rodar-no-windows.cmd`) e automática no GitHub Actions a cada push e pull request.

## 3. Casos de teste

Pré-condição geral: API acessível e credenciais de teste válidas.

| ID | Endpoint | Cenário | Dados de entrada | Resultado esperado | Arquivo | Status |
|---|---|---|---|---|---|---|
| CT01 | `POST /auth/login` | Login válido | `emilys` / `emilyspass` | `200`; `username` igual ao enviado; `accessToken` no formato JWT; corpo conforme `login-response.json` | `auth/login.feature` | ✅ Passou |
| CT02 | `POST /auth/login` | Senha errada | `emilys` / `senhaErrada` | `400`; `{ "message": "Invalid credentials" }`; sem token | `auth/login.feature` | ✅ Passou |
| CT03 | `POST /auth/login` | Usuário inexistente | `usuario_que_nao` / `qualquer` | `400`; `Invalid credentials`; sem token | `auth/login.feature` | ✅ Passou |
| CT04 | `POST /auth/login` | Campos vazios | usuário e senha vazios | `400`; `Username and password required`; sem token | `auth/login.feature` | ✅ Passou |
| CT05 | `GET /auth/me` | Acesso autenticado | Header `Authorization: Bearer <token válido>` | `200`; `username` do usuário logado; `id` numérico; e-mail com `@`; corpo conforme `user.json` | `auth/auth-me.feature` | ✅ Passou |
| CT06 | `GET /auth/me` | Sem token | Nenhum header de autorização | `401`; `{ "message": "Access Token is required" }` | `auth/auth-me.feature` | ✅ Passou |
| CT07 | `GET /auth/me` | Token com assinatura adulterada | Token válido com a 3ª parte trocada | Acesso negado, sem dados do usuário. **Esperado pela boa prática: `401`. Obtido: `500`** (ver defeito D01) | `auth/auth-me.feature` | ⚠️ Passou documentando o defeito |
| CT08 | `POST /auth/products/add` | Criar produto autenticado | Token válido + `{ title, price, category }` fictícios | `201`; resposta contém os dados enviados; `id` numérico; corpo conforme `product.json` | `products/add-product.feature` | ✅ Passou |

CT02 a CT04 são um único `Scenario Outline` executado com três linhas de dados.

## 4. Rastreabilidade com o enunciado

| Requisito do trabalho | Casos que atendem |
|---|---|
| Pelo menos 1 teste com GET ou POST | CT01 a CT08 |
| Com autenticação | CT05, CT08 (usam o token do login) |
| Validar status HTTP | Todos |
| Validar campos do corpo | Todos |
| Login válido (200 + token) | CT01 |
| Login inválido (400/401 + mensagem) | CT02, CT03, CT04 |
| GET autenticado (200 + campos) | CT05 |
| GET sem token ou com token inválido (401) | CT06 (401) e CT07 (defeito: 500) |
| POST opcional e validação de contrato | CT08; schemas em CT01, CT05, CT08 |

## 5. Defeito encontrado

| Campo | Descrição |
|---|---|
| ID | D01 |
| Título | `GET /auth/me` retorna 500 para token com assinatura inválida |
| Severidade | Média (o acesso é negado, mas o código de status está errado) |
| Passos | 1. Fazer login e obter o `accessToken`. 2. Trocar a última parte do token (assinatura). 3. Chamar `GET /auth/me` com `Authorization: Bearer <token adulterado>` |
| Resultado obtido | `500` com `{ "message": "invalid signature" }` |
| Resultado esperado | `401 Unauthorized`, pois é um erro do cliente (credencial inválida), não do servidor |
| Impacto | Clientes da API não conseguem distinguir token inválido de falha do servidor; monitoramento registra erro 5xx falso |
| Tratamento na suíte | CT07 documenta o comportamento atual com a tag `@defeito-conhecido`. Quando a API for corrigida, trocar para `status 401` |

## 6. Registro de execução

| Item | Valor |
|---|---|
| Data | 10/11/2026 |
| Ambiente | Local (Linux, Java 21) e GitHub Actions (`ubuntu-latest`, Java 21) |
| Total de cenários | 8 |
| Passaram | 8 |
| Falharam | 0 |
| Duração | cerca de 2 segundos (5 threads em paralelo) |

## 7. Evidências

- **Relatório HTML:** `target/karate-reports/karate-summary.html`, gerado a cada execução, com request, response e asserções de cada passo.
- **Pipeline:** aba *Actions* do repositório; cada execução guarda o artifact `karate-report` por 14 dias.
- **Resumo dos testes:** aba *Checks* de cada execução (gerado a partir do JUnit XML).

> Para a entrega, o grupo deve anexar um print do relatório e um print do pipeline verde em `docs/evidencias/`.

# Roteiro da apresentação (10 slides · ~14 min)

Cada integrante fica com uma parte técnica. **Todos** devem saber rodar a demo (ver Plano B).

| Integrante | Slides | Tema | Tempo |
|---|---|---|---|
| **Leticia Rocha Vaz Franco** | 1, 2, 3 | Abertura, o que é o Karate e como funciona | 3 min |
| **Filipe Barbosa da Silva** | 4, 5 | Prós/contras e configuração + autenticação | 3 min |
| **Giovana Alves de Oliveira** | 6, 7 | Cenários, padrão AAA, validações e escalabilidade | 4 min |
| **Pedro de Farias Alexandre** | 8, 9, 10 | CI/CD, demo ao vivo, defeito encontrado e conclusão | 4 min |

---

### Slide 1 — Título *(Leticia)*
- "Automação de Testes de API com Karate"
- Pedro de Farias Alexandre, Leticia Rocha Vaz Franco, Filipe Barbosa da Silva, Giovana Alves de Oliveira; disciplina, link do repositório (com QR code)
- API alvo: DummyJSON (pública, com autenticação JWT)

### Slide 2 — O que é o Karate *(Leticia)*
- Framework open-source (MIT) da Karate Labs, sobre a JVM (Java)
- Os testes são escritos em **Gherkin** (`Given/When/Then`), mas **sem step definitions**: as palavras-chave de HTTP já vêm prontas (`url`, `path`, `request`, `method`, `status`, `match`)
- Num único tool: testes de API, mocks, testes de performance (Gatling) e UI
- Versão usada: **Karate 2.1.4**, uma reescrita completa da v1 que exige Java 21

### Slide 3 — Como funciona *(Leticia)*
- Fluxo: `mvn test` → JUnit → `Runner` do Karate → lê o `karate-config.js` → executa os `.feature` **em paralelo** → gera o relatório HTML
- Tem motor JavaScript embutido para lógica e dados
- Diagrama: `Feature (.feature)` → `HTTP client` → `API` → `match` (asserção)

### Slide 4 — Vantagens, limitações e cenários de uso *(Filipe)*
- ✅ Pouco código, legível até para quem não é dev (PO e analista conseguem ler)
- ✅ `match` poderoso para JSON: comparação parcial, schemas com `#string`/`#number`/`#regex`
- ✅ Paralelismo nativo, relatório HTML pronto, roda em qualquer CI
- ❌ DSL própria (curva de aprendizado; erros de sintaxe só aparecem na execução)
- ❌ Exige JDK + Maven/Gradle, o que pesa para quem é de JS/Python
- ❌ Suporte de IDE mais limitado que o de código Java/TS puro
- Cenários de uso: testes de API REST/GraphQL, contratos entre microsserviços, mocks de dependências, smoke em pipeline

### Slide 5 — Configuração e autenticação *(Filipe)*
- `karate-config.js`: `baseUrl` e credenciais lidas de **variáveis de ambiente** (`karate.sysenv`), com valor padrão público
- Nada fica fixo no teste; trocar de ambiente = trocar variável
- `auth-helper.feature`: login → `accessToken`; reutilizado com `callonce` (um login por feature)
- Segurança: senha e token aparecem mascarados (`***`) no relatório

### Slide 6 — Cenários e validações *(Giovana)*
- 8 cenários: login válido, 3 inválidos (Scenario Outline), GET autenticado, sem token, token adulterado, POST de produto
- Padrão **AAA** marcado com comentários: Arrange (`url`/`request`/`header`) → Act (`method`) → Assert (`status`/`match`)
- Validação em 3 níveis: **status HTTP** → **campos** (`response.username == ...`) → **contrato** (`match response == read('schema.json')`)

### Slide 7 — Escalabilidade *(Giovana)*
- Organização por domínio (`auth/`, `products/`) + `common/` (helper e schemas)
- Novo endpoint = novo `.feature`; o runner descobre sozinho
- Novos dados = nova linha no `Examples`
- Tags (`@smoke`, `@auth`) para escolher o que rodar em cada etapa
- Execução paralela: 8 cenários em ~2 s
- Próximo passo: `karate.callSingle` para fazer um único login na suíte inteira

### Slide 8 — CI/CD com GitHub Actions *(Pedro)*
- Roda a cada push e PR, e também manualmente com filtro de tags
- Passos: Java 21 → `mvn test` → artifact `karate-report` → resumo na aba Checks
- Teste falhou → pipeline vermelho → o PR não deve ser mergeado (*quality gate*)
- Mostrar print do pipeline verde e do artifact

### Slide 9 — Demo ao vivo *(Pedro)*
- `mvn test` no terminal (logs `200`/`400`/`401`/`500`)
- Abrir o `karate-summary.html` → expandir o "GET autenticado" e mostrar request, response e asserções
- **Bônus:** mudar o `status 200` para `201` e rodar de novo para mostrar a falha e a mensagem clara
- **Defeito encontrado:** token adulterado retorna **500** em vez de **401**; foi documentado com a tag `@defeito-conhecido`

### Slide 10 — Valor para a empresa e conclusão *(Pedro)*
- **Qualidade:** regressão automática em cada mudança; o contrato quebrado é pego antes da produção
- **Velocidade:** feedback em segundos no PR; menos teste manual repetitivo
- **Custo:** testes legíveis, então qualquer pessoa do time mantém
- Prova: em minutos a suíte achou um defeito real (500 em vez de 401)
- Perguntas?

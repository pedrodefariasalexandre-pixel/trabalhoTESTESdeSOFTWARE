# Testes de API com Karate — DummyJSON

![API Tests](../../actions/workflows/api-tests.yml/badge.svg)

Suíte de **testes automatizados de API** com o **[Karate](https://karatelabs.io)** contra a API pública **[DummyJSON](https://dummyjson.com)**.
Ela cobre o fluxo de autenticação (`POST /auth/login` → `accessToken` → `GET /auth/me`) e a criação de produto autenticada. Os testes validam o **status HTTP**, os **campos do corpo** e o **contrato (schema)**. Tudo roda em **CI no GitHub Actions** e gera **relatório HTML**.

> Trabalho acadêmico de QA. Só usa dados fictícios e as credenciais **públicas** de teste da DummyJSON (`emilys` / `emilyspass`).

---

## Stack

| Item | Versão |
|---|---|
| Karate (`io.karatelabs:karate-junit6`) | 2.1.4 |
| JUnit Jupiter | 6.1.3 |
| Java (JDK) | 21 ou superior (**obrigatório** no Karate 2) |
| Maven | 3.9+ |

## Cenários cobertos

| # | Feature | Cenário | Esperado |
|---|---|---|---|
| 1 | `login.feature` | Login válido | `200` + `accessToken` (JWT) + schema |
| 2–4 | `login.feature` | Login inválido (senha errada, usuário inexistente, campos vazios) | `400` + `message` |
| 5 | `auth-me.feature` | GET autenticado | `200` + username/id/email + schema |
| 6 | `auth-me.feature` | GET **sem** token | `401` + `Access Token is required` |
| 7 | `auth-me.feature` | GET com token **adulterado** | `500` `invalid signature` ⚠️ *defeito conhecido da API: o esperado seria 401* |
| 8 | `add-product.feature` | POST autenticado `/auth/products/add` | `201` + ecoa os dados + schema |

## Estrutura

```
.
├── .github/workflows/api-tests.yml     # Pipeline CI: roda a cada push/PR e publica o relatório
├── pom.xml                             # Dependências (Karate, JUnit, Logback) e plugins Maven
├── .env.example                        # Nomes das variáveis de ambiente aceitas
├── docs/                               # Material da apresentação (roteiro, guia de estudo, plano B...)
└── src/test/java/
    ├── karate-config.js                # Config global: baseUrl e credenciais via variáveis de ambiente
    ├── logback-test.xml                # Nível de log do console
    └── dummyjson/
        ├── DummyJsonTest.java          # Runner JUnit: executa tudo em paralelo e gera os relatórios
        ├── auth/
        │   ├── login.feature           # POST /auth/login (positivo + negativos)
        │   └── auth-me.feature         # GET /auth/me (autenticado, sem token, token inválido)
        ├── products/
        │   └── add-product.feature     # POST /auth/products/add (autenticado)
        └── common/
            ├── auth-helper.feature     # Helper reutilizável: login → token (@ignore)
            └── schemas/*.json          # Contratos esperados (login, user, product)
```

## Pré-requisitos

- **JDK 21+**: confira com `java -version` ([Temurin](https://adoptium.net) recomendado)
- **Maven 3.9+**: confira com `mvn -v` ([download](https://maven.apache.org/download.cgi))
- **Git**
- Acesso à internet (a API é pública: https://dummyjson.com)

<details>
<summary>Instalação rápida do JDK e do Maven</summary>

**Windows (PowerShell, com winget):**
```powershell
winget install EclipseAdoptium.Temurin.21.JDK
winget install Apache.Maven
```
Feche e reabra o terminal depois de instalar.

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install -y openjdk-21-jdk maven
```
</details>

## Instalação

```bash
git clone https://github.com/pedrodefariasalexandre-pixel/trabalhoTESTESdeSOFTWARE.git
cd trabalhoTESTESdeSOFTWARE
mvn -B test-compile        # baixa as dependências e compila (só na primeira vez demora)
```

## Como executar

**Suíte completa** (Windows e Linux):
```bash
mvn test
```

**Só os testes de fumaça (`@smoke`):**
```bash
mvn test "-Dkarate.options=--tags @smoke"
```

**Um arquivo específico:**
```bash
mvn test "-Dkarate.options=classpath:dummyjson/auth/login.feature"
```

**Ignorando o cenário de defeito conhecido:**
```bash
mvn test "-Dkarate.options=--tags ~@defeito-conhecido"
```

### Variáveis de ambiente (opcional)

Sem nenhuma variável definida, valem os padrões públicos do `karate-config.js`.

| Variável | Padrão |
|---|---|
| `BASE_URL` | `https://dummyjson.com` |
| `DUMMYJSON_USERNAME` | `emilys` |
| `DUMMYJSON_PASSWORD` | `emilyspass` |

Linux / macOS:
```bash
export DUMMYJSON_USERNAME=emilys
export DUMMYJSON_PASSWORD=emilyspass
mvn test
```

Windows PowerShell:
```powershell
$env:DUMMYJSON_USERNAME="emilys"
$env:DUMMYJSON_PASSWORD="emilyspass"
mvn test
```

Windows CMD:
```bat
set DUMMYJSON_USERNAME=emilys
set DUMMYJSON_PASSWORD=emilyspass
mvn test
```

## Como ver o relatório

Depois da execução, abra no navegador:

```
target/karate-reports/karate-summary.html
```

- Linux: `xdg-open target/karate-reports/karate-summary.html`
- Windows: `start target\karate-reports\karate-summary.html`

O relatório mostra cada cenário com os passos, as requisições e respostas completas e o tempo de execução. Também há uma linha do tempo da execução paralela em `karate-timeline.html`.
Senhas e tokens aparecem **mascarados** (`***`).

Também é gerado **JUnit XML** em `target/karate-reports/junit-xml/`, que o CI usa para o resumo na aba *Checks*.

## CI/CD (GitHub Actions)

O arquivo `.github/workflows/api-tests.yml` roda a cada **push** e **pull request** e também manualmente (aba *Actions* → *API Tests (Karate)* → *Run workflow*, com filtro opcional de tags). Os passos são:

1. Instala o Java 21 com cache do Maven.
2. Executa `mvn test`. Se algum cenário falhar, o job fica **vermelho**.
3. Publica `target/karate-reports/` como **artifact** `karate-report`. Para baixar: aba *Actions* → abra a execução → seção *Artifacts*.
4. Publica o resumo dos testes na aba *Checks*.

## Como a suíte cresce

- **Novo endpoint:** crie um `.feature` na pasta do domínio (ex.: `carts/`). O runner encontra o arquivo sozinho.
- **Endpoint protegido:** reutilize `common/auth-helper.feature` com `callonce`, sem repetir código de login.
- **Novo contrato:** crie um JSON em `common/schemas/` e valide com `match`.
- **Novos dados:** acrescente linhas na tabela `Examples` do `Scenario Outline`.
- **Novo ambiente:** use `-Dkarate.env=hml` e `BASE_URL`, sem tocar nos testes.
- **Execução seletiva:** use tags (`@smoke`, `@auth`, `@products`).

## Documentação da apresentação

- [Plano de execução](docs/PLANO-DE-EXECUCAO.md)
- [Roteiro dos slides e divisão das falas](docs/APRESENTACAO.md)
- [Guia de estudo + perguntas do professor](docs/GUIA-DE-ESTUDO.md)
- [Plano B da demo](docs/PLANO-B.md)
- [Comparativo de ferramentas](docs/COMPARATIVO.md)

## Equipe

| Integrante | Responsabilidade na apresentação |
|---|---|
| Integrante 1 | Ferramenta: visão geral |
| Integrante 2 | Configuração e autenticação |
| Integrante 3 | Cenários e validações |
| Integrante 4 | Escalabilidade e CI/CD |
| Integrante 5 | Demo ao vivo e relatório |

# Guia de estudo do código

## Arquivo por arquivo (em linguagem simples)

### `pom.xml`
É a "lista de compras" do Maven. Ele declara:
- **karate-junit6 2.1.4**: o Karate em si, mais a ponte com o JUnit
- **junit-jupiter 6.1.3**: o JUnit, que é quem o `mvn test` sabe executar. No Karate 2 ele precisa ser declarado à parte.
- **logback-classic**: imprime os logs no console
- `<testResources>`: diz ao Maven para copiar os `.feature`, `.json` e `.js` de `src/test/java`. É a convenção do Karate: o teste fica ao lado do runner.
- Java **21**, porque o Karate 2 exige.

### `src/test/java/karate-config.js`
Roda **antes de cada cenário**. Tudo o que a função retorna vira variável global nas features (`baseUrl`, `credentials`).
- `karate.sysenv('BASE_URL', 'https://dummyjson.com')` lê a variável de ambiente e, se ela não existir, usa o padrão.
- `karate.env` é o ambiente escolhido com `-Dkarate.env=hml`.
- Também configura os timeouts e o **mascaramento** de senha e token nos relatórios.

### `dummyjson/common/auth-helper.feature`
É uma "função" em Gherkin: faz `POST /auth/login` e devolve `token`.
- A tag `@ignore` impede que ele rode como teste sozinho.
- Quem precisa de token chama `callonce read('classpath:...auth-helper.feature')`. O `callonce` executa o login **uma vez** por arquivo e guarda o resultado.

### `dummyjson/auth/login.feature`
- `Background`: o que se repete em todos os cenários (URL + path).
- **Login válido:** confere status 200, o `username` e o `accessToken` e valida o corpo inteiro contra `login-response.json`.
- **Scenario Outline:** o mesmo teste roda 3 vezes, uma por linha da tabela `Examples` (senha errada, usuário inexistente, campos vazios). Os valores entram pelos `<placeholders>`.

### `dummyjson/auth/auth-me.feature`
- **GET autenticado:** envia `Authorization: Bearer <token>` e valida os campos e o contrato com `contains deep` (o contrato confere só alguns campos, inclusive dentro de `address`).
- **Sem token:** espera `401` e a mensagem `Access Token is required`.
- **Token adulterado:** troca a assinatura do JWT. A API responde **500**, quando o correto seria 401. O teste documenta esse comportamento real e ficou com a tag `@defeito-conhecido`.

### `dummyjson/products/add-product.feature`
`POST /auth/products/add` com token. Espera `201`, verifica que a resposta contém o que foi enviado (`contains novoProduto`) e valida o contrato. A DummyJSON **simula** a criação e não salva nada.

### `dummyjson/common/schemas/*.json`
São os contratos esperados. Os marcadores do Karate fazem o papel de "tipo":
`#string`, `#number`, `#object`, `#notnull`, `#present`, `#regex <expressão>`.

### `dummyjson/DummyJsonTest.java`
Único código Java do projeto. Ele usa o `Runner` do Karate para:
- rodar tudo em `classpath:dummyjson`, exceto `@ignore`
- usar **5 threads** em paralelo
- gerar HTML e **JUnit XML**
- reprovar o teste JUnit se algum cenário falhar (`assertEquals(0, falhas)`), o que deixa o build/CI vermelho

### `logback-test.xml`
Nível de log do console. Em INFO, aparece uma linha por requisição.

### `.github/workflows/api-tests.yml`
Pipeline: checkout → Java 21 (com cache) → `mvn test` → upload do relatório como **artifact** (sempre, mesmo com falha) → resumo na aba Checks.

---

## Palavras-chave do Karate que vocês precisam dominar

| Palavra | O que faz |
|---|---|
| `url` / `path` | Monta o endereço (`path 'auth', 'me'` → `/auth/me`) |
| `request` | Corpo JSON da requisição |
| `header` | Define um header (ex.: `Authorization`) |
| `method get/post` | **Dispara** a requisição (o "Act") |
| `status 200` | Confere o status HTTP |
| `response` | Corpo da resposta já convertido para JSON |
| `match ==` | Igualdade **exata** (nenhum campo a mais nem a menos) |
| `match contains` | Igualdade **parcial** no 1º nível |
| `match contains deep` | Igualdade parcial também nos objetos aninhados |
| `match !contains` | Garante que algo **não** está presente |
| `def` | Cria uma variável |
| `read('...')` | Lê um arquivo (JSON, feature, JS) |
| `call` / `callonce` | Reutiliza outra feature (`callonce` = só 1 vez por arquivo) |

---

## 10 perguntas prováveis do professor

1. **Por que Karate, e não Postman ou REST Assured?**
   Ele tem a legibilidade do Gherkin sem precisar de step definitions, o `match` para JSON e o schema já vêm prontos, roda em paralelo nativamente e gera relatório sozinho. Escrevemos menos código para a mesma cobertura (ver `COMPARATIVO.md`).

2. **Isso é BDD/Cucumber?**
   Usa a sintaxe Gherkin, mas **não** é Cucumber. No Cucumber você escreve um step definition em código para cada frase. No Karate as frases (`url`, `method`, `match`) já são a implementação.

3. **Onde ficam a URL e as credenciais? Por que não no teste?**
   No `karate-config.js`, lidas de variáveis de ambiente com `karate.sysenv`. Assim trocamos de ambiente sem editar teste e, num projeto real, a senha viria de um *secret* do CI, sem ir para o código.

4. **Como funciona a autenticação?**
   O `auth-helper.feature` faz o login e guarda o `accessToken`. As features protegidas chamam o helper com `callonce` e mandam `Authorization: Bearer <token>`. O login fica num lugar só e não se repete.

5. **Qual a diferença entre `call` e `callonce`?**
   O `call` executa sempre que é chamado. O `callonce` executa uma vez por arquivo e reaproveita o resultado nos outros cenários. Para a suíte inteira existe o `karate.callSingle`.

6. **Como vocês validam o corpo da resposta?**
   Em três níveis: campos específicos (`response.username == credentials.username`), tipos (`'#number'`) e contrato completo (`match response == read('schema.json')`).

7. **O que acontece se a API mudar o formato da resposta?**
   O `match` do schema falha e mostra o caminho exato do campo diferente. O CI fica vermelho no PR, antes de chegar à produção.

8. **Por que o teste de token inválido espera 500?**
   Porque é o comportamento **real** da DummyJSON. O correto seria 401, então encontramos um defeito. Documentamos com a tag `@defeito-conhecido` e o comentário explica que, quando a API for corrigida, o teste muda para `status 401`. Outra opção seria deixar o teste falhando até a correção, mas isso esconderia outras falhas no pipeline.

9. **Como a suíte roda no CI e como se vê o resultado?**
   O GitHub Actions roda `mvn test` a cada push e PR. O relatório HTML vira um *artifact* para download, e o JUnit XML gera o resumo na aba Checks. Se um cenário falha, o job fica vermelho.

10. **Como a suíte cresce sem virar bagunça?**
    Uma pasta por domínio, um `.feature` por endpoint, helpers e schemas em `common/`, dados em `Examples` e tags para escolher o que rodar. O runner descobre os arquivos novos sozinho, então não é preciso registrar nada.

**Pergunta bônus: o que é o padrão AAA no Karate?**
Arrange = `url`, `path`, `header`, `request`. Act = `method`. Assert = `status` e `match`. Está marcado com comentários em cada cenário.

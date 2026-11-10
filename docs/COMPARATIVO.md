# Comparativo: Karate × REST Assured × Postman+Newman

| Critério | **Karate** | REST Assured | Postman + Newman |
|---|---|---|---|
| Linguagem dos testes | Gherkin + DSL própria (pouco código) | Java (código puro) | JavaScript nos scripts + interface gráfica |
| Curva para quem não programa | Baixa: lê como texto | Alta: precisa saber Java/JUnit | Baixa na interface; média nos scripts |
| Asserções em JSON | `match` nativo (exato, parcial, aninhado, `#regex`) | Hamcrest/JsonPath; mais verboso | `pm.expect` (Chai); manual |
| Validação de schema | Embutida (marcadores `#string`, `#number`) | Módulo `json-schema-validator` | `pm.response.to.have.jsonSchema` (JSON Schema) |
| Reuso (ex.: login) | `call`/`callonce` de outra feature | Métodos e classes Java | Pre-request script, variáveis de coleção |
| Paralelismo | Nativo (`parallel(5)`) | Via JUnit/TestNG (configuração extra) | Não nativo no Newman |
| Relatório | HTML pronto + JUnit XML | Precisa de plugin (Allure, Surefire) | Reporter extra (`htmlextra`) |
| Versionamento / code review | Ótimo (texto puro) | Ótimo | Fraco (JSON de coleção grande, diffs ruins) |
| Extra | Mocks, performance (Gatling) e UI na mesma ferramenta | Só API | Mock server e monitor (recursos na nuvem/pagos) |
| Pré-requisito | JDK 21 + Maven | JDK + Maven/Gradle | Node.js (Newman) |

## Por que adotamos o Karate
1. **Menos código, mesma cobertura:** um cenário de login tem cerca de 8 linhas. No REST Assured seriam classe, imports, builder e asserções Hamcrest.
2. **Legível para o time todo:** analistas e POs conseguem ler e revisar o teste num PR.
3. **Tudo embutido:** schema, paralelismo e relatório vêm prontos, sem montar várias bibliotecas.
4. **Melhor que Postman para escalar:** são arquivos texto, com diff e code review limpos e organização por pastas.

## Quando NÃO escolheríamos o Karate
- O time é forte em Java e quer reutilizar classes do sistema (DTOs, clientes): **REST Assured**
- Testes exploratórios rápidos ou um time sem nenhuma experiência com código: **Postman**

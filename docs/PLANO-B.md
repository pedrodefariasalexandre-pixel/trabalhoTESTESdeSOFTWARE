# Plano B da demo

## Preparação (fazer ANTES do dia)
- [ ] Gravar um **vídeo** de 1–2 min: `mvn test` → abrir o `karate-summary.html` → expandir o GET autenticado
- [ ] Salvar a pasta `target/karate-reports/` de uma execução bem-sucedida (zip) no pendrive **e** no drive
- [ ] Prints: terminal com "8 passed", relatório, pipeline verde no GitHub, artifact
- [ ] Rodar `mvn test` uma vez na máquina da apresentação para baixar as dependências (o cache do Maven fica em `~/.m2`)
- [ ] Deixar uma execução recente do GitHub Actions verde, com o artifact disponível
- [ ] Ter **2 integrantes** com o projeto rodando em notebooks diferentes

## Na hora: o que fazer em cada falha

| Falhou | Sintoma | Ação imediata |
|---|---|---|
| **API DummyJSON fora do ar** | `connect timed out`, 5xx em tudo | Mostrar a última execução **no GitHub Actions** e baixar o artifact. Se não der, abrir o relatório salvo e o vídeo. Frase: *"o teste detectou a indisponibilidade, que é exatamente o papel dele"* |
| **Sem internet** | Maven não baixa nada, API inacessível | Abrir o **relatório HTML offline** (zip) e passar o **vídeo**. Explicar o código direto na IDE |
| **Maven/Java quebrado na máquina** | `mvn: command not found`, erro de versão | Trocar para o notebook do 2º integrante. Se não der, rodar no GitHub (*Actions → Run workflow*, ~1 min) |
| **Teste falha inesperadamente** | Vermelho no terminal | **Aproveitar:** abrir o relatório e mostrar a mensagem do `match`, que indica o campo, o valor esperado e o valor real. Isso demonstra o valor da ferramenta |
| **Projetor/tela** | — | Slides em PDF no pendrive. Demo pelo vídeo no celular, se preciso |

## Execução mínima garantida (sem internet para o Maven)
Se as dependências já estiverem no cache e só faltar a internet "pesada":
```bash
mvn -o test            # -o = offline, usa só o cache ~/.m2 (ainda precisa acessar a API)
```

## Roteiro curto da demo ao vivo (2 min)
1. `mvn test "-Dkarate.options=--tags @smoke"` (mais rápido, 2 cenários)
2. Mostrar no console: `POST /auth/login 200` → `GET /auth/me 200`
3. Abrir `target/karate-reports/karate-summary.html` → cenário GET autenticado → request, response e `match`
4. (Se sobrar tempo) rodar a suíte completa e mostrar o cenário `@defeito-conhecido` (500)

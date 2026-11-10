# Plano de execução — deixar o trabalho pré-pronto hoje

Tempo total estimado: **~4h30** (dá para dividir entre os integrantes em paralelo a partir da etapa 3).

| # | Etapa | Responsável | Tempo | Status |
|---|---|---|---|---|
| 1 | Ter o Git e o JDK 21 (no Windows o `rodar-no-windows.cmd` providencia o JDK) | Todos | 20 min | ☐ |
| 2 | Repositório **público** no GitHub com o Actions verde | Pedro | — | ☑ |
| 3 | Cada integrante clona o repo e roda `./mvnw test` (no Windows: `rodar-no-windows.cmd`) na própria máquina | Todos | 15 min | ☐ |
| 4 | Abrir o `karate-summary.html` e navegar por um cenário (request/response) | Todos | 10 min | ☐ |
| 5 | Ler o `docs/GUIA-DE-ESTUDO.md` e o arquivo da sua parte | Todos | 40 min | ☐ |
| 6 | Montar os slides a partir do `docs/APRESENTACAO.md` | Leticia | 60 min | ☐ |
| 7 | Gravar o vídeo da demo (Plano B) e salvar prints + relatório | Giovana | 30 min | ☐ |
| 8 | Ensaio cronometrado com a demo ao vivo (meta: 12–15 min) | Todos | 40 min | ☐ |
| 9 | Treinar as 10 perguntas do guia de estudo (um pergunta, outro responde) | Todos | 30 min | ☐ |
| 10 | Revisão final: README, link do repo nos slides, badge do CI verde | Filipe | 15 min | ☐ |

## Critério de "pronto"
- [ ] `./mvnw test` (no Windows: `rodar-no-windows.cmd`) passa em pelo menos 2 máquinas do grupo
- [ ] Pipeline verde no GitHub com o artifact `karate-report` disponível
- [ ] Slides com o link do repositório
- [ ] Vídeo da demo + relatório HTML salvos offline (pendrive/drive)
- [ ] Cada integrante explica a própria parte **e** consegue rodar a demo sozinho

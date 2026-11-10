/*
 * karate-config.js
 * Executado automaticamente pelo Karate ANTES de cada cenário.
 * Tudo o que esta função retorna vira variável global nos arquivos .feature.
 *
 * Regra do projeto: URL e credenciais NUNCA ficam escritas nos testes.
 * Elas vêm de variáveis de ambiente, com um valor padrão (público e de teste).
 */
function fn() {
  // Ambiente escolhido com: mvn test -Dkarate.env=hml  (padrão: dev)
  var env = karate.env || 'dev';

  var config = {
    env: env,
    // karate.sysenv(NOME, padrão) lê uma variável de ambiente do sistema operacional
    baseUrl: karate.sysenv('BASE_URL', 'https://dummyjson.com'),
    credentials: {
      // Credenciais PÚBLICAS de teste documentadas em https://dummyjson.com/docs/auth
      username: karate.sysenv('DUMMYJSON_USERNAME', 'emilys'),
      password: karate.sysenv('DUMMYJSON_PASSWORD', 'emilyspass')
    }
  };

  // Para um novo ambiente (ex.: hml), basta rodar com -Dkarate.env=hml e BASE_URL apontando
  // para ele. Regras específicas de ambiente entram aqui, sem mexer nos .feature:
  // if (env === 'hml') { config.algumaFlag = true; }

  // Timeouts (ms): evita que a suíte fique travada se a API estiver lenta
  karate.configure('connectTimeout', 10000);
  karate.configure('readTimeout', 15000);

  // Não expõe segredos no relatório (o header Authorization já é mascarado por padrão no Karate 2)
  karate.configure('logging', {
    mask: { jsonPaths: ['$.password', '$.accessToken', '$.refreshToken'] }
  });

  return config;
}

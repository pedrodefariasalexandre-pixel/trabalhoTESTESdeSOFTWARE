package dummyjson;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Ponto de entrada da suíte (usado pelo "mvn test" e pelo CI).
 *
 * - Executa todas as .feature dentro de "dummyjson" em paralelo.
 * - Ignora os arquivos marcados com @ignore (ex.: o helper de login).
 * - Gera o relatório HTML em target/karate-reports/karate-summary.html
 *   e o JUnit XML (lido pelo GitHub Actions) em target/karate-reports/junit-xml/.
 * - Se qualquer cenário falhar, este teste JUnit falha -> o build/pipeline fica vermelho.
 *
 * Filtros sem mudar código: mvn test -Dkarate.options="--tags @smoke"
 */
class DummyJsonTest {

    @Test
    void executarSuiteDeApi() {
        SuiteResult result = Runner.path("classpath:dummyjson")
                .tags("~@ignore")
                .outputJunitXml(true)
                .parallel(5);

        assertEquals(0, result.getScenarioFailedCount(), String.join("\n", result.getErrors()));
    }
}

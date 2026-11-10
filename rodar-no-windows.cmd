@echo off
rem Roda a suite no Windows sem precisar instalar nada como administrador.
rem 1) Se nao houver Java 21+, baixa um JDK portatil (Temurin) para a pasta do usuario.
rem 2) Executa os testes com o Maven Wrapper (mvnw.cmd), que baixa o Maven sozinho.
rem Uso: rodar-no-windows.cmd            (suite completa)
rem      rodar-no-windows.cmd "-Dkarate.options=--tags @smoke"
setlocal
cd /d "%~dp0"
set "JDK_DIR=%USERPROFILE%\.jdk21-portatil"

java -version 2>&1 | findstr /R /C:"version \"2[1-9]" >nul
if %errorlevel%==0 goto rodar

if exist "%JDK_DIR%" goto usarportatil
echo Java 21 nao encontrado. Baixando JDK 21 portatil (~200 MB), aguarde...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; [Net.ServicePointManager]::SecurityProtocol='Tls12'; Invoke-WebRequest 'https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/jdk/hotspot/normal/eclipse' -OutFile \"$env:TEMP\jdk21.zip\"; Expand-Archive \"$env:TEMP\jdk21.zip\" \"$env:USERPROFILE\.jdk21-portatil\" -Force"
if errorlevel 1 goto erro

:usarportatil
for /d %%D in ("%JDK_DIR%\jdk-*") do set "JAVA_HOME=%%D"
if not defined JAVA_HOME goto erro
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo Usando JDK portatil em %JAVA_HOME%

:rodar
call mvnw.cmd test %*
set "RESULTADO=%errorlevel%"
echo.
echo Relatorio: target\karate-reports\karate-summary.html
echo Para abrir: start target\karate-reports\karate-summary.html
exit /b %RESULTADO%

:erro
echo.
echo Nao foi possivel preparar o Java 21. Verifique a internet ou instale o JDK 21 manualmente (https://adoptium.net).
exit /b 1

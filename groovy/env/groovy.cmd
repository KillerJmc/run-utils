@echo off

REM Usage1: groovy main.groovy
REM Usage2: groovy -cp "xxx.jar;lib/*" main.groovy

REM groovy jar name
set GROOVY_JAR=%~dp0/groovy-4.0.11.jar

REM -cp value pass to groovy.cmd
set LIB_PATH=

REM script path
set SCRIPT_PATH=%1

REM if -cp option specified, set %LIB_PATH%
if "%1" == "-cp" set LIB_PATH=%2 && set SCRIPT_PATH=%3

REM start groovy script
"%JAVA_HOME%/bin/java.exe" -cp "%GROOVY_JAR%;%LIB_PATH%" groovy.ui.GroovyMain "%SCRIPT_PATH%"


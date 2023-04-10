@echo off

REM Author: Jmc
REM Date: 2023.4.10

set INSTALL_DIR=C:\Program Files\run-utils

set RUN_JAVA_EXE_PATH=%INSTALL_DIR%\java\bin\RunJava.exe
set RUN_C_EXE_PATH=%INSTALL_DIR%\c\bin\RunC.exe
set RUN_CPP_EXE_PATH=%INSTALL_DIR%\cpp\bin\RunCpp.exe
set RUN_LUA_EXE_PATH=%INSTALL_DIR%\lua\bin\RunLua.exe
set RUN_GROOVY_EXE_PATH=%INSTALL_DIR%\groovy\bin\RunGroovy.exe
set RUN_PYTHON_EXE_PATH=%INSTALL_DIR%\python\bin\RunPython.exe

REM ensure run as Admin permission
whoami /groups | find "S-1-16-12288" >nul 2>&1
if "%errorlevel%" NEQ "0" powershell Start-Process cmd -Verb runAs -ArgumentList /c,%0 & exit /B

echo Copying repository to install dir...
xcopy /E /Y /I /Q "%~dp0" "%INSTALL_DIR%" >nul

echo Associating .java .jar
ftype RunUtils.java="%RUN_JAVA_EXE_PATH%" "%%1" >nul
ftype RunUtils.jar="%RUN_JAVA_EXE_PATH%" "%%1" >nul
assoc .java=RunUtils.java >nul
assoc .jar=RunUtils.jar >nul

echo Associating .c
ftype RunUtils.c="%RUN_C_EXE_PATH%" "%%1" >nul
assoc .c=RunUtils.c >nul

echo Associating .cpp
ftype RunUtils.cpp="%RUN_CPP_EXE_PATH%" "%%1" >nul
assoc .cpp=RunUtils.cpp >nul

echo Associating .lua
ftype RunUtils.lua="%RUN_LUA_EXE_PATH%" "%%1" >nul
assoc .lua=RunUtils.lua >nul

echo Associating .groovy
ftype RunUtils.groovy="%RUN_GROOVY_EXE_PATH%" "%%1" >nul
assoc .groovy=RunUtils.groovy >nul

echo Associating .py
ftype RunUtils.python="%RUN_PYTHON_EXE_PATH%" "%%1" >nul
assoc .py=RunUtils.python >nul

echo .
echo Install successfully finished!
pause

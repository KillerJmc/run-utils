@echo off

powershell -ExecutionPolicy Bypass -File "%~dp0\bin\RunLua.ps1" %*

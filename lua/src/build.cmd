@echo off

REM generate icon resource file
"%MINGW_HOME%/bin/windres.exe" icon.rc -O coff -o icon.o

REM generate exe with icon
"%MINGW_HOME%/bin/g++.exe" -o ../bin/RunLua.exe RunLua.cpp icon.o

REM remove icon.o
del icon.o

echo Build successfully!
pause

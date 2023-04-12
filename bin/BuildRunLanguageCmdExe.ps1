<#
����RunXXX.exe��RunXXX.cmd����ŵ�������Ŀ¼��bin�ļ�����

�÷���BuildRunLanguageCmdExe.ps1 $languageName

�����ļ�����״ͼ��
-- $languageName
  -- bin
    -- Run$languageNameCapitalize.ps1
  -- res
    -- $languageName.ico
    -- icon.rc

��״ͼ���ӣ�
  -- java
    -- bin
      -- RunJava.ps1
    -- res
      -- java.ico
      -- icon.rc
#>

# ����Ҳ���MINGW_HOME�ͱ���
if ($env:MINGW_HOME.Length -eq 0)
{
    Write-Error "�Ҳ���MINGW_HOME��"
    pause; return
}

# �ڻỰ�����MINGW�����dll���ļ�
$env:PATH += ";$env:MINGW_HOME\bin"

# ��������
$languageName = $args[0]

# ������������ĸ��д
$languageNameCapitalize = $languageName.Substring(0,1).ToUpper() + $languageName.Substring(1)

# runXxx���ƣ�����cpp���ƺ�����exe���ƣ�
$runLanguageName = "Run" + $languageNameCapitalize

# ����cpp·����RunXXX.cpp��
$runLanguageCppPath = ".\$runLanguageName.cpp"

# run-utils��·��
$rootPath = "$PSScriptRoot\.."
# �л�·��
cd $rootPath

# ����cmd·����RunXXX.cmd��
$runLanguageCmdPath = "$languageName\bin\$runLanguageName.cmd"

# ����exe·����RunXXX.exe��
$exePath = "$languageName\bin\$runLanguageName.exe"

# ͼ����Դ�����ļ���·����icon.rc��
$iconRcPath = "$languageName\res\icon.rc"

# ����ͼ����Դ�ļ�·����icon.o��
$iconResPath = "$languageName\res\icon.o"

# RunXXX.cmd������
$runLanguageCmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0\?.ps1" %*
"@.Replace("?", $runLanguageName)

# RunXXX.cpp������
$runLanguageCppContent = @"
#include <iostream>
#include <cstdlib>
#include <Windows.h>

std::string get_pwd()
{
	char exe_path[MAX_PATH];
	GetModuleFileNameA(NULL, exe_path, MAX_PATH);
	return std::string(exe_path).substr(0, std::string(exe_path).find_last_of('\\'));
}

std::string get_args_str(int argc, char* argv[])
{
	std::string args;
	for (int i = 1; i < argc; i++)
	{
		args += std::string(argv[i]) + " ";
	}
	return args;
}

std::string get_cmd(std::string pwd, std::string cmd_name, std::string args_str)
{
	return "\"" + pwd + "\\" + cmd_name + "\" " + args_str;
}

int main(int argc, char* argv[])
{
	auto pwd = get_pwd();
	auto args_str = get_args_str(argc, argv);
	auto cmd = get_cmd(pwd, "?.cmd", args_str);

	system(cmd.c_str());
}
"@.Replace("?", $runLanguageName)

# ��RunXXX.cmd���������Ŀ��·��
$runLanguageCmdContent | Out-File -Encoding default "$runLanguageCmdPath"

# ����ʱcpp����д��.cpp�ļ�
$runLanguageCppContent | Out-File -Encoding default "$runLanguageCppPath"

# ����ͼ����Դ�ļ���icon.o��
& "$env:MINGW_HOME\bin\windres.exe" "$iconRcPath" -O coff -o "$iconResPath"

# ���ɴ�ͼ���exe
& "$env:MINGW_HOME\bin\g++.exe" -static -o "$exePath" "$runLanguageCppPath" "$iconResPath"

# ɾ����ʱcpp�ļ���ͼ����Դ�ļ�
rm "$runLanguageCppPath"
rm "$iconResPath"

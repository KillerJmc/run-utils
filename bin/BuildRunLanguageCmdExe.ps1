<#
构建RunXXX.exe和RunXXX.cmd并存放到语言子目录的bin文件夹中

用法：BuildRunLanguageCmdExe.ps1 $languageName

所需文件的树状图：
-- $languageName
  -- bin
    -- Run$languageNameCapitalize.ps1
  -- res
    -- $languageName.ico
    -- icon.rc

树状图例子：
  -- java
    -- bin
      -- RunJava.ps1
    -- res
      -- java.ico
      -- icon.rc
#>

# 如果找不到MINGW_HOME就报错
if ($env:MINGW_HOME.Length -eq 0)
{
    Write-Error "找不到MINGW_HOME！"
    pause; return
}

# 在会话中添加MINGW所需的dll库文件
$env:PATH += ";$env:MINGW_HOME\bin"

# 语言名称
$languageName = $args[0]

# 语言名称首字母大写
$languageNameCapitalize = $languageName.Substring(0,1).ToUpper() + $languageName.Substring(1)

# runXxx名称（用于cpp名称和生成exe名称）
$runLanguageName = "Run" + $languageNameCapitalize

# 生成cpp路径（RunXXX.cpp）
$runLanguageCppPath = ".\$runLanguageName.cpp"

# run-utils根路径
$rootPath = "$PSScriptRoot\.."
# 切换路径
cd $rootPath

# 生成cmd路径（RunXXX.cmd）
$runLanguageCmdPath = "$languageName\bin\$runLanguageName.cmd"

# 生成exe路径（RunXXX.exe）
$exePath = "$languageName\bin\$runLanguageName.exe"

# 图标资源导向文件的路径（icon.rc）
$iconRcPath = "$languageName\res\icon.rc"

# 生成图标资源文件路径（icon.o）
$iconResPath = "$languageName\res\icon.o"

# RunXXX.cmd的内容
$runLanguageCmdContent = @"
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0\?.ps1" %*
"@.Replace("?", $runLanguageName)

# RunXXX.cpp的内容
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

# 将RunXXX.cmd内容输出到目标路径
$runLanguageCmdContent | Out-File -Encoding default "$runLanguageCmdPath"

# 将临时cpp内容写入.cpp文件
$runLanguageCppContent | Out-File -Encoding default "$runLanguageCppPath"

# 生成图标资源文件（icon.o）
& "$env:MINGW_HOME\bin\windres.exe" "$iconRcPath" -O coff -o "$iconResPath"

# 生成带图标的exe
& "$env:MINGW_HOME\bin\g++.exe" -static -o "$exePath" "$runLanguageCppPath" "$iconResPath"

# 删除临时cpp文件和图标资源文件
rm "$runLanguageCppPath"
rm "$iconResPath"

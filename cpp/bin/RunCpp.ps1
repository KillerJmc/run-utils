# RunJava
# Arthur: Jmc
# Date: 2022.4.9

# 如果找不到MINGW_HOME就报错
if ($env:MINGW_HOME.Length -eq 0)
{
    Write-Error "找不到MINGW_HOME！"
    pause; return
}

# 参数只能有一个
if ($args.Length -eq 0)
{
    Write-Warning "请输入要执行的文件，只能是单个cpp文件。"
    pause; return
}
elseif ($args.Length -gt 1)
{
    Write-Error "参数个数大于1！"
    pause; return
}

# 文件路径
$filePath = $args[0].ToString()

# 文件名
[string] $fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)

# 检查路径是否存在
if (-not (Test-Path $filePath))
{
    Write-Error "路径不存在！"
    pause; return
}

# 按情况执行
if ($filePath.EndsWith(".cpp"))
{
    # 临时C文件路径
    $tmpCppPath = [System.IO.Path]::GetTempPath() + "temp.cpp"

    # 临时C文件编译完的exe路径
    $tmpExePath = [System.IO.Path]::GetTempPath() + "temp.exe"

    # 转化源码的编码为系统编码并输出到临时c文件来解决编码问题
    cat -Encoding UTF8 $filePath | Out-File -Encoding default $tmpCppPath

    # 编译临时的c文件，获取exe文件
    & "$env:MINGW_HOME/bin/g++.exe" -o "$tmpExePath" "$tmpCppPath"

    # 执行exe文件
    & $tmpExePath

    # 清除临时c文件和编译完的exe文件
    rm $tmpCppPath
    rm $tmpExePath
}
else
{
    Write-Error "文件格式错误，仅支持cpp文件！"
    pause; return
}

# 退出信息
Write-Host -NoNewline "`n进程已退出，按任意键关闭此窗口. . ."
cmd /c "pause > nul"


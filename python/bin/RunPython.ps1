# RunPython
# Arthur: Jmc
# Date: 2023.4.10

# 如果找不到PYTHON_HOME就报错
if ($env:PYTHON_HOME.Length -eq 0)
{
    Write-Error "找不到PYTHON_HOME！"
    pause; return
}

# 参数只能有一个
if ($args.Length -eq 0)
{
    Write-Warning "请输入要执行的文件，只能是单个python文件。"
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

# 执行python脚本
if ($filePath.EndsWith(".py"))
{
    # 执行py文件
    & "$env:PYTHON_HOME\python.exe" "$filePath"
}
else
{
    Write-Error "文件格式错误，仅支持py文件！"
    pause; return
}

# 退出信息
Write-Host -NoNewline "`n进程已退出，按任意键关闭此窗口. . ."
cmd /c "pause > nul"


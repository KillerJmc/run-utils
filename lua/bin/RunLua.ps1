# RunLua
# Arthur: Jmc
# Date: 2023.3.31

# 参数只能有一个
if ($args.Length -eq 0)
{
    Write-Warning "请输入要执行的文件，只能是单个lua文件。"
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

# 执行lua脚本
if ($filePath.EndsWith(".lua"))
{
    # 临时Lua文件路径
    $tmpLuaPath = [System.IO.Path]::GetTempPath() + "temp.lua"

    # 转化源码的编码为系统编码并输出到临时Lua文件来解决编码问题
    cat -Encoding UTF8 $filePath | Out-File -Encoding default $tmpLuaPath

    # 执行临时Lua文件
    & "$PSScriptRoot\..\env\lua.exe" "$tmpLuaPath"

    # 清除临时Lua文件
    rm $tmpLuaPath
}
else
{
    Write-Error "文件格式错误，仅支持lua文件！"
    pause; return
}

# 退出信息
Write-Host -NoNewline "`n进程已退出，按任意键关闭此窗口. . ."
cmd /c "pause > nul"


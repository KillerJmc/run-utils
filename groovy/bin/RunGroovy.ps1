# RunGroovy
# Arthur: Jmc
# Date: 2023.3.31

# 如果找不到JAVA_HOME就报错
if ($env:JAVA_HOME.Length -eq 0)
{
    Write-Error "找不到JAVA_HOME！"
    pause; return
}

# 参数只能有一个
if ($args.Length -eq 0)
{
    Write-Warning "请输入要执行的文件，只能是单个groovy文件。"
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

# 执行groovy脚本
if ($filePath.EndsWith(".groovy"))
{
    # 临时Groovy文件路径
    $tmpGroovyPath = [System.IO.Path]::GetTempPath() + "temp.groovy"

    # 转化源码的编码为系统编码并输出到临时Groovy文件来解决编码问题
    cat -Encoding UTF8 $filePath | Out-File -Encoding default $tmpGroovyPath

    # 执行临时Groovy文件（如果有外部依赖需要把所有jar包放在同级目录或同级的lib目录中）
    & "$PSScriptRoot\..\env\groovy.cmd" -cp `""lib/*;."`" "$tmpGroovyPath"

    # 清除临时Groovy文件
    rm $tmpGroovyPath
}
else
{
    Write-Error "文件格式错误，仅支持groovy文件！"
    pause; return
}

# 退出信息
Write-Host -NoNewline "`n进程已退出，按任意键关闭此窗口. . ."
cmd /c "pause > nul"


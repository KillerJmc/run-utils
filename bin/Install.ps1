# 作者：Jmc
# 时间：2023.4.11

# 确保使用管理员权限执行脚本
$adminGroup = "S-1-5-32-544"
if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent().groups -match $adminGroup)) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 获取语言名称列表
function getLanguageNames($rootDir) {
    # 遍历时排除文件夹列表
    $excludeDirList = ".idea", "bin"
    # 通过遍历仓库文件夹，获取语言名称列表
    return ls -directory -exclude $excludeDirList $rootDir | select -expand name
}

# 通过语言名称列表获取扩展名名称列表
function getAssociationNames($languageNames) {
    # 编程语言名称到扩展名的映射表（特指名称和扩展名不同的）
    $diffLanguageNameToAssociacion = @{ python = "py" }
    # 额外需要映射的扩展名数组
    $extAssociationNames = @("jar")
    # 文件扩展名数组
    $associationNames = @() + $extAssociationNames

    # 构建文件扩展名数组
    foreach ($languageName in $languageNames) {
        # 获取扩展名并存入
        $associationNames += if ($diffLanguageNameToAssociacion.ContainsKey($languageName)) {
            $diffLanguageNameToAssociacion[$languageName]
        } else {
            $languageName
        }
    }
    return $associationNames
}

# 构建扩展名依赖的.reg文件并执行
function executeClearAssociationReg($asscoiationNames) {
    # 清除扩展名依赖的.reg文件路径
    $regPath = "$PSScriptRoot\ClearFileAssociations.reg"
    # 清除扩展名依赖的.reg文件内容
    $content = "Windows Registry Editor Version 5.00"
    # 清除扩展名依赖的reg列内容
    $columnTemplate = @"


[-HKEY_CLASSES_ROOT\.?]
[-HKEY_CLASSES_ROOT\?_auto_file]
[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.?]
"@

    # 遍历文件扩展名数组
    foreach ($asscoiationName in $asscoiationNames) {
        # 在清除扩展名依赖的reg内容字符串中添加清除扩展名依赖的列内容
        $content += $columnTemplate.Replace("?", $asscoiationName)
    }

    # 输出内容到指定文件路径
    $content > $regPath

    # 执行reg文件并删除
    regedit /s $regPath
    rm $regPath
}

# 将run-utils文件夹复制到安装目录
function copyRunUtilsToInstallDir($rootDir, $installDir) {
    # 如果存在旧的安装目录，进行删除
    $oldInstallLocation = "$installDir\run-utils"
    if (Test-Path $oldInstallLocation) {
        rm -r -force $oldInstallLocation
    }

    # 复制run-utils文件夹到安装目录
    cp -r -force $rootDir $installDir
}

# 通过编程语言名称构建RunXXX.exe和RunXXX.cmd到安装目录
function buildRunLanguageCmdExe($installDir, $languageNames) {
    # 要执行的脚本路径
    $scriptPath = "$installDir\run-utils\bin\BuildRunLanguageCmdExe.ps1"
    foreach ($languageName in $languageNames)
    {
        # 执行脚本来为每种编程语言构建cmd和exe文件
        & "$scriptPath" "$languageName"
    }
}

# 关联文件打开方式
function buildFileAssociations($languageNames, $associationNames, $installDir)
{
    foreach ($languageName in $languageNames)
    {
        # 语言名称首字母大写
        $languageNameCapitalize = $languageName.Substring(0, 1).ToUpper() + $languageName.Substring(1)

        # 执行cmd构建ftype（打开方式）
        cmd /c "ftype RunUtils.$languageName=`"$installDir\run-utils\$languageName\bin\Run$languageNameCapitalize.exe`" `"%1`"" | Out-Null
    }

    # 扩展名到编程语言名称的映射表（特指扩展名和语言名称不同的）
    $diffAssoiciationNameToLanguageName = @{
        py = "python"
        jar = "java"
    }
    foreach ($associationName in $associationNames)
    {
        # 通过扩展名获取语言名称
        $languageName = if ($diffAssoiciationNameToLanguageName.ContainsKey($associationName)) {
            $diffAssoiciationNameToLanguageName[$associationName]
        } else {
            $associationName
        }

        # 执行cmd将文件扩展名关联到正确的打开方式
        cmd /c "assoc .$associationName=RunUtils.$languageName" | Out-Null
    }
}

# run-utils文件夹路径
$rootDir = "$PSScriptRoot\.."

# 安装路径
$installDir = "C:\Program Files"

# 语言名称列表
$languageNames = getLanguageNames $rootDir

# 扩展名名称列表
$associationNames = getAssociationNames $languageNames

echo "安装run-utils`n"

echo "正在解除默认编程文件打开方式...`n"
executeClearAssociationReg $associationNames

echo "正在复制run-utils到安装目录...`n"
copyRunUtilsToInstallDir $rootDir $installDir

echo "正在构建exe文件到安装目录...`n"
buildRunLanguageCmdExe $installDir $languageNames

echo "正在关联文件默认打开方式...`n"
buildFileAssociations $languageNames $associationNames $installDir

echo "安装完成！"
pause


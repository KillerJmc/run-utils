# 作者：Jmc
# 时间：2023.4.12

# 确保使用管理员权限执行脚本
$adminGroup = "S-1-5-32-544"
if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent().groups -match $adminGroup)) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 获取语言名称列表
function getLanguageNames($rootDir) {
    # 遍历时排除文件夹列表
    $excludeDirList = ".git", ".idea", "bin"
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

# 去除关联编程文件打开方式
function removeLanguageFileAssociations($languageNames, $associationNames)
{
    foreach ($languageName in $languageNames)
    {
        # 执行cmd删除ftype（打开方式）
        cmd /c "ftype RunUtils.$languageName=" | Out-Null
    }

    foreach ($associationName in $associationNames)
    {
        # 执行cmd去除文件扩展名的打开方式（解除ftype绑定）
        cmd /c "assoc .$associationName=" | Out-Null
    }
}

# 从安装目录删除run-utils文件夹
function deleteRunUtilsFromInstallDir($installDir) {
    # 如果存在安装目录，进行删除
    if (Test-Path $installDir) {
        rm -r -force $installDir
    }
}

# run-utils文件夹路径
$rootDir = "$PSScriptRoot"

# 安装路径
$installDir = "C:\Program Files\run-utils"

# 语言名称列表
$languageNames = getLanguageNames $rootDir

# 扩展名名称列表
$associationNames = getAssociationNames $languageNames

echo "卸载run-utils`n"

echo "正在还原编程文件打开方式...`n"
removeLanguageFileAssociations $languageNames $associationNames

echo "正在删除安装目录中的run-utils文件夹...`n"
deleteRunUtilsFromInstallDir $installDir

echo "卸载完成！"
pause

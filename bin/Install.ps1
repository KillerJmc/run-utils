# ���ߣ�Jmc
# ʱ�䣺2023.4.11

# ȷ��ʹ�ù���ԱȨ��ִ�нű�
$adminGroup = "S-1-5-32-544"
if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent().groups -match $adminGroup)) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# ��ȡ���������б�
function getLanguageNames($rootDir) {
    # ����ʱ�ų��ļ����б�
    $excludeDirList = ".idea", "bin"
    # ͨ�������ֿ��ļ��У���ȡ���������б�
    return ls -directory -exclude $excludeDirList $rootDir | select -expand name
}

# ͨ�����������б��ȡ��չ�������б�
function getAssociationNames($languageNames) {
    # ����������Ƶ���չ����ӳ�����ָ���ƺ���չ����ͬ�ģ�
    $diffLanguageNameToAssociacion = @{ python = "py" }
    # ������Ҫӳ�����չ������
    $extAssociationNames = @("jar")
    # �ļ���չ������
    $associationNames = @() + $extAssociationNames

    # �����ļ���չ������
    foreach ($languageName in $languageNames) {
        # ��ȡ��չ��������
        $associationNames += if ($diffLanguageNameToAssociacion.ContainsKey($languageName)) {
            $diffLanguageNameToAssociacion[$languageName]
        } else {
            $languageName
        }
    }
    return $associationNames
}

# ������չ��������.reg�ļ���ִ��
function executeClearAssociationReg($asscoiationNames) {
    # �����չ��������.reg�ļ�·��
    $regPath = "$PSScriptRoot\ClearFileAssociations.reg"
    # �����չ��������.reg�ļ�����
    $content = "Windows Registry Editor Version 5.00"
    # �����չ��������reg������
    $columnTemplate = @"


[-HKEY_CLASSES_ROOT\.?]
[-HKEY_CLASSES_ROOT\?_auto_file]
[-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.?]
"@

    # �����ļ���չ������
    foreach ($asscoiationName in $asscoiationNames) {
        # �������չ��������reg�����ַ�������������չ��������������
        $content += $columnTemplate.Replace("?", $asscoiationName)
    }

    # ������ݵ�ָ���ļ�·��
    $content > $regPath

    # ִ��reg�ļ���ɾ��
    regedit /s $regPath
    rm $regPath
}

# ��run-utils�ļ��и��Ƶ���װĿ¼
function copyRunUtilsToInstallDir($rootDir, $installDir) {
    # ������ھɵİ�װĿ¼������ɾ��
    $oldInstallLocation = "$installDir\run-utils"
    if (Test-Path $oldInstallLocation) {
        rm -r -force $oldInstallLocation
    }

    # ����run-utils�ļ��е���װĿ¼
    cp -r -force $rootDir $installDir
}

# ͨ������������ƹ���RunXXX.exe��RunXXX.cmd����װĿ¼
function buildRunLanguageCmdExe($installDir, $languageNames) {
    # Ҫִ�еĽű�·��
    $scriptPath = "$installDir\run-utils\bin\BuildRunLanguageCmdExe.ps1"
    foreach ($languageName in $languageNames)
    {
        # ִ�нű���Ϊÿ�ֱ�����Թ���cmd��exe�ļ�
        & "$scriptPath" "$languageName"
    }
}

# �����ļ��򿪷�ʽ
function buildFileAssociations($languageNames, $associationNames, $installDir)
{
    foreach ($languageName in $languageNames)
    {
        # ������������ĸ��д
        $languageNameCapitalize = $languageName.Substring(0, 1).ToUpper() + $languageName.Substring(1)

        # ִ��cmd����ftype���򿪷�ʽ��
        cmd /c "ftype RunUtils.$languageName=`"$installDir\run-utils\$languageName\bin\Run$languageNameCapitalize.exe`" `"%1`"" | Out-Null
    }

    # ��չ��������������Ƶ�ӳ�����ָ��չ�����������Ʋ�ͬ�ģ�
    $diffAssoiciationNameToLanguageName = @{
        py = "python"
        jar = "java"
    }
    foreach ($associationName in $associationNames)
    {
        # ͨ����չ����ȡ��������
        $languageName = if ($diffAssoiciationNameToLanguageName.ContainsKey($associationName)) {
            $diffAssoiciationNameToLanguageName[$associationName]
        } else {
            $associationName
        }

        # ִ��cmd���ļ���չ����������ȷ�Ĵ򿪷�ʽ
        cmd /c "assoc .$associationName=RunUtils.$languageName" | Out-Null
    }
}

# run-utils�ļ���·��
$rootDir = "$PSScriptRoot\.."

# ��װ·��
$installDir = "C:\Program Files"

# ���������б�
$languageNames = getLanguageNames $rootDir

# ��չ�������б�
$associationNames = getAssociationNames $languageNames

echo "��װrun-utils`n"

echo "���ڽ��Ĭ�ϱ���ļ��򿪷�ʽ...`n"
executeClearAssociationReg $associationNames

echo "���ڸ���run-utils����װĿ¼...`n"
copyRunUtilsToInstallDir $rootDir $installDir

echo "���ڹ���exe�ļ�����װĿ¼...`n"
buildRunLanguageCmdExe $installDir $languageNames

echo "���ڹ����ļ�Ĭ�ϴ򿪷�ʽ...`n"
buildFileAssociations $languageNames $associationNames $installDir

echo "��װ��ɣ�"
pause


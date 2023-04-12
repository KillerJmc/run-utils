# ���ߣ�Jmc
# ʱ�䣺2023.4.12

# ȷ��ʹ�ù���ԱȨ��ִ�нű�
$adminGroup = "S-1-5-32-544"
if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent().groups -match $adminGroup)) {
    Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# ��ȡ���������б�
function getLanguageNames($rootDir) {
    # ����ʱ�ų��ļ����б�
    $excludeDirList = ".git", ".idea", "bin"
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

# ȥ����������ļ��򿪷�ʽ
function removeLanguageFileAssociations($languageNames, $associationNames)
{
    foreach ($languageName in $languageNames)
    {
        # ִ��cmdɾ��ftype���򿪷�ʽ��
        cmd /c "ftype RunUtils.$languageName=" | Out-Null
    }

    foreach ($associationName in $associationNames)
    {
        # ִ��cmdȥ���ļ���չ���Ĵ򿪷�ʽ�����ftype�󶨣�
        cmd /c "assoc .$associationName=" | Out-Null
    }
}

# �Ӱ�װĿ¼ɾ��run-utils�ļ���
function deleteRunUtilsFromInstallDir($installDir) {
    # ������ڰ�װĿ¼������ɾ��
    if (Test-Path $installDir) {
        rm -r -force $installDir
    }
}

# run-utils�ļ���·��
$rootDir = "$PSScriptRoot"

# ��װ·��
$installDir = "C:\Program Files\run-utils"

# ���������б�
$languageNames = getLanguageNames $rootDir

# ��չ�������б�
$associationNames = getAssociationNames $languageNames

echo "ж��run-utils`n"

echo "���ڻ�ԭ����ļ��򿪷�ʽ...`n"
removeLanguageFileAssociations $languageNames $associationNames

echo "����ɾ����װĿ¼�е�run-utils�ļ���...`n"
deleteRunUtilsFromInstallDir $installDir

echo "ж����ɣ�"
pause

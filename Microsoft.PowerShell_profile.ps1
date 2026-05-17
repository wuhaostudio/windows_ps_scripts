# 配置字体颜色
Set-PSReadLineOption -Colors @{
    ContinuationPrompt = "$([char]0x1b)[92m"
    Default            = "$([char]0x1b)[92m"
    Member             = "$([char]0x1b)[92m"
    Number             = "$([char]0x1b)[92m"
    Operator           = "$([char]0x1b)[92m"
    Parameter          = "$([char]0x1b)[92m"
    String             = "$([char]0x1b)[92m"
    Type               = "$([char]0x1b)[92m"
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
# 导入自定义函数:
$FuncDir = Join-Path (Split-Path $PROFILE -Parent) "Functions"
if (Test-Path $FuncDir) {
    Get-ChildItem -Path $FuncDir -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

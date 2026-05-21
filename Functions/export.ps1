function export {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $Arguments
    )

    $Name   = $null
    $Value  = $null
    $Scope  = 'User'          # 默认作用域
    $specifiedScopes = @()    # 记录用户指定了哪些作用域开关

    $i = 0
    while ($i -lt $Arguments.Count) {
        $arg = $Arguments[$i]

        switch -Wildcard ($arg) {
            '--help' {
                Write-Host @"
用法: export 变量名="值" [--User] [--Process] [--Machine]
默认作用域为 User (永久保存当前用户环境)。
--User      : 当前用户环境 (默认)
--Process   : 仅当前会话有效
--Machine   : 系统环境 (需要管理员权限)
"@
                return
            }
            '--User' {
                $Scope = 'User'
                $specifiedScopes += 'User'
            }
            '--Process' {
                $Scope = 'Process'
                $specifiedScopes += 'Process'
            }
            '--Machine' {
                $Scope = 'Machine'
                $specifiedScopes += 'Machine'
            }
            default {
                if ($arg -match '^([^=]+)=(.*)$') {
                    $Name  = $Matches[1]
                    $Value = $Matches[2]
                }
                else {
                    Write-Error "无法识别的参数: '$arg'。请使用 变量名=`"值`" 格式，或使用 --User/--Process/--Machine。"
                    return
                }
            }
        }
        $i++
    }

    # 检查是否指定了多个作用域
    $uniqueScopes = $specifiedScopes | Select-Object -Unique
    if ($uniqueScopes.Count -gt 1) {
        Write-Error "不能同时指定多个作用域开关。你指定了: $($uniqueScopes -join ', ')。请只使用其中一个。"
        return
    }

    if (-not $Name) {
        Write-Error "必须指定变量名和值，例如: export MY_VAR=`"hello`""
        return
    }

    # Machine 级别管理员权限检查
    if ($Scope -eq 'Machine') {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Error "设置 Machine 级别环境变量需要以管理员身份运行 PowerShell。"
            return
        }
    }

    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        Write-Host "✓ 环境变量 '$Name' 已设置 (作用域: $Scope)" -ForegroundColor Green
    }
    catch {
        Write-Error "设置失败: $_"
    }
}

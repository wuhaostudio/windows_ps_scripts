function unexport {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $Arguments
    )

    $Names = @()
    $Scope = 'User'
    $specifiedScopes = @()

    foreach ($arg in $Arguments) {
        switch -Wildcard ($arg) {
            '--help' {
                Write-Host @"
用法: unexport 变量名 [变量名...] [--User] [--Process] [--Machine]
默认作用域为 User (删除当前用户环境变量)。
--User      : 当前用户环境 (默认)
--Process   : 仅当前会话
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
                if ($arg -match '=') {
                    Write-Error "无法识别的参数: '$arg'。请只传入变量名，例如: unexport MY_VAR"
                    return
                }
                $Names += $arg
            }
        }
    }

    $uniqueScopes = $specifiedScopes | Select-Object -Unique
    if ($uniqueScopes.Count -gt 1) {
        Write-Error "不能同时指定多个作用域开关。你指定了: $($uniqueScopes -join ', ')。请只使用其中一个。"
        return
    }

    if ($Names.Count -eq 0) {
        Write-Error "必须指定变量名，例如: unexport MY_VAR"
        return
    }

    if ($Scope -eq 'Machine') {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        )
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Error "删除 Machine 级别环境变量需要以管理员身份运行 PowerShell。"
            return
        }
    }

    foreach ($Name in $Names) {
        try {
            [Environment]::SetEnvironmentVariable($Name, $null, $Scope)
            Write-Host "✓ 环境变量 '$Name' 已删除 (作用域: $Scope)" -ForegroundColor Green
        }
        catch {
            Write-Error "删除 '$Name' 失败: $_"
        }
    }
}

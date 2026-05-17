function sudo {
    [CmdletBinding()]
    param(
        [switch]$NoExit,          # 可选开关：执行后不退出窗口（默认保持窗口）
        [switch]$Hidden,          # 可选开关：隐藏窗口（后台静默执行）
        [switch]$UseCmd,          # 可选开关：用 CMD 而非 PowerShell 执行命令
        [parameter(Mandatory=$false, ValueFromRemainingArguments=$true)]
        [string[]]$CommandParts   # 接收用户输入的命令及参数（剩余所有参数）
    )

    # === 场景1：无命令输入时提示用法 ===
    if (-not $CommandParts) {
        Write-Host "`n用法：" -ForegroundColor Cyan
        Write-Host "  sudo [[-NoExit] | [-Hidden] | [-UseCmd]] <命令> [参数...]" -ForegroundColor White
        Write-Host "`n示例：" -ForegroundColor Cyan
        Write-Host "  sudo Get-Service wuauserv                     # 查看服务（保持窗口）" -ForegroundColor Gray
        Write-Host "  sudo -NoExit:$false sfc /scannow              # 执行后关闭窗口" -ForegroundColor Gray
        Write-Host "  sudo Get-Process | Where CPU -gt 50 | Sort CPU # 复杂管道命令" -ForegroundColor Gray
        Write-Host "  sudo -Hidden net start wuauserv                # 后台启动服务（无窗口）" -ForegroundColor Gray
        Write-Host "  sudo -UseCmd ipconfig /all                     # 用 CMD 执行命令" -ForegroundColor Gray
        return
    }

    $currentDir = (Get-Location).Path
    $directorySwitch = if ($UseCmd) {
        "cd /d `"$currentDir`" &&"
    }else {
        "Set-Location `"$currentDir`"; "
    }
    
    # === 场景2：拼接命令字符串（处理特殊符号） ===
    $fullCommand = $directorySwitch + ($CommandParts -join ' ')  # 用空格连接命令各部分

    # === 场景3：构建启动参数 ===
    $targetApp = if ($UseCmd) { "cmd" } else { "powershell" }  # 选择执行环境（CMD/PowerShell）
    $appArgs = @()  # 传递给目标应用的参数

    if ($UseCmd) {
        # 若用 CMD，参数格式为 /k（保持窗口）或 /c（执行后关闭），默认用 /k
        $cmdParam = if ($NoExit) { "/k" } else { "/c" }
        $appArgs += "$cmdParam $fullCommand"
    } else {
        # 若用 PowerShell，参数格式为 -Command（执行命令）+ 可选 -NoExit（保持窗口）
        $psParam = "-Command `"$fullCommand`""  # 用双引号包裹命令，避免解析错误
        if ($NoExit) { $psParam += " -NoExit" }  # 追加 -NoExit 保持窗口
        $appArgs += $psParam
    }

    # === 场景4：启动管理员权限进程 ===
    try {
        $processParams = @{
            FilePath     = $targetApp       # 目标程序（powershell 或 cmd）
            Verb         = "RunAs"          # 强制管理员权限（触发 UAC 弹窗）
            ArgumentList = $appArgs         # 传递给目标程序的参数
            WorkingDirectory = $currentDir
        }
        if ($Hidden) { $processParams.WindowStyle = "Hidden" }  # 隐藏窗口（后台执行）

        Write-Host "`n在目录 [$currentDir] 下以管理员权限执行命令：`n$fullCommand`n" -ForegroundColor Yellow
        Start-Process @processParams  # 启动进程
    } catch {
        Write-Error "提权失败！错误：$($_.Exception.Message)`n可能是 UAC 被拒绝或权限不足。" -ForegroundColor Red
    }
}

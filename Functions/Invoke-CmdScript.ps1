#支持将cmd子进程中的所有环境变量导入到当前powershell中，已模拟实现.bat文件在powershell中运行
function Invoke-CmdScript {
    param(
        [string]$scriptPath
    )
    # 在 cmd 中运行批处理，然后执行 set 命令输出所有环境变量
    $output = cmd /c "call `"$scriptPath`" && set"
    # 将输出的每一行解析为环境变量并导入当前 PowerShell 会话
    foreach ($line in $output) {
        if ($line -match '^([^=]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            Set-Item -Path "env:$name" -Value $value
        }
    }
}

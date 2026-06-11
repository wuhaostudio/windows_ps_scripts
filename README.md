# WindowsPowerShell Custom Profile

这个目录保存了一组 PowerShell 用户配置和自定义函数，适合放在
`$HOME\Documents\WindowsPowerShell` 下作为当前用户的 PowerShell 启动配置。

## 目录结构

```text
WindowsPowerShell/
├── Microsoft.PowerShell_profile.ps1
├── Functions/
│   ├── export.ps1
│   ├── Invoke-CmdScript.ps1
│   ├── Keep-Screen.ps1
│   ├── sudo.ps1
│   └── unset.ps1
├── Modules/
│   └── Microsoft.PowerShell.ThreadJob/
└── Scripts/
```

## Profile

### `Microsoft.PowerShell_profile.ps1`

PowerShell 启动时会自动加载这个 profile。当前配置做了两件事：

1. 如果检测到 Chocolatey profile，则导入它，用于启用 `choco` 命令的 Tab 补全。
2. 自动加载 `Functions` 目录下的所有 `*.ps1` 文件。

因此，把新的函数脚本放入 `Functions` 目录后，新开一个 PowerShell 窗口即可使用。

## Functions

### `sudo`

以管理员权限运行命令，会触发 Windows UAC 提权。

```powershell
sudo Get-Service wuauserv
sudo -UseCmd ipconfig /all
sudo -Hidden net start wuauserv
sudo -NoExit sfc /scannow
```

参数：

- `-UseCmd`: 使用 `cmd.exe` 执行命令，而不是 PowerShell。
- `-Hidden`: 隐藏启动窗口。
- `-NoExit`: 命令执行后保持窗口打开。

### `export`

以类似 Linux shell 的方式设置环境变量。默认写入当前用户环境变量。

```powershell
export MY_VAR="hello"
export MY_VAR="hello" --User
export MY_VAR="hello" --Process
export MY_VAR="hello" --Machine
export --help
```

作用域：

- `--User`: 当前用户环境变量，默认值，持久保存到 `HKCU\Environment`。
- `--Process`: 仅当前 PowerShell 进程有效，关闭窗口后失效。
- `--Machine`: 系统环境变量，持久保存到系统级环境变量位置，需要管理员权限。

### `unset`

删除由 `export` 或系统环境变量机制设置的环境变量。默认删除当前用户环境变量。

```powershell
unset MY_VAR
unset MY_VAR --User
unset MY_VAR --Process
unset MY_VAR --Machine
unset A B C --User
unset --help
```

作用域规则与 `export` 一致。删除 `--Machine` 级环境变量需要管理员权限。

### `Invoke-CmdScript`

在 PowerShell 中执行 `.bat` 或 `.cmd` 脚本，并把 cmd 子进程中的环境变量导入当前
PowerShell 会话。

这对于需要运行传统批处理初始化脚本的工具链很有用，例如某些编译器环境初始化脚本。

```powershell
Invoke-CmdScript "C:\path\to\setup.bat"
```

### `Keep-Screen`

静默运行指定的 VBS 启动器：

```powershell
Keep-Screen
```

当前脚本内写死的路径为：

```text
C:\Scripts\Terminal\launcher.vbs
```

如果该文件不存在，函数会输出错误并停止。

## Modules

### `Microsoft.PowerShell.ThreadJob`

目录中包含 `Microsoft.PowerShell.ThreadJob` 模块。它没有在 profile 中显式导入，
PowerShell 通常会在需要相关命令时按需自动加载。

## 安装方式

将本仓库内容放到当前用户 PowerShell 配置目录：

```powershell
$HOME\Documents\WindowsPowerShell
```

如果目录不存在，可以先创建：

```powershell
New-Item -ItemType Directory -Path "$HOME\Documents\WindowsPowerShell" -Force
```

然后重新打开 PowerShell，或者手动加载 profile：

```powershell
. $PROFILE
```

## 注意事项

- `sudo` 会触发 UAC，并在新的进程中执行命令。
- `export --Machine` 和 `unexport --Machine` 需要管理员权限。
- `export --User` 和 `export --Machine` 修改的是持久环境变量，新开的终端或程序通常才能读取到最新值。
- `Keep-Screen` 依赖本机路径 `C:\Scripts\Terminal\launcher.vbs`，换机器后需要按需调整。

function Keep-Screen {
    $VbsPath = "C:\Scripts\Terminal\launcher.vbs"

    if (-not (Test-Path -LiteralPath $VbsPath)) {
        Write-Error "VBS 启动器未找到: $VbsPath"
        return
    }

    # 使用 wscript.exe 静默运行（无窗口、无任务栏图标）
    Start-Process -FilePath "wscript.exe" -ArgumentList "`"$VbsPath`"" -WindowStyle Hidden -Wait:$false

    Write-Host "✅ 任务启动成功！" -ForegroundColor Green
}

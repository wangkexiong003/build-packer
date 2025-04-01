
$FlagFile = Join-Path -Path $PWD.Path -ChildPath "ffmpeg.pid"
$OutputFile = Join-Path -Path $PWD.Path -ChildPath "desktop_record_$(Get-Date -Format 'yyyyMMdd_HHmmss').mp4"

New-Item -Path $FlagFile -ItemType File -Force

$FFmpegEXE = "ffmpeg.exe"
$FFmpegPara = "-f gdigrab -framerate 30 -i desktop -c:v libx264 -preset ultrafast -pix_fmt yuv420p `"$OutputFile`""

$StartInfo = New-Object System.Diagnostics.ProcessStartInfo
$StartInfo.FileName = $FFmpegEXE
$StartInfo.Arguments = $FFmpegPara
$StartInfo.RedirectStandardInput = $true
$StartInfo.UseShellExecute = $false

$FFmpegProcess = New-Object System.Diagnostics.Process
$FFmpegProcess.StartInfo = $StartInfo
$FFmpegProcess.Start() | Out-Null

while ($true) {
  Start-Sleep -Seconds 5

  if (-not (Test-Path $FlagFile)) {
    $FFmpegProcess.StandardInput.WriteLine('q')
    $FFmpegProcess.WaitForExit()
    break
  }
}


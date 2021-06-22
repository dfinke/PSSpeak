param ($fullPath)

if (-not $fullPath) {
    $fullpath = $env:PSModulePath -split ":(?!\\)|;|," |
    Where-Object { $_ -notlike ([System.Environment]::GetFolderPath("UserProfile") + "*") -and $_ -notlike "$pshome*" } |
    Select-Object -First 1
    $fullPath = Join-Path $fullPath -ChildPath "PSSpeak"
}
Push-location $PSScriptRoot
Robocopy . $fullPath /mir /XD .vscode .git CI __tests__ data mdHelp /XF .gitattributes .gitignore InstallModule.ps1
Pop-Location
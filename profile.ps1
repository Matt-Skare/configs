Set-PSReadlineOption -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin -EditMode Windows

function Invoke-CustomizeConsole {
  $hostVersion="$($Host.Version.Major)`.$($Host.Version.Minor)`.$($Host.Version.Build)"
  $Host.UI.RawUI.WindowTitle = "PowerShell $hostVersion"
}
Invoke-CustomizeConsole

function prompt {  
  # Write the time 
  Write-Host '[' -NoNewline
  Write-Host (Get-Date -Format "HH:mm") -fore yellow -NoNewline
  Write-Host '] ' -NoNewline

  # Show the git branch if in a git repo
  if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitBranch = git rev-parse --abbrev-ref HEAD 2>$null
    if ($LASTEXITCODE -eq 0) {
      Write-Host '(' -NoNewline
      Write-Host $gitBranch -fore cyan -NoNewline
      Write-Host ') ' -NoNewline
    }
  }
  
  # Write the path
  Write-Host $(Get-Location).Path.replace($home, '~') -fore green -NoNewline
  Write-Host $(if ($nestedpromptlevel -ge 1) {
      '>>' 
    }) -NoNewline
  return '> '
}
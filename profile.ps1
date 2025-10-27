Set-PSReadlineOption -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin -EditMode Windows
Import-Module posh-git

function Invoke-CustomizeConsole {
  $hostVersion="$($Host.Version.Major).$($Host.Version.Minor).$($Host.Version.Build)"
  $Host.UI.RawUI.WindowTitle = "PowerShell $hostVersion"
}
Invoke-CustomizeConsole

# Cache admin status to avoid repeated checks
$script:isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function prompt {
#region Timestamp
  # Write the time 
  Write-Host '[' -NoNewline
  Write-Host (Get-Date -Format "HH:mm") -ForegroundColor Yellow -NoNewline
  Write-Host '] ' -NoNewline
#endregion

#region Admin Indicator
  if ($script:isAdmin) {
    Write-Host '⚡ ' -ForegroundColor Red -NoNewline
  }
#endregion

#region Git Indicators
  # Show the git branch if in a git repo
  $gitStatus = (git status -b --porcelain=v1 2>$null | Select-Object -First 1)
    
  # Parse the branch line (starts with ##)
  if ($gitStatus -match '^## (.+?)(?:\.\.\.(.+?))?(?: \[(.+)\])?$') {
    $branchName = $matches[1]
    $trackingInfo = $matches[3]
    
    Write-Host '(' -NoNewline
    Write-Host $branchName -ForegroundColor Cyan -NoNewline
    
    # Parse tracking information if it exists
    if ($trackingInfo) {
        # Look for "ahead X" pattern
        if ($trackingInfo -match 'ahead (\d+)') {
            Write-Host " ↑$($matches[1])" -ForegroundColor Magenta -NoNewline
        }
        # Look for "behind X" pattern  
        if ($trackingInfo -match 'behind (\d+)') {
            Write-Host " ↓$($matches[1])" -ForegroundColor Blue -NoNewline
        }
    }
    Write-Host ') ' -NoNewline
  }
#endregion
  
#region Working Directory
  # Write the path
  Write-Host (Get-Location).Path.Replace($HOME, '~') -ForegroundColor Green -NoNewline
#endregion

  if ($nestedpromptlevel -ge 1) {
      Write-Host '>>' -NoNewline
  }
  return '> '
}

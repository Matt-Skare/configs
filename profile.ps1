Set-PSReadlineOption -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin -EditMode Windows
Import-Module posh-git

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
  $gitStatus = ( git status -b --porcelain=v1 | Select-Object -First 1 ) 2>$null
    
  Write-Host $gitBranch -fore cyan -NoNewline
  # Parse the branch line (starts with ##)
  if ($gitStatus -match '^## (.+?)(?:\.\.\.(.+?))?(?: \[(.+)\])?$') {
    $branchName = $matches[1]
    $trackingInfo = $matches[3]
    
    # Initialize variables
    $ahead = 0
    $behind = 0
    
    # Parse tracking information if it exists
    if ($trackingInfo) {
        # Look for "ahead X" pattern
        if ($trackingInfo -match 'ahead (\d+)') {
            $ahead = [int]$matches[1]
        }
        # Look for "behind X" pattern  
        if ($trackingInfo -match 'behind (\d+)') {
            $behind = [int]$matches[1]
        }
    }
    Write-Host '(' -NoNewline
    Write-Host "$branchName" -fore Cyan -NoNewline
    if ($ahead) {
      Write-Host " ↑$ahead" -fore magenta -NoNewline
    }
    if ($behind) {
      Write-Host " ↓$behind" -fore blue -NoNewline
    }
    Write-Host ') ' -NoNewline
  }#endregion
  
  # Write the path
  Write-Host $(Get-Location).Path.replace($home, '~') -fore green -NoNewline
  Write-Host $(if ($nestedpromptlevel -ge 1) {
      '>>' 
    }) -NoNewline
  return '> '
}

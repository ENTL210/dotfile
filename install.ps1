# Dotfile installer for Windows. Works in Windows PowerShell 5.1 and PowerShell 7.
#
#   powershell -ExecutionPolicy Bypass -File $HOME\Dotfile\install.ps1       shows the menu
#   powershell -ExecutionPolicy Bypass -File $HOME\Dotfile\install.ps1 1     runs option 1
#
# To add a new option later: write a function, add a line to Show-Menu,
# and add a case to Invoke-Choice.

param([string]$Choice = "")

$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path

function Info($msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Cyan }
function Warn($msg) { Write-Host "    ! $msg" -ForegroundColor Yellow }

function Ask-Yes($question) {
    $reply = Read-Host "$question [y/N]"
    return ($reply -match '^(y|yes)$')
}

function Update-PathFromSystem {
    # programs installed by winget are not on PATH in this window until it is refreshed
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

# ---------------------------------------------------------------- helpers

function Pull-Dotfile {
    Info "Getting the newest Dotfile from GitHub"
    if (-not (Test-Path (Join-Path $Repo ".git"))) {
        Warn "This folder is not a git clone, skipping the pull"
        return
    }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Warn "git is not installed yet, skipping the pull"
        return
    }
    git -C "$Repo" pull --ff-only
    if ($LASTEXITCODE -ne 0) {
        Warn "Pull failed (local changes or no internet). Using the files already here."
    }
}

function Get-WingetPackage($id) {
    # install the package, or upgrade it when it is already installed
    winget list --id $id -e --accept-source-agreements *> $null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    upgrading $id"
        winget upgrade --id $id -e --silent --accept-source-agreements --accept-package-agreements *> $null
    } else {
        Write-Host "    installing $id"
        winget install --id $id -e --silent --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) { Warn "Could not install $id" }
    }
}

function Install-Programs {
    Info "Installing / updating Neovim and the tools the config uses"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Warn "winget was not found. Install 'App Installer' from the Microsoft Store, then run this again."
        return
    }
    $packages = @(
        "Neovim.Neovim",
        "Git.Git",
        "OpenJS.NodeJS.LTS",
        "BurntSushi.ripgrep.MSVC",
        "sharkdp.fd"
    )
    foreach ($p in $packages) { Get-WingetPackage $p }
    Update-PathFromSystem

    if (Get-Command nvim -ErrorAction SilentlyContinue) {
        Write-Host "    $((nvim --version | Select-Object -First 1))"
    } else {
        Warn "nvim is installed but not on PATH in this window. Open a new terminal."
    }
}

function Link-Config {
    Info "Putting the Dotfile config in place"
    $source = Join-Path $Repo "nvim"
    $target = Join-Path $env:LOCALAPPDATA "nvim"

    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # an old link: remove only the link, not the folder it points to
            cmd /c rmdir "$target" | Out-Null
        } else {
            $backup = "$target.backup.$(Get-Date -Format yyyyMMddHHmmss)"
            Move-Item $target $backup
            Write-Host "    Old config moved to $backup"
            if (Ask-Yes "Also clear the old config's plugin data (recommended the first time)?") {
                $data = Join-Path $env:LOCALAPPDATA "nvim-data"
                if (Test-Path $data) { Remove-Item $data -Recurse -Force }
                Write-Host "    Cleared old plugin data"
            }
        }
    }

    # a junction works without admin rights or Developer Mode
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Write-Host "    $target -> $source"
}

function Sync-Plugins {
    Info "Installing plugins at the versions in lazy-lock.json"
    if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
        Warn "nvim not found in this window, skipping. Open a new terminal and run nvim."
        return
    }
    nvim --headless "+Lazy! restore" +qa *> $null
    if ($LASTEXITCODE -ne 0) { Warn "Plugin sync reported a problem, open nvim and run :Lazy" }
    Write-Host "    Done. Language servers install the first time you open a code file."
}

# ---------------------------------------------------------------- options

function Option-Install {
    Install-Programs   # first, so git exists for the pull on a brand new machine
    Pull-Dotfile
    Link-Config
    Sync-Plugins
    Info "Neovim is ready"
}

function Show-Menu {
    Write-Host ""
    Write-Host "  Dotfile setup"
    Write-Host "  [1] Install / Update nvim"
    Write-Host "  [0] Quit"
}

function Invoke-Choice($c) {
    switch ($c) {
        "1" { Option-Install }
        "0" { return }
        "q" { return }
        default { Write-Host "  Not an option: $c" }
    }
}

if ($Choice -ne "") {
    Invoke-Choice $Choice
} else {
    Show-Menu
    $c = Read-Host "  Choose"
    Invoke-Choice $c
}

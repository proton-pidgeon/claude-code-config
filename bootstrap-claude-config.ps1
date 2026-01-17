<#
.SYNOPSIS
    Claude Code Configuration Bootstrap Script for Windows

.DESCRIPTION
    Cross-platform PowerShell script to set up Claude Code configuration on a new Windows host

.PARAMETER RepoUrl
    The Git repository URL (required)

.EXAMPLE
    .\bootstrap-claude-config.ps1 -RepoUrl "git@github.com:username/claude-code-config.git"

.EXAMPLE
    .\bootstrap-claude-config.ps1 -RepoUrl "https://github.com/username/claude-code-config.git"

.EXAMPLE
    # Download and execute in one command:
    iwr -useb https://raw.githubusercontent.com/username/claude-code-config/main/bootstrap-claude-config.ps1 | iex; Bootstrap-ClaudeConfig -RepoUrl "https://github.com/username/claude-code-config.git"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepoUrl
)

# Error handling
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Main bootstrap function
function Bootstrap-ClaudeConfig {
    param([string]$RepoUrl)

    # Default values
    $HomeDir = $env:USERPROFILE
    if (-not $HomeDir) {
        Write-ColorOutput "Error: HOME directory not set" "Red"
        exit 1
    }

    $ClaudeConfigDir = Join-Path $HomeDir ".claude"
    $BackupDir = Join-Path $HomeDir ".claude.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
    $CredFile = $null

    Write-ColorOutput "Claude Code Configuration Bootstrap" "Blue"
    Write-ColorOutput "====================================" "Blue"
    Write-Host ""
    Write-Host "This script will:"
    Write-Host "  • Clone your Claude Code configuration from: $RepoUrl"
    Write-Host "  • Set up configuration in: $ClaudeConfigDir"
    Write-Host "  • Create required directories (agents, skills, commands, etc.)"
    Write-Host "  • Preserve any existing credentials"
    Write-Host ""
    $response = Read-Host "Do you want to continue? (y/n)"

    if ($response -notmatch '^[Yy]$') {
        Write-ColorOutput "Bootstrap cancelled" "Red"
        exit 0
    }

    # Step 1: Check for existing .claude directory
    if (Test-Path $ClaudeConfigDir) {
        Write-ColorOutput "Found existing .claude directory" "Yellow"
        $response = Read-Host "Backup existing configuration to $BackupDir? (y/n)"

        if ($response -match '^[Yy]$') {
            Copy-Item -Path $ClaudeConfigDir -Destination $BackupDir -Recurse
            Write-ColorOutput "✓ Backed up to $BackupDir" "Green"

            # Preserve credentials if they exist
            $credPath = Join-Path $ClaudeConfigDir ".credentials.json"
            if (Test-Path $credPath) {
                $CredFile = Join-Path $BackupDir ".credentials.json"
                Write-ColorOutput "Preserving credentials from backup" "Yellow"
            }

            # Remove existing directory
            Remove-Item -Path $ClaudeConfigDir -Recurse -Force
        }
        else {
            $response = Read-Host "Remove existing .claude directory? (y/n)"
            if ($response -match '^[Yy]$') {
                Remove-Item -Path $ClaudeConfigDir -Recurse -Force
                Write-ColorOutput "✓ Removed existing directory" "Green"
            }
            else {
                Write-ColorOutput "Cannot proceed without replacing or backing up existing directory" "Red"
                exit 1
            }
        }
    }

    # Step 2: Clone repository
    Write-Host ""
    Write-ColorOutput "Cloning repository..." "Blue"
    try {
        git clone $RepoUrl $ClaudeConfigDir
        Write-ColorOutput "✓ Repository cloned" "Green"
    }
    catch {
        Write-ColorOutput "Error cloning repository: $_" "Red"
        exit 1
    }

    # Step 3: Restore credentials if backed up
    if ($CredFile -and (Test-Path $CredFile)) {
        Write-Host ""
        Write-ColorOutput "Restoring credentials..." "Yellow"
        Copy-Item -Path $CredFile -Destination (Join-Path $ClaudeConfigDir ".credentials.json")
        Write-ColorOutput "✓ Credentials restored" "Green"
    }
    else {
        Write-Host ""
        Write-ColorOutput "No existing credentials found (this is normal for first setup)" "Yellow"
    }

    # Step 4: Create settings.local.json from template
    Write-Host ""
    Write-ColorOutput "Setting up host-specific configuration..." "Blue"
    $templatePath = Join-Path $ClaudeConfigDir "settings.local.template.json"
    $localSettingsPath = Join-Path $ClaudeConfigDir "settings.local.json"

    if (Test-Path $templatePath) {
        if (-not (Test-Path $localSettingsPath)) {
            Copy-Item -Path $templatePath -Destination $localSettingsPath
            Write-ColorOutput "✓ Created settings.local.json" "Green"
        }
        else {
            Write-ColorOutput "settings.local.json already exists, skipping" "Yellow"
        }
    }

    # Step 5: Create required directories if missing
    Write-Host ""
    Write-ColorOutput "Creating required directories..." "Blue"
    $directories = @("agents", "skills", "commands", "plugins", "ide")
    foreach ($dir in $directories) {
        $dirPath = Join-Path $ClaudeConfigDir $dir
        if (-not (Test-Path $dirPath)) {
            New-Item -Path $dirPath -ItemType Directory -Force | Out-Null
        }
    }
    Write-ColorOutput "✓ Directories created" "Green"

    # Step 6: Verify Git setup
    Write-Host ""
    Write-ColorOutput "Verifying Git configuration..." "Blue"
    Push-Location $ClaudeConfigDir

    # Check that credentials are excluded
    $checkIgnore = git check-ignore .credentials.json 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "✓ Credentials file is properly excluded" "Green"
    }
    else {
        Write-ColorOutput "Warning: Credentials file may not be properly excluded" "Red"
    }

    # Show current status
    Write-Host ""
    Write-ColorOutput "Git Status:" "Blue"
    git status --short | Select-Object -First 5
    Write-Host ""

    Pop-Location

    # Step 7: Summary and next steps
    Write-ColorOutput "Bootstrap Complete!" "Blue"
    Write-ColorOutput "=====================================" "Blue"
    Write-Host ""
    Write-ColorOutput "Next Steps:" "Green"
    Write-Host ""
    Write-Host "1. Review host-specific settings:"
    Write-Host "   Edit $ClaudeConfigDir\settings.local.json"
    Write-Host ""
    Write-Host "2. Authenticate with Claude:"
    Write-Host "   claude auth login"
    Write-Host ""
    Write-Host "3. Verify plugins:"
    Write-Host "   claude plugin list"
    Write-Host ""
    Write-Host "4. Check configuration:"
    Write-Host "   cd $ClaudeConfigDir"
    Write-Host "   git status"
    Write-Host ""
    if ($BackupDir -and (Test-Path $BackupDir)) {
        Write-ColorOutput "Backup location: $BackupDir" "Yellow"
        Write-Host ""
    }
    Write-Host "For more information, see: $ClaudeConfigDir\SYNC-README.md"
}

# Execute if RepoUrl is provided
if ($RepoUrl) {
    Bootstrap-ClaudeConfig -RepoUrl $RepoUrl
}

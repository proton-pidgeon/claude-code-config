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
    # Download and execute in one command (with cache-busting):
    $timestamp = [DateTimeOffset]::Now.ToUnixTimeSeconds(); iwr -useb "https://raw.githubusercontent.com/username/claude-code-config/main/bootstrap-claude-config.ps1?t=$timestamp" | iex; Bootstrap-ClaudeConfig -RepoUrl "https://github.com/username/claude-code-config.git"
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

# ============================================
# Utility Functions for Item Discovery
# ============================================

# Extract YAML field from frontmatter
function Get-YamlField {
    param(
        [string]$FilePath,
        [string]$Field
    )

    if (-not (Test-Path $FilePath)) {
        return $null
    }

    $content = Get-Content -Path $FilePath -Raw

    # Extract content between --- markers
    if ($content -match "(?s)^---\r?\n(.*?)\r?\n---") {
        $frontmatter = $Matches[1]

        # Find the field
        foreach ($line in $frontmatter -split "`n") {
            $escapedField = [regex]::Escape($Field)
            if ($line -match "^$escapedField`:\s*`"?(.+?)`"?\s*$") {
                return $Matches[1].Trim()
            }
        }
    }
    return $null
}

# Get display name for an item (name - description)
function Get-ItemDisplay {
    param([string]$FilePath)

    $name = Get-YamlField -FilePath $FilePath -Field "name"
    $desc = Get-YamlField -FilePath $FilePath -Field "description"

    if ($desc -and $desc.Length -gt 70) {
        $desc = $desc.Substring(0, 70)
    }

    if ($name) {
        return "$name - $desc"
    }
    return (Split-Path -Leaf $FilePath)
}

# Parse all items in directory into hashtable
function Get-AvailableItems {
    param(
        [string]$DirectoryPath
    )

    $items = @()

    if (-not (Test-Path $DirectoryPath)) {
        return $items
    }

    Get-ChildItem -Path $DirectoryPath -Filter "*.md" | ForEach-Object {
        $name = Get-YamlField -FilePath $_.FullName -Field "name"
        $display = Get-ItemDisplay -FilePath $_.FullName
        if ($name) {
            $items += @{
                Name = $name
                FileName = $_.Name
                Display = $display
            }
        }
    }

    return $items
}

# Parse skills (handles both single files and directories)
function Get-AvailableSkills {
    param([string]$DirectoryPath)

    $items = @()

    if (-not (Test-Path $DirectoryPath)) {
        return $items
    }

    # Single-file skills
    Get-ChildItem -Path $DirectoryPath -Filter "*.md" | ForEach-Object {
        $name = Get-YamlField -FilePath $_.FullName -Field "name"
        $display = Get-ItemDisplay -FilePath $_.FullName
        if ($name) {
            $items += @{
                Name = $name
                Id = $_.Name
                Display = $display
                Type = "File"
            }
        }
    }

    # Multi-directory skills
    Get-ChildItem -Path $DirectoryPath -Directory | ForEach-Object {
        $skillMdPath = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $skillMdPath) {
            $name = Get-YamlField -FilePath $skillMdPath -Field "name"
            $display = Get-ItemDisplay -FilePath $skillMdPath
            if ($name) {
                $items += @{
                    Name = $name
                    Id = $_.Name
                    Display = $display
                    Type = "Directory"
                }
            }
        }
    }

    return $items
}

# ============================================
# Interactive Selection Functions
# ============================================

# Multi-select menu with numbered items
function Select-InteractiveItems {
    param(
        [string]$Prompt,
        [array]$Items
    )

    $selected = @()
    $state = @{}

    # Initialize all states to false
    for ($i = 0; $i -lt $Items.Count; $i++) {
        $state[$i] = $false
    }

    $done = $false
    while (-not $done) {
        Clear-Host
        Write-ColorOutput $Prompt "Cyan"
        Write-Host "Use numbers to toggle, 'a' for all, 'n' for none, 'd' when done:"
        Write-Host ""

        for ($i = 0; $i -lt $Items.Count; $i++) {
            $checkbox = if ($state[$i]) { "[x]" } else { "[ ]" }
            Write-Host "  $($i+1). $checkbox $($Items[$i].Display)"
        }

        Write-Host ""
        $choice = Read-Host "Selection (1-$($Items.Count), a/n/d)"

        switch ($choice.ToLower()) {
            'a' {
                for ($i = 0; $i -lt $Items.Count; $i++) {
                    $state[$i] = $true
                }
            }
            'n' {
                for ($i = 0; $i -lt $Items.Count; $i++) {
                    $state[$i] = $false
                }
            }
            'd' {
                $done = $true
            }
            default {
                if ($choice -match '^\d+$') {
                    $idx = [int]$choice - 1
                    if ($idx -ge 0 -and $idx -lt $Items.Count) {
                        $state[$idx] = -not $state[$idx]
                    }
                }
            }
        }
    }

    # Build selected array
    for ($i = 0; $i -lt $Items.Count; $i++) {
        if ($state[$i]) {
            $selected += $Items[$i]
        }
    }

    return $selected
}

# Category selection menu
function Select-CategoryItems {
    param(
        [string]$Category,
        [array]$Items
    )

    $selected = @()

    if ($Items.Count -eq 0) {
        Write-ColorOutput "No $Category available" "Yellow"
        return $selected
    }

    Write-Host ""
    Write-ColorOutput "$Category Selection" "Cyan"
    Write-Host "Found $($Items.Count) available"
    Write-Host ""
    Write-Host "  1. Install all"
    Write-Host "  2. Skip all"
    Write-Host "  3. Choose individually"
    Write-Host ""

    $choice = Read-Host "Your choice (1-3)"

    switch ($choice) {
        '1' {
            $selected = $Items
            Write-ColorOutput "✓ Selected all $Category" "Green"
        }
        '2' {
            Write-ColorOutput "Skipped $Category" "Yellow"
        }
        '3' {
            $selected = Select-InteractiveItems -Prompt "Choose $Category" -Items $Items
        }
        default {
            Write-ColorOutput "Invalid choice, skipping $Category" "Yellow"
        }
    }

    return $selected
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
    Write-Host "  • Let you interactively choose which agents, skills, and commands to install"
    Write-Host "  • Set up configuration in: $ClaudeConfigDir"
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

    # Step 5: Interactive selection of items to install
    Write-Host ""
    Write-ColorOutput "Selecting items to install..." "Blue"

    # Parse available items from cloned repository
    $AvailableAgents = Get-AvailableItems -DirectoryPath (Join-Path $ClaudeConfigDir "agents")
    $AvailableSkills = Get-AvailableSkills -DirectoryPath (Join-Path $ClaudeConfigDir "skills")
    $AvailableCommandsSC = Get-AvailableItems -DirectoryPath (Join-Path $ClaudeConfigDir "commands\sc")
    $AvailableCommandsPrototype = Get-AvailableItems -DirectoryPath (Join-Path $ClaudeConfigDir "commands\kd-prototype")

    # Get user selections
    $SelectedAgents = Select-CategoryItems -Category "Agents" -Items $AvailableAgents
    $SelectedSkills = Select-CategoryItems -Category "Skills" -Items $AvailableSkills
    $SelectedCommandsSC = Select-CategoryItems -Category "SuperClaude Commands (sc)" -Items $AvailableCommandsSC
    $SelectedCommandsPrototype = Select-CategoryItems -Category "kd:prototype Commands" -Items $AvailableCommandsPrototype

    # Backup the entire cloned repo for source files
    $TempCloneDir = Join-Path $env:TEMP "claude-clone-backup-$(Get-Random)"
    Copy-Item -Path $ClaudeConfigDir -Destination $TempCloneDir -Recurse

    # Create fresh directory structure
    Write-Host ""
    Write-ColorOutput "Installing selected items..." "Blue"
    $directories = @(
        (Join-Path $ClaudeConfigDir "agents"),
        (Join-Path $ClaudeConfigDir "skills"),
        (Join-Path $ClaudeConfigDir "commands\sc"),
        (Join-Path $ClaudeConfigDir "commands\kd-prototype"),
        (Join-Path $ClaudeConfigDir "plugins"),
        (Join-Path $ClaudeConfigDir "ide")
    )
    foreach ($dir in $directories) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    # Remove all existing items from cloned repo (we'll install selected ones)
    Remove-Item -Path (Join-Path $ClaudeConfigDir "agents\*.md") -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $ClaudeConfigDir "skills\*.md") -ErrorAction SilentlyContinue
    Get-ChildItem -Path (Join-Path $ClaudeConfigDir "skills") -Directory -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $ClaudeConfigDir "commands\sc\*.md") -ErrorAction SilentlyContinue
    Remove-Item -Path (Join-Path $ClaudeConfigDir "commands\kd-prototype\*.md") -ErrorAction SilentlyContinue

    # Install selected agents
    if ($SelectedAgents.Count -gt 0) {
        Write-ColorOutput "Installing agents:" "Green"
        foreach ($agent in $SelectedAgents) {
            $sourceFile = Join-Path (Join-Path $TempCloneDir "agents") $agent.FileName
            Copy-Item -Path $sourceFile -Destination (Join-Path $ClaudeConfigDir "agents") -ErrorAction SilentlyContinue
            Write-ColorOutput "  ✓ $($agent.Name)" "Green"
        }
    }

    # Install selected skills
    if ($SelectedSkills.Count -gt 0) {
        Write-ColorOutput "Installing skills:" "Green"
        foreach ($skill in $SelectedSkills) {
            if ($skill.Type -eq "Directory") {
                # Multi-directory skill
                $sourceSkillDir = Join-Path (Join-Path $TempCloneDir "skills") $skill.Id
                Copy-Item -Path $sourceSkillDir -Destination (Join-Path $ClaudeConfigDir "skills") -Recurse -ErrorAction SilentlyContinue

                $sourceCommandDir = Join-Path (Join-Path $TempCloneDir "commands") $skill.Id
                if (Test-Path $sourceCommandDir) {
                    Copy-Item -Path $sourceCommandDir -Destination (Join-Path $ClaudeConfigDir "commands") -Recurse -ErrorAction SilentlyContinue
                }
                Write-ColorOutput "  ✓ $($skill.Name) (package)" "Green"
            }
            else {
                # Single-file skill
                $sourceFile = Join-Path (Join-Path $TempCloneDir "skills") $skill.Id
                Copy-Item -Path $sourceFile -Destination (Join-Path $ClaudeConfigDir "skills") -ErrorAction SilentlyContinue
                Write-ColorOutput "  ✓ $($skill.Name)" "Green"
            }
        }
    }

    # Install selected SC commands
    if ($SelectedCommandsSC.Count -gt 0) {
        Write-ColorOutput "Installing SuperClaude commands:" "Green"
        foreach ($cmd in $SelectedCommandsSC) {
            $sourceFile = Join-Path (Join-Path $TempCloneDir "commands" "sc") $cmd.FileName
            Copy-Item -Path $sourceFile -Destination (Join-Path $ClaudeConfigDir "commands\sc") -ErrorAction SilentlyContinue
            Write-ColorOutput "  ✓ $($cmd.Name)" "Green"
        }
    }

    # Install selected kd:prototype commands
    if ($SelectedCommandsPrototype.Count -gt 0) {
        Write-ColorOutput "Installing kd:prototype commands:" "Green"
        foreach ($cmd in $SelectedCommandsPrototype) {
            $sourceFile = Join-Path (Join-Path $TempCloneDir "commands" "kd-prototype") $cmd.FileName
            Copy-Item -Path $sourceFile -Destination (Join-Path $ClaudeConfigDir "commands\kd-prototype") -ErrorAction SilentlyContinue
            Write-ColorOutput "  ✓ $($cmd.Name)" "Green"
        }
    }

    # Cleanup temporary backup
    Remove-Item -Path $TempCloneDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-ColorOutput "✓ Items installed" "Green"

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
    Write-ColorOutput "Installation Summary:" "Green"
    Write-Host ""
    Write-Host "  Agents installed:       $($SelectedAgents.Count)"
    Write-Host "  Skills installed:       $($SelectedSkills.Count)"
    Write-Host "  SC commands installed:  $($SelectedCommandsSC.Count)"
    Write-Host "  Prototype commands:     $($SelectedCommandsPrototype.Count)"
    Write-Host ""
    Write-ColorOutput "Next Steps:" "Green"
    Write-Host ""
    Write-Host "1. Review host-specific settings:"
    Write-Host "   Edit $ClaudeConfigDir\settings.local.json"
    Write-Host ""
    Write-Host "2. Authenticate with Claude:"
    Write-Host "   claude auth login"
    Write-Host ""
    Write-Host "3. Verify your installation:"
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

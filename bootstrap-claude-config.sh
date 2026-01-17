#!/bin/bash

# Claude Code Configuration Bootstrap Script
# Cross-platform script to set up Claude Code configuration on a new host
# Usage: ./bootstrap-claude-config.sh -r <repo_url>
# Example: ./bootstrap-claude-config.sh -r "git@github.com:username/claude-code-config.git"
#
# Remote execution with cache-busting:
# bash <(curl -fsSL "https://raw.githubusercontent.com/proton-pidgeon/claude-code-config/main/bootstrap-claude-config.sh?t=$(date +%s)") -r "https://github.com/proton-pidgeon/claude-code-config.git"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
REPO_URL=""
HOME_DIR="${HOME:?HOME directory not set}"
CLAUDE_CONFIG_DIR="$HOME_DIR/.claude"
BACKUP_DIR="$HOME_DIR/.claude.backup.$(date +%s)"

# ============================================
# Utility Functions for Item Discovery
# ============================================

# Extract YAML field from frontmatter
parse_yaml_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | grep "^${field}:" | cut -d':' -f2- | sed 's/^[ "]*//;s/[ "]*$//' | head -1
}

# Get display name for an item (name - description)
get_item_display() {
  local file="$1"
  local name=$(parse_yaml_field "$file" "name")
  local desc=$(parse_yaml_field "$file" "description" | cut -c1-70)
  if [ -z "$name" ]; then
    echo "$(basename "$file")"
  else
    echo "$name - $desc"
  fi
}

# Parse all items in directory into array (format: name:filename:display)
parse_items() {
  local dir="$1"
  local -n result_array="$2"

  if [ ! -d "$dir" ]; then
    return
  fi

  for file in "$dir"/*.md; do
    [ -f "$file" ] || continue
    local name=$(parse_yaml_field "$file" "name")
    local display=$(get_item_display "$file")
    if [ -n "$name" ]; then
      result_array+=("$name:$(basename "$file"):$display")
    fi
  done
}

# Parse skills (handles both single files and directories)
parse_skills() {
  local dir="$1"
  local -n result_array="$2"

  if [ ! -d "$dir" ]; then
    return
  fi

  # Single-file skills
  for file in "$dir"/*.md; do
    [ -f "$file" ] || continue
    local name=$(parse_yaml_field "$file" "name")
    local display=$(get_item_display "$file")
    if [ -n "$name" ]; then
      result_array+=("$name:$(basename "$file"):$display")
    fi
  done

  # Multi-directory skills
  for subdir in "$dir"/*/; do
    [ -d "$subdir" ] || continue
    local skill_name=$(basename "$subdir")
    if [ -f "$subdir/SKILL.md" ]; then
      local name=$(parse_yaml_field "$subdir/SKILL.md" "name")
      local display=$(get_item_display "$subdir/SKILL.md")
      if [ -n "$name" ]; then
        result_array+=("$name:$skill_name:$display")
      fi
    fi
  done
}

# ============================================
# Interactive Selection Functions
# ============================================

# Multi-select menu with checkbox simulation
multi_select_menu() {
  local prompt="$1"
  shift
  local -n options="$1"
  shift
  local -n selected="$1"

  local -a state
  local i
  for ((i=0; i<${#options[@]}; i++)); do
    state[$i]=0
  done

  while true; do
    echo ""
    echo -e "${BLUE}$prompt${NC}"
    echo "Use numbers to toggle, 'a' for all, 'n' for none, 'd' when done:"
    echo ""

    for ((i=0; i<${#options[@]}; i++)); do
      local checkbox="[ ]"
      [ "${state[$i]}" -eq 1 ] && checkbox="[x]"
      local display=$(echo "${options[$i]}" | cut -d':' -f3-)
      echo "  $((i+1)). $checkbox $display"
    done

    echo ""
    echo -n "Selection (1-${#options[@]}, a/n/d): "
    read -r choice < /dev/tty

    case "$choice" in
      a|A)
        for ((i=0; i<${#options[@]}; i++)); do state[$i]=1; done
        ;;
      n|N)
        for ((i=0; i<${#options[@]}; i++)); do state[$i]=0; done
        ;;
      d|D)
        break 2
        ;;
      [0-9]*)
        if [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
          local idx=$((choice-1))
          [ "${state[$idx]}" -eq 0 ] && state[$idx]=1 || state[$idx]=0
        fi
        ;;
    esac
  done

  # Build selected array with just name:filename
  for ((i=0; i<${#options[@]}; i++)); do
    if [ "${state[$i]}" -eq 1 ]; then
      local name=$(echo "${options[$i]}" | cut -d':' -f1)
      local file=$(echo "${options[$i]}" | cut -d':' -f2)
      selected+=("$name:$file")
    fi
  done
}

# Category selection menu
select_category_items() {
  local category="$1"
  local source_dir="$2"
  local -n items="$3"
  local -n selected="$4"

  if [ ${#items[@]} -eq 0 ]; then
    echo -e "${YELLOW}No $category available${NC}"
    return
  fi

  echo ""
  echo -e "${BLUE}$category Selection${NC}"
  echo "Found ${#items[@]} available"
  echo ""
  echo "  1. Install all"
  echo "  2. Skip all"
  echo "  3. Choose individually"
  echo ""
  echo -n "Your choice (1-3): "
  read -r choice < /dev/tty

  case "$choice" in
    1)
      for item in "${items[@]}"; do
        local name=$(echo "$item" | cut -d':' -f1)
        local file=$(echo "$item" | cut -d':' -f2)
        selected+=("$name:$file")
      done
      echo -e "${GREEN}✓ Selected all $category${NC}"
      ;;
    2)
      echo -e "${YELLOW}Skipped $category${NC}"
      ;;
    3)
      multi_select_menu "Choose $category" items selected
      ;;
    *)
      echo -e "${YELLOW}Invalid choice, skipping $category${NC}"
      ;;
  esac
}

# ============================================
# Installation Functions
# ============================================

# Install single file item
install_single_file() {
  local source="$1"
  local dest_dir="$2"
  local name="$3"

  if [ -f "$source" ]; then
    mkdir -p "$dest_dir"
    cp "$source" "$dest_dir/"
    echo -e "${GREEN}  ✓ $name${NC}"
    return 0
  else
    echo -e "${RED}  ✗ $name (file not found)${NC}"
    return 1
  fi
}

# Install skill package (handles single files and multi-file packages)
install_skill_package() {
  local source_skills="$1"
  local source_commands="$2"
  local dest_skills="$3"
  local dest_commands="$4"
  local skill_name="$5"
  local display_name="$6"

  mkdir -p "$dest_skills"
  mkdir -p "$dest_commands"

  # Check if it's a multi-file skill (directory exists)
  if [ -d "$source_skills/$skill_name" ]; then
    cp -r "$source_skills/$skill_name" "$dest_skills/"
    if [ -d "$source_commands/$skill_name" ]; then
      cp -r "$source_commands/$skill_name" "$dest_commands/"
    fi
    echo -e "${GREEN}  ✓ $display_name (package)${NC}"
  elif [ -f "$source_skills/${skill_name}.md" ]; then
    cp "$source_skills/${skill_name}.md" "$dest_skills/"
    echo -e "${GREEN}  ✓ $display_name${NC}"
  else
    echo -e "${RED}  ✗ $display_name (not found)${NC}"
    return 1
  fi
  return 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -r|--repo)
      REPO_URL="$2"
      shift 2
      ;;
    -h|--help)
      echo "Bootstrap Claude Code configuration from remote repository"
      echo ""
      echo "Usage: $0 -r <repo_url> [options]"
      echo ""
      echo "Options:"
      echo "  -r, --repo URL       Repository URL (required)"
      echo "  -h, --help           Show this help message"
      echo ""
      echo "Examples:"
      echo "  $0 -r 'git@github.com:username/claude-code-config.git'"
      echo "  $0 -r 'https://github.com/username/claude-code-config.git'"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Validate repo URL
if [ -z "$REPO_URL" ]; then
  echo -e "${RED}Error: Repository URL is required${NC}"
  echo "Usage: $0 -r <repo_url>"
  exit 1
fi

echo -e "${BLUE}Claude Code Configuration Bootstrap${NC}"
echo "===================================="
echo ""
echo "This script will:"
echo "  • Clone your Claude Code configuration from: $REPO_URL"
echo "  • Let you interactively choose which agents, skills, and commands to install"
echo "  • Set up configuration in: $CLAUDE_CONFIG_DIR"
echo "  • Preserve any existing credentials"
echo ""
echo -n "Do you want to continue? (y/n) "
read -r response < /dev/tty
[[ "$response" =~ ^[Yy]$ ]] || { echo -e "${RED}Bootstrap cancelled${NC}"; exit 0; }
echo ""

# Step 1: Check for existing .claude directory
if [ -d "$CLAUDE_CONFIG_DIR" ]; then
  echo -e "${YELLOW}Found existing .claude directory${NC}"
  echo -n "Backup existing configuration to $BACKUP_DIR? (y/n) "
  read -r response < /dev/tty
  if [[ "$response" =~ ^[Yy]$ ]]; then
    cp -r "$CLAUDE_CONFIG_DIR" "$BACKUP_DIR"
    echo -e "${GREEN}✓ Backed up to $BACKUP_DIR${NC}"

    # Preserve credentials if they exist
    if [ -f "$CLAUDE_CONFIG_DIR/.credentials.json" ]; then
      CRED_FILE="$BACKUP_DIR/.credentials.json"
      echo -e "${YELLOW}Preserving credentials from backup${NC}"
    fi
  else
    echo -n "Remove existing .claude directory? (y/n) "
    read -r response < /dev/tty
    if [[ "$response" =~ ^[Yy]$ ]]; then
      rm -rf "$CLAUDE_CONFIG_DIR"
      echo -e "${GREEN}✓ Removed existing directory${NC}"
    else
      echo -e "${RED}Cannot proceed without replacing or backing up existing directory${NC}"
      exit 1
    fi
  fi
fi

# Step 2: Clone repository
echo ""
echo -e "${BLUE}Cloning repository...${NC}"
git clone "$REPO_URL" "$CLAUDE_CONFIG_DIR"
echo -e "${GREEN}✓ Repository cloned${NC}"

# Step 3: Restore credentials if backed up
if [ -n "$CRED_FILE" ] && [ -f "$CRED_FILE" ]; then
  echo ""
  echo -e "${YELLOW}Restoring credentials...${NC}"
  cp "$CRED_FILE" "$CLAUDE_CONFIG_DIR/.credentials.json"
  echo -e "${GREEN}✓ Credentials restored${NC}"
else
  echo ""
  echo -e "${YELLOW}No existing credentials found (this is normal for first setup)${NC}"
fi

# Step 4: Create settings.local.json from template
echo ""
echo -e "${BLUE}Setting up host-specific configuration...${NC}"
if [ -f "$CLAUDE_CONFIG_DIR/settings.local.template.json" ]; then
  if [ ! -f "$CLAUDE_CONFIG_DIR/settings.local.json" ]; then
    cp "$CLAUDE_CONFIG_DIR/settings.local.template.json" "$CLAUDE_CONFIG_DIR/settings.local.json"
    echo -e "${GREEN}✓ Created settings.local.json${NC}"
  else
    echo -e "${YELLOW}settings.local.json already exists, skipping${NC}"
  fi
fi

# Step 5: Interactive selection of items to install
echo ""
echo -e "${BLUE}Selecting items to install...${NC}"

# Parse available items from cloned repository
declare -a AVAILABLE_AGENTS=()
declare -a AVAILABLE_SKILLS=()
declare -a AVAILABLE_COMMANDS_SC=()
declare -a AVAILABLE_COMMANDS_PROTOTYPE=()

parse_items "$CLAUDE_CONFIG_DIR/agents" AVAILABLE_AGENTS
parse_skills "$CLAUDE_CONFIG_DIR/skills" AVAILABLE_SKILLS
parse_items "$CLAUDE_CONFIG_DIR/commands/sc" AVAILABLE_COMMANDS_SC
parse_items "$CLAUDE_CONFIG_DIR/commands/kd-prototype" AVAILABLE_COMMANDS_PROTOTYPE

# Get user selections
declare -a SELECTED_AGENTS=()
declare -a SELECTED_SKILLS=()
declare -a SELECTED_COMMANDS_SC=()
declare -a SELECTED_COMMANDS_PROTOTYPE=()

select_category_items "Agents" "$CLAUDE_CONFIG_DIR/agents" AVAILABLE_AGENTS SELECTED_AGENTS
select_category_items "Skills" "$CLAUDE_CONFIG_DIR/skills" AVAILABLE_SKILLS SELECTED_SKILLS
select_category_items "SuperClaude Commands (sc)" "$CLAUDE_CONFIG_DIR/commands/sc" AVAILABLE_COMMANDS_SC SELECTED_COMMANDS_SC
select_category_items "kd:prototype Commands" "$CLAUDE_CONFIG_DIR/commands/kd-prototype" AVAILABLE_COMMANDS_PROTOTYPE SELECTED_COMMANDS_PROTOTYPE

# Backup the entire cloned repo for source files
TEMP_CLONE_DIR="/tmp/claude-clone-backup-$$"
cp -r "$CLAUDE_CONFIG_DIR" "$TEMP_CLONE_DIR"

# Create fresh directory structure (keep only .git and config files)
echo ""
echo -e "${BLUE}Installing selected items...${NC}"
mkdir -p "$CLAUDE_CONFIG_DIR/agents"
mkdir -p "$CLAUDE_CONFIG_DIR/skills"
mkdir -p "$CLAUDE_CONFIG_DIR/commands/sc"
mkdir -p "$CLAUDE_CONFIG_DIR/commands/kd-prototype"
mkdir -p "$CLAUDE_CONFIG_DIR/plugins"
mkdir -p "$CLAUDE_CONFIG_DIR/ide"

# Remove all existing items from cloned repo (we'll install selected ones)
rm -rf "$CLAUDE_CONFIG_DIR/agents"/*.md
rm -rf "$CLAUDE_CONFIG_DIR/skills"/*.md
rm -rf "$CLAUDE_CONFIG_DIR/skills"/*/ 2>/dev/null || true
rm -rf "$CLAUDE_CONFIG_DIR/commands/sc"/*.md
rm -rf "$CLAUDE_CONFIG_DIR/commands/kd-prototype"/*.md

# Install selected agents
if [ ${#SELECTED_AGENTS[@]} -gt 0 ]; then
  echo -e "${GREEN}Installing agents:${NC}"
  for item in "${SELECTED_AGENTS[@]}"; do
    local name=$(echo "$item" | cut -d':' -f1)
    local file=$(echo "$item" | cut -d':' -f2)
    local source_file="$TEMP_CLONE_DIR/agents/$file"
    if [ -f "$source_file" ]; then
      cp "$source_file" "$CLAUDE_CONFIG_DIR/agents/"
      echo -e "${GREEN}  ✓ $name${NC}"
    fi
  done
fi

# Install selected skills
if [ ${#SELECTED_SKILLS[@]} -gt 0 ]; then
  echo -e "${GREEN}Installing skills:${NC}"
  for item in "${SELECTED_SKILLS[@]}"; do
    local name=$(echo "$item" | cut -d':' -f1)
    local skill_id=$(echo "$item" | cut -d':' -f2)

    # Check if it's a multi-directory skill (skill_id is just the dir name without extension)
    if [ -d "$TEMP_CLONE_DIR/skills/$skill_id" ]; then
      cp -r "$TEMP_CLONE_DIR/skills/$skill_id" "$CLAUDE_CONFIG_DIR/skills/" 2>/dev/null
      if [ -d "$TEMP_CLONE_DIR/commands/$skill_id" ]; then
        cp -r "$TEMP_CLONE_DIR/commands/$skill_id" "$CLAUDE_CONFIG_DIR/commands/" 2>/dev/null
      fi
      echo -e "${GREEN}  ✓ $name (package)${NC}"
    elif [ -f "$TEMP_CLONE_DIR/skills/$skill_id" ]; then
      # Single-file skill (skill_id already includes .md extension)
      cp "$TEMP_CLONE_DIR/skills/$skill_id" "$CLAUDE_CONFIG_DIR/skills/"
      echo -e "${GREEN}  ✓ $name${NC}"
    fi
  done
fi

# Install selected SC commands
if [ ${#SELECTED_COMMANDS_SC[@]} -gt 0 ]; then
  echo -e "${GREEN}Installing SuperClaude commands:${NC}"
  for item in "${SELECTED_COMMANDS_SC[@]}"; do
    local name=$(echo "$item" | cut -d':' -f1)
    local file=$(echo "$item" | cut -d':' -f2)
    local source_file="$TEMP_CLONE_DIR/commands/sc/$file"
    if [ -f "$source_file" ]; then
      cp "$source_file" "$CLAUDE_CONFIG_DIR/commands/sc/"
      echo -e "${GREEN}  ✓ $name${NC}"
    fi
  done
fi

# Install selected kd:prototype commands
if [ ${#SELECTED_COMMANDS_PROTOTYPE[@]} -gt 0 ]; then
  echo -e "${GREEN}Installing kd:prototype commands:${NC}"
  for item in "${SELECTED_COMMANDS_PROTOTYPE[@]}"; do
    local name=$(echo "$item" | cut -d':' -f1)
    local file=$(echo "$item" | cut -d':' -f2)
    local source_file="$TEMP_CLONE_DIR/commands/kd-prototype/$file"
    if [ -f "$source_file" ]; then
      cp "$source_file" "$CLAUDE_CONFIG_DIR/commands/kd-prototype/"
      echo -e "${GREEN}  ✓ $name${NC}"
    fi
  done
fi

# Step 5b: Generate plugin installation script (before cleanup)
if [ -f "$TEMP_CLONE_DIR/plugins/installed_plugins.json" ]; then
  PLUGIN_INSTALL_SCRIPT="$CLAUDE_CONFIG_DIR/install-plugins.sh"
  cat > "$PLUGIN_INSTALL_SCRIPT" << 'EOF'
#!/bin/bash
# Install Claude plugins
# Run this after: claude auth login

set -e

echo "Installing Claude plugins..."
echo ""

# List of plugins to install
declare -a PLUGINS=(
  "episodic-memory@superpowers-marketplace"
  "hookify@claude-plugins-official"
  "superpowers@claude-plugins-official"
)

for plugin in "${PLUGINS[@]}"; do
  echo "Installing: $plugin"
  claude plugin install "$plugin"
done

echo ""
echo "✓ All plugins installed successfully"
EOF
  chmod +x "$PLUGIN_INSTALL_SCRIPT"
  echo -e "${GREEN}✓ Generated plugin installation script${NC}"
fi

# Cleanup temporary backup
rm -rf "$TEMP_CLONE_DIR"

echo -e "${GREEN}✓ Items installed${NC}"

# Step 6: Verify Git setup
echo ""
echo -e "${BLUE}Verifying Git configuration...${NC}"
cd "$CLAUDE_CONFIG_DIR"

# Check that credentials are excluded
if git check-ignore .credentials.json > /dev/null 2>&1; then
  echo -e "${GREEN}✓ Credentials file is properly excluded${NC}"
else
  echo -e "${RED}Warning: Credentials file may not be properly excluded${NC}"
fi

# Show current status
echo ""
echo -e "${BLUE}Git Status:${NC}"
git status --short | head -5
echo ""

# Step 7: Summary and next steps
echo -e "${BLUE}Bootstrap Complete!${NC}"
echo "====================================="
echo ""
echo -e "${GREEN}Installation Summary:${NC}"
echo ""
echo "  Agents installed:       ${#SELECTED_AGENTS[@]}"
echo "  Skills installed:       ${#SELECTED_SKILLS[@]}"
echo "  SC commands installed:  ${#SELECTED_COMMANDS_SC[@]}"
echo "  Prototype commands:     ${#SELECTED_COMMANDS_PROTOTYPE[@]}"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "1. Review host-specific settings:"
echo "   Edit $CLAUDE_CONFIG_DIR/settings.local.json"
echo ""
echo "2. Authenticate with Claude:"
echo "   claude auth login"
echo ""
echo "3. Install plugins (if generated):"
echo "   $CLAUDE_CONFIG_DIR/install-plugins.sh"
echo ""
echo "4. Verify your installation:"
echo "   cd $CLAUDE_CONFIG_DIR"
echo "   git status"
echo ""
if [ -n "$BACKUP_DIR" ]; then
  echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
  echo ""
fi
echo "For more information, see: $CLAUDE_CONFIG_DIR/SYNC-README.md"

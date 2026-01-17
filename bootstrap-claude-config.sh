#!/bin/bash

# Claude Code Configuration Bootstrap Script
# Cross-platform script to set up Claude Code configuration on a new host
# Usage: ./bootstrap-claude-config.sh -r <repo_url>
# Example: ./bootstrap-claude-config.sh -r "git@github.com:username/claude-code-config.git"

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
echo "  • Set up configuration in: $CLAUDE_CONFIG_DIR"
echo "  • Create required directories (agents, skills, commands, etc.)"
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

# Step 5: Create required directories if missing
echo ""
echo -e "${BLUE}Creating required directories...${NC}"
mkdir -p "$CLAUDE_CONFIG_DIR/agents"
mkdir -p "$CLAUDE_CONFIG_DIR/skills"
mkdir -p "$CLAUDE_CONFIG_DIR/commands"
mkdir -p "$CLAUDE_CONFIG_DIR/plugins"
mkdir -p "$CLAUDE_CONFIG_DIR/ide"
echo -e "${GREEN}✓ Directories created${NC}"

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
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo "1. Review host-specific settings:"
echo "   Edit $CLAUDE_CONFIG_DIR/settings.local.json"
echo ""
echo "2. Authenticate with Claude:"
echo "   claude auth login"
echo ""
echo "3. Verify plugins:"
echo "   claude plugin list"
echo ""
echo "4. Check configuration:"
echo "   cd $CLAUDE_CONFIG_DIR"
echo "   git status"
echo ""
if [ -n "$BACKUP_DIR" ]; then
  echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
  echo ""
fi
echo "For more information, see: $CLAUDE_CONFIG_DIR/SYNC-README.md"

#!/bin/bash

# Claude Code Configuration Sync Helper
# Quick commands for syncing configuration across hosts
# Usage: ./sync-claude-config.sh -a <action> [options]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory (where .claude is)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Validate we're in .claude directory
if [ ! -f ".gitignore" ]; then
  echo -e "${RED}Error: This script must be run from the .claude directory${NC}"
  exit 1
fi

# Function to show status
show_status() {
  echo -e "${BLUE}Git Status${NC}"
  echo "==========="
  git status
  echo ""
  echo -e "${BLUE}Current Branch${NC}"
  git branch --show-current
  echo ""
  echo -e "${BLUE}Remote Configuration${NC}"
  git remote -v
}

# Function to show diff
show_diff() {
  echo -e "${BLUE}Uncommitted Changes${NC}"
  echo "==================="
  if git diff --quiet; then
    echo -e "${GREEN}No uncommitted changes${NC}"
  else
    git diff
  fi
  echo ""
  echo -e "${BLUE}Staged Changes${NC}"
  echo "==============="
  if git diff --cached --quiet; then
    echo -e "${GREEN}No staged changes${NC}"
  else
    git diff --cached
  fi
}

# Function to check for credentials
check_credentials() {
  echo -e "${BLUE}Security Check${NC}"
  echo "==============="

  # Check if .credentials.json is ignored
  if git check-ignore .credentials.json > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Credentials file is excluded${NC}"
  else
    echo -e "${RED}✗ Warning: Credentials may not be excluded${NC}"
  fi

  # Check if credentials are staged
  if git diff --cached --name-only | grep -q credentials; then
    echo -e "${RED}✗ ERROR: Credentials appear to be staged!${NC}"
    echo "Run: git reset HEAD .credentials.json"
    return 1
  else
    echo -e "${GREEN}✓ No credentials staged${NC}"
  fi

  # Check repository size
  REPO_SIZE=$(du -sh .git 2>/dev/null | cut -f1)
  echo -e "${BLUE}Repository Size: $REPO_SIZE${NC}"

  return 0
}

# Function to pull changes
pull_changes() {
  echo -e "${BLUE}Pulling from Remote${NC}"
  echo "==================="

  # Check for uncommitted changes
  if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    echo "Stashing changes before pull..."
    git stash
    STASHED=true
  fi

  # Perform pull
  if git pull; then
    echo -e "${GREEN}✓ Successfully pulled changes${NC}"

    # Restore stashed changes if any
    if [ "$STASHED" = true ]; then
      echo ""
      echo -e "${BLUE}Restoring stashed changes...${NC}"
      if git stash pop; then
        echo -e "${GREEN}✓ Stashed changes restored${NC}"
      else
        echo -e "${YELLOW}Warning: Conflicts found when restoring stashed changes${NC}"
        echo "Run: git stash pop  # to complete manually"
      fi
    fi

    return 0
  else
    echo -e "${RED}✗ Pull failed${NC}"
    if [ "$STASHED" = true ]; then
      echo "Restoring stashed changes..."
      git stash pop
    fi
    return 1
  fi
}

# Function to push changes
push_changes() {
  local message="$1"

  if [ -z "$message" ]; then
    echo -e "${RED}Error: Commit message required${NC}"
    echo "Usage: $0 push 'Your commit message'"
    return 1
  fi

  echo -e "${BLUE}Pushing Configuration${NC}"
  echo "===================="

  # Stage all changes
  echo -e "${BLUE}Staging changes...${NC}"
  git add -A

  # Security check before commit
  echo -e "${BLUE}Running security checks...${NC}"
  if ! check_credentials; then
    echo -e "${RED}✗ Push cancelled due to security issues${NC}"
    git reset
    return 1
  fi

  # Show what will be committed
  echo ""
  echo -e "${BLUE}Changes to be committed:${NC}"
  git diff --cached --name-only

  echo ""
  echo -n -e "${YELLOW}Continue with commit? (y/n) ${NC}"
  read -r response
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    git reset
    return 0
  fi

  # Commit
  echo ""
  echo -e "${BLUE}Creating commit...${NC}"
  if git commit -m "$message"; then
    echo -e "${GREEN}✓ Commit created${NC}"
  else
    echo -e "${YELLOW}No changes to commit${NC}"
    return 0
  fi

  # Push
  echo ""
  echo -e "${BLUE}Pushing to remote...${NC}"
  if git push; then
    echo -e "${GREEN}✓ Successfully pushed changes${NC}"
    return 0
  else
    echo -e "${RED}✗ Push failed${NC}"
    echo "Try: git push -u origin main"
    return 1
  fi
}

# Function to show help
show_help() {
  echo -e "${BLUE}Claude Code Configuration Sync${NC}"
  echo ""
  echo "Usage: $0 -a <action> [options]"
  echo ""
  echo -e "${BLUE}Actions:${NC}"
  echo "  status          Show git status and remote configuration"
  echo "  diff            Show all changes (uncommitted and staged)"
  echo "  check           Run security checks on credentials"
  echo "  pull            Pull changes from remote"
  echo "  push MSG        Commit and push with message"
  echo ""
  echo -e "${BLUE}Examples:${NC}"
  echo "  $0 -a status"
  echo "  $0 -a diff"
  echo "  $0 -a pull"
  echo "  $0 -a push 'Update: installed new plugin'"
  echo ""
  echo -e "${BLUE}Common Workflows:${NC}"
  echo ""
  echo "Before switching hosts:"
  echo "  $0 -a status                      # Review changes"
  echo "  $0 -a push 'Update settings'      # Commit and push"
  echo ""
  echo "After switching hosts:"
  echo "  $0 -a pull                        # Get latest config"
  echo ""
  echo "For more info: cat SYNC-README.md"
}

# Parse arguments
if [ $# -eq 0 ]; then
  show_help
  exit 0
fi

ACTION=""
while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--action)
      ACTION="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      # For push action, remaining args are the message
      if [ "$ACTION" = "push" ]; then
        MESSAGE="$@"
        break
      fi
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Execute action
case "$ACTION" in
  status)
    show_status
    ;;
  diff)
    show_diff
    ;;
  check)
    check_credentials
    ;;
  pull)
    pull_changes
    ;;
  push)
    push_changes "$MESSAGE"
    ;;
  *)
    echo -e "${RED}Unknown action: $ACTION${NC}"
    show_help
    exit 1
    ;;
esac

exit $?

#!/bin/bash

SCRIPTS_DIR="$HOME/scripts"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\e[1;36m╔════════════════════════════════════════════════════════════════════╗"
echo -e "║              Installing Web App Manager Scripts                ║"
echo -e "╚════════════════════════════════════════════════════════════════════╝\e[0m\n"

# Create scripts directory if it doesn't exist
if [[ ! -d "$SCRIPTS_DIR" ]]; then
  echo "Creating $SCRIPTS_DIR directory..."
  mkdir -p "$SCRIPTS_DIR"
fi

# Copy all files except .git and this install script
echo "Copying files to $SCRIPTS_DIR..."
echo ""

COPIED_COUNT=0

while IFS= read -r -d '' file; do
  filename=$(basename "$file")

  # Skip install.sh itself
  if [[ "$filename" == "install.sh" ]]; then
    continue
  fi

  echo -e "  \e[32m✓\e[0m Copying $filename"
  cp "$file" "$SCRIPTS_DIR/"

  # Preserve executable permissions
  if [[ -x "$file" ]]; then
    chmod +x "$SCRIPTS_DIR/$filename"
  fi

  ((COPIED_COUNT++))
done < <(find "$SOURCE_DIR" -maxdepth 1 -type f -not -path '*/\.git/*' -print0)

echo ""
echo -e "\e[1;32m📦 Installation complete! $COPIED_COUNT file(s) copied.\e[0m"
echo -e "\nInstalled scripts in: \e[94m$SCRIPTS_DIR\e[0m"
echo ""
echo "Available commands:"
echo -e "  \e[1mwebapp\e[0m          - Interactive web app manager (install, launch, list, remove)"
echo -e "  \e[1mwebapp-install\e[0m  - Install a new web app"
echo -e "  \e[1mwebapp-launch\e[0m   - Launch web app (used internally)"
echo -e "  \e[1mwebapp-list\e[0m     - List all installed web apps"
echo -e "  \e[1mwebapp-remove\e[0m   - Remove web app(s)"
echo -e "  \e[1mwebapp-backup\e[0m   - Backup installed web apps to GitHub"
echo -e "  \e[1mwebapp-restore\e[0m  - Restore web apps from GitHub"
echo ""
echo -e "\e[33mNote:\e[0m Make sure \e[94m$SCRIPTS_DIR\e[0m is in your PATH"
echo "      Add this to your ~/.bashrc or ~/.zshrc if needed:"
echo -e "      \e[90mexport PATH=\"\$HOME/scripts:\$PATH\"\e[0m"
echo ""

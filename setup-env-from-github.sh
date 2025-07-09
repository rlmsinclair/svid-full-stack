#!/bin/bash

# This script helps you create .env files from GitHub repository secrets
# You need to have the GitHub CLI (gh) installed and authenticated

echo "Setting up environment files from GitHub secrets..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first:"
    echo "brew install gh (macOS) or see https://cli.github.com/manual/installation"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Please authenticate with GitHub CLI first:"
    echo "gh auth login"
    exit 1
fi

# Function to get secrets from a repository
get_repo_secrets() {
    local repo=$1
    local output_file=$2
    
    echo "Fetching secrets from $repo..."
    
    # Get list of secret names
    secrets=$(gh secret list --repo "$repo" --json name -q '.[].name')
    
    if [ -z "$secrets" ]; then
        echo "No secrets found in $repo"
        return 1
    fi
    
    echo "# Environment variables from $repo secrets" > "$output_file"
    echo "# Generated on $(date)" >> "$output_file"
    echo "" >> "$output_file"
    
    # Note: GitHub CLI cannot retrieve secret values for security reasons
    # We'll create a template with placeholders
    while IFS= read -r secret; do
        echo "${secret}=REPLACE_WITH_ACTUAL_VALUE" >> "$output_file"
    done <<< "$secrets"
    
    echo "Created template file: $output_file"
    echo "IMPORTANT: You need to manually replace the placeholder values with actual secret values"
}

# Get repository names
read -p "Enter the GitHub repository for backend (e.g., username/svid-backend): " BACKEND_REPO
read -p "Enter the GitHub repository for frontend (e.g., username/svid-frontend): " FRONTEND_REPO

# Create .env files
get_repo_secrets "$BACKEND_REPO" ".env.backend"
get_repo_secrets "$FRONTEND_REPO" ".env.frontend"

echo ""
echo "Template .env files have been created."
echo "Since GitHub CLI cannot retrieve secret values (for security), you need to:"
echo "1. Go to your GitHub repository settings"
echo "2. Navigate to Settings > Secrets and variables > Actions"
echo "3. Copy the actual values and replace the placeholders in the .env files"
echo ""
echo "Alternatively, if you have these secrets stored elsewhere (e.g., password manager),"
echo "you can copy them from there."
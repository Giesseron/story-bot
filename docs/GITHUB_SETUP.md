# GitHub Repository Setup Guide

## Overview

This guide walks you through creating a GitHub repository and pushing your local story-bot project to GitHub.

---

## Option 1: Create Repository via GitHub Website (Recommended)

### Step 1: Create Repository on GitHub

1. Go to [https://github.com/new](https://github.com/new)
2. Fill in repository details:
   - **Repository name**: `story-bot` (or your preferred name)
   - **Description**: `AI-powered Telegram bot that generates personalized bedtime stories for children`
   - **Visibility**:
     - ✅ **Public** (if you want to share with others)
     - ⬜ **Private** (if you want to keep it private)
   - **Initialize repository**:
     - ⬜ DO NOT check "Add a README file" (we already have one)
     - ⬜ DO NOT add .gitignore (we already have one)
     - ⬜ DO NOT choose a license yet (you can add later)
3. Click **"Create repository"**

### Step 2: Connect Local Repository to GitHub

After creating the repository, GitHub will show you a page with setup instructions. Follow these commands:

```bash
# Add GitHub as remote origin
git remote add origin https://github.com/YOUR_USERNAME/story-bot.git

# Rename branch to main (optional, if you prefer 'main' over 'master')
git branch -M main

# Push your code to GitHub
git push -u origin main
```

**Replace `YOUR_USERNAME`** with your actual GitHub username!

### Step 3: Verify Upload

1. Refresh your GitHub repository page
2. You should see all your files:
   - README.md
   - database/schema.sql
   - docs/
   - config/
   - etc.

---

## Option 2: Create Repository via GitHub CLI

If you have [GitHub CLI](https://cli.github.com/) installed:

```bash
# Create repository and push in one command
gh repo create story-bot --public --source=. --remote=origin --push
```

Or for private repository:

```bash
gh repo create story-bot --private --source=. --remote=origin --push
```

---

## Step-by-Step Commands (After Creating GitHub Repo)

Run these commands in your terminal from the story-bot directory:

```bash
# 1. Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/story-bot.git

# 2. Verify remote was added
git remote -v

# 3. (Optional) Rename branch to 'main' if you prefer
git branch -M main

# 4. Push to GitHub
git push -u origin main
```

**Expected output:**
```
Enumerating objects: 15, done.
Counting objects: 100% (15/15), done.
Delta compression using up to 8 threads
Compressing objects: 100% (12/12), done.
Writing objects: 100% (15/15), 45.67 KiB | 7.61 MiB/s, done.
Total 15 (delta 0), reused 0 (delta 0), pack-reused 0
To https://github.com/YOUR_USERNAME/story-bot.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## Authentication Methods

### Method 1: Personal Access Token (Recommended)

If you get authentication errors, you need to create a Personal Access Token:

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Fill in:
   - **Note**: `story-bot-access`
   - **Expiration**: 90 days (or your preference)
   - **Scopes**: Check `repo` (full control of private repositories)
4. Click **"Generate token"**
5. **Copy the token immediately** (you won't see it again!)

When pushing to GitHub, use the token as your password:
```
Username: YOUR_GITHUB_USERNAME
Password: ghp_your_personal_access_token_here
```

### Method 2: SSH Key (More Secure)

If you prefer SSH authentication:

1. Generate SSH key (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "giesseron@gmail.com"
   ```

2. Copy public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

3. Add to GitHub:
   - Go to [GitHub Settings > SSH and GPG keys](https://github.com/settings/keys)
   - Click "New SSH key"
   - Paste your public key
   - Click "Add SSH key"

4. Change remote URL to SSH:
   ```bash
   git remote set-url origin git@github.com:YOUR_USERNAME/story-bot.git
   ```

5. Push:
   ```bash
   git push -u origin main
   ```

---

## Troubleshooting

### Error: "remote origin already exists"

```bash
# Remove existing remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/YOUR_USERNAME/story-bot.git
```

### Error: "failed to push some refs"

This means the remote has files that your local doesn't have:

```bash
# Option 1: Pull first (if you added README/License on GitHub)
git pull origin main --allow-unrelated-histories
git push -u origin main

# Option 2: Force push (only if you're sure - DESTRUCTIVE)
git push -u origin main --force
```

### Error: "Support for password authentication was removed"

You need to use a Personal Access Token instead of your password. See "Authentication Methods" above.

---

## Repository Settings (After Upload)

### Add Repository Topics

1. Go to your repository on GitHub
2. Click ⚙️ next to "About"
3. Add topics:
   - `telegram-bot`
   - `ai`
   - `claude`
   - `storytelling`
   - `n8n`
   - `bedtime-stories`
   - `supabase`

### Set Up GitHub Pages (Optional)

If you want to host documentation:

1. Go to **Settings > Pages**
2. Source: Deploy from a branch
3. Branch: main, folder: /docs
4. Save

### Add Repository Description

In "About" section, add:
```
🌙 AI-powered Telegram bot that generates personalized bedtime stories for children using Claude AI, n8n, and Supabase
```

Website: `https://t.me/your_bot_username` (your Telegram bot link)

---

## Best Practices

### 1. Protect Secrets

**NEVER commit these files:**
- `.env` (already in .gitignore)
- `config/.env` (already in .gitignore)
- Any file with API keys or tokens

**If you accidentally committed secrets:**
```bash
# Remove from git history (dangerous - use carefully)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (only do this if you're the only user)
git push origin --force --all
```

Then **immediately rotate all exposed API keys!**

### 2. Branch Protection

For production projects, enable branch protection:

1. Go to **Settings > Branches**
2. Add rule for `main` branch:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date

### 3. Issue Templates

Create `.github/ISSUE_TEMPLATE/bug_report.md` for consistent bug reports.

### 4. Contributing Guidelines

Create `CONTRIBUTING.md` to help contributors.

---

## Daily Workflow

After initial setup, here's your daily git workflow:

```bash
# 1. Make changes to files
# (edit code, update docs, etc.)

# 2. Check what changed
git status

# 3. Stage changes
git add .
# or selectively: git add file1.txt file2.txt

# 4. Commit changes
git commit -m "Add image generation feature"

# 5. Push to GitHub
git push

# 6. Pull latest changes (if working with others)
git pull
```

---

## Collaboration

### Inviting Collaborators

1. Go to **Settings > Collaborators**
2. Click "Add people"
3. Enter GitHub username or email
4. Choose permission level:
   - **Read**: View only
   - **Write**: Can push to repository
   - **Admin**: Full control

### Working with Pull Requests

If someone contributes:

1. They fork your repository
2. Make changes in their fork
3. Submit a pull request
4. You review and merge (or request changes)

---

## GitHub Actions (Future Enhancement)

You can automate testing and deployment:

Create `.github/workflows/test.yml`:

```yaml
name: Test Schema

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate SQL Schema
        run: |
          # Add validation commands here
          echo "Schema validation passed"
```

---

## Repository Visibility

### Making Public Repository Private

1. Go to **Settings > General**
2. Scroll to "Danger Zone"
3. Click "Change visibility"
4. Select "Make private"

### Making Private Repository Public

Same steps, but select "Make public"

⚠️ **Warning**: Once public, anyone can see your code. Ensure no secrets are committed!

---

## Useful Git Commands

```bash
# View commit history
git log --oneline

# View changes since last commit
git diff

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes - CAREFUL!)
git reset --hard HEAD~1

# Create new branch
git checkout -b feature/new-feature

# Switch branches
git checkout main

# Merge branch into main
git checkout main
git merge feature/new-feature

# Delete branch
git branch -d feature/new-feature

# View remote info
git remote -v

# Fetch without merging
git fetch origin
```

---

## Next Steps

After pushing to GitHub:

1. ✅ Share repository link with collaborators
2. ✅ Add a LICENSE file (MIT recommended)
3. ✅ Set up GitHub Issues for bug tracking
4. ✅ Consider GitHub Sponsors if you want donations
5. ✅ Star your own repo (why not? 😊)

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Add remote | `git remote add origin URL` |
| Push | `git push -u origin main` |
| Pull | `git pull origin main` |
| Status | `git status` |
| Commit | `git commit -m "message"` |
| View remotes | `git remote -v` |
| Clone | `git clone URL` |

---

**Your code is now safely backed up on GitHub!** 🎉

Remember to push regularly to keep your GitHub repository up to date.

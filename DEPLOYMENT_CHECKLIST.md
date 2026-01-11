# Story-Bot Deployment Checklist

**Status**: Ready for deployment
**n8n Location**: http://localhost:5679
**Last Updated**: 2026-01-11

---

## Phase 1: Telegram Bot Setup (5 minutes)

### Step 1: Create Your Telegram Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` command
3. Follow prompts:
   - **Bot name**: "Bedtime Story Bot" (or your choice)
   - **Bot username**: Must end in "bot" (e.g., `mystorybot` or `bedtime_tales_bot`)
4. **Copy your bot token** - looks like: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz`

**Save your bot token here:**
```
BOT_TOKEN=_________________________________
```

### Step 2: Configure Bot Settings

Send these commands to @BotFather:

```
/setdescription
[Select your bot]
An AI-powered bot that creates personalized bedtime stories for children

/setabouttext
[Select your bot]
Create magical bedtime stories tailored to your child's interests!

/setcommands
[Select your bot]
start - Start creating a story
cancel - Cancel current story
help - Get help and instructions
```

✅ **Checkpoint**: Your bot should appear in your Telegram bot list

---

## Phase 2: Supabase Database Setup (10 minutes)

### Step 3: Create Supabase Project

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Click **"New Project"**
3. Fill in:
   - **Name**: `story-bot`
   - **Database Password**: Create a strong password
   - **Region**: Choose closest to your users
4. Wait 2-3 minutes for project to initialize

### Step 4: Run Database Schema

1. In Supabase dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy the entire contents of `database/schema.sql`
4. Paste and click **"Run"**
5. Verify success (should see "Success. No rows returned")

### Step 5: Get Supabase Credentials

1. Go to **Settings** → **API**
2. Copy these values:

**Project URL** (remove `https://`):
```
SUPABASE_URL=_________________________________
```

**Service Role Key** (NOT anon key - use the secret one):
```
SUPABASE_KEY=_________________________________
```

✅ **Checkpoint**: Run test query in SQL Editor: `SELECT * FROM conversation_states;`

---

## Phase 3: Google Gemini API Setup (5 minutes)

### Step 6: Get Gemini API Key

1. Go to [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign in with Google account
3. Click **"Create API Key"**
4. Select **"Create API key in new project"**
5. Copy your key (starts with `AIzaSy`)

**Save your API key:**
```
GEMINI_API_KEY=_________________________________
```

**Why Gemini?**
- ✅ FREE tier: 1,500 requests/day
- ✅ 20x cheaper than Claude
- ✅ Perfect for bedtime stories

✅ **Checkpoint**: Test API key:
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Say hello"}]}]}'
```

---

## Phase 4: n8n Workflow Import (15 minutes)

### Step 7: Access n8n

1. Open browser and go to: **http://localhost:5679**
2. Log in with your n8n credentials

### Step 8: Import Main Workflow

1. Click **"Workflows"** in sidebar
2. Click **"Add workflow"** → **"Import from file"**
3. Select: `n8n-workflows/story-bot-main-workflow.json`
4. Click **"Import"**
5. Workflow will open in editor

### Step 9: Configure Credentials

The workflow needs 3 credentials:

#### A. Telegram Credentials
1. Click on **"Telegram Trigger"** node
2. Click **"Create New Credential"** under "Credentials"
3. Enter:
   - **Credential Name**: "Story Bot Telegram"
   - **Access Token**: [Your bot token from Step 1]
4. Click **"Save"**

#### B. Supabase Credentials
1. Click on any **"Supabase"** node
2. Click **"Create New Credential"**
3. Enter:
   - **Credential Name**: "Story Bot Database"
   - **Host**: [Your Supabase URL without https://]
   - **Service Role Secret**: [Your service_role key from Step 5]
4. Click **"Save"**

#### C. Google Gemini Credentials
1. Click on **"HTTP Request"** node (labeled "Generate Story with Gemini")
2. Click **"Create New Credential"**
3. Select **"Header Auth"**
4. Enter:
   - **Credential Name**: "Gemini API"
   - **Name**: `x-goog-api-key`
   - **Value**: [Your Gemini API key from Step 6]
4. Click **"Save"**

### Step 10: Update Webhook URL

1. Look for the **"Webhook"** node at the start
2. Copy the **Production URL** (looks like: `https://your-domain.com/webhook/...`)
3. Keep this URL - you'll need it in Step 12

### Step 11: Import Error Handler Workflow

1. Go back to workflows list
2. Click **"Add workflow"** → **"Import from file"**
3. Select: `n8n-workflows/story-bot-error-handler.json`
4. Click **"Import"**
5. Configure credentials (same as above)
6. Click **"Save"**

✅ **Checkpoint**: Both workflows should be visible in your workflow list

---

## Phase 5: Telegram Webhook Configuration (5 minutes)

### Step 12: Set Telegram Webhook

You need to tell Telegram where to send messages. Use this command:

```bash
curl -X POST https://api.telegram.org/bot[YOUR_BOT_TOKEN]/setWebhook \
  -H "Content-Type: application/json" \
  -d '{"url": "[YOUR_N8N_WEBHOOK_URL]"}'
```

**Example:**
```bash
curl -X POST https://api.telegram.org/bot1234567890:ABCdefGHI/setWebhook \
  -H "Content-Type: application/json" \
  -d '{"url": "https://n8n.example.com/webhook/story-bot"}'
```

**Expected response:**
```json
{"ok":true,"result":true,"description":"Webhook was set"}
```

### Step 13: Verify Webhook

```bash
curl https://api.telegram.org/bot[YOUR_BOT_TOKEN]/getWebhookInfo
```

Should show your webhook URL and `pending_update_count: 0`

✅ **Checkpoint**: Webhook is active

---

## Phase 6: Activate Workflows (2 minutes)

### Step 14: Activate Workflows in n8n

1. Open **story-bot-main-workflow**
2. Click the **toggle switch** in top-right (should turn green)
3. Status changes to "Active"

4. Open **story-bot-error-handler**
5. Click the **toggle switch**
6. Status changes to "Active"

✅ **Checkpoint**: Both workflows show "Active" status

---

## Phase 7: Testing (10 minutes)

### Step 15: First Test - Start Command

1. Open Telegram
2. Search for your bot username
3. Click **"Start"**
4. Send `/start`

**Expected response:**
```
Welcome to Bedtime Story Generator! 🌙

I create personalized bedtime stories just for you.

Let's create a magical story together!

Who is the main character? (e.g., a brave princess, a curious robot)
```

✅ **Pass** / ❌ **Fail**

### Step 16: Complete Story Generation Flow

Answer all 5 questions:
1. **Character**: "a brave little mouse"
2. **Location**: "a magical forest"
3. **Topic**: "friendship"
4. **Problem**: "lost her way home"
5. **Ending**: "finds new friends who help her"

**Expected**: Bot generates and sends a complete story within 10 seconds

✅ **Pass** / ❌ **Fail**

### Step 17: Test Cancel Command

1. Send `/start` again
2. Answer first question
3. Send `/cancel`

**Expected**: "Your current story has been cancelled. Send /start to create a new one!"

✅ **Pass** / ❌ **Fail**

### Step 18: Test Rate Limiting

Generate 5 stories in quick succession.

**Expected**: After 5 stories in 1 hour, bot should say "You've reached the limit. Please try again later."

✅ **Pass** / ❌ **Fail**

### Step 19: Database Verification

In Supabase SQL Editor:

```sql
-- Check conversation states
SELECT * FROM conversation_states ORDER BY created_at DESC LIMIT 5;

-- Check generated stories
SELECT * FROM generated_stories ORDER BY created_at DESC LIMIT 5;

-- Check usage metrics
SELECT * FROM usage_metrics ORDER BY created_at DESC LIMIT 10;
```

✅ **Checkpoint**: Data is being stored correctly

---

## Phase 8: Monitoring & Maintenance

### Step 20: Set Up Monitoring

Monitor these in Supabase:
- Number of stories generated per day
- Error rates
- User activity

Monitor in n8n:
- Workflow execution history
- Failed executions
- Response times

---

## 🎉 Deployment Complete!

Your Story Bot is now live and ready to create bedtime stories!

### Quick Reference

**Access Points:**
- n8n Dashboard: http://localhost:5679
- Supabase Dashboard: https://app.supabase.com
- Bot in Telegram: @your_bot_username

**Important Commands:**
- `/start` - Begin story creation
- `/cancel` - Cancel current story
- `/help` - Get help

**Rate Limits:**
- 5 stories per hour per user
- 20 stories per day per user

**Cost Estimates:**
- Gemini API: FREE (1,500 requests/day)
- Supabase: FREE tier (up to 500MB)
- n8n: Depends on hosting method

---

## Troubleshooting

### Bot doesn't respond to /start
- Check n8n workflow is "Active"
- Verify webhook is set: `curl https://api.telegram.org/bot[TOKEN]/getWebhookInfo`
- Check n8n execution history for errors

### "Database error" message
- Verify Supabase credentials in n8n
- Check database schema was run correctly
- Test connection from Supabase SQL Editor

### Story generation fails
- Verify Gemini API key is correct
- Check API quota: https://aistudio.google.com/app/apikey
- Review n8n execution logs

### Webhook errors
- Ensure webhook URL is publicly accessible
- Check n8n is running and reachable
- Verify webhook URL in Telegram matches n8n

---

**Need Help?** Check the detailed docs in `/docs/` folder or open an issue on GitHub.

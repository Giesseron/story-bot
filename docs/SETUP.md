# Bedtime Story Generator - Setup Guide

## Overview

This guide will walk you through setting up the Bedtime Story Generator from scratch. The entire process takes approximately 1-2 hours.

## Prerequisites

Before starting, ensure you have:

- [ ] A computer with internet access
- [ ] A Telegram account
- [ ] Credit card for Anthropic API (free credits available for new accounts)
- [ ] Email address for Supabase account

## Architecture Quick Reference

```
User → Telegram Bot → n8n Workflow → Claude API
                            ↓
                       Supabase Database
```

---

## Phase 1: Account Creation (20 minutes)

### 1.1 Create Supabase Account

1. Go to [https://supabase.com/](https://supabase.com/)
2. Click "Start your project" or "Sign up"
3. Sign up using GitHub, Google, or email
4. Verify your email address

### 1.2 Create Anthropic Account

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Click "Sign up"
3. Create account with email or Google
4. Complete verification

### 1.3 Choose n8n Hosting Option

**Option A: n8n Cloud (Recommended for beginners)**
1. Go to [https://n8n.io/](https://n8n.io/)
2. Click "Start for free"
3. Sign up for an account
4. Choose a plan (Starter plan works fine)

**Option B: Self-hosted (For advanced users)**
1. Requires Docker or Node.js
2. See [n8n self-hosting docs](https://docs.n8n.io/hosting/)
3. Minimum: 2GB RAM, 1 CPU core

---

## Phase 2: Database Setup (15 minutes)

### 2.1 Create Supabase Project

1. Log in to [Supabase Dashboard](https://app.supabase.com/)
2. Click "New project"
3. Fill in details:
   - **Name**: `story-bot`
   - **Database Password**: Generate strong password (save it!)
   - **Region**: Choose closest to your users
4. Click "Create new project"
5. Wait 2-3 minutes for project initialization

### 2.2 Run Database Schema

1. In Supabase dashboard, click on your project
2. Go to **SQL Editor** (left sidebar)
3. Click "New query"
4. Open the file `database/schema.sql` from this repository
5. Copy the entire contents
6. Paste into the SQL Editor
7. Click "Run" button (or press Ctrl/Cmd + Enter)
8. Verify success: You should see "Success. No rows returned"

### 2.3 Get Supabase Credentials

1. In Supabase dashboard, go to **Settings** > **API**
2. Copy and save these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** key: For read-only access (we won't use this)
   - **service_role** key: For full access (THIS is what we need)
3. ⚠️ **IMPORTANT**: Never expose the service_role key publicly!

### 2.4 Verify Database Setup

1. Go to **Table Editor** in Supabase
2. You should see these tables:
   - `conversation_states`
   - `generated_stories`
   - `usage_metrics`
   - `user_preferences`
3. Click on each table to verify structure

---

## Phase 3: API Keys Setup (10 minutes)

### 3.1 Get Anthropic API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Navigate to **API Keys** section
3. Click "Create Key"
4. Name it: "Story Bot Production"
5. Copy the key (starts with `sk-ant-`)
6. ⚠️ **IMPORTANT**: Save it immediately - you can't view it again!

### 3.2 Check API Credits

1. In Anthropic Console, go to **Billing**
2. Check available credits
3. New accounts get $5 free credit
4. Add payment method if needed
5. Set up billing alerts (recommended: $10 threshold)

### 3.3 Test API Access (Optional but Recommended)

```bash
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_API_KEY_HERE" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "Say hello"}]
  }'
```

Expected response: JSON with Claude's message

---

## Phase 4: Telegram Bot Setup (10 minutes)

See detailed guide in `docs/TELEGRAM_SETUP.md`

Quick steps:
1. Open Telegram and search for `@BotFather`
2. Send `/newbot`
3. Follow instructions to create bot
4. Save the bot token
5. Configure bot commands

---

## Phase 5: n8n Workflow Setup (30 minutes)

### 5.1 Access n8n Instance

**For n8n Cloud:**
1. Go to your n8n cloud dashboard
2. Click on your instance
3. You'll see the workflow editor

**For Self-hosted:**
1. Access n8n at `http://localhost:5678`
2. Complete initial setup wizard

### 5.2 Add Credentials to n8n

#### Add Telegram Credentials

1. In n8n, click **Credentials** (left sidebar)
2. Click "Add Credential"
3. Search for "Telegram"
4. Select "Telegram API"
5. Enter:
   - **Name**: "Story Bot Telegram"
   - **Access Token**: Your bot token from BotFather
6. Click "Save"

#### Add Anthropic Credentials

1. Click "Add Credential"
2. Search for "HTTP Header Auth" (n8n may not have native Anthropic node)
3. Enter:
   - **Name**: "Anthropic API"
   - **Header Name**: `x-api-key`
   - **Header Value**: Your Anthropic API key
4. Click "Save"

#### Add Supabase Credentials

1. Click "Add Credential"
2. Search for "Supabase"
3. Select "Supabase API"
4. Enter:
   - **Name**: "Story Bot Database"
   - **Host**: Your Supabase project URL (without https://)
   - **Service Role Key**: Your service_role key from Supabase
5. Click "Save"

### 5.3 Import Workflow

**Note**: The workflow file will be created in Phase 2 of implementation. For now, you'll build it manually following the architecture guide.

1. In n8n, click "Add workflow"
2. Name it: "Telegram Story Bot - Main"
3. See `docs/ARCHITECTURE.md` for detailed node configuration

---

## Phase 6: Configuration (10 minutes)

### 6.1 Set Up Environment Variables

1. Copy the environment template:
   ```bash
   cp config/environment.template config/.env
   ```

2. Edit `config/.env` and fill in all values:
   - Telegram bot token
   - Anthropic API key
   - Supabase URL and key
   - n8n webhook URL
   - Other settings

3. **Do not commit `.env` to git!** (It's already in .gitignore)

### 6.2 Configure Telegram Webhook

Once your n8n workflow is running:

1. Get your n8n webhook URL (from the Webhook node in n8n)
   - Example: `https://your-n8n.app/webhook/story-bot`

2. Register webhook with Telegram:
   ```bash
   curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
     -H "Content-Type: application/json" \
     -d '{"url": "https://your-n8n.app/webhook/story-bot"}'
   ```

3. Verify webhook is set:
   ```bash
   curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo"
   ```

---

## Phase 7: Testing (15 minutes)

### 7.1 Basic Functionality Test

1. Open Telegram
2. Search for your bot by username
3. Send `/start`
4. Complete the question flow:
   - Answer all 5 questions
   - Wait for story generation
   - Verify story is returned

### 7.2 Test Commands

- Send `/help` - Should show help message
- Start a story, then send `/cancel` - Should cancel and reset
- Send `/start` again - Should work correctly

### 7.3 Test Error Handling

1. Test with empty answers
2. Test with very long answers (>1000 characters)
3. Test with special characters: `@#$%^&*()`
4. Send multiple messages rapidly

### 7.4 Verify Database

1. Go to Supabase Table Editor
2. Check `conversation_states` table:
   - Should have your user entry
   - State should be 'idle' after completion
3. Check `generated_stories` table:
   - Should have your generated story
   - Verify all fields are populated

---

## Phase 8: Monitoring & Maintenance

### 8.1 Set Up Monitoring

1. **Supabase Monitoring**:
   - Go to Supabase Dashboard > Reports
   - Monitor database usage
   - Check API request logs

2. **Anthropic Usage**:
   - Check [Anthropic Console > Usage](https://console.anthropic.com/usage)
   - Monitor token consumption
   - Track costs

3. **n8n Execution History**:
   - In n8n, go to "Executions"
   - Review successful and failed runs
   - Set up error alerts

### 8.2 Set Up Alerts

1. **Cost Alerts** (Anthropic):
   - Set daily budget alert at $5
   - Set monthly budget alert at $50

2. **Error Alerts** (n8n):
   - Configure email notifications for workflow errors
   - Set up webhook to monitoring service (optional)

### 8.3 Regular Maintenance Tasks

**Daily:**
- Check error logs in n8n
- Monitor API usage and costs
- Review generated stories for quality

**Weekly:**
- Run database cleanup function:
  ```sql
  SELECT cleanup_old_conversations();
  ```
- Check database size in Supabase
- Review user metrics

**Monthly:**
- Archive old stories:
  ```sql
  SELECT archive_old_stories();
  ```
- Review and optimize costs
- Update dependencies if needed
- Rotate API keys (security best practice)

---

## Troubleshooting

### Bot doesn't respond

1. Check n8n workflow is active (toggle at top right)
2. Verify webhook is registered: `/getWebhookInfo`
3. Check n8n execution logs for errors
4. Verify Telegram bot token is correct

### Database errors

1. Check Supabase project is running
2. Verify service_role key is correct
3. Check database connection in n8n credentials
4. Review n8n execution logs for SQL errors

### Claude API errors

1. Check API key is valid
2. Verify you have credits: [Anthropic Console > Billing](https://console.anthropic.com/billing)
3. Check rate limits (default: 5 requests/minute)
4. Review error message in n8n logs

### Stories are low quality

1. Adjust Claude system prompt (see workflow)
2. Increase max_tokens (default: 1024)
3. Adjust temperature (default: 0.7, range: 0-1)
4. Review user input quality

---

## Security Checklist

Before going to production:

- [ ] All API keys stored securely (n8n credentials, not in workflow)
- [ ] `.env` file is in `.gitignore`
- [ ] Supabase Row Level Security (RLS) is enabled
- [ ] Telegram webhook secret is configured
- [ ] Rate limiting is enabled
- [ ] Cost monitoring and alerts are set up
- [ ] Database backups are configured
- [ ] Bot commands are set up correctly
- [ ] Privacy policy is prepared (if making public)
- [ ] GDPR compliance considered (if EU users)

---

## Next Steps

After setup is complete:

1. **Beta Testing**: Invite 5-10 friends to test
2. **Gather Feedback**: What works? What doesn't?
3. **Iterate**: Improve prompts, add features
4. **Scale**: Optimize for more users
5. **Monitor**: Keep an eye on costs and errors

---

## Getting Help

- **Supabase**: [docs.supabase.com](https://docs.supabase.com)
- **n8n**: [docs.n8n.io](https://docs.n8n.io)
- **Anthropic**: [docs.anthropic.com](https://docs.anthropic.com)
- **Telegram Bot API**: [core.telegram.org/bots/api](https://core.telegram.org/bots/api)

---

## Estimated Costs

Based on 1000 stories per month:

- **Anthropic Claude API**: $5-10/month
- **Supabase**: Free (up to 500MB database)
- **n8n Cloud**: $20/month (or free self-hosted)
- **Total**: ~$25-30/month

Scale economics improve significantly with volume!

---

**Congratulations!** 🎉 Your Bedtime Story Generator is now set up and ready to create magical stories!

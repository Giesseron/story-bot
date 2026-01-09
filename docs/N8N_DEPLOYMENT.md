# n8n Workflow Deployment Guide

## Overview

This guide walks you through deploying the Bedtime Story Generator workflows in n8n. The setup takes approximately 30-45 minutes.

---

## Prerequisites

Before starting, ensure you have completed:

- ✅ **Phase 1 Setup** (Database, Telegram bot, API keys)
- ✅ **Supabase database** running with schema deployed
- ✅ **Telegram bot** created via BotFather
- ✅ **Anthropic API key** obtained
- ✅ **n8n instance** running (cloud or self-hosted)

---

## Part 1: Configure n8n Credentials (20 minutes)

### 1.1 Access n8n

**For n8n Cloud:**
1. Go to [app.n8n.cloud](https://app.n8n.cloud)
2. Log in to your account
3. Select your instance

**For Self-hosted:**
1. Go to `http://localhost:5678` (or your n8n URL)
2. Log in with your credentials

### 1.2 Add Telegram Bot Credentials

1. Click **Credentials** in the left sidebar
2. Click **Add Credential** (top right)
3. Search for "Telegram"
4. Select **Telegram API**
5. Fill in:
   - **Credential Name**: `Telegram Story Bot`
   - **Access Token**: Your bot token from @BotFather (format: `1234567890:ABCdef...`)
6. Click **Save**

**Test the credential:**
- After saving, n8n will automatically test the connection
- You should see a green checkmark
- If it fails, double-check your bot token

### 1.3 Add Supabase Credentials

1. Click **Add Credential**
2. Search for "Supabase"
3. Select **Supabase API**
4. Fill in:
   - **Credential Name**: `Supabase Story Bot`
   - **Host**: Your Supabase URL (e.g., `yourproject.supabase.co`)
     - **Remove** `https://` from the beginning!
   - **Service Role Secret**: Your Supabase service_role key
     - Find in: Supabase Dashboard → Settings → API → service_role key
5. Click **Save**

**Important Notes:**
- Use `service_role` key, NOT the `anon` public key
- The host should be just the domain, without `https://`
- Example: `abcdefghij.supabase.co` ✅
- Example: `https://abcdefghij.supabase.co` ❌

### 1.4 Add Anthropic API Credentials

n8n might not have a native Anthropic credential type. We'll use HTTP Header Auth:

1. Click **Add Credential**
2. Search for "HTTP Header Auth"
3. Select **Header Auth**
4. Fill in:
   - **Credential Name**: `Claude API`
   - **Name**: `x-api-key`
   - **Value**: Your Anthropic API key (starts with `sk-ant-`)
5. Click **Save**

**Alternative Method (if n8n has Anthropic integration):**
1. Search for "Anthropic"
2. Select **Anthropic API**
3. Enter your API key
4. Save

---

## Part 2: Import Main Workflow (10 minutes)

### 2.1 Import Workflow File

1. In n8n, click **Workflows** (left sidebar)
2. Click **Add workflow** (top right) or the **+** button
3. Click the **⋮** menu (three dots, top right)
4. Select **Import from File**
5. Navigate to: `n8n-workflows/story-bot-main-workflow.json`
6. Click **Open**

The workflow should now appear in your n8n editor.

### 2.2 Update Credential References

After importing, you need to link the credentials:

**For each node that needs credentials:**

#### Telegram Nodes (4 nodes):
- **Send Next Question**
- **Send Story to User**
- **Send Cancel Message**
- **Send Help Message**

For each:
1. Click the node
2. Under **Credentials**, click the dropdown
3. Select **Telegram Story Bot** (or create if not found)
4. Save

#### Supabase Nodes (6 nodes):
- **Get User State**
- **Update User State**
- **Save Story to Database**
- **Log Usage Metrics**
- **Reset User State**
- **Cancel - Reset State**

For each:
1. Click the node
2. Under **Credentials**, click the dropdown
3. Select **Supabase Story Bot**
4. Save

#### HTTP Request Node (Claude API):
- **Call Claude API**

1. Click the node
2. Under **Authentication**, select **Predefined Credential Type**
3. Set **Credential Type** to the Anthropic/Header Auth you created
4. Select **Claude API** from dropdown
5. Save

### 2.3 Configure Webhook URL

1. Click on the **Telegram Webhook** node (first node)
2. You'll see two URLs:
   - **Test URL**: For testing (temporary)
   - **Production URL**: For production use
3. Copy the **Production URL**
   - Example: `https://yourinstance.app.n8n.cloud/webhook/story-bot`
4. Save this URL - you'll need it to register with Telegram

### 2.4 Save and Activate Workflow

1. Click **Save** (top right)
2. Rename the workflow if needed: Click the title, type "Telegram Story Bot - Main"
3. Toggle the **Active** switch (top right) to ON
4. The workflow is now listening for webhooks!

---

## Part 3: Import Error Handler Workflow (5 minutes)

### 3.1 Import Error Handler

1. Click **Workflows** → **Add workflow**
2. Click **⋮** → **Import from File**
3. Select: `n8n-workflows/story-bot-error-handler.json`
4. Click **Open**

### 3.2 Update Credentials

Same as before, update credentials for:
- Telegram nodes
- Supabase nodes

### 3.3 Activate Error Handler

1. Save the workflow
2. Toggle **Active** to ON
3. This workflow will automatically catch errors from the main workflow

---

## Part 4: Register Telegram Webhook (5 minutes)

Now that your n8n workflow is active, register it with Telegram.

### 4.1 Get Your Webhook URL

From the **Telegram Webhook** node in your workflow, copy the **Production URL**.

Example: `https://yourinstance.app.n8n.cloud/webhook/story-bot`

### 4.2 Register with Telegram

Open a terminal and run:

```bash
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://yourinstance.app.n8n.cloud/webhook/story-bot",
    "max_connections": 40,
    "allowed_updates": ["message"]
  }'
```

**Replace:**
- `<YOUR_BOT_TOKEN>` with your actual bot token
- The URL with your actual n8n webhook URL

**Expected Response:**
```json
{
  "ok": true,
  "result": true,
  "description": "Webhook was set"
}
```

### 4.3 Verify Webhook

```bash
curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo"
```

**Expected Response:**
```json
{
  "ok": true,
  "result": {
    "url": "https://yourinstance.app.n8n.cloud/webhook/story-bot",
    "has_custom_certificate": false,
    "pending_update_count": 0,
    "max_connections": 40
  }
}
```

---

## Part 5: Testing Your Bot (10 minutes)

### 5.1 Basic Functionality Test

1. **Open Telegram**
2. Search for your bot by username
3. Click **Start** or send `/start`
4. **Expected**: Bot should respond with the first question

### 5.2 Complete Flow Test

Send these messages in order:

```
User: /start
Bot: Who should be the main character? 🌟

User: A brave rabbit
Bot: Where does the story take place? 🗺️

User: Enchanted forest
Bot: What should the story be about? 📖

User: Friendship
Bot: What challenge should the character face? 🎯

User: Finding a lost friend
Bot: How should the story end? ✨

User: Happy reunion
Bot: [Generates and sends complete story]
```

### 5.3 Test Commands

- **Cancel**: Send `/cancel` mid-flow
  - **Expected**: "Story cancelled!" message, state reset

- **Help**: Send `/help`
  - **Expected**: Help message with instructions

- **Restart**: After completion, send "I want a story"
  - **Expected**: Flow restarts from beginning

### 5.4 Monitor in n8n

1. Go to **Executions** in n8n (left sidebar)
2. You'll see each workflow run
3. Click on an execution to see the full flow
4. Green = success, Red = error

**Debug Tips:**
- Click on each node to see its output
- Check for errors in red nodes
- Review input/output data

---

## Part 6: Verify Database Operations

### 6.1 Check Conversation States

1. Go to Supabase Dashboard
2. Navigate to **Table Editor** → `conversation_states`
3. After sending a message, you should see:
   - Your `user_id` and `chat_id`
   - Current `state` (e.g., `awaiting_character`)
   - `answers` JSON object

### 6.2 Check Generated Stories

1. Complete a full story flow
2. Check **Table Editor** → `generated_stories`
3. You should see:
   - Your story text
   - All answers in JSON format
   - Timestamp

### 6.3 Check Usage Metrics

1. Check **Table Editor** → `usage_metrics`
2. You should see:
   - `action`: `story_generated`
   - `tokens_used`: Token count
   - `cost_usd`: Estimated cost

---

## Troubleshooting

### Issue: Webhook doesn't receive messages

**Solutions:**
1. Verify workflow is **Active** (toggle at top right)
2. Check webhook is registered:
   ```bash
   curl "https://api.telegram.org/bot<TOKEN>/getWebhookInfo"
   ```
3. Ensure webhook URL is correct (copy from n8n)
4. Check n8n instance is publicly accessible

### Issue: "Credential not found" errors

**Solutions:**
1. Reopen each node with credentials
2. Reselect the credential from dropdown
3. Save each node
4. Save workflow

### Issue: Supabase queries failing

**Solutions:**
1. Verify service_role key is correct
2. Check Supabase host doesn't include `https://`
3. Test credential in n8n
4. Check database schema is deployed

### Issue: Claude API errors

**Solutions:**
1. Verify API key is correct (starts with `sk-ant-`)
2. Check you have available credits in Anthropic Console
3. Review rate limits (default: 5 requests/minute)
4. Check HTTP Request node authentication settings

### Issue: State not persisting

**Solutions:**
1. Check Supabase queries are executing
2. Review n8n execution logs
3. Verify JSON parsing in state machine
4. Check for SQL syntax errors

### Issue: Stories are empty or malformed

**Solutions:**
1. Review Claude API response in execution logs
2. Check "Extract Story Text" node output
3. Verify prompt structure in "Prepare Claude Prompt"
4. Adjust temperature or max_tokens if needed

---

## Configuration Options

### Adjust Story Length

In the **Prepare Claude Prompt** node, modify:

```javascript
const userPrompt = `Create a bedtime story (8-10 sentences) with...`; // Longer stories
const userPrompt = `Create a bedtime story (4-6 sentences) with...`; // Shorter stories
```

### Change Question Text

In the **State Machine Logic** node, modify the `QUESTIONS` array:

```javascript
const QUESTIONS = [
  {
    question: "Your custom question here?",
    answer_key: 'character'
  },
  // ...
];
```

### Adjust Rate Limits

Add a new node before story generation:

1. Add **Supabase** node
2. Query: `SELECT check_rate_limit({{ $json.user_id }}, 5, 1)`
3. Add **IF** node to check result
4. If false, send rate limit message

### Add Welcome Message

In **Command Router**, add logic to detect new users and send a welcome message.

---

## Performance Optimization

### Enable Workflow Settings

1. Click **Workflow Settings** (gear icon)
2. Configure:
   - **Timeout**: 60 seconds (for Claude API calls)
   - **Error Workflow**: Select "Telegram Story Bot - Error Handler"
   - **Save Execution Progress**: ON (for debugging)
   - **Timezone**: Your timezone

### Add Caching (Advanced)

For frequently repeated prompts, add prompt caching:

In **Call Claude API** node, add to request body:
```json
{
  "system": [
    {
      "type": "text",
      "text": "...",
      "cache_control": {"type": "ephemeral"}
    }
  ]
}
```

This can save up to 90% on input token costs.

---

## Monitoring & Maintenance

### Daily Checks

- Review n8n **Executions** for errors
- Check **usage_metrics** table for costs
- Monitor Anthropic Console for token usage

### Weekly Tasks

- Clean up old conversation states:
  ```sql
  SELECT cleanup_old_conversations();
  ```
- Review error logs
- Check database size in Supabase

### Monthly Tasks

- Archive old stories:
  ```sql
  SELECT archive_old_stories();
  ```
- Review and optimize costs
- Update API keys if needed
- Export workflow backup

---

## Backup & Recovery

### Export Workflows

1. In n8n, open workflow
2. Click **⋮** → **Export**
3. Save JSON file
4. Store in version control (already in repo!)

### Restore Workflows

1. **Import from File** as shown in Part 2
2. Reconfigure credentials
3. Activate workflow

### Database Backup

Supabase automatically backs up your database. To create manual backup:

1. Go to Supabase Dashboard → **Database** → **Backups**
2. Click **Create backup**
3. Download backup file

---

## Security Checklist

Before going live:

- [ ] Telegram webhook uses HTTPS
- [ ] Supabase service_role key is secure
- [ ] Anthropic API key is not exposed
- [ ] n8n credentials are password-protected
- [ ] Rate limiting is enabled
- [ ] Error handling is active
- [ ] Database RLS is enabled
- [ ] Workflow execution logs don't contain sensitive data

---

## Next Steps

After successful deployment:

1. ✅ Test with 5-10 beta users
2. ✅ Monitor for errors and performance
3. ✅ Gather user feedback
4. ✅ Implement rate limiting if needed
5. ✅ Add usage analytics
6. ✅ Consider adding image generation (Phase 3)

---

## Getting Help

- **n8n Community**: [community.n8n.io](https://community.n8n.io)
- **n8n Docs**: [docs.n8n.io](https://docs.n8n.io)
- **GitHub Issues**: [Your repo issues page]

---

**Congratulations!** 🎉 Your Telegram Story Bot is now live and ready to create magical bedtime stories!

Test it out and watch the magic happen! 🌙✨

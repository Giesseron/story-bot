# n8n Deployment with Gemini - Step by Step Guide

## ✨ What's Different with Gemini

**Benefits of using Gemini:**
- 🆓 **Generous free tier** - 1,500 requests/day (vs Claude's paid-only)
- 💰 **20x cheaper** - ~$0.0001 per story (vs Claude's ~$0.003)
- ⚡ **Fast response times** - Similar to Claude
- 🎨 **Great creative writing** - Excellent for bedtime stories

---

## Part 1: Get Your Gemini API Key (5 minutes)

### Step 1: Go to Google AI Studio
Open: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

### Step 2: Sign In
Use any Google/Gmail account

### Step 3: Create API Key
1. Click **"Create API Key"**
2. Select **"Create API key in new project"**
3. Copy your key (format: `AIzaSy...`)

**Save it here:**
```
Gemini API Key: AIzaSy_____________________________
```

---

## Part 2: Add Credentials to n8n (10 minutes)

### 2.1 Access n8n
Go to: `http://localhost:5678`

### 2.2 Add Telegram Credentials

1. Click **Credentials** (left sidebar)
2. Click **"Add Credential"**
3. Search for **"Telegram"**
4. Select **"Telegram API"**
5. Fill in:
   - **Name**: `Telegram Story Bot`
   - **Access Token**: Your bot token from @BotFather
6. Click **Save**

### 2.3 Add Supabase Credentials

1. Click **"Add Credential"**
2. Search for **"Supabase"**
3. Select **"Supabase API"**
4. Fill in:
   - **Name**: `Supabase Story Bot`
   - **Host**: Your Supabase URL **WITHOUT** `https://`
     - ✅ Example: `abc defg.supabase.co`
     - ❌ NOT: `https://abcdefg.supabase.co`
   - **Service Role Secret**: Your service_role key (the LONG one)
5. Click **Save**

### 2.4 Add Gemini API Credentials

**Important:** n8n doesn't have native Gemini support yet, so we use Query Auth:

1. Click **"Add Credential"**
2. Search for **"HTTP Query Auth"**
3. Select **"Query Auth"**
4. Fill in:
   - **Name**: `Gemini API Key`
   - **Name**: `key` (the parameter name)
   - **Value**: Your Gemini API key (starts with `AIzaSy...`)
5. Click **Save**

---

## Part 3: Import Workflow (5 minutes)

### 3.1 Download Workflow
The workflow is already in your project: `n8n-workflows/story-bot-main-workflow.json`

### 3.2 Import to n8n

1. In n8n, click **Workflows** (left sidebar)
2. Click **"Add workflow"** (or **+** button)
3. Click **⋮** menu (three dots, top right)
4. Select **"Import from File"**
5. Navigate to `/home/tailorgap/projects/story-bot/n8n-workflows/`
6. Select **`story-bot-main-workflow.json`**
7. Click **Open**

### 3.3 Link Credentials

After importing, update credentials for each node:

**Telegram nodes (4 nodes):**
- Send Next Question
- Send Story to User
- Send Cancel Message
- Send Help Message

For each: Click node → Select "Telegram Story Bot" credential → Save

**Supabase nodes (6 nodes):**
- Get User State
- Update User State
- Save Story to Database
- Log Usage Metrics
- Reset User State
- Cancel - Reset State

For each: Click node → Select "Supabase Story Bot" credential → Save

**Gemini API node (1 node):**
- Call Gemini API

Click node → Select "Gemini API Key" credential → Save

### 3.4 Save and Activate

1. Click **Save** (top right)
2. Name it: "Telegram Story Bot - Main (Gemini)"
3. Toggle **Active** switch to ON

---

## Part 4: Test Gemini API (5 minutes)

Before connecting to Telegram, let's test Gemini works:

### 4.1 Test in Terminal

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "parts": [{"text": "Write a short bedtime story about a brave mouse"}]
    }]
  }'
```

**Expected:** JSON response with a story

### 4.2 Test in n8n (Manual Execution)

1. Open your workflow
2. Click on **"Call Gemini API"** node
3. Click **"Execute node"** (play button)
4. Check output - should see Gemini's response

---

## Part 5: Register Telegram Webhook (5 minutes)

### 5.1 Get Webhook URL

1. In your n8n workflow, click **"Telegram Webhook"** node (first node)
2. Copy the **Production URL**

For localhost, the URL will be:
```
http://localhost:5678/webhook/story-bot
```

**⚠️ Important:** Telegram requires HTTPS! For localhost testing, you need a tunnel.

### 5.2 Set Up ngrok (for localhost)

If running n8n locally, use ngrok to create HTTPS tunnel:

```bash
# Install ngrok (if not installed)
# Download from: https://ngrok.com/download

# Start tunnel
ngrok http 5678
```

You'll see output like:
```
Forwarding https://abc123.ngrok.io -> http://localhost:5678
```

**Use the HTTPS URL** as your webhook:
```
https://abc123.ngrok.io/webhook/story-bot
```

### 5.3 Register Webhook with Telegram

```bash
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://abc123.ngrok.io/webhook/story-bot",
    "max_connections": 40,
    "allowed_updates": ["message"]
  }'
```

**Replace:**
- `<YOUR_BOT_TOKEN>` - Your Telegram bot token
- The URL - Your ngrok or production URL

**Expected response:**
```json
{
  "ok": true,
  "result": true,
  "description": "Webhook was set"
}
```

### 5.4 Verify Webhook

```bash
curl "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo"
```

Should show your webhook URL.

---

## Part 6: Test Your Bot! (10 minutes)

### 6.1 Start a Conversation

1. Open Telegram
2. Find your bot
3. Send `/start`

**Expected:** Bot asks "Who should be the main character? 🌟"

### 6.2 Complete Story Flow

```
You: /start
Bot: Who should be the main character? 🌟

You: A tiny hedgehog
Bot: Where does the story take place? 🗺️

You: A magical garden
Bot: What should the story be about? 📖

You: Making new friends
Bot: What challenge should the character face? 🎯

You: Being too shy to say hello
Bot: How should the story end? ✨

You: Finding courage and making friends
Bot: [Generates story powered by Gemini!]
```

### 6.3 Monitor in n8n

1. Go to **Executions** tab
2. Watch your workflow run in real-time
3. Click on any execution to see details
4. Check each node's output

---

## Part 7: Verify Database (5 minutes)

### 7.1 Check Supabase

1. Go to [app.supabase.com](https://app.supabase.com)
2. Select your project
3. Go to **Table Editor**

**Check `conversation_states` table:**
- Should see your user_id
- State should be 'idle' after completing story

**Check `generated_stories` table:**
- Should see your story
- All answers should be saved in JSON

**Check `usage_metrics` table:**
- Should see tokens_used
- cost_usd (should be very low - around $0.0001)

---

## Troubleshooting

### Issue: "Credentials not found"

**Solution:**
- Reopen each node
- Reselect credentials from dropdown
- Save workflow again

### Issue: Gem ini API returns error

**Solution:**
- Verify API key is correct (starts with `AIzaSy`)
- Check you haven't exceeded free tier (1500/day)
- Test API key with curl command above

### Issue: Webhook not receiving messages

**Solution:**
- Check workflow is Active (toggle at top)
- Verify ngrok is running (for localhost)
- Check webhook URL in Telegram: `/getWebhookInfo`
- Ensure URL is HTTPS

### Issue: Stories are empty

**Solution:**
- Check "Extract Story Text" node output
- Verify Gemini response structure matches code
- Review n8n execution logs

---

## Cost Tracking

### Free Tier Limits
- **1,500 requests/day** - About 1,000 stories/day
- **1M tokens/minute** - Plenty for real-time generation

### If You Exceed Free Tier

**Gemini 1.5 Flash pricing:**
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

**Cost per story:** ~$0.0001 (100 times cheaper than Claude!)

### Monitor Usage

Check at: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

Or in your Supabase `usage_metrics` table:
```sql
SELECT
  COUNT(*) as total_stories,
  SUM(tokens_used) as total_tokens,
  SUM(cost_usd) as total_cost
FROM usage_metrics
WHERE action = 'story_generated';
```

---

## Production Deployment

For production (not localhost):

### Option 1: Deploy n8n to Cloud

**Recommended services:**
- **n8n Cloud** - $20/month, easiest setup
- **DigitalOcean** - $6/month droplet
- **AWS/GCP/Azure** - Various options

**Steps:**
1. Deploy n8n to server with public IP/domain
2. Configure HTTPS (use Let's Encrypt)
3. Import workflow
4. Register webhook with production URL

### Option 2: Use n8n Cloud

1. Sign up at [n8n.cloud](https://n8n.cloud)
2. Create instance
3. Import workflow
4. Use provided n8n Cloud URL for webhook
5. No need for ngrok!

---

## Security Checklist

- [ ] Gemini API key is in n8n credentials (not in code)
- [ ] Telegram bot token is secure
- [ ] Supabase service_role key is protected
- [ ] Webhook uses HTTPS
- [ ] Rate limiting is configured
- [ ] Error handling is active

---

## Next Steps

After successful deployment:

1. ✅ Test with multiple stories
2. ✅ Invite 5-10 beta testers
3. ✅ Monitor usage and costs
4. ✅ Gather feedback
5. ✅ Iterate and improve

---

**Congratulations!** 🎉 Your Gemini-powered story bot is live!

Gemini 1.5 Flash gives you:
- Generous free tier for testing
- 20x lower costs than Claude
- Great story quality
- Fast response times

Enjoy creating magical bedtime stories! 🌙✨

# n8n Workflow Import Guide

**n8n URL**: http://localhost:3652
**Workflow Location**: `/home/tailorgap/projects/story-bot/n8n-workflows/`

---

## Step 1: Access n8n Dashboard

1. Open your browser
2. Go to: **http://localhost:3652**
3. Log in with your n8n credentials

---

## Step 2: Import Main Workflow

### A. Start Import Process
1. Click **"Workflows"** in the left sidebar
2. Click **"Add workflow"** (top right)
3. Click the **"..."** menu (three dots)
4. Select **"Import from file"**

### B. Select File
1. Navigate to: `/home/tailorgap/projects/story-bot/n8n-workflows/`
2. Select: **`story-bot-main-workflow.json`**
3. Click **"Open"** or **"Import"**

### C. Review Workflow
The workflow will open in the editor. You should see these nodes:
- Webhook (trigger)
- Telegram nodes
- Supabase nodes
- HTTP Request (for Gemini API)
- Function nodes

---

## Step 3: Update Gemini Model Configuration

**IMPORTANT**: The workflow needs to use `gemini-2.5-flash` instead of the old model.

### Find and Update HTTP Request Node:

1. Look for the **HTTP Request** node labeled "Generate Story with Gemini"
2. Click on it to open settings
3. Find the **URL** field
4. Change the URL from:
   ```
   https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent
   ```
   To:
   ```
   https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent
   ```

---

## Step 4: Configure Credentials

The workflow needs 3 credentials. For each one that shows a warning ⚠️:

### A. Telegram Credentials

1. Find any **Telegram** node (usually "Telegram Trigger" at the start)
2. Click on it
3. In the right panel, find **"Credential to connect with"**
4. Click **"Create New Credential"**
5. Fill in:
   - **Credential Name**: `Story Bot Telegram`
   - **Access Token**: `8570806933:AAH28nnR7hJWsIIn8wVrAiql_Ag4fXB3ZIk`
6. Click **"Save"**
7. The credential will now be applied to all Telegram nodes

### B. Supabase Credentials

1. Find any **Supabase** node
2. Click on it
3. Click **"Create New Credential"** under credentials
4. Fill in:
   - **Credential Name**: `Story Bot Database`
   - **Host**: `mclohdrtxgenxnkfoqbd.supabase.co`
   - **Service Role Secret**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jbG9oZHJ0eGdlbnhua2ZvcWJkIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2Nzk3MTUxOSwiZXhwIjoyMDgzNTQ3NTE5fQ.v_9hBht_5pAbmhoQooUn5WtTSN6XJhMtuylyaSWKrSQ`
5. Click **"Save"**
6. The credential will be applied to all Supabase nodes

### C. Gemini API Credentials

The HTTP Request node might use **Header Auth** for authentication:

1. Find the **HTTP Request** node (Generate Story with Gemini)
2. Click on it
3. In **Authentication** section:
   - If dropdown shows "None", change it to **"Header Auth"**
4. Click **"Create New Credential"**
5. Fill in:
   - **Credential Name**: `Gemini API Key`
   - **Name**: `x-goog-api-key`
   - **Value**: `AIzaSyAYZfatVbHz2Wn0BHX3KpYRLoUmc6sqWhY`
6. Click **"Save"**

**Alternative**: Some workflows use query parameter for API key. If you don't see Header Auth option:
- The API key might already be in the URL as a query parameter
- Look for `?key={{$credentials.geminiApiKey}}` in the URL
- You may need to create a generic credential

---

## Step 5: Save Workflow

1. Click **"Save"** button (top right)
2. Give it a name: `Story Bot - Main Workflow`
3. Click **"Save"**

---

## Step 6: Get Webhook URL

1. Click on the **Webhook** node (first node in workflow)
2. In the right panel, look for **"Webhook URLs"**
3. Copy the **Production URL** (looks like: `https://your-domain.com/webhook/xyz`)
4. **Save this URL** - you'll need it for Telegram webhook setup

**Note**: If you see `http://localhost:3652/webhook/...`, you'll need to configure n8n with a public domain or use a tunnel service like ngrok.

---

## Step 7: Activate Workflow

1. Find the toggle switch in the top-right corner
2. Click it to turn it **ON** (should turn green)
3. Status should change to **"Active"**

---

## Step 8: Import Error Handler Workflow (Optional)

Repeat Steps 2-7 for the error handler:
- File: **`story-bot-error-handler.json`**
- Name: `Story Bot - Error Handler`
- Configure same credentials

---

## Troubleshooting

### "Credential not found"
- Re-create the credential in that specific node
- Make sure to click "Save" after creating

### "Webhook URL not accessible"
- If using `localhost`, you need a public URL
- Consider using: ngrok, cloudflare tunnel, or deploy n8n to cloud

### "Node execution failed"
- Check all credentials are configured
- Verify API keys are correct
- Check n8n execution logs (bottom panel)

---

## Next Steps

After import:
1. ✅ Workflows imported
2. ✅ Credentials configured
3. ✅ Webhook URL copied
4. ⏭️ Set up Telegram webhook (next step)
5. ⏭️ Test the bot

---

**Need help?** Check the n8n execution logs or contact support.

# Getting Your Gemini API Key

## Quick Setup (5 minutes)

### Step 1: Go to Google AI Studio

Open this link: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

### Step 2: Sign In

Sign in with your Google account (any Gmail account works)

### Step 3: Create API Key

1. Click **"Create API Key"** button
2. Choose an option:
   - **Create API key in new project** (Recommended for first time)
   - Or select an existing Google Cloud project
3. Click **"Create API key"**

### Step 4: Copy Your Key

Your API key will appear - it looks like this:
```
AIzaSyB1234567890abcdefghijklmnopqrstuvwxyz
```

⚠️ **IMPORTANT**: Copy and save this key immediately!

### Step 5: Save to Checklist

Paste your key in `API_KEYS_CHECKLIST.md`:

```
## 3. Google Gemini API Key

Format: AIzaSyB...

Your API Key:
[PASTE YOUR GEMINI KEY HERE]
```

---

## Free Tier Limits

Gemini 1.5 Flash free tier includes:
- ✅ **1,500 requests per day**
- ✅ **1 million tokens per minute**
- ✅ **1,500 requests per minute**

**This is VERY generous** - enough for:
- ~1,000 stories per day
- Great for testing and small-scale production

---

## Pricing (If You Exceed Free Tier)

**Gemini 1.5 Flash:**
- Input: $0.075 per 1M tokens
- Output: $0.30 per 1M tokens

**Compared to Claude:**
- About **20x cheaper** than Claude 3.5 Sonnet!
- Cost per story: ~$0.0001 (vs Claude's ~$0.003)

---

## Testing Your API Key

Run this command to test:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{
    "contents": [{
      "parts": [{"text": "Say hello"}]
    }]
  }'
```

**Expected response:** JSON with Gemini's greeting

---

## Security Notes

- ✅ Never commit your API key to git
- ✅ Store in n8n credentials (encrypted)
- ✅ Don't share publicly
- ✅ Can regenerate anytime in AI Studio

---

## Rate Limit Monitoring

Check usage at: [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

You'll see:
- Requests today
- Remaining quota
- Usage graphs

---

**Once you have your key, continue to n8n deployment!**

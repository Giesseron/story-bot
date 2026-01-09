# API Keys Checklist

## Quick Reference for n8n Deployment

Copy this information as you gather your API keys.

---

## 1. Telegram Bot Token

**Where to find it:**
1. Open Telegram and search for `@BotFather`
2. Send `/mybots`
3. Select your bot
4. Click "API Token"

**Format:** `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567`

**Your Token:**
```
[PASTE YOUR TELEGRAM BOT TOKEN HERE]
```

---

## 2. Supabase Credentials

**Where to find them:**
1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Select your `story-bot` project
3. Go to **Settings** → **API**

**You need:**

### Project URL:
**Format:** `abcdefghij.supabase.co` (WITHOUT https://)

**Your URL:**
```
[PASTE SUPABASE URL HERE - NO https://]
```

### Service Role Key:
**Format:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (LONG key)

**⚠️ Use service_role key, NOT anon public key!**

**Your Service Role Key:**
```
[PASTE SERVICE_ROLE KEY HERE]
```

---

## 3. Google Gemini API Key

**Where to find it:**
1. Go to [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign in with Google account
3. Click **"Create API Key"**
4. Select **"Create API key in new project"**
5. Copy your key

**Format:** `AIzaSy...`

**Your API Key:**
```
[PASTE GEMINI API KEY HERE]
```

**Benefits:**
- ✅ FREE tier: 1,500 requests/day
- ✅ 20x cheaper than Claude
- ✅ Great for bedtime stories

---

## 4. n8n Access

**Your n8n URL:** `http://localhost:5678`

**Username/Password:** [Your n8n login credentials]

---

## Verification Checklist

Before proceeding to n8n setup:

- [ ] I have my Telegram bot token
- [ ] I have my Supabase URL (without https://)
- [ ] I have my Supabase service_role key (not anon key)
- [ ] I have my Gemini API key
- [ ] I can access n8n at localhost:5678
- [ ] My database schema is deployed in Supabase
- [ ] My Telegram bot is created via @BotFather

---

## Quick Test Commands

**Test Telegram bot token:**
```bash
curl https://api.telegram.org/bot<YOUR_TOKEN>/getMe
```

**Test Supabase connection:**
```bash
curl -X GET 'https://YOUR_PROJECT.supabase.co/rest/v1/conversation_states?limit=1' \
  -H "apikey: YOUR_SERVICE_ROLE_KEY" \
  -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY"
```

**Test Gemini API:**
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"contents":[{"parts":[{"text":"Say hello"}]}]}'
```

---

**Once you have all keys, continue with n8n deployment!**

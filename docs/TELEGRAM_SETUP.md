# Telegram Bot Setup Guide

## Overview

This guide walks you through creating and configuring your Telegram bot using BotFather. The entire process takes about 10 minutes.

---

## Step 1: Create the Bot

### 1.1 Open BotFather

1. Open Telegram on any device (mobile, desktop, or web)
2. In the search bar, type: `@BotFather`
3. Select the official BotFather (verified with blue checkmark)
4. Click "Start" or send `/start`

### 1.2 Create New Bot

1. Send the command: `/newbot`

2. BotFather will ask: **"Alright, a new bot. How are we going to call it? Please choose a name for your bot."**
   - Enter a display name (can be anything)
   - Example: `Bedtime Story Generator`

3. BotFather will ask: **"Good. Now let's choose a username for your bot. It must end in 'bot'."**
   - Username must be unique across all Telegram
   - Must end with `bot`
   - Examples:
     - `bedtime_story_generator_bot`
     - `mystorymaker_bot`
     - `kidsstory_bot`

4. If successful, BotFather will respond with:
   ```
   Done! Congratulations on your new bot. You will find it at t.me/your_bot_username

   Use this token to access the HTTP API:
   1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567

   Keep your token secure and store it safely, it can be used by anyone to control your bot.
   ```

5. **IMPORTANT**: Copy and save the token immediately!
   - Format: `1234567890:ABCdefGHIjklMNOpqrsTUVwxyz1234567`
   - Store it in a password manager or secure note
   - You'll need this for n8n configuration

### 1.3 Verify Bot Creation

1. Click on the bot link provided: `t.me/your_bot_username`
2. Click "Start"
3. The bot won't respond yet (we haven't connected it to n8n)
4. This is normal - we'll set it up later

---

## Step 2: Configure Bot Settings

### 2.1 Set Bot Description

The description appears on the bot's profile page.

1. Go back to BotFather chat
2. Send: `/setdescription`
3. Select your bot from the list
4. Send this description (or customize):

```
🌙 Welcome to the Bedtime Story Generator! 🌙

I create personalized bedtime stories just for you! Simply answer a few fun questions, and I'll craft a unique tale featuring your chosen character, setting, and adventure.

Perfect for:
✨ Parents looking for fresh bedtime stories
📚 Educators creating engaging content
🎨 Anyone who loves magical tales

Send /start to begin your story adventure!
```

### 2.2 Set About Text

The "about" text appears in the bot info page.

1. Send: `/setabouttext`
2. Select your bot
3. Send:

```
AI-powered bedtime story generator. Creates personalized stories through interactive conversation.
```

### 2.3 Set Bot Commands

Commands appear in the command menu (makes it easy for users).

1. Send: `/setcommands`
2. Select your bot
3. Send this list (one command per line):

```
start - Begin creating a new story
cancel - Cancel current story and start over
help - Show help and instructions
```

4. BotFather will confirm: "Success! Command list updated."

### 2.4 Set Bot Profile Picture (Optional)

1. Send: `/setuserpic`
2. Select your bot
3. Send an image file (square format works best)
   - Recommended: 512x512 pixels
   - PNG or JPG format
   - Story-related image (book, moon, stars, etc.)

### 2.5 Disable Group Privacy (Optional)

By default, bots in groups only see messages that mention them. If you want the bot to work in group chats and see all messages:

1. Send: `/setprivacy`
2. Select your bot
3. Choose "Disable"
4. ⚠️ **Note**: Only do this if you plan to support group chats

**For this project, we recommend keeping privacy ENABLED** (bots only work in 1-on-1 chats by default).

---

## Step 3: Test Bot Token

Before proceeding, verify your token works.

### 3.1 Using cURL (Command Line)

```bash
curl https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe
```

Replace `<YOUR_BOT_TOKEN>` with your actual token.

**Expected response:**
```json
{
  "ok": true,
  "result": {
    "id": 1234567890,
    "is_bot": true,
    "first_name": "Bedtime Story Generator",
    "username": "your_bot_username",
    "can_join_groups": true,
    "can_read_all_group_messages": false,
    "supports_inline_queries": false
  }
}
```

### 3.2 Using Web Browser

Simply paste this in your browser's address bar:
```
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getMe
```

If you see JSON data, the token works!

---

## Step 4: Set Webhook (After n8n Setup)

⚠️ **Do this AFTER setting up your n8n workflow** (see SETUP.md Phase 5)

### 4.1 Get Your n8n Webhook URL

From your n8n workflow:
1. Open the "Webhook" node
2. Copy the "Production URL"
3. Example: `https://your-n8n-instance.app/webhook/story-bot`

### 4.2 Register Webhook with Telegram

```bash
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://your-n8n-instance.app/webhook/story-bot",
    "max_connections": 40,
    "allowed_updates": ["message", "callback_query"]
  }'
```

**Expected response:**
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

**Expected response:**
```json
{
  "ok": true,
  "result": {
    "url": "https://your-n8n-instance.app/webhook/story-bot",
    "has_custom_certificate": false,
    "pending_update_count": 0,
    "max_connections": 40
  }
}
```

### 4.4 Troubleshooting Webhook

**Problem**: Webhook fails to set

**Solutions**:
1. **Check URL**: Must be HTTPS (not HTTP)
2. **Valid SSL**: Certificate must be valid (not self-signed)
3. **Port**: Must use port 443, 80, 88, or 8443
4. **Accessible**: n8n instance must be publicly accessible

**Problem**: `pending_update_count` is increasing

**Solutions**:
1. n8n workflow is not processing messages
2. Check n8n execution logs
3. Verify workflow is active
4. Check webhook node configuration

---

## Step 5: Additional Bot Settings (Optional)

### 5.1 Inline Mode (Future Feature)

To allow users to use your bot inline (like `@your_bot query`):

1. Send: `/setinline`
2. Select your bot
3. Send placeholder text
4. You'll need to implement inline query handling in n8n

**Not needed for initial version.**

### 5.2 Bot Payment (Future Feature)

If you want to charge for stories:

1. Send: `/setpayment`
2. Select your bot
3. Follow BotFather's instructions
4. Integrate payment provider

**Not needed for initial version.**

---

## Step 6: Bot Management Commands

Useful commands for managing your bot:

### Get Current Settings

```bash
# Get bot info
/mybots → Select bot → "API Token"

# Get current description
/setdescription → Select bot → (Leave empty to see current)

# Get current commands
/setcommands → Select bot → (Send /empty to clear)
```

### Security Commands

```bash
# Revoke and generate new token (use if token is exposed)
/token → Select bot → "Revoke current token"

# Delete bot (PERMANENT - be careful!)
/deletebot → Select bot → Confirm
```

---

## Step 7: Testing Checklist

Before going live, verify everything:

- [ ] Bot username is set correctly
- [ ] Bot description is appealing and clear
- [ ] About text is set
- [ ] Commands are configured (/start, /cancel, /help)
- [ ] Profile picture is uploaded (optional)
- [ ] Bot token is stored securely
- [ ] Webhook is set and verified
- [ ] Test message sends successfully (after n8n setup)
- [ ] Commands appear in Telegram command menu

---

## Common Issues & Solutions

### Issue: "Sorry, this username is already taken"

**Solution**: Choose a different username. Try adding numbers or underscores.

### Issue: Can't find my bot in Telegram search

**Solution**:
1. Use the direct link: `t.me/your_bot_username`
2. Make sure username is spelled correctly
3. Bot may take a few minutes to appear in search

### Issue: Bot doesn't respond

**Possible causes**:
1. Webhook not set (see Step 4)
2. n8n workflow not active
3. n8n webhook URL incorrect
4. Network issues

**Solution**: Check webhook status and n8n logs

### Issue: Lost bot token

**Solution**:
1. Open BotFather
2. Send `/mybots`
3. Select your bot
4. Click "API Token"
5. If you suspect it's compromised, revoke it and generate a new one

---

## Security Best Practices

### DO:
✅ Store bot token in environment variables or credentials manager
✅ Use HTTPS for webhook
✅ Implement rate limiting in your workflow
✅ Monitor bot usage regularly
✅ Rotate tokens periodically (every 6-12 months)

### DON'T:
❌ Commit bot token to git
❌ Share token publicly
❌ Use HTTP for webhooks
❌ Disable privacy mode unless necessary
❌ Give admin rights in groups without good reason

---

## Bot Username Suggestions

If your preferred name is taken, try:

- `bedtime_story_ai_bot`
- `ai_story_generator_bot`
- `kidsstorymaker_bot`
- `nighttime_tales_bot`
- `dream_story_bot`
- `mystory_creator_bot`
- Add your name: `johns_story_bot`
- Add year: `story_bot_2026`

---

## Next Steps

After completing Telegram setup:

1. ✅ Save bot token to `config/.env`
2. ✅ Continue to n8n workflow setup (see SETUP.md Phase 5)
3. ✅ Set webhook after n8n is running
4. ✅ Test end-to-end flow

---

## Quick Reference

### Essential Commands

| Command | Purpose |
|---------|---------|
| `/newbot` | Create new bot |
| `/mybots` | Manage existing bots |
| `/setcommands` | Set bot commands menu |
| `/setdescription` | Set bot description |
| `/token` | Get/revoke bot token |
| `/deletebot` | Delete bot permanently |

### API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `/getMe` | Get bot info |
| `/setWebhook` | Register webhook |
| `/getWebhookInfo` | Check webhook status |
| `/deleteWebhook` | Remove webhook |
| `/getUpdates` | Get messages (polling mode) |

### Webhook Testing

```bash
# Set webhook
curl -X POST "https://api.telegram.org/bot<TOKEN>/setWebhook" \
  -d "url=https://your-webhook-url"

# Check webhook
curl "https://api.telegram.org/bot<TOKEN>/getWebhookInfo"

# Delete webhook
curl -X POST "https://api.telegram.org/bot<TOKEN>/deleteWebhook"
```

---

**Your Telegram bot is now ready to connect to n8n!** 🤖

Continue to `docs/SETUP.md` Phase 5 to connect everything together.

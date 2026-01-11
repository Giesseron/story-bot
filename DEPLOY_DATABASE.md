# Deploy Database Schema to Supabase

**Project**: Story-Bot
**Database**: mclohdrtxgenxnkfoqbd.supabase.co
**Status**: Ready to deploy

---

## Quick Deploy Instructions

### Step 1: Open Supabase SQL Editor

1. Go to: https://app.supabase.com/project/mclohdrtxgenxnkfoqbd
2. Click on **SQL Editor** in the left sidebar
3. Click **"New Query"**

### Step 2: Copy Database Schema

Open the file: `/home/tailorgap/projects/story-bot/database/schema.sql`

Or copy from here:

```bash
cat /home/tailorgap/projects/story-bot/database/schema.sql
```

### Step 3: Run the Schema

1. Paste the entire schema.sql contents into the SQL Editor
2. Click **"Run"** (or press Ctrl+Enter)
3. Wait for execution (should take 5-10 seconds)

**Expected Result:**
```
Success. No rows returned
```

### Step 4: Verify Tables Were Created

Run this verification query in a new SQL Editor tab:

```sql
-- Check all tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

**Expected Output:**
- conversation_states
- generated_stories
- usage_metrics
- user_preferences

### Step 5: Test Database Functions

```sql
-- Test rate limit function
SELECT check_rate_limit(123456789, 5, 1);

-- Should return: true
```

---

## What Gets Created

### Tables (4):
1. **conversation_states** - Tracks user conversation progress
2. **generated_stories** - Stores all generated stories
3. **usage_metrics** - Tracks API usage and rate limiting
4. **user_preferences** - User settings (future use)

### Functions (4):
1. **check_rate_limit()** - Validates if user exceeded limits
2. **get_user_story_count()** - Counts stories in time window
3. **cleanup_old_conversations()** - Removes old data (privacy)
4. **archive_old_stories()** - Archives stories after 90 days

### Triggers (2):
1. Auto-update timestamps on conversation_states
2. Auto-update timestamps on user_preferences

### Security:
- Row Level Security (RLS) enabled on all tables
- Proper indexes for performance
- Data retention policies

---

## Troubleshooting

### Error: "extension uuid-ossp does not exist"
**Solution:** Extensions are enabled by default in Supabase. If you see this, try:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Error: "relation already exists"
**Solution:** Tables already exist. You can skip or drop and recreate:
```sql
DROP TABLE IF EXISTS conversation_states CASCADE;
DROP TABLE IF EXISTS generated_stories CASCADE;
DROP TABLE IF EXISTS usage_metrics CASCADE;
DROP TABLE IF EXISTS user_preferences CASCADE;
-- Then run the full schema again
```

### Error: Permission denied
**Solution:** Make sure you're using the service_role key, not anon key

---

## After Deployment

Once successful, you can proceed to:
- ✅ Get Gemini API key
- ✅ Import n8n workflows
- ✅ Test the bot

---

**Ready?** Follow the steps above and let me know when the schema is deployed!

# 🌙 Bedtime Story Generator

An AI-powered Telegram bot that creates personalized bedtime stories for children through interactive conversation.

## ✨ Features

- 🤖 **Conversational Interface** - No app installation required, works directly in Telegram
- 🎨 **Personalized Stories** - Each story is unique based on user's choices
- ⚡ **Real-time Generation** - Stories created in seconds using Claude AI
- 🔒 **Privacy-First** - Minimal data collection, automatic cleanup
- 📊 **Rate Limited** - Built-in cost controls and usage tracking
- 🌍 **Scalable Architecture** - Handles from 10 to 10,000+ users

## 🎯 How It Works

1. User sends "I want a story" to the Telegram bot
2. Bot asks 5 simple questions:
   - Who is the main character?
   - Where does the story take place?
   - What is the main topic?
   - What problem occurs?
   - How should the story end?
3. Claude AI generates a personalized 6-8 sentence bedtime story
4. Bot delivers the complete story instantly

## 🏗️ Architecture

```
User (Telegram) → Telegram Bot API → n8n Workflow
                                          ↓
                  ┌──────────────────────┴──────────────────────┐
                  │                                              │
            Supabase DB                                    Claude API
        (State & Stories)                              (Story Generation)
```

**Tech Stack:**
- **Frontend**: Telegram Bot
- **Orchestration**: n8n (workflow automation)
- **Database**: Supabase (PostgreSQL)
- **AI**: Anthropic Claude API
- **Optional**: Stable Diffusion (story illustrations)

## 🚀 Quick Start

### Prerequisites

- Telegram account
- Anthropic API key ([get one here](https://console.anthropic.com/))
- Supabase account ([sign up](https://supabase.com/))
- n8n instance ([cloud](https://n8n.io/) or [self-hosted](https://docs.n8n.io/hosting/))

### Setup Guide

Detailed setup instructions available in [docs/SETUP.md](docs/SETUP.md)

**Quick steps:**

1. **Clone this repository**
   ```bash
   git clone https://github.com/yourusername/story-bot.git
   cd story-bot
   ```

2. **Set up Supabase database**
   ```bash
   # Run the schema in Supabase SQL Editor
   cat database/schema.sql
   ```

3. **Create Telegram bot**
   - Follow [docs/TELEGRAM_SETUP.md](docs/TELEGRAM_SETUP.md)
   - Get bot token from @BotFather

4. **Configure environment**
   ```bash
   cp config/environment.template config/.env
   # Edit .env with your API keys
   ```

5. **Set up n8n workflow**
   - Import workflow (coming in Phase 2)
   - Add credentials
   - Activate workflow

6. **Test the bot**
   - Open Telegram
   - Send `/start` to your bot
   - Create your first story!

## 📁 Project Structure

```
story-bot/
├── database/
│   └── schema.sql              # Complete PostgreSQL schema
├── config/
│   └── environment.template    # Environment variables template
├── docs/
│   ├── SETUP.md               # Detailed setup guide
│   ├── TELEGRAM_SETUP.md      # Telegram bot configuration
│   └── ARCHITECTURE.md        # Technical architecture details
├── n8n-workflows/
│   └── (workflow files - coming in Phase 2)
├── .gitignore                 # Git ignore rules
├── CLAUDE.md                  # AI assistant project rules
└── README.md                  # This file
```

## 📚 Documentation

- **[Setup Guide](docs/SETUP.md)** - Complete installation instructions
- **[Telegram Setup](docs/TELEGRAM_SETUP.md)** - Bot configuration guide
- **[Architecture](docs/ARCHITECTURE.md)** - Technical design and decisions
- **[Database Schema](database/schema.sql)** - Database structure and functions

## 💰 Cost Estimate

Running costs for 1,000 stories/month:

- **Claude API**: $5-10/month
- **Supabase**: Free (up to 500MB database)
- **n8n Cloud**: $20/month (or free self-hosted)
- **Total**: ~$25-30/month

Scales efficiently - 10,000 stories/month costs only ~$50-80/month.

## 🛡️ Security & Privacy

- ✅ All API keys stored securely (not in code)
- ✅ HTTPS encryption for all communication
- ✅ Minimal data collection (only Telegram IDs)
- ✅ Automatic data cleanup (7 days for conversations, 90 days for stories)
- ✅ Rate limiting to prevent abuse
- ✅ Row-level security in database

## 🔧 Configuration

Key settings in `config/.env`:

```bash
# Rate Limiting
MAX_STORIES_PER_HOUR=5
MAX_STORIES_PER_DAY=20

# Story Generation
DEFAULT_STORY_LENGTH=medium
MIN_STORY_SENTENCES=6
MAX_STORY_SENTENCES=8

# Data Retention
CONVERSATION_RETENTION_DAYS=7
STORY_RETENTION_DAYS=90
```

## 🧪 Testing

Test checklist before going live:

- [ ] Bot responds to `/start`
- [ ] All 5 questions asked in sequence
- [ ] Story is generated successfully
- [ ] `/cancel` command works
- [ ] `/help` command shows information
- [ ] Database correctly stores state
- [ ] Rate limiting prevents abuse
- [ ] Error handling works gracefully

## 🚀 Deployment

**Option 1: n8n Cloud (Recommended for beginners)**
- Sign up at [n8n.io](https://n8n.io/)
- Import workflow
- Set webhook URL in Telegram

**Option 2: Self-hosted**
- Requires Docker or Node.js
- See [n8n hosting docs](https://docs.n8n.io/hosting/)
- Minimum: 2GB RAM, 1 CPU core

**Option 3: Serverless**
- Convert n8n workflow to cloud functions (advanced)
- Deploy to AWS Lambda, Google Cloud Functions, etc.

## 📈 Monitoring

Track key metrics:

- **Usage**: Stories per day, unique users
- **Performance**: Response time, error rate
- **Cost**: API token usage, daily spend
- **Quality**: User feedback, story ratings

Set up alerts for:
- Error rate > 5%
- Daily cost > $10
- Response time > 15 seconds

## 🎨 Future Enhancements

**Phase 2** (Weeks 3-4):
- [ ] Story illustrations with Stable Diffusion
- [ ] Story history and favorites
- [ ] Multi-language support

**Phase 3** (Month 2):
- [ ] Voice narration (text-to-speech)
- [ ] Story series (continuing adventures)
- [ ] Parent dashboard (web interface)

**Phase 4** (Month 3+):
- [ ] Native mobile apps
- [ ] Subscription model
- [ ] Teacher portal for classrooms

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

MIT License - feel free to use for personal or commercial projects.

## 🐛 Troubleshooting

**Bot doesn't respond?**
- Check n8n workflow is active
- Verify Telegram webhook is set
- Review n8n execution logs

**Database errors?**
- Check Supabase project is running
- Verify service_role key is correct
- Review connection settings

**Claude API errors?**
- Verify API key is valid
- Check you have available credits
- Review rate limits

**More help?** See [docs/SETUP.md#troubleshooting](docs/SETUP.md#troubleshooting)

## 👥 Use Cases

- **Parents**: Quick, personalized bedtime stories every night
- **Educators**: Interactive storytelling for classrooms
- **Content Creators**: Generate unique story ideas
- **Speech Therapists**: Personalized social stories
- **Librarians**: Engage children with custom tales

## 🌟 Why This Project?

Traditional bedtime stories are wonderful, but sometimes you need something fresh. This bot creates unlimited unique stories tailored to your child's interests, making bedtime more engaging and magical.

**Built with ❤️ for parents, educators, and anyone who loves storytelling.**

---

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/story-bot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/story-bot/discussions)
- **Email**: your-email@example.com

---

**Star ⭐ this repo if you find it useful!**

Made with Claude AI • Powered by n8n • Built for bedtime 🌙

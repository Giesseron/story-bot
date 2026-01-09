# Bedtime Story Generator - Technical Architecture

## System Overview

The Bedtime Story Generator is a serverless, event-driven system that uses n8n as the orchestration layer between Telegram, Supabase, and Claude AI.

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Interface                            │
│                      (Telegram Mobile/Desktop)                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ HTTPS (Webhook)
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                     Telegram Bot API                             │
│                   (Message Routing)                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ Webhook POST
                            │
┌───────────────────────────▼─────────────────────────────────────┐
│                      n8n Workflow Engine                         │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  1. Message Router                                         │ │
│  │  2. State Machine Controller                               │ │
│  │  3. Question Flow Manager                                  │ │
│  │  4. API Orchestrator                                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└────────┬──────────────────┬──────────────────┬──────────────────┘
         │                  │                  │
         │                  │                  │
         │                  │                  │
    ┌────▼────┐      ┌──────▼───────┐    ┌────▼────────┐
    │Supabase │      │  Claude API  │    │  Optional   │
    │Database │      │(Story Gen)   │    │Image API    │
    └─────────┘      └──────────────┘    └─────────────┘
```

---

## Component Architecture

### 1. Telegram Bot (User Interface Layer)

**Technology**: Telegram Bot API
**Purpose**: User interaction interface
**Communication**: Webhook (push) to n8n

**Responsibilities**:
- Receive user messages
- Display bot responses
- Provide command interface (/start, /cancel, /help)
- Show typing indicators
- Handle multimedia (future: images)

**Data Flow**:
```
User Input → Telegram Client → Telegram API → n8n Webhook
n8n Response → Telegram API → Telegram Client → User Screen
```

---

### 2. n8n Workflow Engine (Orchestration Layer)

**Technology**: n8n (v1.0+)
**Purpose**: Central business logic and orchestration
**Hosting**: Self-hosted or n8n Cloud

**Core Workflows**:

#### 2.1 Main Story Bot Workflow

**Trigger**: Webhook (receives Telegram updates)

**Node Structure**:
```
1. Webhook Trigger
   ↓
2. Extract Message Data (Function)
   ↓
3. Command Router (Switch)
   ├─→ /start → Initialize Flow
   ├─→ /cancel → Cancel Flow
   ├─→ /help → Show Help
   └─→ Default → Process Answer
       ↓
4. Get User State (Supabase)
   ↓
5. State Machine Logic (Function)
   ↓
6. Update State (Supabase)
   ↓
7. Branch: Generate or Ask?
   ├─→ Ask Next Question
   │   └─→ Send Telegram Message
   │
   └─→ Generate Story
       ↓
       8. Prepare Claude Prompt (Function)
       ↓
       9. Call Claude API (HTTP Request)
       ↓
       10. Extract Story (Function)
       ↓
       11. Save Story (Supabase)
       ↓
       12. Reset State (Supabase)
       ↓
       13. Send Story (Telegram)
```

**State Machine States**:
```javascript
const STATES = {
    IDLE: 'idle',                          // No active conversation
    AWAITING_CHARACTER: 'awaiting_character', // Q1: Who is the main character?
    AWAITING_LOCATION: 'awaiting_location',   // Q2: Where does it take place?
    AWAITING_TOPIC: 'awaiting_topic',         // Q3: What is the main topic?
    AWAITING_PROBLEM: 'awaiting_problem',     // Q4: What problem occurs?
    AWAITING_ENDING: 'awaiting_ending',       // Q5: How should it end?
    GENERATING: 'generating'                  // Story generation in progress
};
```

**State Transitions**:
```
idle → awaiting_character → awaiting_location → awaiting_topic
→ awaiting_problem → awaiting_ending → generating → idle
```

#### 2.2 Error Handling Workflow

**Trigger**: Error Trigger (catches failures in main workflow)

**Flow**:
```
Error Occurs
   ↓
Log Error Details
   ↓
Reset User State to 'idle'
   ↓
Send Error Message to User
   ↓
(Optional) Alert Admin
```

**Error Types Handled**:
- Database connection failures
- Claude API timeouts
- Invalid user states
- Rate limit exceeded
- Malformed webhook data

---

### 3. Supabase Database (Persistence Layer)

**Technology**: PostgreSQL 14+ (Supabase)
**Purpose**: State management and data persistence
**Access**: Service role key (full access)

#### 3.1 Database Schema

**Table: conversation_states**
```sql
{
    id: UUID (PK),
    chat_id: BIGINT,
    user_id: BIGINT,
    state: VARCHAR(50),
    current_question: INT,
    answers: JSONB,
    created_at: TIMESTAMP,
    updated_at: TIMESTAMP
}
```
**Purpose**: Track current conversation state for each user
**Indexing**: (chat_id, user_id), state, updated_at
**Constraints**: Unique(chat_id, user_id)

**Table: generated_stories**
```sql
{
    id: UUID (PK),
    chat_id: BIGINT,
    user_id: BIGINT,
    story_text: TEXT,
    answers: JSONB,
    image_url: TEXT,
    created_at: TIMESTAMP
}
```
**Purpose**: Archive of generated stories
**Indexing**: (user_id, created_at), (chat_id, created_at)
**Retention**: 90 days (configurable)

**Table: usage_metrics**
```sql
{
    id: UUID (PK),
    user_id: BIGINT,
    action: VARCHAR(50),
    tokens_used: INT,
    cost_usd: DECIMAL(10,6),
    created_at: TIMESTAMP
}
```
**Purpose**: Rate limiting and cost tracking
**Indexing**: (user_id, created_at), action

**Table: user_preferences** (Future)
```sql
{
    id: UUID (PK),
    user_id: BIGINT,
    preferred_language: VARCHAR(10),
    story_length: VARCHAR(20),
    enable_images: BOOLEAN,
    created_at: TIMESTAMP,
    updated_at: TIMESTAMP
}
```
**Purpose**: User personalization settings

#### 3.2 Database Functions

**Rate Limiting Function**:
```sql
check_rate_limit(user_id, max_stories, time_window_hours) → BOOLEAN
```
**Purpose**: Returns TRUE if user hasn't exceeded limit

**Cleanup Function**:
```sql
cleanup_old_conversations() → INT
```
**Purpose**: Removes conversations older than 7 days

**Archive Function**:
```sql
archive_old_stories() → INT
```
**Purpose**: Removes stories older than 90 days

---

### 4. Claude API (AI Generation Layer)

**Technology**: Anthropic Claude API
**Model**: claude-3-5-sonnet-20241022
**Purpose**: Story text generation

#### 4.1 API Configuration

```javascript
{
    model: "claude-3-5-sonnet-20241022",
    max_tokens: 1024,
    temperature: 0.7,
    system: "System prompt for story generation",
    messages: [
        { role: "user", content: "User prompt with story parameters" }
    ]
}
```

#### 4.2 Prompt Structure

**System Prompt**:
```
You are a creative children's story writer. Generate a warm,
age-appropriate bedtime story (6-8 sentences) that is gentle,
positive, and suitable for children ages 3-10.

Ensure the story:
- Has a clear beginning, middle, and end
- Uses simple, engaging language
- Includes a positive message
- Is calming and suitable for bedtime
- Contains no scary or inappropriate content
```

**User Prompt Template**:
```
Create a bedtime story with these elements:
- Main character: {character}
- Setting: {location}
- Theme: {topic}
- Challenge: {problem}
- Ending: {ending}

Write a gentle, engaging bedtime story that brings these elements together.
```

#### 4.3 Response Handling

**Expected Response Structure**:
```json
{
    "content": [
        {
            "type": "text",
            "text": "Once upon a time..."
        }
    ],
    "usage": {
        "input_tokens": 150,
        "output_tokens": 250
    }
}
```

**Error Handling**:
- Timeout: Retry with exponential backoff (max 3 attempts)
- Rate limit: Queue request, inform user of delay
- Invalid response: Log error, ask user to try again
- Token limit: Adjust max_tokens or prompt length

---

### 5. Optional: Image Generation Layer

**Technology**: Stable Diffusion or DALL-E
**Purpose**: Visual story illustrations
**Integration**: Separate workflow triggered after story generation

**Flow**:
```
Story Generated
   ↓
Trigger Image Workflow (async)
   ↓
Prepare Image Prompt
   ↓
Call Image API
   ↓
Save Image URL
   ↓
Send Image to User
```

**Image Prompt Template**:
```
A child-friendly, whimsical illustration of {character} in {location},
digital art, warm colors, gentle style, suitable for children's book,
storybook illustration
```

---

## Data Flow Diagrams

### Happy Path: Complete Story Generation

```
User: "I want a story"
   ↓
[Telegram] → [n8n Webhook]
   ↓
[Extract Message] chat_id=123, user_id=456, text="I want a story"
   ↓
[Command Router] → Matches "story" keyword
   ↓
[Get User State] → Query Supabase
   ↓
[State Check] → state = 'idle' (or create new record)
   ↓
[State Transition] → 'idle' → 'awaiting_character'
   ↓
[Update Database] → Set state='awaiting_character', current_question=1
   ↓
[Send Question 1] → "Who is the main character?"
   ↓
User: "A brave rabbit"
   ↓
[Receive Answer] → text="A brave rabbit"
   ↓
[Get State] → state='awaiting_character'
   ↓
[Save Answer] → answers.character = "A brave rabbit"
   ↓
[State Transition] → 'awaiting_character' → 'awaiting_location'
   ↓
[Send Question 2] → "Where does the story take place?"
   ↓
... (repeat for questions 3, 4, 5) ...
   ↓
User: "Happy celebration"
   ↓
[Receive Final Answer]
   ↓
[Save Answer] → answers.ending = "Happy celebration"
   ↓
[State Transition] → 'awaiting_ending' → 'generating'
   ↓
[Prepare Claude Prompt] → Compile all answers into prompt
   ↓
[Call Claude API] → POST /v1/messages
   ↓
[Claude Generates Story] → ~250 tokens, ~3-5 seconds
   ↓
[Extract Story Text]
   ↓
[Save to Database] → Insert into generated_stories
   ↓
[Log Usage] → Insert into usage_metrics
   ↓
[Reset State] → state='idle', answers={}
   ↓
[Send Story] → "🌙 Here's your personalized bedtime story! 🌙\n\n..."
   ↓
User receives story ✅
```

### Error Path: API Failure

```
[Call Claude API]
   ↓
❌ API Returns 503 Service Unavailable
   ↓
[Error Trigger Activated]
   ↓
[Log Error] → "Claude API timeout, user_id=456"
   ↓
[Reset State] → state='idle'
   ↓
[Send Error Message] → "Oops! Something went wrong. Please try again."
   ↓
User can restart with /start
```

---

## Security Architecture

### 1. Authentication & Authorization

**Telegram Bot Token**:
- Stored in n8n credentials (encrypted at rest)
- Never exposed in workflow JSON
- Validated on every webhook request

**Supabase Access**:
- Service role key for backend operations
- Row Level Security (RLS) enabled
- No public anon key used

**Claude API Key**:
- Stored in n8n credentials
- Passed via HTTP header (x-api-key)
- Rotated every 90 days

### 2. Data Security

**In Transit**:
- All communication over HTTPS
- TLS 1.2+ required
- Certificate validation enabled

**At Rest**:
- Supabase encryption at rest (AES-256)
- No plaintext storage of sensitive data
- Conversation states deleted after 7 days

**PII Handling**:
- Only store Telegram IDs (not names/usernames)
- Story content treated as user data
- GDPR-compliant deletion on request

### 3. Rate Limiting

**Per-User Limits**:
- 5 stories per hour
- 20 stories per day
- Enforced via database function

**Global Limits**:
- n8n: 1000 executions/day (cloud tier dependent)
- Claude API: 5 requests/minute (tier dependent)
- Supabase: 500 API calls/second (free tier)

### 4. Input Validation

**User Input Sanitization**:
```javascript
// Validate and clean user input
function sanitizeInput(text) {
    // Remove control characters
    text = text.replace(/[\x00-\x1F\x7F-\x9F]/g, '');

    // Limit length
    if (text.length > 1000) {
        text = text.substring(0, 1000);
    }

    // Trim whitespace
    return text.trim();
}
```

**SQL Injection Prevention**:
- All queries use parameterized statements
- Supabase client handles escaping
- No raw SQL with user input

---

## Performance Considerations

### Response Times

| Operation | Target | Typical |
|-----------|--------|---------|
| Receive message → Acknowledge | <1s | 200-500ms |
| Question display | <2s | 500ms-1s |
| Story generation | <10s | 5-8s |
| Database query | <500ms | 100-300ms |

### Throughput

| Metric | Capacity |
|--------|----------|
| Concurrent users | 100-500 (n8n dependent) |
| Stories per hour | 1000+ (API limit dependent) |
| Database connections | 15 (Supabase free tier) |

### Optimization Strategies

1. **Prompt Caching** (Claude API):
   - Cache system prompt across requests
   - Saves ~50% input tokens

2. **Database Connection Pooling**:
   - Supabase manages internally
   - n8n reuses connections

3. **Async Operations**:
   - Image generation runs in background
   - Non-blocking story delivery

---

## Monitoring & Observability

### Key Metrics

**Business Metrics**:
- Stories generated per day
- Unique active users
- Completion rate (started → finished)
- Average time to complete flow

**Technical Metrics**:
- n8n workflow execution success rate
- API latency (P50, P95, P99)
- Database query performance
- Error rate by type

**Cost Metrics**:
- Claude API token usage
- Cost per story
- Database storage growth
- n8n execution minutes

### Logging Strategy

**n8n Execution Logs**:
- Every workflow execution logged
- Retention: 7 days (n8n cloud) / configurable (self-hosted)
- Searchable by user_id, error type

**Application Logs**:
- Structured JSON logging
- Include: timestamp, user_id, action, result, duration
- Sensitive data redacted

**Example Log Entry**:
```json
{
    "timestamp": "2026-01-09T10:30:45Z",
    "level": "info",
    "action": "story_generated",
    "user_id": 123456789,
    "chat_id": 123456789,
    "duration_ms": 5234,
    "tokens_used": 245,
    "cost_usd": 0.003,
    "model": "claude-3-5-sonnet-20241022"
}
```

### Alerting

**Critical Alerts** (immediate response):
- Error rate > 10% over 5 minutes
- Claude API returning errors
- Database connection failures
- Webhook not receiving updates

**Warning Alerts** (review within 1 hour):
- Error rate > 5% over 15 minutes
- Response time > 15s P95
- Daily cost > $10
- Storage > 80% capacity

---

## Scalability Path

### Current Capacity
- **Users**: 100-500 concurrent
- **Stories**: 1000-2000 per day
- **Cost**: $25-50/month

### Scale to 10k Users
**Required Changes**:
1. Upgrade Supabase to Pro ($25/month)
2. Upgrade n8n to Business tier ($50/month)
3. Add Redis for session caching
4. Implement queue system for story generation
5. Add load balancer (if self-hosted)

**Estimated Cost**: $200-300/month

### Scale to 100k Users
**Required Changes**:
1. Move to dedicated infrastructure
2. Implement microservices architecture
3. Add CDN for image delivery
4. Multiple n8n instances with load balancing
5. Database read replicas
6. Horizontal scaling of stateless components

**Estimated Cost**: $1000-2000/month

---

## Deployment Architecture

### Production Setup (Recommended)

```
Production Environment
├── n8n Cloud (or self-hosted with 2GB RAM)
├── Supabase Pro (for better rate limits)
├── Anthropic Claude API (Pay-as-you-go)
└── Cloudflare (optional, for DDoS protection)
```

### Development Setup

```
Development Environment
├── n8n Desktop or Docker (local)
├── Supabase Local (Docker)
├── Anthropic Claude API (shared key with production)
└── Ngrok (for Telegram webhook testing)
```

### CI/CD Pipeline (Future)

```
Code Push → GitHub
    ↓
GitHub Actions
    ↓
├─→ Run Tests
├─→ Validate SQL Schema
├─→ Export n8n Workflows
└─→ Deploy to n8n Cloud
```

---

## Technology Decisions Rationale

### Why n8n?
✅ Visual workflow builder (faster development)
✅ Built-in error handling
✅ Native integrations (Telegram, Supabase, HTTP)
✅ Can self-host or use cloud
❌ Less flexible than custom code
❌ Learning curve for complex logic

### Why Supabase?
✅ PostgreSQL (powerful, reliable)
✅ Real-time capabilities (future features)
✅ Built-in auth system (future)
✅ Generous free tier
❌ Vendor lock-in
❌ Cold starts on free tier

### Why Claude?
✅ Excellent at creative writing
✅ Strong safety guardrails
✅ Good reasoning for story coherence
✅ Competitive pricing
❌ Rate limits on free tier
❌ Less control than open-source models

---

## Future Architecture Enhancements

### Phase 2 Features
1. **Story Illustrations**: Integrate Stable Diffusion
2. **Voice Stories**: Text-to-speech with ElevenLabs
3. **Story History**: User can view past stories
4. **Favorite Characters**: Save and reuse characters

### Phase 3 Features
1. **Multi-language**: Support Spanish, French, German
2. **Story Series**: Continuing adventures
3. **Parent Dashboard**: Web interface for managing stories
4. **Social Sharing**: Share stories with friends

### Phase 4 Features
1. **Mobile App**: Native iOS/Android apps
2. **Subscription Model**: Premium features
3. **Teacher Portal**: Classroom management
4. **Analytics Dashboard**: Usage insights

---

## Conclusion

This architecture provides:
- ✅ **Simplicity**: No-code/low-code approach
- ✅ **Reliability**: Proven technologies
- ✅ **Scalability**: Clear path to growth
- ✅ **Maintainability**: Easy to understand and modify
- ✅ **Cost-effective**: Starts at ~$25/month

The serverless, event-driven design allows the system to scale from 10 to 100,000 users with minimal architectural changes.

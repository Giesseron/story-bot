-- ============================================================
-- Bedtime Story Generator - Database Schema
-- ============================================================
-- Description: PostgreSQL schema for Telegram-based AI story generator
-- Database: Supabase (PostgreSQL 14+)
-- Version: 1.0.0
-- Created: 2026-01-09
-- ============================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Table: conversation_states
-- Description: Tracks the current state of each user's conversation
-- Purpose: State machine management for question flow
-- ============================================================

CREATE TABLE IF NOT EXISTS conversation_states (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Telegram identifiers
    chat_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,

    -- State management
    state VARCHAR(50) NOT NULL DEFAULT 'idle',
    current_question INT DEFAULT 0,

    -- User answers stored as JSON
    -- Structure: {"character": "...", "location": "...", "topic": "...", "problem": "...", "ending": "..."}
    answers JSONB DEFAULT '{}',

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT conversation_states_unique_user UNIQUE(chat_id, user_id),
    CONSTRAINT valid_state CHECK (state IN (
        'idle',
        'awaiting_character',
        'awaiting_location',
        'awaiting_topic',
        'awaiting_problem',
        'awaiting_ending',
        'generating'
    ))
);

-- Indexes for conversation_states
CREATE INDEX idx_conversation_states_chat_user ON conversation_states(chat_id, user_id);
CREATE INDEX idx_conversation_states_state ON conversation_states(state);
CREATE INDEX idx_conversation_states_updated ON conversation_states(updated_at);

-- Comments for conversation_states
COMMENT ON TABLE conversation_states IS 'Tracks user conversation state and progress through question flow';
COMMENT ON COLUMN conversation_states.chat_id IS 'Telegram chat identifier (supports group chats)';
COMMENT ON COLUMN conversation_states.user_id IS 'Telegram user identifier';
COMMENT ON COLUMN conversation_states.state IS 'Current state in the conversation flow';
COMMENT ON COLUMN conversation_states.current_question IS 'Current question number (0-5)';
COMMENT ON COLUMN conversation_states.answers IS 'JSON object containing user answers to questions';

-- ============================================================
-- Table: generated_stories
-- Description: Stores all generated stories for history and analytics
-- Purpose: Audit trail, user history, analytics
-- ============================================================

CREATE TABLE IF NOT EXISTS generated_stories (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Telegram identifiers
    chat_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,

    -- Story content
    story_text TEXT NOT NULL,

    -- Story parameters (the answers that generated this story)
    answers JSONB NOT NULL,

    -- Optional image URL if image generation is enabled
    image_url TEXT,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT story_text_not_empty CHECK (LENGTH(story_text) > 0)
);

-- Indexes for generated_stories
CREATE INDEX idx_generated_stories_user ON generated_stories(user_id, created_at DESC);
CREATE INDEX idx_generated_stories_chat ON generated_stories(chat_id, created_at DESC);
CREATE INDEX idx_generated_stories_created ON generated_stories(created_at);

-- Comments for generated_stories
COMMENT ON TABLE generated_stories IS 'Archive of all generated stories with their parameters';
COMMENT ON COLUMN generated_stories.story_text IS 'The complete generated story text';
COMMENT ON COLUMN generated_stories.answers IS 'JSON object with character, location, topic, problem, ending';
COMMENT ON COLUMN generated_stories.image_url IS 'Optional URL to generated illustration image';

-- ============================================================
-- Table: usage_metrics
-- Description: Tracks API usage for rate limiting and cost monitoring
-- Purpose: Rate limiting, cost control, analytics
-- ============================================================

CREATE TABLE IF NOT EXISTS usage_metrics (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Telegram identifier
    user_id BIGINT NOT NULL,

    -- Action tracking
    action VARCHAR(50) NOT NULL,

    -- Cost tracking
    tokens_used INT,
    cost_usd DECIMAL(10, 6),

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT valid_action CHECK (action IN (
        'story_generated',
        'image_generated',
        'api_call',
        'rate_limited'
    ))
);

-- Indexes for usage_metrics
CREATE INDEX idx_usage_metrics_user_time ON usage_metrics(user_id, created_at DESC);
CREATE INDEX idx_usage_metrics_action ON usage_metrics(action);
CREATE INDEX idx_usage_metrics_created ON usage_metrics(created_at);

-- Comments for usage_metrics
COMMENT ON TABLE usage_metrics IS 'Tracks API usage for rate limiting and cost monitoring';
COMMENT ON COLUMN usage_metrics.action IS 'Type of action performed (story_generated, image_generated, etc)';
COMMENT ON COLUMN usage_metrics.tokens_used IS 'Number of tokens consumed by Claude API';
COMMENT ON COLUMN usage_metrics.cost_usd IS 'Estimated cost in USD for this operation';

-- ============================================================
-- Table: user_preferences (Optional - Future Enhancement)
-- Description: Stores user preferences and settings
-- Purpose: Personalization, user experience
-- ============================================================

CREATE TABLE IF NOT EXISTS user_preferences (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

    -- Telegram identifier
    user_id BIGINT NOT NULL UNIQUE,

    -- Preferences
    preferred_language VARCHAR(10) DEFAULT 'en',
    story_length VARCHAR(20) DEFAULT 'medium', -- short, medium, long
    enable_images BOOLEAN DEFAULT FALSE,

    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT valid_story_length CHECK (story_length IN ('short', 'medium', 'long'))
);

-- Indexes for user_preferences
CREATE INDEX idx_user_preferences_user ON user_preferences(user_id);

-- Comments for user_preferences
COMMENT ON TABLE user_preferences IS 'User preferences and personalization settings';
COMMENT ON COLUMN user_preferences.story_length IS 'Preferred story length: short (4-6 sentences), medium (6-8), long (10-12)';

-- ============================================================
-- Functions and Triggers
-- ============================================================

-- Function: Update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update updated_at on conversation_states
CREATE TRIGGER update_conversation_states_updated_at
    BEFORE UPDATE ON conversation_states
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger: Auto-update updated_at on user_preferences
CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON user_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- Helper Functions for Rate Limiting
-- ============================================================

-- Function: Check if user has exceeded rate limit
CREATE OR REPLACE FUNCTION check_rate_limit(
    p_user_id BIGINT,
    p_max_stories INT DEFAULT 5,
    p_time_window_hours INT DEFAULT 1
)
RETURNS BOOLEAN AS $$
DECLARE
    story_count INT;
BEGIN
    SELECT COUNT(*) INTO story_count
    FROM usage_metrics
    WHERE user_id = p_user_id
        AND action = 'story_generated'
        AND created_at > NOW() - (p_time_window_hours || ' hours')::INTERVAL;

    RETURN story_count < p_max_stories;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_rate_limit IS 'Returns TRUE if user has not exceeded rate limit, FALSE otherwise';

-- Function: Get user story count in time window
CREATE OR REPLACE FUNCTION get_user_story_count(
    p_user_id BIGINT,
    p_time_window_hours INT DEFAULT 1
)
RETURNS INT AS $$
DECLARE
    story_count INT;
BEGIN
    SELECT COUNT(*) INTO story_count
    FROM usage_metrics
    WHERE user_id = p_user_id
        AND action = 'story_generated'
        AND created_at > NOW() - (p_time_window_hours || ' hours')::INTERVAL;

    RETURN story_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_user_story_count IS 'Returns the number of stories generated by user in the specified time window';

-- ============================================================
-- Data Retention Policies (Optional)
-- ============================================================

-- Function: Clean up old conversation states (older than 7 days)
CREATE OR REPLACE FUNCTION cleanup_old_conversations()
RETURNS INT AS $$
DECLARE
    deleted_count INT;
BEGIN
    WITH deleted AS (
        DELETE FROM conversation_states
        WHERE updated_at < NOW() - INTERVAL '7 days'
        RETURNING *
    )
    SELECT COUNT(*) INTO deleted_count FROM deleted;

    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION cleanup_old_conversations IS 'Deletes conversation states older than 7 days for privacy';

-- Function: Archive old stories (older than 90 days)
CREATE OR REPLACE FUNCTION archive_old_stories()
RETURNS INT AS $$
DECLARE
    archived_count INT;
BEGIN
    -- In production, you might move these to an archive table
    -- For now, we just delete them
    WITH archived AS (
        DELETE FROM generated_stories
        WHERE created_at < NOW() - INTERVAL '90 days'
        RETURNING *
    )
    SELECT COUNT(*) INTO archived_count FROM archived;

    RETURN archived_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION archive_old_stories IS 'Archives/deletes stories older than 90 days';

-- ============================================================
-- Row Level Security (RLS) - Supabase Best Practice
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE conversation_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Note: You'll need to create specific RLS policies based on your authentication setup
-- For a bot backend, you typically create a service role policy that allows all operations

-- Example policy for service role (adjust based on your Supabase setup)
-- CREATE POLICY "Service role has full access" ON conversation_states
--     FOR ALL TO service_role USING (true);

-- ============================================================
-- Initial Data / Seed Data
-- ============================================================

-- You can add seed data here if needed
-- Example: Default user preferences, configuration values, etc.

-- ============================================================
-- Database Setup Complete
-- ============================================================

-- Verification queries (uncomment to test after running):
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
-- SELECT * FROM conversation_states LIMIT 1;
-- SELECT check_rate_limit(123456789, 5, 1);

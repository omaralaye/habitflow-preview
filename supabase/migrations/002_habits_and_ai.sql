-- Habits table (replaces in-memory storage)
CREATE TABLE habits (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title       TEXT NOT NULL,
  description TEXT DEFAULT '',
  icon        INT NOT NULL DEFAULT 0,
  color_value BIGINT NOT NULL DEFAULT 0,
  category    TEXT NOT NULL DEFAULT 'Other',
  duration    TEXT NOT NULL DEFAULT 'Daily',
  difficulty  TEXT DEFAULT 'Easy',
  popularity  DOUBLE PRECISION DEFAULT 0,
  users       TEXT DEFAULT '',
  is_added    BOOLEAN DEFAULT true,
  is_challenge BOOLEAN DEFAULT false,
  challenge_id INT,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- Daily logs for progress tracking
CREATE TABLE daily_logs (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  habit_id     BIGINT REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
  log_date     DATE NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  created_at   TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, habit_id, log_date)
);

-- AI chat message history
CREATE TABLE ai_chat_messages (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role       TEXT NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Cached AI insights (weekly narratives, pattern detections, tips)
CREATE TABLE ai_insights (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id      UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  insight_type TEXT NOT NULL CHECK (insight_type IN ('weekly', 'pattern', 'tip', 'schedule')),
  content      TEXT NOT NULL,
  week_start   DATE,
  created_at   TIMESTAMPTZ DEFAULT now()
);

-- Row Level Security
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;

-- Users can only see their own habits
CREATE POLICY "Users can view own habits"
  ON habits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits"
  ON habits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
  ON habits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
  ON habits FOR DELETE
  USING (auth.uid() = user_id);

-- Daily logs policies
CREATE POLICY "Users can view own daily logs"
  ON daily_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily logs"
  ON daily_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily logs"
  ON daily_logs FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own daily logs"
  ON daily_logs FOR DELETE
  USING (auth.uid() = user_id);

-- AI chat messages policies
CREATE POLICY "Users can view own chat messages"
  ON ai_chat_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own chat messages"
  ON ai_chat_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- AI insights policies
CREATE POLICY "Users can view own insights"
  ON ai_insights FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own insights"
  ON ai_insights FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own insights"
  ON ai_insights FOR DELETE
  USING (auth.uid() = user_id);

-- Service role can manage all
CREATE POLICY "Service role can manage all habits"
  ON habits FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all daily_logs"
  ON daily_logs FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all ai_chat_messages"
  ON ai_chat_messages FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Service role can manage all ai_insights"
  ON ai_insights FOR ALL
  USING (auth.role() = 'service_role');

-- Indexes for performance
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_daily_logs_user_id ON daily_logs(user_id);
CREATE INDEX idx_daily_logs_habit_id ON daily_logs(habit_id);
CREATE INDEX idx_daily_logs_log_date ON daily_logs(log_date);
CREATE INDEX idx_ai_chat_messages_user_id ON ai_chat_messages(user_id);
CREATE INDEX idx_ai_insights_user_id ON ai_insights(user_id);

-- Enable auto-updated_at for habits
CREATE TRIGGER set_habits_updated_at
  BEFORE UPDATE ON habits
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

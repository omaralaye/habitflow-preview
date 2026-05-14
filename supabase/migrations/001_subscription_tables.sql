-- Subscription plans
CREATE TABLE subscription_plans (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  description TEXT,
  max_habits  INT,
  price_monthly_cents INT,
  price_yearly_cents  INT,
  stripe_price_id_monthly TEXT,
  stripe_price_id_yearly  TEXT,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- User subscriptions
CREATE TABLE user_subscriptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  plan_id         TEXT REFERENCES subscription_plans(id) NOT NULL DEFAULT 'free',
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  status          TEXT NOT NULL DEFAULT 'active',
  current_period_start TIMESTAMPTZ,
  current_period_end   TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Auto-create subscription row on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_subscriptions (user_id, plan_id)
  VALUES (NEW.id, 'free');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Row Level Security
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage all subscriptions"
  ON user_subscriptions FOR ALL
  USING (auth.role() = 'service_role');

-- Enable auto-updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Seed plans
INSERT INTO subscription_plans (id, name, description, max_habits, price_monthly_cents, price_yearly_cents, stripe_price_id_monthly, stripe_price_id_yearly)
VALUES
  ('free',     'Free',     'Basic habit tracking', 5,  null, null, null, null),
  ('premium',  'Premium',  'Unlimited habits & more', null, 999, 7999, null, null)
ON CONFLICT (id) DO NOTHING;

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const NVIDIA_BASE_URL = "https://integrate.api.nvidia.com/v1";
const NVIDIA_MODEL = "meta/llama-3.1-8b-instruct";

const SYSTEM_PROMPTS: Record<string, string> = {
  coach: `You are a compassionate, insightful habit coach for the HabitFlow app. You have access to the user's current habits, streaks, and progress stats. Your role is to:
- Greet them warmly and reference their recent progress
- Give specific, personalized encouragement based on their actual habits
- Detect patterns ("I notice you often skip X on Y day")
- Suggest micro-adjustments when they're struggling
- Celebrate milestones genuinely
- Keep responses concise (2-4 sentences) and conversational
- NEVER give generic advice like "just stay consistent" without context
- Reference their actual habit names and data
- Ask thoughtful follow-up questions

You are NOT a general AI assistant. Stay focused on habit coaching.`,

  parse_habit: `You are a habit parser for the HabitFlow app. Convert the user's natural language habit description into a structured JSON object. Extract:
- title: short habit name (required)
- category: one of "Health", "Fitness", "Mindfulness", "Learning", "Productivity", "Social", "Finance", "Sleep", "Other"
- duration: one of "Daily", "Weekdays", "Weekends", "Weekly", "3x / Week", "Custom"
- description: brief description (optional, max 100 chars)

Return ONLY valid JSON with no other text. Example:
Input: "I want to read 20 pages before bed every night"
Output: {"title":"Read 20 pages","category":"Learning","duration":"Daily","description":"Read 20 pages before bed nightly"}

Input: "meditate for 10 minutes on weekend mornings"
Output: {"title":"Morning Meditation","category":"Mindfulness","duration":"Weekends","description":"10 minute meditation on weekend mornings"}`,

  insight: `You are a habit analyst for the HabitFlow app. Given the user's habit data and weekly stats, generate a brief, personalized weekly insight (2-3 sentences). Be specific:
- Mention actual habit names and streak numbers
- Identify one strength and one opportunity for growth
- Suggest one small actionable tip
- Use a warm, encouraging tone
- Never use clichés

Return ONLY the insight text, no preamble.`,

  analysis: `You are a habit pattern analyst for the HabitFlow app. Given the user's complete habit data and daily logs, analyze their patterns. Identify:
1. Which habits they're most consistent with and why it might be working
2. Which habits they struggle with and potential reasons (timing, difficulty, etc.)
3. Any correlations between habits (e.g., "When you meditate, you're 30% more likely to complete your workout")
4. The time of day or day of week they perform best
5. Specific recommendations for improvement

Return a concise analysis (3-5 sentences maximum). Be specific and data-driven.`,

  schedule: `You are a scheduling optimizer for the HabitFlow app. Given the user's habit completion data, suggest optimal times and scheduling adjustments. Focus on:
1. Which habits should be done at what time of day based on completion patterns
2. Whether any habits should have their frequency adjusted
3. Optimal ordering of habits (e.g., "Do X before Y for better completion")
4. Specific, actionable recommendations

Return 2-3 concise suggestions. Be specific about habit names and times.`,
};

serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization")?.replace("Bearer ", "");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No auth" }), { status: 401 });
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const nvidiaApiKey = Deno.env.get("NVIDIA_API_KEY") ?? "";

    if (!nvidiaApiKey) {
      return new Response(JSON.stringify({ error: "NVIDIA API key not configured" }), { status: 500 });
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: { headers: { Authorization: `Bearer ${authHeader}` } },
    });

    const { data: { user }, error: userError } = await supabase.auth.getUser(authHeader);
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
    }

    const { messages, mode, context } = await req.json();
    const validMode = ["coach", "parse_habit", "insight", "analysis", "schedule"].includes(mode) ? mode : "coach";

    let contextBlock = "";
    if (context) {
      contextBlock = `\n\nUser context (current app data):\n${JSON.stringify(context, null, 2)}`;
    }

    const systemMessage = SYSTEM_PROMPTS[validMode] + contextBlock;

    const nvidiaMessages = [
      { role: "system", content: systemMessage },
      ...(messages || []),
    ];

    const nvidiaResponse = await fetch(`${NVIDIA_BASE_URL}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${nvidiaApiKey}`,
      },
      body: JSON.stringify({
        model: NVIDIA_MODEL,
        messages: nvidiaMessages,
        temperature: validMode === "parse_habit" ? 0.1 : 0.7,
        top_p: 0.95,
        max_tokens: validMode === "parse_habit" ? 200 : 500,
      }),
    });

    if (!nvidiaResponse.ok) {
      const errorText = await nvidiaResponse.text();
      return new Response(
        JSON.stringify({ error: `NVIDIA API error: ${nvidiaResponse.status}`, details: errorText }),
        { status: 502 },
      );
    }

    const nvidiaData = await nvidiaResponse.json();
    const aiContent = nvidiaData.choices?.[0]?.message?.content ?? "";

    return new Response(JSON.stringify({ content: aiContent }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), { status: 500 });
  }
});

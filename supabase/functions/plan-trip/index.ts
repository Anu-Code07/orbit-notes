// Supabase Edge Function: plan-trip
// Secrets: GROQ_API_KEY (required), GROQ_MODEL (optional)
//
// Deploy:
//   supabase functions deploy plan-trip --project-ref oyjxpiradbbuocxsunmu
//   supabase secrets set GROQ_API_KEY=gsk_... --project-ref oyjxpiradbbuocxsunmu

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

type PlanBody = {
  vibe?: string;
  dayCount?: number;
  pace?: string;
  focus?: string;
  companions?: string;
  mustInclude?: string;
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const groqKey = Deno.env.get('GROQ_API_KEY');
    if (!groqKey) {
      return json(
        { error: 'GROQ_API_KEY is not configured on the server.' },
        500,
      );
    }

    const body = (await req.json()) as PlanBody;
    const vibe = (body.vibe ?? '').trim();
    const dayCount = clamp(Number(body.dayCount ?? 4), 1, 14);
    if (vibe.length < 2) {
      return json({ error: 'Describe the trip vibe first.' }, 400);
    }

    const model = Deno.env.get('GROQ_MODEL') ?? 'llama-3.3-70b-versatile';
    const must = (body.mustInclude ?? '').trim() || 'none';

    const groqResponse = await fetch(
      'https://api.groq.com/openai/v1/chat/completions',
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${groqKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model,
          temperature: 0.7,
          response_format: { type: 'json_object' },
          messages: [
            {
              role: 'system',
              content:
                'You are Orbit, a poetic travel journal planner. ' +
                'Reply with JSON only matching: ' +
                '{"title":string,"destination":string,"summary":string,' +
                '"days":[{"dayIndex":number,"title":string,"placeHint":string,' +
                '"entryPrompt":string}]}. ' +
                'dayIndex starts at 1. placeHint MUST be a real searchable ' +
                'landmark or neighborhood name (good for photos). ' +
                'entryPrompt is a short journal spark (1-2 sentences). ' +
                'Keep titles evocative, not generic.',
            },
            {
              role: 'user',
              content: `Plan a ${dayCount}-day travel journal for Orbit Notes.
Vibe: ${vibe}
Pace: ${body.pace ?? 'balanced'}
Focus: ${body.focus ?? 'mixed'}
Companions: ${body.companions ?? 'travelers'}
Must include: ${must}
Return exactly ${dayCount} days.`,
            },
          ],
        }),
      },
    );

    if (!groqResponse.ok) {
      const detail = await groqResponse.text();
      console.error('Groq error', groqResponse.status, detail);
      return json(
        { error: `Trip planning failed (${groqResponse.status}). Try again.` },
        502,
      );
    }

    const groqJson = await groqResponse.json();
    const content = groqJson?.choices?.[0]?.message?.content?.trim();
    if (!content) {
      return json({ error: 'AI returned an empty plan.' }, 502);
    }

    const plan = JSON.parse(content);
    return json({ plan }, 200);
  } catch (error) {
    console.error(error);
    return json({ error: 'Could not plan this trip. Try again.' }, 500);
  }
});

function clamp(n: number, min: number, max: number) {
  if (Number.isNaN(n)) return min;
  return Math.min(max, Math.max(min, Math.floor(n)));
}

function json(payload: unknown, status: number) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

# Converting n8n Workflow to Use Gemini

## Quick Conversion Guide

After importing the workflow into n8n, make these 3 simple changes to use Gemini instead of Claude.

---

## Change 1: Rename "Prepare Claude Prompt" Node

1. Click on the node named **"Prepare Claude Prompt"**
2. At the top, change the name to: **"Prepare Gemini Prompt"**
3. Replace the entire JavaScript code with:

```javascript
// Prepare Gemini API request for story generation
const answers = $json.answers;

const systemInstruction = `You are a creative children's story writer. Generate a warm, age-appropriate bedtime story (6-8 sentences) that is gentle, positive, and suitable for children ages 3-10.

Ensure the story:
- Has a clear beginning, middle, and end
- Uses simple, engaging language
- Includes a positive message or lesson
- Is calming and suitable for bedtime
- Contains no scary, violent, or inappropriate content
- Flows naturally and engagingly
- Ends on a peaceful, comforting note`;

const userPrompt = `Create a bedtime story with these elements:

- Main character: ${answers.character}
- Setting: ${answers.location}
- Theme: ${answers.topic}
- Challenge: ${answers.problem}
- Ending: ${answers.ending}

Write a gentle, engaging bedtime story (6-8 sentences) that brings these elements together in a cohesive, magical tale.`;

return {
  json: {
    chat_id: $json.chat_id,
    user_id: $json.user_id,
    username: $json.username,
    systemInstruction,
    userPrompt,
    answers,
    model: 'gemini-1.5-flash'
  }
};
```

4. Click **Save**

---

## Change 2: Update "Call Claude API" Node

1. Click on the node named **"Call Claude API"**
2. Rename it to: **"Call Gemini API"**
3. Update the settings:

### Basic Settings:
- **Method**: POST
- **URL**: `https://generativelanguage.googleapis.com/v1beta/models/{{ $json.model }}:generateContent`

### Authentication:
- **Authentication**: Generic Credential Type
- **Generic Auth Type**: Query Auth
- **Credential for Query Auth**: Select "Gemini API Key" (that you created)

### Body:
- **Send Body**: ON
- **Body Content Type**: JSON
- **Specify Body**: Using JSON

**JSON Body:**
```json
{
  "contents": [{
    "parts": [{
      "text": {{ JSON.stringify($json.userPrompt) }}
    }]
  }],
  "systemInstruction": {
    "parts": [{
      "text": {{ JSON.stringify($json.systemInstruction) }}
    }]
  },
  "generationConfig": {
    "temperature": 0.9,
    "topK": 40,
    "topP": 0.95,
    "maxOutputTokens": 1024
  }
}
```

4. Click **Save**

---

## Change 3: Update "Extract Story Text" Node

1. Click on **"Extract Story Text"** node
2. Replace the entire JavaScript code with:

```javascript
// Extract story from Gemini response
const geminiResponse = $input.first().json;
const promptData = $('Prepare Gemini Prompt').first().json;

let story = '';
let tokensUsed = 0;
let inputTokens = 0;
let outputTokens = 0;

// Extract story text from Gemini response
if (geminiResponse.candidates && geminiResponse.candidates[0]) {
  const candidate = geminiResponse.candidates[0];
  if (candidate.content && candidate.content.parts && candidate.content.parts[0]) {
    story = candidate.content.parts[0].text;
  }
}

// Extract token usage
if (geminiResponse.usageMetadata) {
  inputTokens = geminiResponse.usageMetadata.promptTokenCount || 0;
  outputTokens = geminiResponse.usageMetadata.candidatesTokenCount || 0;
  tokensUsed = inputTokens + outputTokens;
}

// Calculate approximate cost (Gemini 1.5 Flash pricing)
// Input: $0.075 per 1M tokens = $0.000000075 per token
// Output: $0.30 per 1M tokens = $0.0000003 per token
const costUSD = (inputTokens * 0.000000075) + (outputTokens * 0.0000003);

return {
  json: {
    chat_id: promptData.chat_id,
    user_id: promptData.user_id,
    story,
    answers: promptData.answers,
    tokensUsed,
    inputTokens,
    outputTokens,
    costUSD: costUSD.toFixed(6),
    timestamp: new Date().toISOString()
  }
};
```

3. Click **Save**

---

## Change 4: Update Workflow Name

1. At the top of the workflow, click on the name
2. Change to: **"Telegram Story Bot - Main (Gemini)"**
3. Click **Save**

---

## Verification Checklist

After making all changes:

- [ ] "Prepare Gemini Prompt" node has new code
- [ ] "Call Gemini API" node URL is correct
- [ ] "Call Gemini API" node uses Query Auth with Gemini API Key credential
- [ ] "Extract Story Text" node has new Gemini parsing code
- [ ] Workflow is saved
- [ ] Workflow is Active (toggle at top right)

---

## Test Gemini API

Before testing with Telegram, test the Gemini node:

1. Click on **"Call Gemini API"** node
2. Click **"Execute node"** (play button icon)
3. Should see Gemini's response in the output

If you see an error:
- Check your API key is correct
- Verify the URL is correct
- Check you haven't exceeded free tier limit (1500/day)

---

## Quick Test

```bash
# Test Gemini API directly
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Say hello"}]}]}'
```

---

**That's it!** Your workflow now uses Gemini instead of Claude. 🎉

Continue with the [GEMINI_N8N_DEPLOYMENT.md](GEMINI_N8N_DEPLOYMENT.md) guide for full setup.

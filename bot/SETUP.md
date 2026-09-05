# 🐝 SchoolBuzz WhatsApp Bot — Setup Guide

## Overview

SchoolBuzz is a WhatsApp bot that coordinates school drop-off and pickup. Family members send simple commands to the bot, and it replies with formatted updates.

```
Dad: dropoff
Bot: 🏫 School Update
     ✅ Drop-off confirmed
     👤 By: Dad
     🏫 School: Maple Elementary
     📅 Sunday, September 6, 2026
     🕐 7:46 AM
```

---

## Step 1: Create Meta Developer Account

1. Go to **https://developers.facebook.com/**
2. Log in with your Facebook account
3. Click **"Create App"**
4. Select **"Business"** → Click **"Next"**
5. App name: `SchoolBuzz`
6. Contact email: your email
7. Click **"Create App"**

---

## Step 2: Set Up WhatsApp Cloud API

1. In your app dashboard → Click **"Add Products"**
2. Find **"WhatsApp"** → Click **"Set Up"**
3. Select or create a **Meta Business Account**
4. You'll get a temporary test phone number

### Get Your Credentials

Go to **WhatsApp → API Setup** and copy:

| Credential | Where to find |
|------------|---------------|
| **Phone Number ID** | API Setup → "From" phone number ID |
| **Business Account ID** | API Setup → WhatsApp Business Account ID |
| **Temporary Access Token** | API Setup → Temporary access token |

> ⚠️ The temporary token expires in 24 hours. For production, create a **permanent token** (see Step 5).

---

## Step 3: Deploy the Bot

### Option A: Railway (Recommended — Free)

1. Go to **https://railway.app/**
2. Sign in with GitHub
3. Click **"New Project"** → **"Deploy from GitHub Repo"**
4. Select your `SchoolBuzz` repository
5. Set **Root Directory** to `bot`
6. Add environment variables:

```
WHATSAPP_API_TOKEN=your_token_here
WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id
WHATSAPP_BUSINESS_ACCOUNT_ID=your_business_account_id
WEBHOOK_VERIFY_TOKEN=schoolbuzz_verify_2026
PORT=3000
```

7. Deploy — Railway gives you a URL like `https://schoolbuzz-bot.up.railway.app`

### Option B: Render (Free)

1. Go to **https://render.com/**
2. **New** → **Web Service**
3. Connect GitHub repo
4. Root directory: `bot`
5. Build command: `npm install`
6. Start command: `node src/server.js`
7. Add same environment variables
8. Deploy — Render gives you a URL like `https://schoolbuzz-bot.onrender.com`

### Option C: Local (for testing)

```bash
cd bot
cp .env.example .env
# Edit .env with your credentials
npm install
npm run dev
```

Use **ngrok** to expose locally:
```bash
ngrok http 3000
# Copy the https URL (e.g., https://abc123.ngrok.io)
```

---

## Step 4: Configure Webhook

1. Go back to **https://developers.facebook.com/**
2. Your app → **WhatsApp → Configuration**
3. Click **"Edit"** next to Webhook
4. **Callback URL**: `https://your-deployed-url.com/webhook`
5. **Verify token**: `schoolbuzz_verify_2026`
6. Click **"Verify and save"**
7. Subscribe to **messages** field

### Test the Webhook

Send a message to your WhatsApp test number. You should see:
- Console log: `📩 [YourName] your message`
- Bot reply in WhatsApp

---

## Step 5: Create Permanent Access Token

The temporary token expires. For production:

1. Go to **Business Settings** → **System Users**
2. Click **"Add"**
3. Name: `SchoolBuzz Bot`
4. Role: **Admin**
5. Click **"Create System User"**
6. Click **"Generate New Token"**
7. Select your app
8. Check permissions: `whatsapp_business_management`, `whatsapp_business_messaging`
9. Click **"Generate Token"**
10. Copy this token — it doesn't expire

Update your environment variable with this permanent token.

---

## Step 6: Add to Family WhatsApp Group

### Option A: Direct Messages (Recommended for MVP)
Each family member messages the bot directly. The bot only sees messages sent to it.

### Option B: Group Chat
1. Add the bot's phone number to your family WhatsApp group
2. In group settings, the bot can respond to messages
3. Note: Bot needs to be mentioned or configured to respond to all messages

> **Important:** WhatsApp Cloud API bots respond to individual messages by default. Group support requires additional configuration.

---

## Bot Commands

| Command | Shortcut | What it does |
|---------|----------|-------------|
| `dropoff` | `do` | Log a morning drop-off |
| `pickup` | `pu` | Log an afternoon pickup |
| `message your text` | `msg your text` | Send a custom message |
| `history` | `hist` | View last 10 events |
| `status` | — | Show bot configuration |
| `school Maple Elementary` | — | Set school name |
| `cooldown 30` | — | Set cooldown (5-120 min) |
| `help` | `commands` | Show all commands |
| `ping` | — | Check if bot is alive |

---

## Example Conversation

```
Dad:    dropoff
Bot:    👍 (reaction)
Bot:    🏫 School Update
        ✅ Drop-off confirmed
        👤 By: Dad
        🏫 School: Maple Elementary
        📅 Monday, September 7, 2026
        🕐 7:46 AM
        _Sent from SchoolBuzz_

Mom:    pickup
Bot:    👍 (reaction)
Bot:    🏫 School Update
        🔁 Pickup confirmed
        👤 By: Mom
        🏫 School: Maple Elementary
        📅 Monday, September 7, 2026
        🕐 3:18 PM
        _Sent from SchoolBuzz_

Dad:    message Running 10 minutes late
Bot:    💬 (reaction)
Bot:    🏫 School Message
        👤 From: Dad
        🏫 School: Maple Elementary
        💬 Running 10 minutes late
        🕐 3:14 PM
        _Sent from SchoolBuzz_

Dad:    history
Bot:    📋 Recent Events (last 10)
        ✅ DROPOFF — Dad
           Sep 7 at 7:46 AM
        🔁 PICKUP — Mom
           Sep 7 at 3:18 PM
        💬 MESSAGE — Dad
           Sep 7 at 3:14 PM
           💬 Running 10 minutes late
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Bot doesn't respond | Check webhook URL is correct and accessible |
| "Invalid signature" error | Verify WHATSAPP_APP_SECRET matches Meta dashboard |
| Token expired | Create permanent token (Step 5) |
| Messages not received | Check webhook subscription includes "messages" field |
| Database error | Ensure `data/` directory is writable |

---

## Free Tier Limits

| Limit | Value |
|-------|-------|
| Free conversations | 1,000/month |
| Message types | Text, reactions |
| Webhook calls | Unlimited |
| Hosting (Railway) | Free tier available |
| Database | SQLite (local file) |

**Estimated monthly cost: $0**

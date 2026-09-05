# 🐝 SchoolBuzz WhatsApp Bot

A WhatsApp bot for coordinating school drop-off and pickup. Uses Meta's official Cloud API (free tier).

## Quick Start

```bash
cd bot
cp .env.example .env
# Edit .env with your WhatsApp API credentials
npm install
npm start
```

## How It Works

```
Family member sends "dropoff" in WhatsApp
          │
          ▼
WhatsApp Cloud API sends webhook to your server
          │
          ▼
Bot processes command, saves to database
          │
          ▼
Bot replies with formatted update
```

## Commands

| Command | What |
|---------|------|
| `dropoff` | Log morning drop-off |
| `pickup` | Log afternoon pickup |
| `message text` | Send custom message |
| `history` | View recent events |
| `status` | Show configuration |
| `help` | Show all commands |

## Deploy

- **Railway**: `railway.toml` included
- **Render**: `Procfile` included
- **Docker**: `Dockerfile` included

See [SETUP.md](SETUP.md) for full setup guide.

## Tech Stack

- Node.js + Express
- SQLite (better-sqlite3)
- Meta WhatsApp Cloud API

## Cost

$0/month (free tier: 1,000 conversations/month)

require('dotenv').config();
const express = require('express');
const crypto = require('crypto');
const { handleMessage } = require('./handler');
const { initDatabase } = require('./database');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const VERIFY_TOKEN = process.env.WEBHOOK_VERIFY_TOKEN || 'schoolbuzz_verify_2026';

// Initialize database on startup
initDatabase();

// ─── Health Check ─────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    status: 'ok',
    app: 'SchoolBuzz WhatsApp Bot',
    version: '1.0.0',
    uptime: process.uptime(),
  });
});

// ─── Webhook Verification (GET) ───────────────────────────
// Meta sends this when you configure the webhook URL
app.get('/webhook', (req, res) => {
  const mode = req.query['hub.mode'];
  const token = req.query['hub.verify_token'];
  const challenge = req.query['hub.challenge'];

  if (mode === 'subscribe' && token === VERIFY_TOKEN) {
    console.log('✅ Webhook verified');
    return res.status(200).send(challenge);
  }

  console.log('❌ Webhook verification failed');
  return res.sendStatus(403);
});

// ─── Webhook Messages (POST) ──────────────────────────────
// Meta sends incoming messages here
app.post('/webhook', (req, res) => {
  const body = req.body;

  // Verify request signature (optional but recommended)
  if (process.env.WHATSAPP_APP_SECRET) {
    const signature = req.headers['x-hub-signature-256'];
    if (signature) {
      const expectedSig =
        'sha256=' +
        crypto
          .createHmac('sha256', process.env.WHATSAPP_APP_SECRET)
          .update(JSON.stringify(body))
          .digest('hex');

      if (signature !== expectedSig) {
        console.log('❌ Invalid signature');
        return res.sendStatus(403);
      }
    }
  }

  // Check if this is a WhatsApp message
  if (body.object === 'whatsapp_business_account') {
    const entries = body.entry || [];
    for (const entry of entries) {
      const changes = entry.changes || [];
      for (const change of changes) {
        if (change.field === 'messages') {
          const value = change.value;
          const messages = value.messages || [];
          const contacts = value.contacts || [];

          for (const message of messages) {
            // Process each message
            handleMessage(message, contacts, value.metadata)
              .catch((err) => console.error('Error handling message:', err));
          }
        }
      }
    }
  }

  // Always respond 200 quickly
  res.sendStatus(200);
});

// ─── Start Server ─────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`
🐝 SchoolBuzz Bot running on port ${PORT}
📡 Webhook URL: https://your-domain.com/webhook
🔗 Health check: http://localhost:${PORT}/
  `);
});

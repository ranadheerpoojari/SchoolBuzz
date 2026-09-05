const axios = require('axios');

const API_URL = 'https://graph.facebook.com/v21.0';
const TOKEN = process.env.WHATSAPP_API_TOKEN;
const PHONE_NUMBER_ID = process.env.WHATSAPP_PHONE_NUMBER_ID;

/**
 * Send a text message via WhatsApp Cloud API.
 * @param {string} to - Recipient phone number (with country code)
 * @param {string} text - Message text (supports *bold*, _italic_, ~strikethrough~)
 * @param {string} [replyTo] - Message ID to reply to (optional)
 */
async function sendText(to, text, replyTo) {
  try {
    const payload = {
      messaging_product: 'whatsapp',
      recipient_type: 'individual',
      to,
      type: 'text',
      text: {
        preview_url: false,
        body: text,
      },
    };

    // Add reply context if replying to a specific message
    if (replyTo) {
      payload.context = { message_id: replyTo };
    }

    const response = await axios.post(
      `${API_URL}/${PHONE_NUMBER_ID}/messages`,
      payload,
      {
        headers: {
          Authorization: `Bearer ${TOKEN}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log(`📤 Sent to ${to}: ${text.substring(0, 50)}...`);
    return response.data;
  } catch (error) {
    console.error('❌ Failed to send message:', error.response?.data || error.message);
    throw error;
  }
}

/**
 * Send an emoji reaction to a message.
 * @param {string} to - Recipient phone number
 * @param {string} messageId - Message ID to react to
 * @param {string} emoji - Emoji to react with
 */
async function sendReaction(to, messageId, emoji) {
  try {
    const response = await axios.post(
      `${API_URL}/${PHONE_NUMBER_ID}/messages`,
      {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to,
        type: 'reaction',
        reaction: {
          message_id: messageId,
          emoji,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${TOKEN}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log(`👍 Reacted with ${emoji} to ${messageId}`);
    return response.data;
  } catch (error) {
    // Reactions are non-critical, just log
    console.error('⚠️ Failed to send reaction:', error.response?.data || error.message);
  }
}

/**
 * Mark a message as read.
 * @param {string} messageId - Message ID to mark as read
 */
async function markAsRead(messageId) {
  try {
    await axios.post(
      `${API_URL}/${PHONE_NUMBER_ID}/messages`,
      {
        messaging_product: 'whatsapp',
        status: 'read',
        message_id: messageId,
      },
      {
        headers: {
          Authorization: `Bearer ${TOKEN}`,
          'Content-Type': 'application/json',
        },
      }
    );
  } catch (error) {
    console.error('⚠️ Failed to mark as read:', error.message);
  }
}

module.exports = { sendText, sendReaction, markAsRead };

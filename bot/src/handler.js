const { sendText, sendReaction } = require('./whatsapp');
const { saveEvent, getRecentEvents, getLastEvent, getSettings, updateSettings } = require('./database');

// Cooldown tracking (in-memory, resets on restart)
const lastEventTime = {};

async function handleMessage(message, contacts, metadata) {
  // Only handle text messages for now
  if (message.type !== 'text') {
    await sendText(
      message.from,
      '🐝 SchoolBuzz only supports text commands.\n\nSend *help* to see available commands.',
      message.id
    );
    return;
  }

  const text = message.text.body.trim().toLowerCase();
  const senderPhone = message.from;
  const senderName = contacts[0]?.profile?.name || 'Unknown';
  const timestamp = new Date(parseInt(message.timestamp) * 1000);

  console.log(`📩 [${senderName}] ${text}`);

  // ─── Command Router ───────────────────────────────────
  const commands = {
    dropoff: () => handleAction('DROPOFF', senderPhone, senderName, timestamp, message),
    do: () => handleAction('DROPOFF', senderPhone, senderName, timestamp, message),
    pickup: () => handleAction('PICKUP', senderPhone, senderName, timestamp, message),
    pu: () => handleAction('PICKUP', senderPhone, senderName, timestamp, message),
    message: () => handleCustomMessage(senderPhone, senderName, timestamp, message),
    msg: () => handleCustomMessage(senderPhone, senderName, timestamp, message),
    history: () => handleHistory(senderPhone, message),
    hist: () => handleHistory(senderPhone, message),
    status: () => handleStatus(senderPhone, message),
    help: () => handleHelp(senderPhone, message),
    commands: () => handleHelp(senderPhone, message),
    setup: () => handleSetup(senderPhone, senderName, message),
    cooldown: () => handleCooldown(senderPhone, message),
    school: () => handleSchoolName(senderPhone, message),
    ping: () => sendText(senderPhone, '🏓 Pong! SchoolBuzz is alive.', message.id),
  };

  // Check if it's a known command
  const baseCommand = text.split(' ')[0];
  if (commands[baseCommand]) {
    await commands[baseCommand]();
    return;
  }

  // Check if it starts with "message " or "msg "
  if (text.startsWith('message ') || text.startsWith('msg ')) {
    const customText = text.replace(/^(message|msg)\s+/, '');
    await handleCustomMessage(senderPhone, senderName, timestamp, message, customText);
    return;
  }

  // Check if it looks like a dropoff/pickup shorthand
  if (text === 'drop off' || text === 'drop-off') {
    await handleAction('DROPOFF', senderPhone, senderName, timestamp, message);
    return;
  }
  if (text === 'pick up' || text === 'pick-up') {
    await handleAction('PICKUP', senderPhone, senderName, timestamp, message);
    return;
  }

  // Unknown command
  await sendText(
    senderPhone,
    `🤔 I don't understand *"${text}"*.\n\nSend *help* to see available commands.`,
    message.id
  );
}

// ─── Action Handler (Drop-off / Pickup) ──────────────────
async function handleAction(actionType, senderPhone, senderName, timestamp, message) {
  const settings = getSettings();

  // Cooldown check
  const cooldownKey = `${senderPhone}_${actionType}`;
  const lastTime = lastEventTime[cooldownKey];
  if (lastTime) {
    const elapsed = (Date.now() - lastTime) / 1000 / 60;
    if (elapsed < settings.cooldownMinutes) {
      const remaining = Math.ceil(settings.cooldownMinutes - elapsed);
      await sendText(
        senderPhone,
        `⏳ Cooldown active. Try again in *${remaining} minute${remaining > 1 ? 's' : ''}*.`,
        message.id
      );
      return;
    }
  }

  // Save event
  const event = saveEvent({
    actionType,
    caregiverName: senderName,
    caregiverPhone: senderPhone,
    schoolName: settings.schoolName,
    timestamp,
  });

  // Update cooldown
  lastEventTime[cooldownKey] = Date.now();

  // Build response
  const emoji = actionType === 'DROPOFF' ? '✅' : '🔁';
  const actionLabel = actionType === 'DROPOFF' ? 'Drop-off confirmed' : 'Pickup confirmed';
  const time = formatTime(timestamp);
  const date = formatDate(timestamp);

  const response = `🏫 *School Update*

${emoji} ${actionLabel}
👤 By: ${senderName}
🏫 School: ${settings.schoolName}
📅 ${date}
🕐 ${time}

_Sent from SchoolBuzz_`;

  await sendReaction(senderPhone, message.id, '👍');
  await sendText(senderPhone, response, message.id);
}

// ─── Custom Message Handler ─────────────────────────────
async function handleCustomMessage(senderPhone, senderName, timestamp, message, customText) {
  if (!customText) {
    await sendText(
      senderPhone,
      '💬 Send a message with:\n\n*message* your text here\n\nExample:\nmessage Running 10 minutes late',
      message.id
    );
    return;
  }

  const settings = getSettings();
  const time = formatTime(timestamp);

  saveEvent({
    actionType: 'MESSAGE',
    caregiverName: senderName,
    caregiverPhone: senderPhone,
    schoolName: settings.schoolName,
    timestamp,
    customMessage: customText,
  });

  const response = `🏫 *School Message*

👤 From: ${senderName}
🏫 School: ${settings.schoolName}

💬 ${customText}

🕐 ${time}

_Sent from SchoolBuzz_`;

  await sendReaction(senderPhone, message.id, '💬');
  await sendText(senderPhone, response, message.id);
}

// ─── History Handler ─────────────────────────────────────
async function handleHistory(senderPhone, message) {
  const events = getRecentEvents(10);
  const settings = getSettings();

  if (events.length === 0) {
    await sendText(senderPhone, '📋 No events yet.', message.id);
    return;
  }

  let response = `📋 *Recent Events (last 10)*\n\n`;

  for (const event of events) {
    const emoji = event.actionType === 'DROPOFF' ? '✅' : event.actionType === 'PICKUP' ? '🔁' : '💬';
    const time = formatTime(new Date(event.timestamp));
    const date = formatDateShort(new Date(event.timestamp));
    response += `${emoji} *${event.actionType}* — ${event.caregiverName}\n   ${date} at ${time}`;
    if (event.customMessage) response += `\n   💬 ${event.customMessage}`;
    response += '\n\n';
  }

  response += `_Sent from SchoolBuzz_`;
  await sendText(senderPhone, response, message.id);
}

// ─── Status Handler ──────────────────────────────────────
async function handleStatus(senderPhone, message) {
  const settings = getSettings();
  const lastEvent = getLastEvent();

  let response = `📊 *SchoolBuzz Status*

🏫 School: ${settings.schoolName}
⏳ Cooldown: ${settings.cooldownMinutes} min
👥 Caregivers: ${settings.caregiverNames}`;

  if (lastEvent) {
    const time = formatTime(new Date(lastEvent.timestamp));
    const date = formatDateShort(new Date(lastEvent.timestamp));
    response += `\n\n📌 Last event: *${lastEvent.actionType}* by ${lastEvent.caregiverName}\n   ${date} at ${time}`;
  } else {
    response += '\n\n📌 No events yet';
  }

  await sendText(senderPhone, response, message.id);
}

// ─── Help Handler ────────────────────────────────────────
async function handleHelp(senderPhone, message) {
  const help = `🐝 *SchoolBuzz Commands*

*dropoff* (or *do*)
Log a morning drop-off

*pickup* (or *pu*)
Log an afternoon pickup

*message* your text
Send a custom message
Example: message Running late

*history* (or *hist*)
View recent events

*status*
Show bot configuration

*setup* school name
Set the school name

*cooldown* minutes
Set cooldown duration (5-120)

*school*
View current school name

*ping*
Check if bot is alive

*help*
Show this message

💡 _Just type the command in the chat!_`;

  await sendText(senderPhone, help, message.id);
}

// ─── Setup Handler ───────────────────────────────────────
async function handleSetup(senderPhone, senderName, message) {
  await sendText(
    senderPhone,
    `⚙️ *Setup Commands*\n\n*school* Maple Elementary\nSet school name\n\n*cooldown* 30\nSet cooldown in minutes (5-120)\n\nExample:\nschool Maple Elementary\ncooldown 15`,
    message.id
  );
}

// ─── Cooldown Handler ────────────────────────────────────
async function handleCooldown(senderPhone, message) {
  const text = message.text.body.trim();
  const parts = text.split(' ');

  if (parts.length < 2) {
    const settings = getSettings();
    await sendText(
      senderPhone,
      `⏳ Current cooldown: *${settings.cooldownMinutes} minutes*\n\nChange with: *cooldown* 30\n(Range: 5-120 minutes)`,
      message.id
    );
    return;
  }

  const minutes = parseInt(parts[1]);
  if (isNaN(minutes) || minutes < 5 || minutes > 120) {
    await sendText(senderPhone, '❌ Cooldown must be between 5 and 120 minutes.', message.id);
    return;
  }

  updateSettings({ cooldownMinutes: minutes });
  await sendText(senderPhone, `✅ Cooldown set to *${minutes} minutes*.`, message.id);
}

// ─── School Name Handler ─────────────────────────────────
async function handleSchoolName(senderPhone, message) {
  const text = message.text.body.trim();
  const parts = text.split(' ');

  if (parts.length < 2) {
    const settings = getSettings();
    await sendText(
      senderPhone,
      `🏫 Current school: *${settings.schoolName}*\n\nChange with: *school* Maple Elementary`,
      message.id
    );
    return;
  }

  const name = parts.slice(1).join(' ');
  updateSettings({ schoolName: name });
  await sendText(senderPhone, `✅ School name set to *${name}*.`, message.id);
}

// ─── Helpers ─────────────────────────────────────────────
function formatTime(date) {
  return date.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
    hour12: true,
  });
}

function formatDate(date) {
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

function formatDateShort(date) {
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  });
}

module.exports = { handleMessage };

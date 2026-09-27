#!/usr/bin/env bash
# @Choose_BOT installer — safe to run again; it updates the bot and keeps your token.
set -e
DIR="$HOME/choose-bot"
echo "== Installing @Choose_BOT into $DIR =="
if ! command -v node >/dev/null || [ "$(node -v | cut -c2- | cut -d. -f1)" -lt 18 ]; then
  echo "== Installing Node.js 20 =="
  apt-get update -y && apt-get install -y curl ca-certificates
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
fi
command -v pm2 >/dev/null || npm install -g pm2
mkdir -p "$DIR" && cd "$DIR"
cat > package.json <<'CYD_EOF'
{
  "name": "choose-bot",
  "version": "2.0.0",
  "private": true,
  "main": "bot.js",
  "type": "commonjs",
  "dependencies": {
    "discord.js": "^14.16.3",
    "node-cron": "^3.0.3",
    "dotenv": "^16.4.5"
  }
}
CYD_EOF
cat > codes.json <<'CYD_EOF'
[{"day":1,"num":"1845421","sec":"845132489","module":"Foundation: from this single, anchored point, you can construct any reality."},{"day":2,"num":"1853125","sec":"849995120","module":"Precision Focus / Reality Molding"},{"day":3,"num":"5142587","sec":"421954321","module":"Reflected Reality / World Selection"},{"day":4,"num":"5194726","sec":"715043769","module":"Data Sphere / Unified Worldconstruct"},{"day":5,"num":"1084321","sec":"194321054","module":"Network Resonance / Co-Creator Sync"},{"day":6,"num":"1954837","sec":"194321099","module":"Remote Rendering / Null Zone Protocol"},{"day":7,"num":"1485321","sec":"991843288","module":"Cloud Compute / Universal Alignment"},{"day":8,"num":"1543218","sec":"984301267","module":"Causal Chain Rewrite / Eternity Creation"},{"day":9,"num":"1843210","sec":"918921452","module":"Range Compression / Unified Impulse"},{"day":10,"num":"1854312","sec":"894153210","module":"Batch Processing / The Tenfold Action"},{"day":11,"num":"1852348","sec":"561432001","module":"Interspecies Bridge / The Embodied World"},{"day":12,"num":"1854321","sec":"485321489","module":"Restore Point / Holistic Integrity"},{"day":13,"num":"1538448","sec":"154321915","module":"Structural Analysis / Creator's Blueprint"},{"day":14,"num":"5831421","sec":"999888776","module":"Causality Analysis / The Light of Source"},{"day":15,"num":"7788001","sec":"532145891","module":"Precision Calibration / The Love Protocol"},{"day":16,"num":"1843212","sec":"123567091","module":"Sensory Immersion / The Harmony of Change"},{"day":17,"num":"1045421","sec":"891000111","module":"Macro Cosmic Alignment / The Path of Eternity"},{"day":18,"num":"1854212","sec":"185321945","module":"Objective Meaning / Transcending Resistance"},{"day":19,"num":"1254312","sec":"158431985","module":"Entropy Reversal / The Eternal Instant"},{"day":20,"num":"1538416","sec":"891543219","module":"Distant Awakening / The Steward"},{"day":21,"num":"8153517","sec":"589148542","module":"Reverse Temporal Stream / The Architect's Hand"},{"day":22,"num":"8153485","sec":"198516789","module":"Perpetual Creation / The Architecture of Love"},{"day":23,"num":"8154574","sec":"581974321","module":"Divine Actualization / The Unified Field"},{"day":24,"num":"5184325","sec":"189543210","module":"Form Transmutation / The Love Imperative"},{"day":25,"num":"1890000","sec":"012459999","module":"Combinatorial Logic / The Eternal Observer"},{"day":26,"num":"1584321","sec":"485617891","module":"Holonic Perception / The Eternity Engine"},{"day":27,"num":"1854342","sec":"185431201","module":"Dynamic Evolution / The Ecology of Help"},{"day":28,"num":"1854512","sec":"195814210","module":"Recursive Evolution / The Creator's Gaze"},{"day":29,"num":"1852142","sec":"512942180","module":"Synthesis Sphere / The Eternal Platform"},{"day":30,"num":"1852143","sec":"185219351","module":"Harmonic Foundation / The Unity Cycle"},{"day":31,"num":"1532106","sec":"185214321","module":"Volumetric Unity / The Eternal Affirmation"}]
CYD_EOF
cat > bot.js <<'CYD_EOF'
require('dotenv').config();
const { Client, GatewayIntentBits, EmbedBuilder, SlashCommandBuilder, ChannelType } = require('discord.js');
const cron = require('node-cron');
const CODES = require('./codes.json');

const TOKEN = process.env.DISCORD_TOKEN;
const TZ = process.env.TIMEZONE || 'America/Los_Angeles';
const [HH, MM] = (process.env.POST_TIME || '07:00').split(':').map(Number);
const CODE_CH = (process.env.CODE_CHANNEL || 'daily-code').replace('#', '');
const WELCOME_CH = (process.env.WELCOME_CHANNEL || 'welcome').replace('#', '');
const SHOP = process.env.SHOP_URL || 'https://chooseyourdestiny.us/pages/hack-the-matrix';
const GOLD = 0xf0c93e;

if (!TOKEN) { console.error('DISCORD_TOKEN missing in .env'); process.exit(1); }

const todayDay = () => +new Intl.DateTimeFormat('en-US', { timeZone: TZ, day: 'numeric' }).format(new Date());
const spaced = n => n.split('').join(' ');
const codeEmbed = (day, title) => {
  const c = CODES.find(x => x.day === day);
  return new EmbedBuilder().setColor(GOLD)
    .setTitle(title || ('Hack The Matrix · Day ' + day))
    .setDescription('**' + c.module + '**')
    .addFields(
      { name: 'Primary sequence', value: '\u0060\u0060\u0060' + spaced(c.num) + '\u0060\u0060\u0060' },
      { name: 'Secondary sequence', value: '\u0060\u0060\u0060' + spaced(c.sec) + '\u0060\u0060\u0060' },
      { name: 'Practice', value: 'Write the numbers by hand once. Settle into your soul\'s seat. Picture the sequence glowing while you hold your intention for three minutes.' })
    .setFooter({ text: 'Choose Your Destiny · Day ' + day + ' of the month' });
};
const courseEmbed = () => new EmbedBuilder().setColor(GOLD).setTitle('Hack The Matrix course')
  .setDescription([
    '**$33** for the full 30/31-day course (length follows the month).',
    'Program days follow the calendar: Day 1 is the 1st, Day 15 is the 15th.',
    'Joining mid-month? Your purchase covers Day 1–31 of the **following** month. Until then you can view past content and join the current class right away.',
    '', SHOP].join('\n'));

const commands = [
  new SlashCommandBuilder().setName('code').setDescription("Today's Hack The Matrix code"),
  new SlashCommandBuilder().setName('day').setDescription('Code for any day').addIntegerOption(o => o.setName('number').setDescription('Day 1–31').setMinValue(1).setMaxValue(31).setRequired(true)),
  new SlashCommandBuilder().setName('course').setDescription('Price and access rules'),
].map(c => c.toJSON());

const findChannel = (guild, name) => guild.channels.cache.find(ch => ch.type === ChannelType.GuildText && ch.name === name);

function start(withMembers) {
  const intents = [GatewayIntentBits.Guilds];
  if (withMembers) intents.push(GatewayIntentBits.GuildMembers);
  const client = new Client({ intents });

  client.once('ready', async () => {
    console.log('Online as ' + client.user.tag + ' in ' + client.guilds.cache.size + ' server(s). Time zone ' + TZ + ', posting at ' + (process.env.POST_TIME || '07:00'));
    for (const g of client.guilds.cache.values()) {
      try { await g.commands.set(commands); } catch (e) { console.error('Could not register commands in ' + g.name + ': ' + e.message); }
      if (!findChannel(g, CODE_CH)) console.warn('No #' + CODE_CH + ' channel in ' + g.name + ' — create it or change CODE_CHANNEL in .env');
    }
    cron.schedule(MM + ' ' + HH + ' * * *', async () => {
      const day = todayDay();
      for (const g of client.guilds.cache.values()) {
        const ch = findChannel(g, CODE_CH);
        if (ch) await ch.send({ embeds: [codeEmbed(day)] }).catch(e => console.error('Post failed in ' + g.name + ': ' + e.message));
      }
      console.log('Posted Day ' + day);
    }, { timezone: TZ });
  });

  client.on('guildCreate', g => g.commands.set(commands).catch(() => {}));

  client.on('interactionCreate', async i => {
    if (!i.isChatInputCommand()) return;
    if (i.commandName === 'code') return i.reply({ embeds: [codeEmbed(todayDay(), "Today's code · Day " + todayDay())] });
    if (i.commandName === 'day') return i.reply({ embeds: [codeEmbed(i.options.getInteger('number'))] });
    if (i.commandName === 'course') return i.reply({ embeds: [courseEmbed()] });
  });

  if (withMembers) client.on('guildMemberAdd', async m => {
    const ch = findChannel(m.guild, WELCOME_CH);
    if (!ch) return;
    ch.send({ content: 'Welcome <@' + m.id + '>!', embeds: [new EmbedBuilder().setColor(GOLD).setTitle('Welcome to Choose Your Destiny')
      .setDescription("Type **/code** for today's Hack The Matrix code, **/day** for any day, and **/course** for the class details.\nThe daily code posts in #" + CODE_CH + ' every morning.')] }).catch(() => {});
  });

  client.login(TOKEN).catch(e => {
    if (withMembers && /disallowed intents/i.test(e.message)) {
      console.warn('Server Members Intent is off in the Developer Portal — running without welcome messages.');
      client.destroy(); return start(false);
    }
    console.error('Login failed: ' + e.message + (/token/i.test(e.message) ? ' — reset the token in the Developer Portal and run: nano ~/choose-bot/.env' : ''));
    process.exit(1);
  });
}
start(true);
CYD_EOF
if [ ! -f .env ] || ! grep -q "^DISCORD_TOKEN=." .env; then
  echo ""
  echo "Paste your bot token (Developer Portal > Bot > Reset Token). It stays hidden while you paste, then press Enter:"
  read -rs TOKEN < /dev/tty
  cat > .env <<CYD_EOF
DISCORD_TOKEN=$TOKEN
TIMEZONE=America/Los_Angeles
POST_TIME=07:00
CODE_CHANNEL=daily-code
WELCOME_CHANNEL=welcome
SHOP_URL=https://chooseyourdestiny.us/pages/hack-the-matrix
CYD_EOF
  chmod 600 .env
fi
npm install --omit=dev --no-audit --no-fund
pm2 delete choose-bot >/dev/null 2>&1 || true
pm2 start bot.js --name choose-bot
pm2 save
pm2 startup systemd -u "$USER" --hp "$HOME" >/dev/null 2>&1 || true
sleep 6
echo ""
echo "== Last log lines =="
pm2 logs choose-bot --lines 15 --nostream
echo ""
echo "Done. If you see 'Online as Choose_BOT', it's working. Type /code in Discord."

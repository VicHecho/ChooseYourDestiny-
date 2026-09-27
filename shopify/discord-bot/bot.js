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

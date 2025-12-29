# 🤖 QuantumAI Trading Bot

Automated trading bot for Bitunix - **Exclusively for Underground Trading members**.

## 📋 Requirements

- **Bitunix account affiliated with Underground Trading**
  - Register: https://www.bitunix.site/register?vipCode=g3gj7090
- VPS with Docker installed (Ubuntu 20.04+ recommended)
- Bitunix API keys with Futures permissions

## 🚀 Quick Installation

### 1. Clone this repository

```bash
git clone https://github.com/CryptoSauceYT/QuantumV1-public.git
cd QuantumV1-public
```

### 2. Configure the bot

Edit `config/application.yaml`:

```yaml
license:
  uid: "YOUR_BITUNIX_UID"  # ← Your Bitunix User ID

bot:
  profiles:
    main:
      your-bitunix-uid: "YOUR_BITUNIX_UID"  # ← Same UID
      api-key: "YOUR_API_KEY"               # ← Bitunix API key
      api-secret: "YOUR_API_SECRET"         # ← Bitunix API secret
```

**Where to find your UID:** Bitunix → Profile → Account Settings

### 3. Run the installer

```bash
chmod +x install.sh
./install.sh
```

### 4. Get your webhook URL

After installation, you'll see your webhook URL:
```
https://YOUR_SERVER_IP/wh/YOUR_TOKEN
```

Use this URL in TradingView alerts.

## ⚙️ Configuration

### Trading Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `leverage` | Leverage multiplier (1-125) | `5` |
| `amount` | Trade size: `"all"` or fixed USDT | `"all"` or `"100"` |
| `secu-tp` | Security Take Profit % | `2.0` |
| `secu-sl` | Security Stop Loss % | `1.5` |
| `entry-type` | Order type | `"limit"` or `"market"` |

### Multiple Profiles

You can create multiple profiles for different strategies:

```yaml
bot:
  profiles:
    conservative:
      leverage: 3
      amount: "50"
      secu-tp: 1.5
      secu-sl: 1.0
      
    aggressive:
      leverage: 10
      amount: "all"
      secu-tp: 3.0
      secu-sl: 2.0
```

## 📡 TradingView Webhook Format

```json
{
  "symbol": "{{ticker}}",
  "side": "{{strategy.order.action}}",
  "tp": {{strategy.order.tp}},
  "sl": {{strategy.order.sl}},
  "profile": "main"
}
```

## 🔧 Commands

```bash
# View logs
docker compose logs -f trading-bot

# Restart bot
docker compose restart trading-bot

# Stop bot
docker compose down

# Update to latest version
docker compose pull tradingbot
docker compose up -d
```

## ❓ Troubleshooting

### Bot won't start - "License denied"

Your Bitunix account must be affiliated with Underground Trading.
Register at: https://www.bitunix.site/register?vipCode=g3gj7090

### Bot won't start - "Invalid API keys"

1. Check your API key and secret in `config/application.yaml`
2. Ensure your API has "Futures Trade" permission
3. Check IP whitelist (add your VPS IP or use 0.0.0.0/0)

### Webhook not receiving signals

1. Check your webhook URL is correct
2. Verify TradingView alert is active
3. Check logs: `docker compose logs -f trading-bot`

## 📊 Compatibility

- ✅ Ubuntu 18.04, 20.04, 22.04, 24.04 LTS
- ✅ Debian 10, 11, 12
- ✅ Any Linux with Docker support

## 🔐 Security

- Your API keys are stored locally on your VPS
- SSL certificates are auto-generated
- Webhook can be protected with secret token

## 📞 Support

- Discord: [Underground Trading](https://discord.gg/underground)
- YouTube: [CryptoSauceYT](https://youtube.com/@CryptoSauceYT)

---

**⚠️ Disclaimer:** Trading cryptocurrencies involves significant risk. Use this bot at your own risk.

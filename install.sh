#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🤖 QUANTUMAI TRADING BOT - INSTALLATION
# ═══════════════════════════════════════════════════════════════════════════

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🤖 QUANTUMAI TRADING BOT - INSTALLATION                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# CHECK & INSTALL DOCKER
# ═══════════════════════════════════════════════════════════════════════════
echo -e "${YELLOW}📋 Checking Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🐳 Docker not found. Installing Docker...${NC}"
    curl -fsSL https://get.docker.com | sh
    
    # Start Docker service
    systemctl start docker
    systemctl enable docker
    
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
else
    echo -e "${GREEN}✅ Docker is already installed${NC}"
fi

# Verify Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}❌ Docker Compose not available${NC}"
    echo "   Please update Docker or install Docker Compose plugin"
    exit 1
fi

echo -e "${GREEN}✅ Docker and Docker Compose are ready${NC}"

# ═══════════════════════════════════════════════════════════════════════════
# CHECK CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${YELLOW}📋 Checking configuration...${NC}"

if [ ! -f "config/application.yaml" ]; then
    echo -e "${RED}❌ config/application.yaml not found${NC}"
    exit 1
fi

# Check if user has configured their UID
if grep -q "YOUR_BITUNIX_UID" config/application.yaml; then
    echo ""
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️  CONFIGURATION REQUIRED                                  ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  Please edit config/application.yaml and replace:           ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  1. YOUR_BITUNIX_UID  → Your Bitunix User ID                ║${NC}"
    echo -e "${RED}║  2. YOUR_API_KEY      → Your Bitunix API Key                ║${NC}"
    echo -e "${RED}║  3. YOUR_API_SECRET   → Your Bitunix API Secret             ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  Find your UID in Bitunix: Profile → Account Settings       ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ Configuration looks good${NC}"

# ═══════════════════════════════════════════════════════════════════════════
# CREATE DIRECTORIES
# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${YELLOW}📁 Creating directories...${NC}"
mkdir -p data ssl
echo -e "${GREEN}✅ Directories created${NC}"

# ═══════════════════════════════════════════════════════════════════════════
# PULL IMAGE
# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${YELLOW}📦 Pulling latest bot image...${NC}"
docker compose pull tradingbot

# ═══════════════════════════════════════════════════════════════════════════
# START SERVICES
# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${YELLOW}🚀 Starting services...${NC}"
docker compose up -d

# ═══════════════════════════════════════════════════════════════════════════
# WAIT FOR STARTUP
# ═══════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${YELLOW}⏳ Waiting for bot to start...${NC}"
sleep 10

# ═══════════════════════════════════════════════════════════════════════════
# CHECK STATUS
# ═══════════════════════════════════════════════════════════════════════════
echo ""
if docker compose ps | grep -q "trading-bot.*running"; then
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✅ BOT IS RUNNING!                                          ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════════════════════════════╣${NC}"
    
    # Get server IP
    SERVER_IP=$(curl -4 -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "YOUR_SERVER_IP")
    
    # Get webhook token from config
    WEBHOOK_TOKEN=$(grep "webhook-token:" config/application.yaml | head -1 | sed 's/.*: *"//' | sed 's/".*//' | tr -d ' ')
    
    if [ -z "$WEBHOOK_TOKEN" ] || [ "$WEBHOOK_TOKEN" = '""' ]; then
        echo -e "${GREEN}║                                                              ║${NC}"
        echo -e "${GREEN}║  📡 Webhook URL: https://${SERVER_IP}/api/v1/quantum_trade   ║${NC}"
    else
        echo -e "${GREEN}║                                                              ║${NC}"
        echo -e "${GREEN}║  📡 Webhook URL: https://${SERVER_IP}/wh/${WEBHOOK_TOKEN}    ║${NC}"
    fi
    
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  📋 Commands:                                                ║${NC}"
    echo -e "${GREEN}║     docker compose logs -f trading-bot   # View logs        ║${NC}"
    echo -e "${GREEN}║     docker compose restart trading-bot   # Restart          ║${NC}"
    echo -e "${GREEN}║     docker compose down                  # Stop             ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
else
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ❌ BOT FAILED TO START                                      ║${NC}"
    echo -e "${RED}╠══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  Check logs: docker compose logs trading-bot                 ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}║  Common issues:                                              ║${NC}"
    echo -e "${RED}║  - Invalid Bitunix UID (not affiliated)                      ║${NC}"
    echo -e "${RED}║  - Invalid API keys                                          ║${NC}"
    echo -e "${RED}║  - License server unreachable                                ║${NC}"
    echo -e "${RED}║                                                              ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi

echo ""

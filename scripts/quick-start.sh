#!/bin/bash
# Quick start script for BSidesSF 2019 CTF deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║  BSidesSF 2019 CTF - Quick Start Deployment          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker is not installed${NC}"
    echo "  Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi
echo -e "${GREEN}✓ Docker is installed${NC}"

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose is not installed${NC}"
    echo "  Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}✓ Docker Compose is installed${NC}"

# Prepare distfiles
echo ""
echo -e "${YELLOW}Step 1: Preparing challenge files...${NC}"
if [ ! -d "distfiles" ]; then
    mkdir -p distfiles
    echo -e "${GREEN}✓ Created distfiles directory${NC}"
else
    echo -e "${GREEN}✓ Distfiles directory exists${NC}"
fi

if [ -f "scripts/prepare-distfiles.sh" ]; then
    bash scripts/prepare-distfiles.sh
else
    echo -e "${YELLOW}⚠ prepare-distfiles.sh not found, skipping${NC}"
fi

# Build and start services
echo ""
echo -e "${YELLOW}Step 2: Starting CTF platform and challenges...${NC}"
echo "This may take several minutes on first run..."

# Start core platform first
echo -e "${BLUE}Starting core platform (CTFd, database, cache)...${NC}"
docker-compose up -d ctfd db cache fileserver

# Wait for CTFd to be ready
echo -e "${BLUE}Waiting for CTFd to be ready...${NC}"
sleep 10
for i in {1..30}; do
    if curl -s http://localhost:8000 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ CTFd is ready!${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Start challenges
echo ""
echo -e "${BLUE}Starting challenge containers...${NC}"
docker-compose up -d

# Wait a bit
sleep 5

# Show status
echo ""
echo -e "${YELLOW}Step 3: Checking service status...${NC}"
docker-compose ps

# Show information
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  CTF Platform Successfully Deployed! 🚀                 ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo "  • CTFd Platform:  ${GREEN}http://localhost:8000${NC}"
echo "  • File Server:    ${GREEN}http://localhost:8080${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Visit ${GREEN}http://localhost:8000${NC}"
echo "  2. Create an admin account"
echo "  3. Configure CTF settings (name, description, dates)"
echo "  4. Import challenges:"
echo "     ${YELLOW}python3 scripts/import-challenges.py --url http://localhost:8000 --token YOUR_ADMIN_TOKEN${NC}"
echo ""
echo -e "${BLUE}Management Commands:${NC}"
echo "  • View logs:       ${YELLOW}docker-compose logs -f ctfd${NC}"
echo "  • Stop services:   ${YELLOW}docker-compose down${NC}"
echo "  • Restart service: ${YELLOW}docker-compose restart SERVICE_NAME${NC}"
echo ""
echo -e "${BLUE}Challenge Categories:${NC}"
echo "  • Binary Exploitation (7 challenges)"
echo "  • Web Vulnerabilities (8 challenges)"
echo "  • Cryptography (4 challenges)"
echo "  • Forensics (6 challenges)"
echo "  • Reverse Engineering (4 challenges)"
echo "  • Network Analysis (3 challenges)"
echo "  • Other (4 challenges)"
echo ""
echo -e "${YELLOW}For detailed documentation, see:${NC}"
echo "  • DEPLOYMENT_README.md"
echo "  • DEPLOYMENT_DESIGN.md"
echo ""
echo -e "${GREEN}Happy hacking! 🏴${NC}"

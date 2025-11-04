# BSidesSF 2019 CTF - Deployment Guide

Quick start guide to deploy and run the CTF platform.

## Prerequisites

- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- 4GB+ RAM
- 20GB+ disk space

## Quick Start (Docker Compose)

### 1. Prepare Challenge Files

First, organize all downloadable challenge files:

```bash
# Create distfiles directory structure
mkdir -p distfiles

# Copy all challenge files to distfiles
./scripts/prepare-distfiles.sh
```

### 2. Start the Platform

```bash
# Build and start all services
docker-compose up -d

# Watch the logs
docker-compose logs -f ctfd
```

### 3. Access the Platform

- **Main Platform**: http://localhost:8000
- **File Server**: http://localhost:8080

### 4. Initial Setup

1. Visit http://localhost:8000
2. Create admin account
3. Configure CTF settings (name, description, start/end time)
4. Import challenges (see below)

### 5. Import Challenges

#### Option A: Manual Import via Web UI

1. Login as admin
2. Go to Admin Panel → Challenges
3. Create each challenge with:
   - Name, category, description
   - Point value
   - Flag (use `challenges.yaml` for reference)
   - Connection info:
     - Web: `http://YOUR_SERVER:PORT`
     - Network: `nc YOUR_SERVER PORT`
     - File: `http://YOUR_SERVER:8080/filename`

#### Option B: Automated Import (Recommended)

Use the CTFd import script:

```bash
# Install CTFd CLI
pip install ctfcli

# Configure
ctfcli config

# Import challenges from YAML
python scripts/import-challenges.py --url http://localhost:8000 --token YOUR_ADMIN_TOKEN
```

## Architecture Overview

```
┌─────────────────────────────────────────┐
│  CTFd Platform (Port 8000)              │
│  - User authentication                   │
│  - Challenge listing                     │
│  - Flag submission                       │
│  - Scoreboard                            │
└─────────────────────────────────────────┘
         │
         ├──> MariaDB (database)
         ├──> Redis (cache)
         │
         ├──> File Server (Port 8080)
         │    - Downloadable challenges
         │
         └──> Challenge Containers
              - Web challenges (various ports)
              - Network services (pwn, crypto)
```

## Service Ports

### Platform Services
- **8000**: CTFd web interface
- **8080**: File server (downloadable challenges)
- **3306**: MariaDB (internal)
- **6379**: Redis (internal)

### Web Challenges
- **4455**: kookie
- **8081**: cloud2clown
- **8888**: pick-tac-toe
- **9292**: mixer
- **5001**: futurella
- **3001**: flagsrv
- **8002**: mainframe
- **5002**: pythia

### Network Challenges (pwn, crypto)
- **5252**: runit
- **5253**: runitplusplus
- **5254**: genius
- **2121**: water-dragon (FTP)
- **5255**: fastflag
- **5256**: straw-clutcher
- **5257**: slowfire
- **5300**: crust (DNS)
- **5258**: decrypto
- **5259**: rsaos

## Managing Services

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart a specific challenge
docker-compose restart runit

# View logs
docker-compose logs -f ctfd
docker-compose logs -f runit

# Rebuild a challenge after changes
docker-compose up -d --build runit

# Check service status
docker-compose ps
```

## Troubleshooting

### Port Conflicts

If you get port conflicts, edit `docker-compose.yml` to change port mappings:

```yaml
ports:
  - "NEW_PORT:CONTAINER_PORT"
```

### Out of Memory

Reduce the number of running challenges or increase Docker memory:

```bash
# Run only specific challenges
docker-compose up -d ctfd db cache fileserver runit kookie
```

### Database Connection Issues

```bash
# Reset database
docker-compose down -v
docker-compose up -d
```

### Container Won't Start

```bash
# Check logs
docker-compose logs CONTAINER_NAME

# Rebuild
docker-compose up -d --build CONTAINER_NAME
```

## Production Deployment

For production deployment, you should:

### 1. Use Reverse Proxy (nginx/traefik)

```nginx
server {
    listen 80;
    server_name ctf.example.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 2. Enable HTTPS (Let's Encrypt)

```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Get certificate
certbot --nginx -d ctf.example.com
```

### 3. Secure Credentials

Edit `docker-compose.yml` and change:
- Database passwords
- Redis configuration
- CTFd secret key

```yaml
environment:
  - MYSQL_ROOT_PASSWORD=CHANGE_ME
  - MYSQL_PASSWORD=CHANGE_ME
  - SECRET_KEY=CHANGE_ME
```

### 4. Configure Backups

```bash
# Backup database
docker exec ctf-db mysqldump -u ctfd -pctfd ctfd > backup.sql

# Backup uploads
docker cp ctf-platform:/var/uploads ./backups/uploads

# Automated backup script
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec ctf-db mysqldump -u ctfd -pctfd ctfd > backup_$DATE.sql
gzip backup_$DATE.sql
EOF

# Schedule with cron
0 2 * * * /path/to/backup.sh
```

### 5. Resource Limits

Add resource limits to `docker-compose.yml`:

```yaml
services:
  runit:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
```

### 6. Monitoring

```bash
# Install monitoring stack
docker-compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d

# Access Grafana
http://localhost:3000
```

## Challenge Configuration

Each challenge in CTFd should include:

### Challenge Description Template

```markdown
## [Challenge Name]

[Description of what the challenge involves]

**Category**: [Web/Pwn/Crypto/Forensics/Reversing/Other]
**Difficulty**: [Easy/Medium/Hard]
**Points**: [100-500]

### Connection Info

[For web challenges]
URL: http://ctf.example.com:PORT

[For network challenges]
`nc ctf.example.com PORT`

[For file challenges]
Download: [Download Button]

### Files
- filename.ext (123 KB)

### Hints
1. First hint (costs 10 points)
2. Second hint (costs 25 points)
```

## Kubernetes Deployment (Advanced)

For larger scale deployment, use Kubernetes:

```bash
# Create namespace
kubectl create namespace bsidesf-ctf

# Deploy CTFd
kubectl apply -f k8s/ctfd/

# Deploy challenges
kubectl apply -f k8s/challenges/

# Deploy ingress
kubectl apply -f k8s/ingress.yaml
```

See `DEPLOYMENT_DESIGN.md` for detailed Kubernetes architecture.

## Customization

### Branding

1. Login as admin
2. Go to Admin Panel → Config → Theme
3. Upload custom logo
4. Change colors in CSS

### Challenge Modifications

To modify a challenge:

1. Edit challenge files in `challenge-name/challenge/`
2. Rebuild container: `docker-compose up -d --build challenge-name`
3. Update challenge description/flag in CTFd if needed

### Adding New Challenges

1. Create challenge directory structure:
```
new-challenge/
├── challenge/
│   ├── Dockerfile
│   └── [challenge files]
├── solution/
│   └── README.md
└── distfiles/
    └── [downloadable files]
```

2. Add to `docker-compose.yml`:
```yaml
  new-challenge:
    build: ./new-challenge/challenge
    ports:
      - "PORT:PORT"
    networks:
      - challenge-network
```

3. Add to `challenges.yaml`
4. Import into CTFd

## Maintenance

### Update CTFd

```bash
# Pull latest CTFd image
docker-compose pull ctfd

# Restart with new image
docker-compose up -d ctfd
```

### Clean Up

```bash
# Remove stopped containers
docker-compose down

# Remove volumes (WARNING: deletes data)
docker-compose down -v

# Remove unused images
docker image prune -a
```

### View Resource Usage

```bash
# Show resource usage
docker stats

# Show disk usage
docker system df
```

## Security Checklist

- [ ] Change default passwords in `docker-compose.yml`
- [ ] Enable HTTPS/TLS
- [ ] Configure firewall rules
- [ ] Set up rate limiting
- [ ] Enable CTFd IP tracking
- [ ] Configure backup strategy
- [ ] Review challenge isolation
- [ ] Test flag submission
- [ ] Set resource limits
- [ ] Enable logging
- [ ] Monitor for anomalies

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Review `DEPLOYMENT_DESIGN.md` for architecture details
3. Check CTFd documentation: https://docs.ctfd.io
4. Review challenge solution READMEs

## License

BSidesSF 2019 CTF challenges are released under MIT License.
CTFd is licensed under Apache 2.0.

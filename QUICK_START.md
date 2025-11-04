# BSidesSF 2019 CTF - Quick Start Guide

Transform this CTF challenge collection into a fully playable server in 3 steps!

## 🚀 Fastest Path to Deployment

```bash
# 1. Run the quick start script
./scripts/quick-start.sh

# 2. Visit http://localhost:8000 and create admin account

# 3. Import challenges
python3 scripts/import-challenges.py --url http://localhost:8000 --token YOUR_ADMIN_TOKEN
```

That's it! Your CTF is now live and playable! 🎉

## 📋 What Gets Deployed

### CTF Platform (CTFd)
- **URL**: http://localhost:8000
- User registration and authentication
- Challenge browsing and organization
- Flag submission and validation
- Real-time scoreboard
- User profiles and solve tracking

### Challenge Services

#### 🌐 Web Challenges (8)
Accessible via browser:
- kookie (port 4455)
- cloud2clown (port 8081)
- pick-tac-toe (port 8888)
- mixer (port 9292)
- futurella (port 5001)
- flagsrv (port 3001)
- mainframe (port 8002)
- pythia (port 5002)

#### 🔌 Network Services (11)
Connect via `nc` (netcat):
- runit (port 5252)
- runitplusplus (port 5253)
- genius (port 5254)
- water-dragon (port 2121)
- fastflag (port 5255)
- straw-clutcher (port 5256)
- slowfire (port 5257)
- crust (port 5300)
- decrypto (port 5258)
- rsaos (port 5259)

#### 📁 Downloadable Files (17)
Available at http://localhost:8080:
- Network Analysis: PCAP files
- Forensics: Images, audio, databases, APKs
- Reverse Engineering: Binaries, archives
- Crypto: Encrypted files

## 🎮 User Experience

### Player Journey

1. **Register**: Visit http://localhost:8000, create account
2. **Browse**: See 36 challenges across 7 categories
3. **Solve**:
   - Web challenges: Click URL to visit
   - Network challenges: Use `nc ctf.example.com PORT`
   - File challenges: Download and analyze
4. **Submit**: Enter flag in format `CTF{...}`
5. **Score**: Watch your rank climb on the scoreboard!

### Challenge Categories

```
Binary Exploitation ──────── 7 challenges ── 100-400 pts
Web Vulnerabilities ────────  8 challenges ── 100-300 pts
Cryptography ───────────────  4 challenges ── 200-350 pts
Forensics ──────────────────  6 challenges ── 100-400 pts
Reverse Engineering ────────  4 challenges ── 200-350 pts
Network Analysis ───────────  3 challenges ── 100-200 pts
Other ──────────────────────  4 challenges ── 100-200 pts
                            ────────────────────────────
                             36 total      ~7,000 points
```

## 🏗️ Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                 Players (Web Browser)             │
│                                                   │
│  Register → Browse → Solve → Submit → Scoreboard │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│          CTFd Platform (localhost:8000)           │
│  ┌─────────────┐  ┌──────────┐  ┌────────────┐  │
│  │   Web UI    │←→│  API     │←→│  Database  │  │
│  └─────────────┘  └──────────┘  └────────────┘  │
└──────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────┐
│              Challenge Containers                 │
│  ┌─────────┐  ┌──────────┐  ┌──────────────┐    │
│  │   Web   │  │  Network │  │ File Server  │    │
│  │Services │  │ Services │  │  (distfiles) │    │
│  └─────────┘  └──────────┘  └──────────────┘    │
└──────────────────────────────────────────────────┘
```

## 🎯 Design Philosophy

### Separation of Concerns

**Platform Layer** (CTFd):
- User management
- Challenge metadata
- Flag validation
- Scoring logic

**Challenge Layer** (Containers):
- Isolated environments
- Service-specific logic
- Flag content
- Vulnerability implementations

### Benefits

✅ **Modular**: Update challenges without touching platform
✅ **Scalable**: Add/remove challenge containers independently
✅ **Secure**: Isolated containers with resource limits
✅ **Flexible**: Deploy to laptop, VPS, or Kubernetes cluster
✅ **Portable**: Standard Docker containers work anywhere

## 📦 Deployment Options

### Option 1: Docker Compose (Recommended for Start)
```bash
./scripts/quick-start.sh
```
- **Best for**: Testing, small events (<100 players)
- **Resources**: 4GB RAM, 2 CPU cores
- **Setup time**: 10 minutes

### Option 2: Kubernetes (Production)
```bash
kubectl apply -f k8s/deploy-all.yaml
```
- **Best for**: Large events (100+ players), production
- **Resources**: Scalable (5+ nodes recommended)
- **Setup time**: 1-2 hours

### Option 3: Cloud Deployment
- **Google Cloud (GKE)**: ~$200/month
- **AWS (EKS)**: ~$250/month
- **DigitalOcean**: ~$50/month (VPS + Docker Compose)

## 🔧 Common Operations

### View Status
```bash
docker-compose ps
```

### Check Logs
```bash
docker-compose logs -f ctfd        # Platform logs
docker-compose logs -f runit       # Challenge logs
```

### Restart a Service
```bash
docker-compose restart kookie
```

### Stop Everything
```bash
docker-compose down
```

### Backup Data
```bash
# Database
docker exec ctf-db mysqldump -u ctfd -pctfd ctfd > backup.sql

# Uploads
docker cp ctf-platform:/var/uploads ./backup/
```

## 🔒 Security Considerations

### Before Going Live

1. **Change Passwords**: Edit `docker-compose.yml`
   - Database passwords
   - Admin passwords
   - Secret keys

2. **Enable HTTPS**: Use nginx reverse proxy + Let's Encrypt

3. **Resource Limits**: Configure CPU/memory limits per container

4. **Firewall**: Only expose necessary ports (80, 443)

5. **Backups**: Schedule automated database backups

6. **Monitoring**: Set up logs and alerts

## 📚 Documentation

- **DEPLOYMENT_DESIGN.md**: Full architectural design and rationale
- **DEPLOYMENT_README.md**: Detailed deployment instructions
- **challenges.yaml**: Complete challenge configuration
- **docker-compose.yml**: Service definitions

## 🛠️ Customization

### Add Your Own Challenge

1. Create challenge directory:
```bash
mkdir -p new-challenge/challenge
cd new-challenge/challenge
```

2. Create Dockerfile and challenge files

3. Add to `docker-compose.yml`:
```yaml
new-challenge:
  build: ./new-challenge/challenge
  ports:
    - "PORT:PORT"
```

4. Add to `challenges.yaml`

5. Deploy:
```bash
docker-compose up -d --build new-challenge
```

### Modify Existing Challenge

1. Edit files in `challenge-name/challenge/`
2. Rebuild: `docker-compose up -d --build challenge-name`
3. Update flag/description in CTFd if needed

### Change Branding

1. Login as admin in CTFd
2. Admin Panel → Config → Theme
3. Upload logo, change colors

## 🎓 Learning Path

### For CTF Organizers
1. Deploy locally with quick-start script
2. Create test user account
3. Import challenges
4. Try solving a few challenges
5. Customize branding
6. Deploy to production

### For Players
1. Register account
2. Browse challenges by category
3. Start with "Easy" challenges
4. Download files or connect to services
5. Find and submit flags
6. Check scoreboard

## 🌟 Key Features

### Built-in
- ✅ User authentication and registration
- ✅ Challenge categories and organization
- ✅ Flag submission and validation
- ✅ Real-time scoreboard with rankings
- ✅ User profiles and solve history
- ✅ Admin panel for management

### Platform (CTFd)
- ✅ Teams support
- ✅ Dynamic scoring
- ✅ Hints system (with point deduction)
- ✅ Challenge unlocking/dependencies
- ✅ Time-based challenges
- ✅ File uploads for challenges
- ✅ Export/import functionality
- ✅ API access
- ✅ Plugin system

## 🤝 Getting Help

### Troubleshooting

**Can't access platform?**
```bash
docker-compose logs -f ctfd
```

**Challenge not working?**
```bash
docker-compose logs -f CHALLENGE_NAME
docker-compose restart CHALLENGE_NAME
```

**Port conflict?**
- Edit `docker-compose.yml` and change port mapping

**Out of memory?**
- Reduce number of running challenges
- Increase Docker memory limit

### Resources

- CTFd Documentation: https://docs.ctfd.io
- Docker Documentation: https://docs.docker.com
- Challenge Solutions: See each challenge's `solution/README.md`

## 🎉 Success Checklist

- [ ] Ran `./scripts/quick-start.sh`
- [ ] Accessed CTFd at http://localhost:8000
- [ ] Created admin account
- [ ] Imported challenges
- [ ] Tested flag submission
- [ ] Checked scoreboard
- [ ] Verified file downloads
- [ ] Tested web challenge access
- [ ] Tested network service (nc)

Once all checked, you have a fully operational CTF! 🏴

## 📊 Expected Resource Usage

### Minimal Setup (Core + 5 challenges)
- **RAM**: 2GB
- **CPU**: 2 cores
- **Disk**: 10GB
- **Players**: ~20

### Full Setup (All 36 challenges)
- **RAM**: 8GB
- **CPU**: 4 cores
- **Disk**: 20GB
- **Players**: ~100

### Production (Kubernetes)
- **RAM**: 16GB+ (across cluster)
- **CPU**: 8+ cores
- **Disk**: 50GB+
- **Players**: 500+

## 🚦 Next Steps

After basic deployment:

1. **Test Everything**: Go through each challenge type
2. **Customize Platform**: Branding, descriptions, rules
3. **Set Start/End Times**: Configure competition schedule
4. **Invite Testers**: Have friends try it out
5. **Production Deploy**: Move to cloud with HTTPS
6. **Promote Event**: Share with your community!

## 💡 Pro Tips

- Start small: Deploy 10 challenges first, add more later
- Test flag submission for each challenge
- Set up monitoring before going live
- Have backup plan (database backups)
- Communicate with players (Discord/Slack channel)
- Monitor server during event
- Have fun! CTFs are about learning and community

---

**Ready to launch your CTF?** Run `./scripts/quick-start.sh` now! 🚀

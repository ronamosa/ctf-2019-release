# BSidesSF 2019 CTF - Playable Server Deployment

A collection of 36 CTF challenges from BSidesSF 2019, now deployable as a fully functional, playable CTF server!

## 🎯 What is This?

This repository contains the challenges from the BSidesSF 2019 CTF, transformed into a **complete, deployable CTF platform** where users can:

- ✅ Register and login with accounts
- ✅ Browse 36 challenges across 7 categories
- ✅ Submit flags and earn points
- ✅ Compete on a live scoreboard
- ✅ Track their progress and solves

All powered by Docker containers and the CTFd platform!

## 🚀 Quick Start (3 Commands)

```bash
# 1. Deploy everything
./scripts/quick-start.sh

# 2. Visit http://localhost:8000 and create admin account

# 3. Import challenges
python3 scripts/import-challenges.py --url http://localhost:8000 --token YOUR_TOKEN
```

**Done!** Your CTF server is now live! 🎉

See [QUICK_START.md](QUICK_START.md) for detailed walkthrough.

## 📦 What's Included

### 36 Challenges Across 7 Categories

| Category | Count | Difficulty | Total Points |
|----------|-------|------------|--------------|
| **Binary Exploitation** | 7 | Medium-Hard | 1,900 pts |
| **Web Vulnerabilities** | 8 | Easy-Medium | 1,650 pts |
| **Cryptography** | 4 | Medium-Hard | 1,100 pts |
| **Forensics** | 6 | Easy-Hard | 1,450 pts |
| **Reverse Engineering** | 4 | Medium-Hard | 1,100 pts |
| **Network Analysis** | 3 | Easy-Medium | 450 pts |
| **Other** | 4 | Easy-Medium | 600 pts |
| **TOTAL** | **36** | | **~8,250 pts** |

### Challenge Highlights

- **GENIUS**: Game Boy reverse engineering with Game Genie codes 🎮
- **WATER-DRAGON**: wu-ftpd heap overflow exploitation 🐉
- **CRUST**: DNS-based command channel with encryption 🔐
- **DISKIMAGE**: Multi-stage forensic extraction from FAT12 in PNG 💾
- **YAYORNAY**: Database steganography using Braille patterns ⠃⠗⠁⠊⠇⠇⠑
- **LAUNCHCODE**: Windows Calculator binary patching 🧮

## 🏗️ Architecture

```
              Players
                 ↓
        CTFd Platform (Web UI)
      (Auth, Scoreboard, Flags)
                 ↓
    ┌────────────┼────────────┐
    ↓            ↓             ↓
Web Challenges  Network    File Downloads
 (8 services)   Services   (17 files)
              (11 services)
```

**Separation of Concerns**:
- **Platform Layer**: CTFd handles users, scoring, flag validation
- **Challenge Layer**: Isolated Docker containers run services
- **File Layer**: Static server hosts downloadable challenges

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[QUICK_START.md](QUICK_START.md)** | 🚀 Fastest path to deployment |
| **[DEPLOYMENT_README.md](DEPLOYMENT_README.md)** | 📚 Detailed deployment guide |
| **[DEPLOYMENT_DESIGN.md](DEPLOYMENT_DESIGN.md)** | 🏛️ Full architecture design |
| **[challenges.yaml](challenges.yaml)** | 📋 Challenge configuration |
| **[docker-compose.yml](docker-compose.yml)** | 🐳 Service definitions |

## 🎮 Use Cases

### 1. Educational Labs
Deploy for students to practice:
- Binary exploitation techniques
- Web vulnerability discovery
- Cryptographic attacks
- Digital forensics
- Reverse engineering

### 2. Team Training
Train security teams on:
- Real-world vulnerabilities
- Attack methodologies
- Tool usage (Ghidra, Wireshark, Burp Suite)

### 3. CTF Events
Run your own CTF competition:
- Internal company events
- University competitions
- Community security meetups
- Online tournaments

### 4. Interview Challenges
Use for technical interviews:
- Assess practical security skills
- Evaluate problem-solving ability
- Test tool proficiency

## 🛠️ Deployment Options

### Option 1: Local/Development (Docker Compose)
```bash
./scripts/quick-start.sh
```
- **Best for**: Testing, small events (<100 players)
- **Requirements**: 4GB RAM, 2 CPU cores
- **Setup**: 10 minutes
- **Cost**: Free

### Option 2: VPS (Docker Compose)
```bash
# On DigitalOcean/Linode/Vultr
git clone [repo]
./scripts/quick-start.sh
# Configure nginx + Let's Encrypt for HTTPS
```
- **Best for**: Public events (50-150 players)
- **Requirements**: 8GB RAM, 4 CPU VPS
- **Setup**: 30 minutes
- **Cost**: $40-60/month

### Option 3: Kubernetes (Production)
```bash
kubectl apply -f k8s/deploy-all.yaml
```
- **Best for**: Large events (500+ players)
- **Requirements**: K8s cluster (3+ nodes)
- **Setup**: 1-2 hours
- **Cost**: $150-300/month

See [DEPLOYMENT_README.md](DEPLOYMENT_README.md) for detailed instructions.

## 📊 System Requirements

### Minimal (Core + 10 challenges)
- 2GB RAM
- 2 CPU cores
- 10GB disk
- ~50 concurrent players

### Recommended (All challenges)
- 8GB RAM
- 4 CPU cores
- 20GB disk
- ~100 concurrent players

### Production (Kubernetes)
- 16GB+ RAM (across cluster)
- 8+ CPU cores
- 50GB+ disk
- 500+ concurrent players

## 🔒 Security Features

### Challenge Isolation
- ✅ Each challenge in isolated container
- ✅ Resource limits (CPU, memory)
- ✅ Network policies
- ✅ Read-only filesystems where appropriate
- ✅ Non-root users

### Platform Security
- ✅ Password hashing (bcrypt)
- ✅ JWT authentication
- ✅ Rate limiting on flag submissions
- ✅ SQL injection protection
- ✅ HTTPS support
- ✅ Admin access controls

## 🎯 Player Experience

### Registration & Login
1. Visit platform URL
2. Create account (username, email, password)
3. Verify email (optional)
4. Login to dashboard

### Challenge Solving
1. Browse challenges by category
2. Read description and connection info
3. Access challenge:
   - **Web**: Click URL
   - **Network**: Use netcat: `nc host port`
   - **File**: Download button
4. Find the flag (format: `CTF{...}`)
5. Submit flag
6. Earn points!

### Scoreboard
- Real-time rankings
- Points breakdown by category
- Solve timestamps
- Team/individual scores

## 📁 Repository Structure

```
ctf-2019-release/
├── README.md                      # This file
├── QUICK_START.md                 # Quick deployment guide
├── DEPLOYMENT_README.md           # Detailed deployment docs
├── DEPLOYMENT_DESIGN.md           # Architecture design
├── challenges.yaml                # Challenge definitions
├── docker-compose.yml             # Docker Compose deployment
├── nginx-files.conf               # File server config
│
├── scripts/
│   ├── quick-start.sh            # One-command deployment
│   ├── prepare-distfiles.sh      # Prepare downloadable files
│   └── import-challenges.py      # Import to CTFd
│
├── k8s/
│   └── deploy-all.yaml           # Kubernetes manifests
│
├── [challenge-name]/             # 36 challenge directories
│   ├── challenge/                # Challenge source
│   │   ├── Dockerfile
│   │   └── [files]
│   ├── solution/                 # Writeup
│   │   └── README.md
│   └── distfiles/                # Downloadable files
│
└── distfiles/                    # Collected challenge files
```

## 🚦 Getting Started Checklist

- [ ] Clone repository
- [ ] Install Docker & Docker Compose
- [ ] Run `./scripts/quick-start.sh`
- [ ] Access http://localhost:8000
- [ ] Create admin account
- [ ] Get admin API token (CTFd settings)
- [ ] Run `python3 scripts/import-challenges.py --url http://localhost:8000 --token TOKEN`
- [ ] Test flag submission
- [ ] Verify scoreboard
- [ ] Test challenge access (web, network, files)
- [ ] Customize branding (optional)
- [ ] Deploy to production (optional)

## 🎓 Learning Resources

### For Players
- Each challenge has a solution in `[challenge]/solution/README.md`
- Categories cover different security domains
- Difficulty ranges from beginner to advanced

### For Organizers
- CTFd documentation: https://docs.ctfd.io
- Docker documentation: https://docs.docker.com
- Kubernetes documentation: https://kubernetes.io/docs

## 🤝 Contributing

Ways to contribute:
- Add new challenges
- Improve documentation
- Fix bugs in existing challenges
- Optimize Docker images
- Add monitoring/observability
- Create tutorial videos

## 🐛 Troubleshooting

### Common Issues

**Port conflicts?**
```bash
# Edit docker-compose.yml and change port mappings
```

**Out of memory?**
```bash
# Run fewer challenges
docker-compose up -d ctfd db cache fileserver runit kookie
```

**Can't access platform?**
```bash
docker-compose logs -f ctfd
```

**Challenge not working?**
```bash
docker-compose logs -f CHALLENGE_NAME
docker-compose restart CHALLENGE_NAME
```

See [DEPLOYMENT_README.md](DEPLOYMENT_README.md#troubleshooting) for more.

## 📜 License

This project is released under the MIT License. See [LICENSE.md](LICENSE.md) for details.

Original challenges created for BSidesSF 2019 CTF.

## 🌟 Acknowledgments

- **BSidesSF 2019** for the original challenges
- **CTFd** for the excellent platform
- **Docker** for containerization
- **Kubernetes** for orchestration

## 📞 Support

- **Issues**: Open a GitHub issue
- **Questions**: Check documentation first
- **Community**: Join CTF Discord/Slack communities

## 🎉 Ready to Play?

```bash
./scripts/quick-start.sh
```

Visit **http://localhost:8000** and start hacking! 🏴

---

**Made with ❤️ for the security community**

# BSidesSF 2019 CTF - Deployment & Playable Server Design

## Executive Summary

This document outlines a comprehensive design to transform the BSidesSF 2019 CTF challenge collection into a fully deployable, playable CTF platform where users can register, authenticate, navigate challenges, and submit flags.

## Current State Analysis

### Challenge Inventory
- **Total Challenges**: 36 across 7 categories
- **Categories**: Network Analysis, Binary Exploitation, Cryptography, Web, Forensics, Reverse Engineering, Other
- **Existing Infrastructure**: Kubernetes deployments (23), Docker containers (14), xinetd services (11)
- **Challenge Types**:
  - **Network Services**: Binary exploitation, crypto services (11 challenges)
  - **Web Applications**: SSRF, cookie manipulation, etc. (8 challenges)
  - **Downloadable Files**: Forensics, reverse engineering (17 challenges)

### Deployment Gap
Currently, challenges exist as isolated components without:
- Central authentication system
- Scoreboard/progress tracking
- Unified flag submission interface
- User management
- Challenge coordination

## Proposed Architecture

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     CTF Platform Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │  API Server  │  │   Database   │      │
│  │  (Frontend)  │──│  (Backend)   │──│  (Progress)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌───────────────────────────┴─────────────────────────────────┐
│                  Challenge Deployment Layer                  │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │           Kubernetes / Docker Cluster                │    │
│  │                                                       │    │
│  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │    │
│  │  │ Web Challenges│  │Binary Pwn    │  │File Server│ │    │
│  │  │ (8 services) │  │(11 services) │  │(17 files) │ │    │
│  │  └──────────────┘  └──────────────┘  └───────────┘ │    │
│  └─────────────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────────────┘
```

### Component Architecture

#### 1. CTF Platform (Central System)

**Technology Stack**:
- **Backend**: Python (Flask/FastAPI) or Node.js (Express)
- **Frontend**: React/Vue.js with responsive design
- **Database**: PostgreSQL or MySQL
- **Authentication**: JWT tokens + bcrypt password hashing
- **Container**: Docker

**Core Features**:
- User registration and authentication
- Challenge listing with categories and difficulty
- Flag submission and validation
- Real-time scoreboard
- User profile and solve tracking
- Admin panel for challenge management

#### 2. Challenge Deployment Infrastructure

**Kubernetes-Based Deployment** (Recommended):
- Each challenge as a separate deployment
- Service mesh for inter-service communication
- Ingress controller for routing
- Resource limits per challenge
- Auto-restart on failure

**Alternative: Docker Compose** (Simpler):
- All challenges defined in single docker-compose.yml
- Easier for small-scale deployment
- Suitable for local or small cloud deployments

#### 3. Challenge Access Patterns

**Network Service Challenges** (11 challenges):
```
runit, runitplusplus, genius, water-dragon, fastflag,
straw-clutcher, slowfire, crust, decrypto, rsaos, sendhalp
```
- Exposed via TCP ports through Kubernetes Services
- Users connect via netcat/telnet
- Platform shows: `nc ctf.example.com 5252`

**Web Application Challenges** (8 challenges):
```
cloud2clown, kookie, pick-tac-toe, mixer, futurella,
flagsrv, mainframe, pythia
```
- Exposed via HTTP through Ingress
- Platform provides clickable URLs
- Format: `https://ctf.example.com/challenges/kookie/`

**Downloadable File Challenges** (17 challenges):
```
table-tennis, thekey, zippy, delta, diskimage, dawnupshaw,
yayornay, weathercompanion, blink, launchcode, slashslash,
goodluks, matryoshka, svgmagic, opendoor, dribbles, sequel
```
- Files served from static file server
- Platform provides download buttons
- Files stored in object storage or mounted volume

## Implementation Plan

### Phase 1: Core Platform Development

#### Database Schema

```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_admin BOOLEAN DEFAULT FALSE
);

-- Challenges table
CREATE TABLE challenges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    points INTEGER DEFAULT 100,
    flag VARCHAR(255) NOT NULL,
    challenge_type VARCHAR(20), -- 'web', 'network', 'file'
    connection_info TEXT, -- URL, nc command, or file path
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Solves table
CREATE TABLE solves (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    challenge_id INTEGER REFERENCES challenges(id),
    solved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, challenge_id)
);

-- Teams table (optional)
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Team members (optional)
CREATE TABLE team_members (
    team_id INTEGER REFERENCES teams(id),
    user_id INTEGER REFERENCES users(id),
    PRIMARY KEY(team_id, user_id)
);
```

#### API Endpoints

```
Authentication:
POST   /api/auth/register      - Create new account
POST   /api/auth/login         - Login and get JWT token
POST   /api/auth/logout        - Invalidate token

Challenges:
GET    /api/challenges         - List all challenges
GET    /api/challenges/:id     - Get challenge details
POST   /api/challenges/:id/submit  - Submit flag

User:
GET    /api/user/profile       - Get current user info
GET    /api/user/solves        - Get user's solved challenges

Scoreboard:
GET    /api/scoreboard         - Get rankings

Admin:
POST   /api/admin/challenges   - Create/update challenge
DELETE /api/admin/challenges/:id  - Delete challenge
GET    /api/admin/users        - List users
```

### Phase 2: Challenge Integration

#### Challenge Configuration File

Create `challenges.yaml`:

```yaml
challenges:
  - id: runit
    name: "runit"
    category: "Binary Exploitation"
    description: "Basic shellcode execution challenge"
    points: 100
    flag: "CTF{Everything_is_easier_in_ring0}"
    type: "network"
    connection: "nc {{HOST}} 5252"
    deployment:
      type: kubernetes
      path: runit/deployment/deploy.yaml
      service_port: 5252

  - id: kookie
    name: "kookie"
    category: "Web"
    description: "Cookie manipulation challenge"
    points: 150
    flag: "CTF{3mbr4c3_th3_c00k13_d4rk51d3}"
    type: "web"
    connection: "https://{{HOST}}/challenges/kookie/"
    deployment:
      type: docker
      dockerfile: kookie/Dockerfile
      port: 4455

  - id: table-tennis
    name: "table-tennis"
    category: "Network Analysis"
    description: "PCAP analysis challenge"
    points: 100
    flag: "CTF{T4BLE-T3NN1S-L0L}"
    type: "file"
    connection: "/files/table-tennis.pcap"
    files:
      - challenge/table-tennis.pcap
```

#### Dockerfile for CTF Platform

```dockerfile
# ctf-platform/Dockerfile
FROM node:18-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Build frontend
RUN npm run build

EXPOSE 3000

CMD ["npm", "start"]
```

### Phase 3: Kubernetes Deployment

#### Master Deployment YAML

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: bsidesf-ctf

---
# k8s/ctf-platform.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ctf-platform
  namespace: bsidesf-ctf
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ctf-platform
  template:
    metadata:
      labels:
        app: ctf-platform
    spec:
      containers:
      - name: platform
        image: ctf-platform:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: ctf-secrets
              key: database-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: ctf-secrets
              key: jwt-secret

---
apiVersion: v1
kind: Service
metadata:
  name: ctf-platform
  namespace: bsidesf-ctf
spec:
  selector:
    app: ctf-platform
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer

---
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ctf-ingress
  namespace: bsidesf-ctf
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  rules:
  - host: ctf.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ctf-platform
            port:
              number: 80
      - path: /challenges/kookie
        pathType: Prefix
        backend:
          service:
            name: kookie
            port:
              number: 4455
  tls:
  - hosts:
    - ctf.example.com
    secretName: ctf-tls
```

### Phase 4: Docker Compose Alternative (Simpler)

For smaller deployments:

```yaml
# docker-compose.yml
version: '3.8'

services:
  # Core Platform
  platform:
    build: ./ctf-platform
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://ctf:password@db:5432/ctf
      - JWT_SECRET=your-secret-key
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=ctf
      - POSTGRES_USER=ctf
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # File Server
  files:
    image: nginx:alpine
    volumes:
      - ./distfiles:/usr/share/nginx/html:ro
    ports:
      - "8080:80"

  # Challenge Services
  runit:
    build: ./runit/challenge
    ports:
      - "5252:5252"

  kookie:
    build: ./kookie
    ports:
      - "4455:4455"

  # Add other challenges...

volumes:
  postgres_data:
```

## Security Considerations

### Challenge Isolation
- Each challenge runs in isolated container
- Resource limits (CPU, memory) per challenge
- Network policies to prevent inter-challenge communication
- Read-only filesystems where possible

### Platform Security
- Password hashing with bcrypt (10+ rounds)
- JWT tokens with short expiry (1-24 hours)
- Rate limiting on flag submissions (prevent brute force)
- Input validation on all endpoints
- SQL injection prevention (parameterized queries)
- CORS configuration
- HTTPS enforcement

### Flag Protection
- Flags stored hashed in database
- Environment variables for sensitive data
- Kubernetes secrets for production

## Deployment Options

### Option 1: Cloud Kubernetes (Production)
**Providers**: GKE, EKS, AKS
**Pros**: Scalable, reliable, managed
**Cons**: More expensive
**Cost**: ~$100-500/month depending on scale

### Option 2: Self-Hosted Kubernetes
**Tools**: k3s, microk8s
**Pros**: Full control, cheaper
**Cons**: More maintenance
**Cost**: Server costs only

### Option 3: Docker Compose (Simple)
**Deployment**: Single server
**Pros**: Easy setup, cheap
**Cons**: Limited scale
**Cost**: ~$20-50/month (single VPS)

## User Experience Flow

### 1. Registration & Login
```
User visits: https://ctf.example.com
→ Clicks "Register"
→ Enters username, email, password
→ Receives JWT token
→ Redirected to dashboard
```

### 2. Challenge Discovery
```
Dashboard shows:
├── Categories (tabs or sidebar)
│   ├── Binary Exploitation (7)
│   ├── Web (8)
│   ├── Crypto (4)
│   └── ...
├── Challenge Cards
│   ├── Name, Points, Solves
│   ├── Difficulty indicator
│   └── Solved checkmark (if completed)
```

### 3. Challenge Interaction
```
User clicks challenge:
→ Shows description
→ Shows connection info:
   - Web: "Visit https://ctf.example.com/challenges/kookie"
   - Network: "Connect with: nc ctf.example.com 5252"
   - File: "Download" button
→ Flag submission box
→ Submit flag
→ Real-time feedback (Correct/Incorrect)
```

### 4. Scoreboard
```
Real-time rankings:
Rank | Team/User | Points | Last Solve
1    | h4x0rs    | 2500   | 2 min ago
2    | pwners    | 2300   | 15 min ago
```

## Implementation Timeline

### Week 1: Platform Development
- Day 1-2: Database setup and user authentication
- Day 3-4: Challenge listing and flag submission
- Day 5-7: Frontend UI development

### Week 2: Challenge Integration
- Day 1-3: Create challenge configuration
- Day 4-5: Update Dockerfiles with flag injection
- Day 6-7: Test all challenges individually

### Week 3: Deployment & Testing
- Day 1-3: Kubernetes/Docker Compose setup
- Day 4-5: Integration testing
- Day 6-7: Security hardening and load testing

### Week 4: Polish & Launch
- Day 1-2: UI/UX improvements
- Day 3-4: Documentation
- Day 5: Soft launch with testers
- Day 6-7: Public launch

## Monitoring & Operations

### Logging
- Centralized logging (ELK stack or Loki)
- Challenge access logs
- Flag submission attempts
- Error tracking

### Monitoring
- Prometheus + Grafana for metrics
- Challenge health checks
- Response time monitoring
- User activity metrics

### Backup
- Database backups (daily)
- Configuration backups
- Disaster recovery plan

## Cost Estimation

### Cloud Deployment (AWS/GCP)
- Kubernetes cluster: $100-200/month
- Load balancer: $20/month
- Database: $30-50/month
- Storage: $10/month
- Total: ~$160-280/month

### VPS Deployment (DigitalOcean/Linode)
- 8GB RAM, 4 vCPU: $40-60/month
- Storage: $5-10/month
- Total: ~$50-70/month

## Next Steps

1. **Choose deployment strategy**: Kubernetes vs Docker Compose
2. **Develop CTF platform**: Backend + Frontend
3. **Create challenge configuration**: challenges.yaml
4. **Update challenge Dockerfiles**: Standardize structure
5. **Deploy infrastructure**: Cloud or self-hosted
6. **Test end-to-end**: Full user journey
7. **Launch**: Soft launch → Public

## Appendix: Technology Choices

### Frontend Framework Options
- **React**: Most popular, large ecosystem
- **Vue.js**: Easier learning curve
- **Svelte**: Lightweight, fast

### Backend Framework Options
- **Flask (Python)**: Simple, great for CTFs
- **FastAPI (Python)**: Modern, async, fast
- **Express (Node.js)**: JavaScript full-stack

### CTF Platform Alternatives
Instead of building from scratch, consider:
- **CTFd**: Open-source, battle-tested
- **rCTF**: Modern, fast, Redis-based
- **FBCTF**: Facebook's platform (archived)
- **Mellivora**: PHP-based platform

### Recommended: Use CTFd
**Benefits**:
- Production-ready
- Active community
- Plugin system
- Challenge import/export
- Team support
- Dynamic scoring

**Integration**:
1. Deploy CTFd
2. Import challenges via API or CSV
3. Deploy challenge containers
4. Configure connection info in CTFd

## Conclusion

This design provides a complete roadmap for transforming the BSidesSF 2019 CTF challenge collection into a fully functional, deployable CTF platform. The modular approach allows for both simple (Docker Compose) and scalable (Kubernetes) deployments, with a recommended path of leveraging existing platforms like CTFd for faster time-to-launch.

The key insight is separating the **platform layer** (user management, scoreboard) from the **challenge layer** (individual containers), allowing each to be developed and scaled independently.

# Video Platform Final — Complete Handover Document

## 🚀 Project Overview
**Video Data Collection & Vendor Management Platform**
- **Mobile App**: Flutter 3.22 (Android APK & iOS IPA)
- **Backend API**: Python 3.10+ Flask REST API
- **Database**: Neon Cloud PostgreSQL
- **VPS**: Hostinger VPS (elevateiq-softtech.com)

---

## 🌐 Live Endpoints

| Service | URL |
|---------|-----|
| **Flask API Base** | `http://elevateiq-softtech.com/videoplatformfinal` |
| **Health Check** | `http://elevateiq-softtech.com/videoplatformfinal/health` |
| **Admin Login** | `POST http://elevateiq-softtech.com/videoplatformfinal/api/v1/auth/login` |
| **VPS Company Website** | `https://elevateiq-softtech.com` |

---

## 🖥️ VPS Server Credentials

| Property | Value |
|----------|-------|
| **Host** | `elevateiq-softtech.com` |
| **Server IP** | `195.35.21.139` |
| **Username** | `root` |
| **Password** | `Elevateiq@95153` |
| **SSH Port** | `22` |
| **Project Directory** | `/var/www/videoplatformfinal` |

### SSH Connection
```bash
ssh root@elevateiq-softtech.com
# Password: Elevateiq@95153
cd /var/www/videoplatformfinal
```

---

## 🗄️ Neon Cloud PostgreSQL

| Property | Value |
|----------|-------|
| **Host** | `ep-young-leaf-axv340na-pooler.c-4.us-east-2.aws.neon.tech` |
| **Database** | `neondb` |
| **User** | `neondb_owner` |
| **Password** | `npg_FBwOPsI5L4fE` |
| **Connection String** | `postgresql://neondb_owner:npg_FBwOPsI5L4fE@ep-young-leaf-axv340na-pooler.c-4.us-east-2.aws.neon.tech/neondb?sslmode=require` |

---

## 👤 Pre-Seeded Test Credentials

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@gmail.com` | `admin123` |
| **Vendor** | `vendor@gmail.com` | `vendor123` |
| **Candidate** | `candidate@gmail.com` | `candidate123` |
| **QC Team** | `qcteam@gmail.com` | `qcteam123` |

---

## ⚡ Complete API Endpoint Reference

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/login` | Login (all roles) |
| POST | `/api/v1/auth/signup` | Candidate signup |
| POST | `/api/v1/auth/refresh` | Refresh JWT token |
| POST | `/api/v1/auth/logout` | Revoke session |

### Videos
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/videos` | List videos |
| POST | `/api/v1/videos/upload` | Upload MP4 |
| GET | `/api/v1/videos/<id>/stream` | Stream video |

### Vendors
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/vendors` | List vendors |
| POST | `/api/v1/vendors` | Create vendor |
| GET | `/api/v1/vendors/dashboard-stats` | Vendor analytics |

### Candidates
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/candidates` | List candidates |
| GET | `/api/v1/candidates/<id>/export-report` | Export PDF/CSV report |

### Admin
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/admins/dashboard-stats` | Platform metrics |
| POST | `/api/v1/admins/videos/dispatch-qc` | Dispatch QC queue |
| POST | `/api/v1/admins/videos/<id>/approve` | Approve video |
| POST | `/api/v1/admins/videos/<id>/reject` | Reject video |

### QC
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/qc/reviews` | Submit review |
| GET | `/api/v1/qc/tickets/assigned` | Get assigned videos |

### 🆕 Custom Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/custom/candidates/<id>/export-report` | Export candidate PDF/CSV |
| POST | `/api/v1/custom/dataset-batch-lock` | Lock dataset batch |

---

## 🐍 Backend Setup (Local Dev)

```bash
cd backend
python -m venv venv
source venv/bin/activate   # Linux/Mac
venv\Scripts\activate      # Windows
pip install -r requirements.txt
python utils/seed_db.py    # Seed test accounts
python app.py              # Start dev server
```

---

## 📱 Mobile App Setup (Local Dev)

```bash
cd mobile-app
flutter pub get
flutter run                # Run on emulator/device
flutter build apk --release  # Build Android APK
```

---

## 🚀 VPS Deployment Commands

```bash
# 1. SSH into VPS
ssh root@elevateiq-softtech.com

# 2. Go to project
cd /var/www/videoplatformfinal

# 3. Pull latest code
git pull origin main

# 4. Rebuild and restart
docker compose down
docker compose up -d --build

# 5. Check status
docker ps
curl http://127.0.0.1/videoplatformfinal/health
```

---

## 🌐 Nginx Location Block (VPS Config)
Add this inside the existing `/etc/nginx/sites-available/elevateiq` server block:

```nginx
location /videoplatformfinal/ {
    rewrite ^/videoplatformfinal/(.*) /$1 break;
    proxy_pass http://127.0.0.1:5001;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout 86400;
    client_max_body_size 500M;
}
```

---

## 🔄 CI/CD — GitHub Actions
Every `git push origin main` automatically:
1. Builds Flutter Android APK
2. Publishes it to GitHub Releases

Download latest APK: `https://github.com/<username>/<repo>/releases/latest`

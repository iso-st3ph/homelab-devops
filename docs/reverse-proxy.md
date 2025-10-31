# Docker & Reverse Proxy

This repository includes a lightweight container platform running internal services behind a reverse proxy.

---

## ✅ Core Components

| Component | Purpose |
|----------|--------|
Docker Engine / Compose | Container runtime & orchestration  
Nginx Reverse Proxy     | Front door to services  
whoami test service     | Demo backend to validate routing  
Health checks           | Validate uptime + internal routing  

---

## 🧱 Folder Structure

```bash
docker/reverse-proxy/
├─ docker-compose.yml
└─ nginx/
   └─ conf.d/
      └─ whoami.conf

flowchart LR
User[Client] --> Proxy[Nginx Reverse Proxy]
Proxy --> whoami[Test Container]
Proxy --> OtherApps[Future Apps (Grafana, Wazuh, etc)]

🔐 Reverse Proxy Config (Nginx)
server {
  listen 80;
  server_name _;

  location / {
    proxy_pass http://whoami:80;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}

🚀 Deployment

cd docker/reverse-proxy
docker-compose up -d

🧪 Smoke Test

curl -sI http://localhost:8080 | head -n 1
curl http://localhost:8080

✅ Live Proof

See docs/images/ for screenshot
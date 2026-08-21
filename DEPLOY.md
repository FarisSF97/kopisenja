# DEPLOY — Kopi Senja ke kopi.sf97.my.id

Panduan lengkap deploy website coffee shop (Node.js + Express +
MySQL + Docker) ke VPS Ubuntu dengan nginx reverse proxy dan SSL certbot.

## Ringkasan

```
                        Pengunjung browser
                      https://kopi.sf97.my.id
                                  ▼
┌──────────────────── VPS Ubuntu (43.173.30.77) ────────────────────┐
│             nginx (host) :443 ──SSL──► :80 redirect               │
│               proxy_pass http://127.0.0.1:3000                    │
│                                ▼                                  │
│         ┌──────────────┐   coffee-net  ┌──────────────┐           │
│         │ coffee-app   │◄─────────────►│ coffee-db    │           │
│         │ Express:3000 │               │ mysql:8.0    │           │
│         └──────────────┘               └──────────────┘           │
└───────────────────────────────────────────────────────────────────┘
```

- **2 container Docker** (app + db);
  nginx berjalan di host, bukan container.
- Port app listen di `127.0.0.1` — satu-satunya pintu masuk
  dari internet adalah nginx + SSL.

## Prasyarat

- [ ] Akses SSH ke VPS (user dengan sudo)
- [ ] Repo GitHub sudah berisi kode terbaru **termasuk folder `deploy/`**
- [ ] Bisa mengatur DNS domain `sf97.my.id` di panel registrar

---

## Langkah 1 — Tambah DNS A Record

Di panel pengelolaan domain (registrar tempat membeli `sf97.my.id`):

|  Jenis  |   Host  |    Nilai     |   TTL   |
|---------|---------|--------------|---------|
|   A     |  `kopi` |`43.173.30.77`| default |

Cek DNS Propagation untuk mengecek sudah online atau belum

```bash
dig +short kopi.sf97.my.id
# ekspektasi output: muncul IP address VPS
```

> Jangan lanjut ke Langkah 8 (certbot) sebelum DNS ini aktif,
> karena validasi certbot butuh DNS yang sudah aktif.

## Langkah 2 — Pastikan Kode Terbaru di GitHub

## Langkah 3 — Install Docker di VPS

Login ke VPS, lalu install Docker:

```bash
# Contoh jika OS VPS adalah Ubuntu
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

# Install latest version
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# verify if Docker is installed
docker --version
docker compose version

# verify if Docker service is running
sudo systemctl status docker

# if not running, start it manually
sudo systemctl start docker
```

Jika `docker compose version` tidak dikenali:

```bash
sudo apt-get update && sudo apt-get install -y docker-compose-plugin
```

Opsional (agar tidak perlu sudo setiap perintah docker):

```bash
sudo usermod -aG docker $USER
# logout & login ulang SSH agar efeknya aktif
```

## Langkah 4 — Clone Repo di VPS

## Langkah 5 — Buat File `.env` di VPS

```bash
vim .env
```

Isi dengan nilai ASLI untuk produksi:

```env
DB_USER=<sesuaikan dengan user database>
DB_PASSWORD=<password kuat produksi>
DB_NAME=<sesuaikan dengan database>
MYSQL_ROOT_PASSWORD=<password root kuat>
WA_NUMBER=<sesuaikan dengan nomor whatsapp>
```

> **PENTING:** MySQL hanya membaca variabel ini saat PERTAMA kali
> volume dibuat. Kalau ingin ganti password, harus reset:
> `docker compose down -v && docker compose up -d --build`
> (semua data menu hilang, init.sql dijalankan ulang).

## Langkah 6 — Jalankan Container

```bash
docker compose up -d --build
docker compose ps
curl -I http://127.0.0.1:3000
```

## Langkah 7 — Pasang Config Nginx

Copy file config nginx di direktori `deploy/` ke direktori VPS `/etc/nginx/sites-available/`,
kemudian:

```bash
sudo ln -s /etc/nginx/sites-available/kopi.sf97.my.id /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Tes via HTTP (belum HTTPS):

```bash
curl -I http://kopi.sf97.my.id
```

Jika firewall UFW aktif, pastikan nginx boleh lewat:

```bash
sudo ufw status
sudo ufw allow 'Nginx Full'
```

## Langkah 8 — Pasang SSL certbot

Pastikan certbot sudah terinstall, jika belum install dulu

```bash
sudo apt install certbot
sudo apt install python3-certbot-nginx
```

Install SSL via certbot

```bash
sudo certbot --nginx -d kopi.sf97.my.id
```

- Masukkan email → setuju ToS → pilih **Redirect** (opsi 2) agar
  HTTP otomatis dialihkan ke HTTPS.
- Certbot akan MENGGEDIT file config kita secara otomatis: menambah
  blok `listen 443 ssl`, sertifikat, dan redirect.
- Auto-renew sudah terjadwal otomatis; cek dengan:

```bash
sudo certbot renew --dry-run
```

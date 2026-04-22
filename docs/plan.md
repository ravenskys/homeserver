# Home server build plan

This document captures **goals**, **constraints**, **software principles**, and **phased first steps** so the build stays aligned with what you want and everything remains **adaptable** as you learn what works on your hardware.

---

## 1. Goals (what you’re building)

| Area | What you want |
|------|----------------|
| **Media** | Store movies/shows; watch from home and while away, without relying on a public cloud for the library. |
| **Files** | “Cloud-like” access: save files, sync or fetch from anywhere, **you** control the data. |
| **Photos / cameras** | Backup and browse phone/camera image libraries; prefer **self-hosted** over vendor lock-in. |
| **Voice / AI (local)** | Smart-home style commands and local automation where possible; **realistic** about RAM (8 GB) for heavy models. |
| **Remote access** | Reach services from outside the home **securely** (VPN or equivalent), not by exposing file shares to the open internet. |

---

## 2. Hardware and expectations

| Resource | Plan |
|----------|------|
| **CPU** | Older i5 — fine for file serving, light transcoding, many Docker services if you don’t run everything at once. |
| **RAM (8 GB)** | Enough to **start**; prefer **direct play** in media apps over heavy on-the-fly transcoding. Stack services gradually and set **memory limits** in Docker if you use containers. |
| **1 TB single disk** | Good for iteration; it’s a **single point of failure**. Plan a **second drive or off-site backup** when you can. Optional: **LUKS** encryption if the machine could be lost or stolen. |
| **Upload bandwidth** | Remote streaming and “feels like cloud” experience depend on **home upload speed** — run a speed test and keep expectations in line. |

---

## 3. Principles (how we choose and run software)

### 3.1 Open source and cost

- **Prefer** open-source, self-hostable software so you can **read**, **change**, and **self-host** without a mandatory subscription.
- **Prefer** tools with **no** or **optional** paid tiers for *your* use case; avoid locking core workflows to a paid cloud you don’t control.
- **Commercial** is OK when it’s **optional** (e.g. a client app) or you explicitly accept it — document the exception here when you add it.

### 3.2 “Customize anything”

Self-hosting already means **you own the config**. To keep that practical:

- **Config as code** — store compose files, env **templates** (never commit secrets), reverse-proxy snippets, and scripts **in this repo** where it makes sense.
- **One source of truth** — for each service, know: *install method* (package vs Docker), *where data lives* (host paths), *where config lives*, *how to back up* that path.
- **Boundary layers** — reverse proxy (e.g. Caddy or Nginx), VPN (Tailscale or WireGuard), and **automation** (e.g. Home Assistant) are where you **most often** want deep customization; invest docs there.
- **Fork-friendly** — favor stacks you can **patch**, **theme**, or **replace** (standard Linux services, well-documented APIs) over black boxes.

### 3.3 Security habits

- **Do not** expose **SMB/NFS** directly to the internet.
- **Do** use a **VPN or mesh** (Tailscale is easy; WireGuard is lean) for “phone on LAN” access.
- If anything must be **public** (rare), put it behind **HTTPS**, strong **auth**, updates, and ideally **fail2ban**; prefer VPN for admin UIs.

---

## 4. Default stack (starting point — all adjustable)

These are **candidates**, not a contract. Swap components as you learn.

| Need | First choice to evaluate | Why it fits the principles |
|------|--------------------------|-----------------------------|
| OS | **Ubuntu Server LTS** or **Debian** | Stable, huge docs, easy to harden. |
| Remote access | **Tailscale** or **WireGuard** | Encrypted tunnel; no need to open many ports. |
| Media | **Jellyfin** | Open source, local; match client codecs for smooth **direct play**. |
| Files / “cloud” | **Nextcloud** *or* **Samba + SFTP/SSH** | Nextcloud = richer apps; Samba+SSH = lighter if you only need files. |
| Photo backup / gallery | **Immich** or **PhotoPrism** *or* **Syncthing** for folder sync only | Immich/PhotoPrism = full gallery; Syncthing = simpler, less RAM. |
| Home + voice / automation | **Home Assistant** | Local, huge integration surface; add **local STT** (e.g. Whisper small) and TTS when ready. |
| Optional heavy AI later | **Ollama** or small **quantized** models | Only after base services are stable; 8 GB is tight for big models. |
| HTTP / TLS | **Caddy** or **Nginx** | Reverse proxy, certs if you expose selected services. |

**Paid / optional** you might add on purpose: mobile apps, some upstream donations, or a VPS **only** if you outgrow “VPN into home” (document if you do).

---

## 5. Phased roadmap

### Phase 0 — Foundation (do first)

1. Install Linux, apply updates, create a **non-root** admin user, enable **firewall** (allow SSH only from where you need, or VPN-only later).
2. Decide **disk layout** and **mounts** (e.g. `/srv/data` for all persistent data).
3. Install **Docker** (or stick to packages — your call); document the choice in this repo.
4. Install **Tailscale** or **WireGuard**; confirm phone/laptop can reach the server on a **test port** (e.g. SSH) before layering apps.

### Phase 1 — Core value

1. **Jellyfin** — libraries pointing at your media folders; test **direct play** on one client.
2. **Files** — Nextcloud *or* Samba for LAN + **SSH/SFTP** for simple remote file drop over VPN.
3. **Backups** — at minimum: **scripted copy** to external drive or second disk; test restore.

### Phase 2 — Photos and more polish

1. **Immich** *or* **PhotoPrism** *or* **Syncthing** — pick one to avoid RAM starvation.
2. Harden: **separate** DB volumes, **retention** rules, and backup includes **databases** where needed.

### Phase 3 — Voice and local AI

1. **Home Assistant** (if you want smart home + automation hub).
2. Add **STT** (e.g. Whisper) and **TTS**; keep models **small** on 8 GB.
3. Add **larger** local LLMs only with spare RAM and realistic expectations — or a **dedicated** machine later.

---

## 6. What to put in *this* repository next

Suggestions as the build proceeds:

- `docker-compose*.yml` (or `compose/` per stack) with **documented** volume paths.
- `docs/` notes for **ports**, **credentials location** (not the secrets themselves), and **backup/restore** steps.
- `env.example` — copy to `.env` on the server, **gitignore** the real `.env`.
- Optional: `scripts/` for backup and updates.

---

## 7. Open decisions (fill in as you go)

- [ ] **Upload speed** at home (rough Mbps up): _____________
- [ ] **Photo priority:** full **gallery** (search, faces) vs **reliable backup** only?
- [ ] **Voice priority:** **smart home + commands** only vs also **“chat with”** local LLM?
- [ ] **Nextcloud** vs **Samba + SSH** for files?
- [ ] **Immich** vs **PhotoPrism** vs **Syncthing-only** for cameras?

Revisit this file when hardware or goals change (e.g. more RAM, second disk).

---

*Last updated: initial version saved from project bootstrap.*

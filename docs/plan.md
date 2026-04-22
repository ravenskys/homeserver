# Home server build plan

This document captures **goals**, **hardware**, **software principles**, and **phased steps** so the build stays aligned with what you want and everything remains **adaptable** as you upgrade storage and services.

---

## 1. Goals (what you’re building)

| Area | What you want |
|------|----------------|
| **Media** | Central library of movies and videos; access from **anywhere**; start playback with a **normal client app** (and optionally **voice** through the home hub). Goal: *request and watch* with minimal friction, not a proprietary cloud. |
| **Private documents** | **Moderate** space for private files, **cloud-like** access (sync, web, or WebDAV) **you** control, reachable safely from outside the home. |
| **Whole-home “brain”** | This server is the **center** for home automation, replacing a scattered mix of **camera** apps and **voice** / AI command interfaces with **one** stack you can customize. |
| **IP cameras** | **Replace** the current camera ecosystem with a **self-hosted** recording / viewing stack (IP cameras, RTSP, NVR-style software—but OSS-first and self-hosted). |
| **Voice & AI (local first)** | Voice commands and automations; prefer **local** processing where practical; add heavier models only when the box has headroom. |
| **Ad blocking (LAN)** | **Pi-hole** (or similar) so the whole house can block ads and noisy telemetry at the **DNS** level. |
| **VPN (road / café WiFi)** | Use the server (or a small companion setup) so when you’re on **untrusted public WiFi**, your traffic can go through a **trusted tunnel** to home—**private** on someone else’s network. |
| **Security habit** | Reach things from outside via **VPN / mesh** first; **do not** expose file shares (SMB) or admin UIs raw to the open internet. |

---

## 2. Hardware (initial and planned)

| Resource | Your plan | Notes |
|----------|-------------|--------|
| **CPU** | **Intel Core i5-3570** (Ivy Bridge) | Fine for file serving, Pi-hole, VPN, many Docker services, and **light** camera / transcoding. **No AVX2** (pre-Haswell); most homelab software still runs; a few very new AI builds may be picky—choose builds or older binaries if something refuses to install. For **NVR** (cameras), CPU load depends on **resolution, FPS, number of cameras**, and whether you use **motion-only** vs **continuous** recording. |
| **RAM** | **16 GB DDR3** | A big step up from 8 GB: **comfortable** for Jellyfin + Nextcloud + Home Assistant + Pi-hole + VPN + a **moderate** camera stack, if you add services **gradually** and set **Docker memory limits** where it helps. |
| **Storage (now)** | **2 × 1 TB** HDD | Use the pair intentionally: e.g. **one volume for live data** and **one for backup**, or **mirroring (RAID1 / btrfs / ZFS mirror)** for one copy of “live” data—decide with safety vs capacity in mind. **Plan backups** to something besides the only two disks in the same chassis (e.g. external drive or off-site when you can). |
| **Storage (future)** | **SSD** (OS + fast metadata / DB) + **4 TB** HDD (bulk media and archives), optional **expansion bay** | When you migrate: **move databases and hot paths** to SSD; keep **media and camera footage** on the large HDD; document **mount points** in this repo. |
| **Upload bandwidth** | (measure and fill in) | Remote streaming and “feels like cloud” still depend on **home upload** speed—note it in section 7. |
| **OS** | **Linux** (no strong version preference) | **Ubuntu Server LTS** or **Debian** (stable) are the default recommendation: long support, huge docs, works well with Docker, Pi-hole, and the stacks below. Pick one and stay on it for a while. |

---

## 3. Principles (how we choose and run software)

### 3.1 Open source and cost

- **Prefer** open-source, self-hostable software so you can **inspect**, **change**, and **own** the deployment without a forced subscription.
- **Prefer** free tiers and **optional** paid extras only when you **choose** them (e.g. a good mobile app donation).
- **Document** any closed-source or paid piece on purpose and why it stayed.

### 3.2 “Customize anything”

- **Config as code** in this repo: compose files, **env templates** (never commit real secrets), reverse-proxy snippets, backup scripts.
- **Per service:** install method, **data path**, **config path**, **backup** procedure, and **port** (documented in `docs/` as you go).
- **Hub layer:** **Home Assistant** is where a lot of **voice, automations, and “house OS”** behavior will live; reverse proxy + VPN are where you customize **how** you reach things from outside.

### 3.3 Security habits

- **Do not** expose **SMB** or **raw database ports** to the internet.
- **Do** use **Tailscale** and/or **WireGuard** for “my laptop/phone = trusted path to home.”
- For **public WiFi**: VPN **to home** (or a controlled endpoint) is the right pattern; Pi-hole is **LAN/DNS**—the **privacy-on-café-WiFi** part is the **encrypted tunnel**, not Pi-hole itself.

### 3.4 Pi-hole + VPN (how they fit together)

- **Pi-hole:** DNS for your LAN; point the **router** or per-device DNS at the server (or use DHCP to hand out Pi-hole as DNS). **Blocks ads/telemetry** for devices that use your network’s DNS.
- **VPN to home (Tailscale / WireGuard):** when you’re **away**, your device gets a path to the **home LAN** (or selected subnets). You can use **Jellyfin, Nextcloud, and Home Assistant** as if you were home—**without** opening those services to the whole world.
- **Café / airport WiFi:** run the **same VPN** so traffic between your device and home is **encrypted** on the untrusted access point. Pi-hole can **also** help when you’re **on** the home network; when remote, you’re mainly relying on the **tunnel** + app auth.

---

## 4. Default stack (candidates—swap as you learn)

| Need | First choice to evaluate | Notes |
|------|--------------------------|--------|
| **OS** | **Ubuntu Server LTS** or **Debian** | Either is fine; LTS = fewer OS upgrades. |
| **Media + “play anywhere”** | **Jellyfin** + official / community **clients** (TV, phone, web) | **Request** a title in the app; for **“Hey, play X”** you layer **Home Assistant** + media player integrations later. Prefer **direct play**; transcoding is heavier on the i5-3570. |
| **Private documents, cloud feel** | **Nextcloud** (or **Files + WebDAV** only if you want lighter) | Web, sync, optional office hooks; good fit for “moderate” private storage with remote access over VPN. |
| **Home hub + voice** | **Home Assistant** | Replaces ad-hoc voice/assistant silos; add **Piper/Whisper**-class components as needed; 16 GB helps. |
| **IP cameras (replace old system)** | **Frigate** (often with **go2rtc**) or **Scrypted**, or lighter **MotionEye** / **Shinobi** | Frigate is popular; on older CPUs, limit **resolutions and FPS**, use **substreams**, and consider a **Coral TPU** later for object detection to spare CPU. Match cameras: **ONVIF / RTSP** preferred. **ZoneMinder** is another OSS option. |
| **Ad blocking** | **Pi-hole** in Docker (or bare metal) | Set DNS on router or via DHCP. Document **blocklists** in repo notes if you want them repeatable. |
| **VPN (remote + untrusted WiFi)** | **Tailscale** (easiest mesh) and/or **WireGuard** (lean, classic) | Use **one** to start; many people run **Tailscale** for “every device to home” with little port forwarding. |
| **Reverse proxy + HTTPS** | **Caddy** or **Nginx** or **Nginx Proxy Manager** | If you only ever access via **VPN**, strict public HTTPS is less critical; still useful for **LAN** and future split-DNS. |
| **Optional heavier local AI** | **Ollama** or small **quantized** models | 16 GB allows **smaller** models more comfortably; still be selective. |

**Commercial cameras** sometimes lock you in—if possible, move toward **ONVIF / RTSP** cams for Frigate/others to consume.

---

## 5. Phased roadmap (suggested order)

### Phase 0 — Foundation

1. Install **Ubuntu/Debian**, updates, **non-root** admin, **firewall** (e.g. `ufw`: SSH, and later VPN/Pi-hole/DNS as needed).
2. **Partition / mount** the two 1 TB drives: capacity vs mirror vs “data + backup”—**document** the layout here.
3. **Docker** (or systemd + packages—your call) and a **naming plan** for volumes under e.g. `/srv/…`.
4. **Tailscale and/or WireGuard** — confirm phone/laptop can reach the server from **another network** (or at least simulate) **before** relying on it for “café” use.

### Phase 1 — Network services + media + files

1. **Pi-hole** — point LAN DNS; verify blocking works.
2. **Jellyfin** — media library, clients on phone/TV; tune for **direct play** where possible.
3. **Nextcloud** (or your chosen doc stack) — private documents, test **web + sync** over **VPN** from outside.

### Phase 2 — “House OS”: cameras and voice

1. **Home Assistant** — integrate what you already have; plan **camera** and **media** entities.
2. **NVR / camera stack** (e.g. Frigate) — add **one camera at a time**; set **retention** on disk; verify CPU with realistic streams.
3. **Voice pipeline** in HA — start simple (dashboards, scripts); add **STT/TTS** when core is stable.

### Phase 3 — Hardening and upgrades

1. **Backups** — databases + config + key folders; test **restore**.
2. **Storage migration** — when **SSD + 4 TB** land, migrate with minimal downtime; update mount docs in this repo.
3. **Optional: Coral / more RAM / expansion bay** as load grows.

---

## 6. What to put in *this* repository as you build

- `docker-compose*.yml` (or `compose/`) with **volume paths** explained.
- `docs/ports.md` (or a section in `docs/`) for **used ports** and **Pi-hole** / **VPN** / **Jellyfin** notes.
- `env.example` — copy to `.env` on the server; real `.env` stays gitignored.
- `scripts/` for backup and updates.
- **Camera decision log:** model, RTSP URL pattern, and **where** recordings live on disk.

---

## 7. Open decisions (fill in as you go)

- [ ] **Home upload speed** (Mbps up): _____________
- [ ] **Two 1 TB drives:** mirror, span, or one live + one backup? _____________
- [ ] **Camera replacement:** new **ONVIF/RTSP** cams vs making **existing** hardware work? _____________
- [ ] **NVR choice:** Frigate vs Scrypted vs lighter tool — start with: _____________
- [ ] **VPN:** Tailscale only, WireGuard only, or both: _____________
- [ ] **Voice:** HA-only first vs add **Rhasspy/OVOS**-style later: _____________

---

*Last updated: hardware and goals (i5-3570, 16 GB, 2×1 TB, media, docs, hub, cameras, voice, Pi-hole, VPN).*

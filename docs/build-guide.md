# Home Server Build Guide

This is the single source of truth for planning and execution.

For USB install workflow, see [usb-build-pack.md](usb-build-pack.md).

## Day 1 quickstart

Use this short runbook on first boot after installing Ubuntu Server 24.04 LTS.

1. Log in as your admin user and update packages:
   - `sudo apt update && sudo apt -y upgrade`
2. Install baseline tools:
   - `sudo apt install -y git curl htop ufw vim`
3. Enable basic firewall (adjust if you changed SSH port):
   - `sudo ufw allow OpenSSH`
   - `sudo ufw enable`
   - `sudo ufw status`
4. Install Tailscale (VPN-first remote management):
   - `curl -fsSL https://tailscale.com/install.sh | sh`
   - `sudo tailscale up`
5. Verify remote path before app installs:
   - confirm Tailscale IP appears with `tailscale ip -4`
   - SSH to that Tailscale IP from another device
6. Prepare service directories:
   - `sudo mkdir -p /srv/{media,docs,cameras,backups,appdata} /opt/compose`
7. Continue with section **5) Phase 0 execution checklist** for mirror setup and Docker.

## 1) Finalized baseline

- **OS:** Ubuntu Server 24.04 LTS
- **CPU:** Intel i5-3570
- **RAM:** 16 GB DDR3
- **Storage now:** 2x1TB HDD in **mirror** (RAID1-style)
- **Storage later:** add SSD for OS/appdata + larger HDD for bulk data
- **Upload speed:** ~750 Mbps typical, up to ~1 Gbps

## 2) Goals

- Media server with remote access
- Private cloud-style document storage
- Camera/NVR replacement with self-hosted stack
- Home automation and voice command hub
- Network-wide ad blocking (Pi-hole)
- Private remote networking from public WiFi (VPN)

## 3) Core stack (default choices)

- **Remote access VPN:** Tailscale first (WireGuard optional later)
- **Media:** Jellyfin
- **Private files/docs:** Nextcloud
- **Home automation + voice foundation:** Home Assistant
- **Camera/NVR candidate:** Frigate (plus go2rtc as needed)
- **Ad blocking:** Pi-hole

## 4) Exposure policy

- Keep admin UIs and internal apps **LAN/VPN only**.
- Do not expose SMB, database ports, or camera stream ports publicly.
- Public exposure should be rare and only behind HTTPS + strong auth.

## 5) Phase 0 execution checklist

### Base OS

- [ ] Install Ubuntu Server 24.04 LTS
- [ ] Create non-root admin user
- [ ] Update packages
- [ ] Set timezone and NTP
- [ ] Install: `git`, `curl`, editor, `htop`, `ufw`

### Storage (mirror)

- [ ] Build mirror on both 1TB HDDs
- [ ] Create mount points:
  - [ ] `/srv/media`
  - [ ] `/srv/docs`
  - [ ] `/srv/cameras`
  - [ ] `/srv/backups`
  - [ ] `/srv/appdata`
- [ ] Add persistent mounts in `/etc/fstab`

### Network + security

- [ ] Set static DHCP lease for server
- [ ] Configure firewall (`ufw`)
  - [ ] allow SSH (prefer VPN path)
  - [ ] allow DNS 53 from LAN for Pi-hole
  - [ ] allow VPN path (Tailscale needs no port-forward; WireGuard uses UDP 51820)
  - [ ] deny unnecessary inbound from WAN

### Runtime

- [ ] Install Docker Engine + Compose plugin
- [ ] Create `/opt/compose` and per-service folders
- [ ] Set basic log rotation and memory limits where needed

### Remote access validation

- [ ] Install and test VPN (start with Tailscale)
- [ ] Confirm remote SSH over VPN
- [ ] Confirm remote app access path before deploying all services

## 6) Service port reference

| Service | Port(s) | Exposure |
|---|---:|---|
| SSH | 22 TCP | VPN-only preferred |
| Jellyfin | 8096/8920 TCP | VPN-only |
| Home Assistant | 8123 TCP | VPN-only |
| Pi-hole DNS | 53 TCP/UDP | LAN + VPN clients |
| Pi-hole UI | 80 TCP | LAN/VPN only |
| Frigate UI/API | 5000 TCP | VPN-only |
| Frigate restream | 8554/8555 | LAN only |
| WireGuard (if used) | 51820 UDP | Public single port |

## 7) Customer app hosting architecture (public-safe)

Use this split so your customer app can be public without exposing homelab internals.

### Zone model

- **Public zone (internet-facing):**
  - Reverse proxy (Caddy)
  - Customer website/app containers
- **Private zone (not public):**
  - Home Assistant, Pi-hole admin, cameras, SMB, internal databases
- **Management zone:**
  - SSH and admin access over Tailscale/WireGuard only

### Non-negotiable rules

- Expose only `80/443` publicly (plus VPN if self-hosting WireGuard).
- Keep databases off public ports; app reaches DB on internal Docker network only.
- Keep admin dashboards VPN-only.
- Use separate Docker networks for `public` and `private`.
- Do not allow customer app containers to mount private homelab data volumes.

### First deployment pattern (start here)

1. Create reverse proxy + app-only compose stack in `/opt/compose/customer-app`.
2. Put app containers on `public_proxy` network.
3. Put app database on `app_internal` network with no published ports.
4. Configure domain DNS to your WAN IP and route through Caddy with HTTPS.
5. Add basic protections: rate limiting, fail2ban, strong admin passwords, MFA where supported.
6. Verify with external scan that only `80/443` (and optional VPN port) are exposed.

### When to move customer app off homelab

Consider VPS/managed hosting if you need higher uptime guarantees, DDoS protection, compliance, or 24/7 operational reliability independent of home internet/power.

## 8) Remaining decisions

- [ ] Camera path: keep existing cameras or move to ONVIF/RTSP models
- [ ] NVR final choice: Frigate vs Scrypted vs lighter option
- [ ] Voice scope: HA automations only vs broader local assistant stack

## 9) Security testing plan (when system is up)

I can help you run a safe, owner-authorized hardening and pentest pass on your own server:

- Port exposure review (`nmap` from LAN and external test node)
- Service auth checks (default creds, weak auth paths, unnecessary open UIs)
- TLS and header checks for any exposed web endpoints
- VPN-only validation for admin surfaces
- Backup/restore and least-privilege review

Use this only on systems you own or explicitly control.

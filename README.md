# Home server

Documentation and configuration for a **local-first** home server: **media** you can start from any device, **private document** storage with cloud-style access, and a **central hub** for **cameras**, **voice/AI commands**, **network-wide ad blocking (Pi-hole)**, and **safe remote access (VPN)**—without handing your data to a public cloud.

This repository holds **plans, notes, and eventually** `docker-compose` files, config templates, and scripts so everything stays **versioned, repeatable, and easy to customize**.

- **Full roadmap, hardware, and software choices:** [docs/plan.md](docs/plan.md)

**Current build target (initial):** Intel **Core i5-3570**, **16 GB** DDR3, **2× 1 TB** HDD, **Linux** (Ubuntu Server or Debian LTS are strong defaults; either works well for Docker and this stack).

**Planned storage upgrade:** system **SSD** + **4 TB** data disk, optional **expansion bay** for more capacity later.

When the GitHub repo is private again, the same content lives in your clone; visibility does not change how you self-host.

---

## Next session (handoff)

- **Git / GitHub:** Use **`ravenskys` only** from this point on. In **Windows Credential Manager**, remove old `github.com` entries, then `git push -u origin main` from this folder so the latest commits land on the remote. (Pushes were failing with 403 when Windows used another account—fix credentials first.)
- **When you’re back:** Ask to **walk through this README** (and [docs/plan.md](docs/plan.md) if you want) and we’ll continue from there.

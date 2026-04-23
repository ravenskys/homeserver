# Session handoff

**Check this file** at the start of a work session (or when you say “read the handoff file”) so context stays consistent with other project builds.

## Pending

- On the **server** (SSH as `ravenskys`): clone this repo, clone [onthegoapp](https://github.com/ravenskys/onthegoapp) into `apps/onthegoapp`, run `scripts/bootstrap-ubuntu-24.04.sh`, then `tailscale up` and follow [build-guide.md](build-guide.md) Phase 0 → services.
- Fill remaining decisions in [build-guide.md](build-guide.md) (customer app section + remaining open items): camera path, NVR final choice, voice scope.
- Google router: DHCP reservation for the server; port forwards **80/443 TCP** to the server only when you go public with Caddy.

## When you resume

- Walk through [**README**](../README.md), then follow [build-guide.md](build-guide.md).
- Add new items under **Pending** (or a dated log below) as you go so the handoff file stays the single “continue here” place.

## Server access (do not put passwords in git)

- **Console / SSH user:** `ravenskys` — password only in your password manager or OS keyring, not in this repo or chat history.

## Done

- GitHub auth corrected to **`ravenskys`** and `main` successfully pushed to `origin/main`.
- Build guide and checklists live in a single [build-guide.md](build-guide.md) (older split files removed).
- Confirmed storage path: start on **2x1TB HDD**, upgrade later to add/migrate to **SSD** (and larger bulk disk).
- Chose **mirror** layout for the initial 2x1TB drives.
- Chose OS baseline: **Ubuntu Server 24.04 LTS**.
- Consolidated docs into single guide: [build-guide.md](build-guide.md).
- `compose/customer-app`: Caddy + Next.js `onthegoapp` (Supabase env; no local DB container).
- **Ubuntu Server installed on the box**; next step on the server: `sudo bash` the bootstrap script from this repo, then `tailscale up` and service deploys.
- Added USB install docs and bootstrap script: `docs/usb-build-pack.md` and `scripts/bootstrap-ubuntu-24.04.sh`.

## Last session

- End of day: working tree saved, committed, and pushed to `origin/main` (see git log on next pull).

---

*Update this file whenever you end a session or need the next person/agent to pick up where you left off.*

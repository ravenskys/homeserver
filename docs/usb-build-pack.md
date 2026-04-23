# USB Build Pack (128 GB Drive)

Yes, this is exactly what the USB can be used for.

Use the USB for two things:

1. **Ubuntu Server 24.04 installer media**
2. **This repo + bootstrap script** for post-install automation

## What to put on the USB

- Ubuntu Server 24.04 LTS ISO
- A clone/export of this repo (or at minimum `scripts/bootstrap-ubuntu-24.04.sh`)

## Build flow

1. Create bootable Ubuntu installer USB.
2. Boot target server and install Ubuntu Server 24.04 LTS.
3. After first login, copy this repo to the server (USB or `git clone`).
4. Run:

```bash
cd /path/to/homeserver
sudo bash scripts/bootstrap-ubuntu-24.04.sh
```

5. Re-login, then complete:
   - `sudo tailscale up`
   - mirror setup for the 2x1TB drives
   - deploy compose stacks

## What the bootstrap script installs/configures

- OS updates
- baseline tools (`git`, `curl`, `htop`, `vim`, `ufw`, etc.)
- core directories under `/srv` and `/opt/compose`
- firewall baseline with SSH allowed
- Docker Engine + Compose plugin
- docker group access for your admin user
- Tailscale package (you run `tailscale up` interactively)

## Notes

- Script expects Ubuntu 24.04-family apt behavior.
- It does **not** partition or format your data disks (safe by default).
- RAID1 mirror setup remains a separate explicit step.

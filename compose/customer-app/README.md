# Customer App Stack (Starter)

This stack now targets your `onthegoapp` Next.js repo directly.

It gives you a safe default starting point:

- `caddy` is the only public entry point (`80/443`)
- `app` is your built Next.js app (Node 20, production mode)
- Supabase stays external (no database container exposed on this host)

## Quick start

1. Copy env template:
   - `cp .env.example .env`
2. Edit `.env` with your real domain/email/password.
3. Confirm repo path exists:
   - `../../apps/onthegoapp`
4. Start stack:
   - `docker compose up -d`
5. Verify:
   - `docker compose ps`
   - open `https://<your-domain>`

The app service is built from:

- `../../apps/onthegoapp` (build context)
- `./Dockerfile` (this folder)

If you update app code, redeploy with:

- `docker compose up -d --build`

## Security notes

- Keep this stack isolated from Home Assistant, Pi-hole admin, camera services, and SMB.
- Keep SSH/admin access over VPN where possible.
- Keep Supabase keys in `.env` only (do not commit real secrets).
- Use long random secrets and rotate them when moving to production.

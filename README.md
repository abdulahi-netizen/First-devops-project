# Dockerized Multi-Service Monitoring Stack

A small multi-container stack with an Nginx reverse proxy routing to two backend services, all connected on a custom Docker network. Built as a DevOps fundamentals capstone covering Docker, networking, Bash automation, and Git.
## Architecture

This stack has three containers, all connected on a custom Docker bridge network (`monitoring-net`):

- **nginx** — the only container exposed to the host, on port 80. Acts as a reverse proxy, routing incoming requests to the correct backend based on the URL path.
- **app-a** — a simple Python HTTP server, not reachable from outside the network.
- **app-b** — same as app-a, running independently.

Nginx routes to each backend by container name (e.g. `http://app-a:8000`), relying on Docker's internal DNS rather than hardcoded IP addresses. This means the backend containers are never directly reachable from the host — only through the proxy.

## How to Run It

1. Clone the repo:
git clone https://github.com/abdulahi-netizen/First-devops-project.git
cd First-devops-project


2. Bring up the stack:

./scripts/deploy.sh

   This builds all images, starts the containers, and waits until both backend services are responding before reporting success.

3. Visit:
   - `http://localhost/app-a/`
   - `http://localhost/app-b/`

   You should see "Hello from App A!" and "Hello from App B!" respectively.

   ## Checking Health

Run the health check manually at any time:

bash scripts/healthcheck.sh

This checks both services, appends a timestamped result to `scripts/healthcheck.log`, and exits with a non-zero code if anything is down.

Example log output:

2026-09-28 10:58:01 - app-a: UP
2026-09-28 10:58:01 - app-b: UP
2026-09-28 11:17:31 - app-a: DOWN
2026-09-28 11:17:31 - app-b: UP

## Diagram
             ┌────────────────────┐

Host (me) │ │
localhost:80 ─▶│ nginx │
│ (reverse proxy) │
└─────────┬──────────┘
│
┌────────────┴────────────┐
│ monitoring-net (Docker │
│ bridge network) │
└────────────┬────────────┘
│
┌────────────┴────────────┐
│ │
┌─────▼─────┐ ┌──────▼─────┐
│ app-a │ │ app-b │
│ (port 8000)│ │ (port 8000)│
└────────────┘ └────────────┘


Only nginx is exposed to the host. app-a and app-b are reachable only inside the Docker network, by container name.

## Logging & Permissions

Nginx's access and error logs are written to a host-mounted volume (`./logs:/var/log/nginx` in `docker-compose.yml`), so log data survives container restarts and is directly inspectable from the host without needing `docker exec`.

By default this directory would be created with very permissive access. I deliberately avoided `chmod 777`, since that would let any user or process on the host write into the log directory — nothing needs that except the container itself. The correct restriction is `755` (owner: read/write/execute, everyone else: read/execute only), since only the nginx process needs write access.

In practice, running `chmod 755 logs` from WSL against this project's location (`/mnt/c/...`, a Windows-mounted path) returned `Operation not permitted`. This is because NTFS doesn't have native Unix permission bits, WSL bridges Windows paths into Linux with a fixed permissive default, and that default can't actually be changed from the Linux side since there's no real Unix permission metadata underneath to modify. Running this project from WSL's native Linux filesystem (e.g. `~/` instead of `/mnt/c/...`) would resolve this, since `chmod` operates on genuine ext4 permission bits there.
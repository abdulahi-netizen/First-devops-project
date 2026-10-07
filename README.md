First DevOps Project

This is a small Docker project I built to practise some of the DevOps fundamentals I’ve been learning.

The main things I wanted to practise were:

* Docker and Dockerfiles
* Docker Compose
* Container networking
* Nginx as a reverse proxy
* Bash scripting
* Basic health checking
* Git/GitHub

What the project does

There are three containers:

* app-a – a small Python HTTP server
* app-b – another small Python HTTP server
* nginx – sits in front of the two apps and routes requests to them

The two Python applications both listen on port 8000 inside their containers.

Nginx is the only container exposed to my host machine on port 80.

The idea is:

Browser
   |
   | localhost:80
   v
 Nginx
  /   \
 /     \
app-a  app-b

The containers communicate using a Docker bridge network called monitoring-net.

Project structure

.
├── app-a/
│   ├── Dockerfile
│   └── app.py
├── app-b/
│   ├── Dockerfile
│   └── app.py
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
├── scripts/
│   ├── deploy.sh
│   ├── healthcheck.sh
│   └── healthcheck.log
├── .gitignore
├── docker-compose.yml
└── README.md

Running the project

Clone the repository:

git clone https://github.com/abdulahi-netizen/First-devops-project.git
cd First-devops-project

Then run:

./scripts/deploy.sh

The script builds the images, starts the containers in the background, and checks whether app-a is responding.

You can then test the applications in your browser:

http://localhost/app-a/
http://localhost/app-b/

You should get:

Hello from App A!

and:

Hello from App B!

How the routing works

Nginx listens on port 80.

In the Nginx configuration:

location /app-a/ {
    proxy_pass http://app-a:8000/;
}
location /app-b/ {
    proxy_pass http://app-b:8000/;
}

So when I visit:

http://localhost/app-a/

the request reaches Nginx first.

Nginx then forwards it to:

app-a:8000

The same happens for app-b.

I use the container names instead of IP addresses because Docker provides DNS between containers on the same network.

Docker networking

The three containers are connected to:

monitoring-net

It is a Docker bridge network.

The backend containers don’t have ports published to the host. This means I can’t directly access app-a:8000 or app-b:8000 from my host machine.

Instead, requests go through Nginx.

This gives the project a simple separation between the public-facing container and the backend containers.

Docker Compose

docker-compose.yml defines the three services and the network.

The important part is:

ports:
  - "80:80"

This publishes port 80 on my machine and maps it to port 80 inside the Nginx container.

The two Python applications don’t have a ports section because they only need to be reachable from inside the Docker network.

Health checking

I also created a simple Bash health-check script:

bash scripts/healthcheck.sh

It checks:

http://localhost/app-a/
http://localhost/app-b/

If a service responds successfully, it records it as UP.

If it doesn’t respond successfully, it records it as DOWN.

The results are written to:

scripts/healthcheck.log

The script also returns a non-zero exit code if either application is down.

For example:

2026-09-28 10:58:01 - app-a: UP
2026-09-28 10:58:01 - app-b: UP
2026-09-28 11:17:31 - app-a: DOWN
2026-09-28 11:17:31 - app-b: UP

I kept this script simple because the purpose of the project was to practise Bash and basic service monitoring rather than build a complete monitoring system.

Nginx logs

The Nginx container has this volume:

volumes:
  - ./logs:/var/log/nginx

This maps the logs directory on my machine to Nginx’s log directory inside the container.

This means the logs can be accessed from the host and aren’t lost just because the Nginx container is recreated.

What I learned

This project helped me understand how the different pieces fit together.

The main thing I learned was that containers can communicate with each other using Docker networking without exposing every service directly to the host.

I also got practice with:

* Writing Dockerfiles
* Building images
* Running multiple containers with Compose
* Creating a Docker network
* Using Nginx as a reverse proxy
* Writing Bash scripts
* Checking services with curl
* Working with container logs
* Using Git and GitHub

This is a learning project, so there are things I would improve in a production setup, such as pinning image versions, adding stronger application health checks, and improving the deployment script.

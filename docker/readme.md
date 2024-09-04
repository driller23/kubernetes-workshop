# Docker Basics Course

## 1. Introduction to Docker

**Example:** Show a simple "Hello World" container
```bash
docker run hello-world
```

## 2. Installing Docker 

**Example:** Install Docker on Ubuntu
```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 3. Docker Images 

**Examples:**
```bash
# Pull an image
docker pull nginx

# List images
docker images

# Remove an image
docker rmi nginx
```

## 4. Running Containers 

**Examples:**
```bash
# Run a container
docker run -d --name my-nginx -p 8080:80 nginx

# Stop a container
docker stop my-nginx

# Start a stopped container
docker start my-nginx

# Execute a command in a running container
docker exec -it my-nginx /bin/bash
```

## 5. Dockerfile and Building Images 

**Example:** Create a simple web application image
```Dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
```

Build and run the image:
```bash
docker build -t my-flask-app .
docker run -d -p 5000:5000 my-flask-app
```

## 6. Docker Networking 

**Examples:**
```bash
# Create a network
docker network create my-network

# Run containers on the network
docker run -d --name db --network my-network postgres
docker run -d --name app --network my-network my-flask-app
```

## 7. Docker Volumes 

**Examples:**
```bash
# Create a volume
docker volume create my-data

# Use a volume with a container
docker run -d --name my-app -v my-data:/app/data my-flask-app
```

## 8. Docker Compose 

**Example:** Create a docker-compose.yml for a web app with a database
```yaml
version: '3'
services:
  web:
    build: .
    ports:
      - "5000:5000"
  db:
    image: postgres
    environment:
      POSTGRES_PASSWORD: example
```

Run the multi-container app:
```bash
docker-compose up -d
```

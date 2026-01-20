
## Automated CI/CD Deployment to Docker Swarm on AWS with Terraform & GitHub Actions

### Project Overview
This project demonstrates a complete end-to-end DevOps workflow for deploying containerized applications using Docker Swarm as the orchestration tool on AWS.
Key components:
* Infrastructure as Code (Terraform) to provision two AWS EC2 VMs (one manager, one worker).
* Installation and configuration of Docker + Docker Swarm cluster (1 manager + 1 worker).
* A GitHub Actions CI/CD pipeline that:
* Builds and tests a Docker image on every git push/commit.
* Deploys the image directly to the Docker Swarm cluster via SSH to the manager node.

Architecture Diagram
The high-level architecture includes AWS EC2 instances managed by Terraform, forming a Docker Swarm cluster, with GitHub Actions handling build → test → deploy.
![Architecture Diagram](https://miro.medium.com/v2/resize:fit:1400/1*lO1VLK0GX955GTP4gHxr4g.gif)


### Technologies & Tools Used
* Cloud Provider: AWS (EC2)
* IaC: Terraform (to create VPC, security groups, EC2 instances, etc.)
* Containerization: Docker
* Orchestration: Docker Swarm
* CI/CD: GitHub Actions
* Deployment Method: SSH from GitHub Actions → Manager node → docker stack deploy or docker service create/update
* Git (version control)

### Step-by-Step Implementation
1. Infrastructure Provisioning with Terraform
* Wrote Terraform configuration files (.tf) to:
* Create a VPC (or use default)
* Define security groups (allow SSH port 22, and Swarm ports: 2377/tcp, 7946/tcp+udp, 4789/udp)
* Launch two EC2 instances (e.g., t2.micro or t3.micro, Amazon Linux 2 or Ubuntu)
* Assign public IPs / Elastic IPs if needed
* Use user_data script or provisioners to install Docker on both instances

```
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "swarm_sg" {
  name        = "docker-swarm-sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict in production!
  }
  # ... add other Swarm ports
  egress { ... }
}

resource "aws_instance" "manager" {
  ami           = "ami-0abcdef1234567890"  # Ubuntu
  instance_type = "t3.micro"
  key_name      = "my-key"
  user_data     = file("install-docker.sh")
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]
  # tags, etc.
}
```

*  Run the terraform command
```
 terraform init
terraform plan
terraform apply -auto-approve
```


### Initialize Docker Swarm Cluster
* SSH to manager node: ssh -i key.pem ubuntu@manager-ip
* Initialize: docker swarm init --advertise-addr <manager-public-ip>→ Outputs join token.
* Copy join command.
* SSH to worker → run join
```
docker swarm join --token SWMTKN-1-abc...xyz <manager-ip>:2377
docker node ls
docker  service  ls
```

### Prepare Application & Docker Image
* Write Dockerfile.
* build  the docker image
*  test the  docker image locally 
```
services:
  app:
    image: yourusername/myapp:${TAG:-latest}
    context: /bitcoin-app/ Dockerfile
      replicas: 2
      restart_policy:
        condition: on-failure
    ports:
      - "80:80"
```

### CI/CD Pipeline with GitHub Actions
* create a gitaction workflow  file
* create  docker secrets on  gitaction workflow secret
* create the managed node  ip address to connect to the managed node
* copy the ssh  of the managed node to connect  the managed node
* create the  username of the managed node 
```
name: Build & Deploy to Swarm

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build & Push Image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: yourusername/myapp:latest

      - name: Deploy to Swarm via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.MANAGER_IP }}
          username: ubuntu
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          script: |
            docker service update --image yourusername/myapp:latest myapp_app || \
            docker stack deploy -c stack.yml myapp
```
![connecting  managed node](https://res.cloudinary.com/dthpnue1d/image/upload/v1718018425/image_2_9b35d23de2.png)
      

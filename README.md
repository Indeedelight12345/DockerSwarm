
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

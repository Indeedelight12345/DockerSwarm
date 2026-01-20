
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

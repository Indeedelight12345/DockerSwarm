# AWS Configuration
aws_region = "us-east-1"

# Environment and Project
environment = "dev"
app_name    = "bitcoin-tracking"

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
public_subnet_1_cidr   = "10.0.1.0/24"
public_subnet_2_cidr   = "10.0.2.0/24"

# EC2 Configuration
instance_type  = "t3.micro"
instance_count = 2
instance_name  = "bitcoin-app-vm"
root_volume_size = 20


# Network Access
allowed_ssh_cidr  = "0.0.0.0/0"    # Change to your IP for better security
allowed_http_cidr = "0.0.0.0/0"
allowed_https_cidr = "0.0.0.0/0"

# Monitoring
enable_monitoring = true

# Admin Credentials
admin_username = "adminuser"
admin_password = "admin1234"

# Additional Tags
tags = {
  CreatedBy = "Terraform"
  Project   = "Bitcoin-Tracking-App"
  Owner     = "DevOps-Team"
}

#!/bin/bash

# Function to check if unzip is installed
check_unzip() {
  if ! command -v unzip &> /dev/null; then
    echo "Unzip not found. Installing..."
    sudo apt update
    sudo apt install -y unzip
  else
    echo "Unzip is already installed."
  fi
}

# Function to check if AWS CLI is installed
check_aws_cli() {
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    
    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    
    echo "AWS CLI installed successfully."
  else
    echo "AWS CLI is already installed."
  fi
}

# Function to check if Docker is installed
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo "Docker not found, installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker installed successfully."
  else
    echo "Docker already installed."
  fi
}

# Function to check if Git is installed
check_git() {
  if ! command -v git &> /dev/null; then
    echo "Git not found. Installing..."
    sudo apt update
    sudo apt install git -y
  else
    echo "Git is already installed."
  fi
}

get_api_server_dns() {
  echo "Fetching API Server DNS (Internal Load Balancer)..."
  DNS_BACKEND=$(aws elbv2 describe-load-balancers --names "App-Internal-ALB" --query "LoadBalancers[0].DNSName" --output text)
  
  if [ "$DNS_BACKEND" == "None" ]; then
    echo "Failed to fetch DNS name for the API server. Please check your AWS CLI configuration."
    exit 1
  else
    echo "API Server DNS: $DNS_BACKEND"
  fi
}
# Main Script Execution

echo "Starting setup script..."

# Step 1: Check if AWS CLI, Docker, and Git are installed
check_unzip
check_aws_cli
check_docker
check_git

# Step 2: Clone the GitHub repository
echo "Cloning the repository..."
sudo git clone https://github.com/uzairgabol/aws-3tier-application.git

# Step 3: Navigate to the `app-tier-python` directory
cd aws-3tier-application/web-tier || { echo "Directory not found! Exiting."; exit 1; }

get_api_server_dns
# Step 4: Build the Docker container using the DB Endpoint as a build argument
echo "Building Docker image..."
sudo docker build -t aws-web-tier .

# Step 5: Run the Docker container on port 80
echo "Running Docker container..."
sudo docker run -e API_URL=$DNS_BACKEND -p 80:80 --restart always -d aws-web-tier

echo "Script execution complete."

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

check_mysql_client() {
  if ! command -v mysql &> /dev/null; then
    echo "MySQL client not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y mysql-client
  else
    echo "MySQL client is already installed."
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

# Function to fetch RDS DB Endpoint
get_rds_db_endpoint() {
  echo "Fetching RDS DB Endpoint..."
  DB_ENDPOINT=$(aws rds describe-db-instances --query "DBInstances[0].Endpoint.Address" --output text)
  
  if [ "$DB_ENDPOINT" == "None" ]; then
    echo "Failed to fetch DB endpoint. Please check your AWS CLI configuration."
    exit 1
  else
    echo "DB Endpoint: $DB_ENDPOINT"
  fi
}

# Function to connect to MySQL, create a database, table, and insert data
setup_mysql_db() {
  DB_PASSWORD="test1234"  # Replace with your actual DB password
  
  echo "Connecting to MySQL database..."

  # Connect to MySQL and create the database/table, and insert data
  mysql -h $DB_ENDPOINT -u admin -p$DB_PASSWORD << EOF
CREATE DATABASE IF NOT EXISTS webappdb;
USE webappdb;

CREATE TABLE IF NOT EXISTS transactions (
  id INT NOT NULL AUTO_INCREMENT,
  amount DECIMAL(10,2),
  description VARCHAR(100),
  PRIMARY KEY(id)
);

INSERT INTO transactions (amount, description) VALUES ('400', 'groceries');
SELECT * FROM transactions;
EOF
}

# Main Script Execution

echo "Starting setup script..."

# Step 1: Check if AWS CLI, Docker, and Git are installed
check_unzip
check_aws_cli
check_docker
check_git
check_mysql_client

# Step 2: Clone the GitHub repository
echo "Cloning the repository..."
git clone https://github.com/uzairgabol/aws-3tier-application.git

# Step 3: Navigate to the `app-tier-python` directory
cd aws-3tier-application/app-tier-python || { echo "Directory not found! Exiting."; exit 1; }

# Step 4: Fetch RDS DB Endpoint
get_rds_db_endpoint

# Step 5: Setup MySQL DB and insert data
setup_mysql_db

# Step 6: Build the Docker container using the DB Endpoint as a build argument
echo "Building Docker image..."
sudo docker build \
  --build-arg DB_HOST=$DB_ENDPOINT \
  --build-arg DB_USER="admin" \
  --build-arg DB_PWD="test1234" \
  --build-arg DB_DATABASE="webappdb" \
  -t aws-app-tier .

# Step 7: Run the Docker container on port 4000
echo "Running Docker container..."
sudo docker run -p 4000:4000 --restart always -d aws-app-tier

echo "Script execution complete."

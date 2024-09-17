#!/bin/bash

BLUE='\033[1;34m'
NC='\033[0m'

function show() {
    echo -e "${BLUE}$1${NC}"
}

# Load variables from .env file
if [ -f ".env" ]; then
    show "Loading environment variables from .env file..."
    export $(grep -v '^#' .env | xargs)
else
    show ".env file not found. Please ensure it exists in the current directory."
    exit 1
fi

if ! command -v curl &> /dev/null
then
    show "curl not found. Installing curl..."
    sudo apt update && sudo apt install -y curl
else
    show "curl is already installed."
fi
echo

if ! command -v docker &> /dev/null
then
    show "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
else
    show "Docker is already installed."
fi
echo

# Verify that environment variables have been loaded correctly
if [[ -z "$PRIV_KEY" || -z "$MAINNET_WSS" || -z "$MAINNET_HTTP" || -z "$SEPOLIA_WSS" || -z "$SEPOLIA_HTTP" ]]; then
    show "One or more required environment variables are missing. Please check the .env file."
    exit 1
fi


sudo sysctl vm.overcommit_memory=1
echo
show "Starting Docker containers using docker-compose(may take 5-10 mins)..."
echo
sudo docker compose up -d

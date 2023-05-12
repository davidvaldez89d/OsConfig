#!/bin/bash

# Author: David Valdez
# Date: 12/05/2023
# Description: This script installs the tools and dependencies needed for the Roots Academy.


# Define variables
PYTHON_VERSION=3.10
DATAROOTS_FOLDER=~/DataRoots/RootsAcademy
GIT_USER_NAME="David"
GIT_USER_EMAIL="david@dataroots.io"


# Define packages
BREW_PACKAGES=(
    python@$PYTHON_VERSION
    bash
    zsh
    poetry
    git
    openjdk
    scala
    apache-spark
    tfenv
    kubernetes-cli
    awscli
    azure-cli
    azcopy
)

BREW_CASK_PACKAGES=(
    google-chrome
    slack
    visual-studio-code
    docker
    azure-data-studio
    microsoft-azure-storage-explorer
)

PIP_PACKAGES=(
    black
    flake8
)


# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script can only be run on macOS."
    exit 1
fi


# Upgrade pip
echo "Upgrading pip..."
python3 -m pip install --upgrade pip


# Create DataRoots folder
mkdir -p $DATAROOTS_FOLDER


# Install Homebrew if not installed
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# Install tools and dependencies
echo "Installing tools and dependencies..."
echo "Installing brew packages..."
for package in "${BREW_PACKAGES[@]}"; do
    if ! brew list "$package" > /dev/null; then
        brew install "$package"
    fi
done

echo "Installing brew cask packages..."
for package in "${BREW_CASK_PACKAGES[@]}"; do
    if ! brew list --cask "$package" > /dev/null; then
        brew install --cask --no-quarantine "$package"
    fi
done

echo "Installing pip packages..."
for package in "${PIP_PACKAGES[@]}"; do
    if ! python3 -m pip list --format=columns | grep "$package" > /dev/null; then
        python3 -m pip install "$package"
    fi
done


# Install JupyterHub and JupyterLab
echo "Installing JupyterHub, JupyterLab, and Configurable HTTP Proxy..."
sudo apt-get install nodejs npm
python3 -m pip install jupyterhub
npm install -g configurable-http-proxy
python3 -m pip install jupyterlab notebook  # needed if running the notebook servers in the same environment


# Configure Git
echo "Configuring Git..."
git config --global user.name $GIT_USER_NAME
git config --global user.email $GIT_USER_EMAIL
git config --global color.ui true
# Gerenate ssh key
ssh-keygen -t rsa -C $GIT_USER_EMAIL
# Save ssh key
echo "$(cat ~/.ssh/id_rsa.pub)" >> ~/.ssh/ssh.txt


# Configure Docker
echo "Configuring Docker..."
echo "Configuring global user in Docker..."
docker run hello-world
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "userns-remap": "default"
}
EOF
sudo systemctl restart docker


# Verify installation
echo "Verifying installation..."

# Verify Homebrew packages
echo "Verifying Homebrew packages..."
for package in "${BREW_PACKAGES[@]}"; do
    if ! brew list "$package" > /dev/null; then
        echo "$package is not installed"
    else
        echo "$package is installed"
    fi
done

# Verify Homebrew cask packages
echo "Verifying Homebrew cask packages..."
for package in "${BREW_CASK_PACKAGES[@]}"; do
    if ! brew list --cask "$package" > /dev/null; then
        echo "$package is not installed"
    else
        echo "$package is installed"
    fi
done

# Verify pip packages
echo "Verifying pip packages..."
for package in "${PIP_PACKAGES[@]}"; do
    if ! python3 -m pip list --format=columns | grep "$package" > /dev/null; then
        echo "$package is not installed"
    else
        echo "$package is installed"
    fi
done

# Verify JupyterHub and Configurable HTTP Proxy
echo "Verifying JupyterHub and Configurable HTTP Proxy..."
jupyterhub -h
configurable-http-proxy -h

# Verify Git configuration
echo "Verifying Git configuration..."
echo "User name: $(git config --global user.name)"
echo "User email: $(git config --global user.email)"

# Verify Docker configuration
echo "Verifying Docker configuration..."
docker ps


# Clean up installation files
echo "Cleaning up installation files..."
brew cleanup


# Done
echo "Done with MacConfig, enjoy!"
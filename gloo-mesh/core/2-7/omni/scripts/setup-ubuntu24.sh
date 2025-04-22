#!/bin/bash


# Terminal color codes.
REDB="\033[1;31m"
WHITEB="\033[1;37m"
GREENB="\033[1;32m"
CLR="\033[0m"

# If the NO_COLOR environment variable exists, disable console colors.
if [[ ! -z "${NO_COLOR}" ]]; then
    echo "Disabling console colors because the NO_COLOR environment variable is set."
    REDB=""
    WHITEB=""
    GREENB=""
    CLR=""
fi

# Ensure that the host platform is Ubuntu 24.04.
if ! grep "PRETTY_NAME=\"Ubuntu 24\." /etc/os-release > /dev/null; then
    echo -e "${REDB}ERROR: this script is designed to work on Ubuntu 24.04 only.${CLR}"
    exit -1
fi

# Ensure that we are running as root.
if [[ $(whoami) != "root" ]]; then
    echo -e "${REDB}ERROR: this script must be run as root.${CLR}"
    exit -1
fi

# Fully update the host system.
echo -e "${WHITEB}Updating system...${CLR}\n"
apt update
apt dist-upgrade -y

# Install Docker, Go command, and step.
echo -e "\n\n${WHITEB}Installing Docker, Go command, and step...${CLR}\n"
apt install docker.io golang-go step -y

# Remove setup packages.
apt clean

# Install kind.
echo -e "\n\n${WHITEB}Installing latest version of kind...${CLR}\n"
go install sigs.k8s.io/kind@latest

# Copy the kind command to /usr/local/bin.
cp /root/go/bin/kind /usr/local/bin/kind

# Install kubectl.
echo -e "\n\n${WHITEB}Installing kubectl...${CLR}\n"
snap install kubectl --classic

# Install helm.  We can't install the latest version, because of this issue: https://github.com/solo-io/workshops/issues/283
echo -e "\n\n${WHITEB}Installing helm...${CLR}\n"

# Create a safe working directory and make it our current directory.
temp_dir=$(mktemp -d)
pushd ${temp_dir} > /dev/null

# Get the latest working version of Helm for this application.
wget -O helm.tar.gz https://get.helm.sh/helm-v3.17.2-linux-amd64.tar.gz

# Check its sha256 hash.
expected_hash="90c28792a1eb5fb0b50028e39ebf826531ebfcf73f599050dbd79bab2f277241"
actual_hash=$(sha256sum ${temp_dir}/helm.tar.gz | cut -f1 -d" ")
if [[ $actual_hash != $expected_hash ]]; then
    echo -e "${REDB}Error: sha256sum of ${temp_dir}/helm.tar.gz is ${actual_hash} instead of ${expected_hash}${CLR}"
    exit -1
fi

# Uncompress the archive and install it into /usr/local/bin.
tar xvzf helm.tar.gz
install -m 0755 -o root -g root linux-amd64/helm /usr/local/bin

# Restore our original working directory.
popd > /dev/null

# Remove the working directory.
rm -rf ${temp_dir}

echo -e "\n\n${GREENB}Done!${CLR}\n"
exit 0

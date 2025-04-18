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

# Install Docker and Go command.
echo -e "\n\n${WHITEB}Installing Docker and Go command...${CLR}\n"
apt install docker.io golang-go -y

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
snap install helm --classic --channel=3.7/stable

echo -e "\n\n${GREENB}Done!${CLR}\n"
exit 0

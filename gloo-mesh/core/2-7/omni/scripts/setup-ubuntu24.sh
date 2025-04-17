#!/bin/bash


# Terminal color codes.
REDB="\033[1;31m"
WHITEB="\033[1;37m"
CLR="\033[0m"

# If the NO_COLOR environment variable exists, disable console colors.
if [[ ! -z "${NO_COLOR}" ]]; then
    echo "Disabling console colors because the NO_COLOR environment variable is set."
    REDB=""
    WHITEB=""
    CLR=""
fi

# Ensure that the host platform is Ubuntu 24.04.
if ! grep "PRETTY_NAME=\"Ubuntu 24\." /etc/os-release; then
    echo -e "${REDB}ERROR: this script is designed to work on Ubuntu 24.04 only.${CLR}"
    exit -1
fi

# Ensure that we are running as root.
if [[ $(whoami) != "root" ]]; then
    echo -e "${REDB}ERROR: this script must be run as root.${CLR}"
    exit -1
fi

# Fully update the host system.
echo -e "\n${WHITEB}Updating system...${CLR}\n"
apt update
apt dist-upgrade -y

# Install Docker and Go command.
echo -e "\n${WHITEB}Installing Docker and Go command...${CLR}\n"
apt install docker.io golang-go -y

# Install kind.
echo -e "\n${WHITEB}Installing latest version of kind...${CLR}\n"
go install sigs.k8s.io/kind@latest

# The kind command ends up here.
export PATH=/root/go/bin:$PATH

# Install kubectl.
snap install kubectl --classic

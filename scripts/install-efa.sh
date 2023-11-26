#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

# Configure multi-card interfaces
yum install -y pciutils

mkdir -p /etc/eks/efa
sudo mv "${WORKING_DIR}/configure-multicard-interfaces.service" /etc/systemd/system/configure-multicard-interfaces.service
sudo mv "${WORKING_DIR}/configure-multicard-interfaces.sh" /etc/eks/efa/configure-multicard-interfaces.sh
sudo chmod +x /etc/eks/efa/configure-multicard-interfaces.sh
sudo systemctl enable configure-multicard-interfaces

# EFA installation instructions https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start.html#efa-start-enable
EFA_INSTALLER_VERSION='1.29.0'
EFA_INSTALLER_PACKAGE="aws-efa-installer-${EFA_INSTALLER_VERSION}.tar.gz"

mkdir -p /tmp/efa-installer
cd /tmp/efa-installer

# Download package, key, and signature
curl -O https://efa-installer.amazonaws.com/${EFA_INSTALLER_PACKAGE}
curl -O https://efa-installer.amazonaws.com/aws-efa-installer.key && gpg --import aws-efa-installer.key
curl -O https://efa-installer.amazonaws.com/${EFA_INSTALLER_PACKAGE}.sig
if ! gpg --verify ./${EFA_INSTALLER_PACKAGE}.sig &> siginfo ;then
    echo "EFA Installer signature failed verification!"
    exit 2
fi

# Extract and install
tar -xf ${EFA_INSTALLER_PACKAGE}
cd aws-efa-installer && ./efa_installer.sh --enable-gdr --minimal --yes

# Clean-up
cd -
rm -rf /tmp/efa-installer

# Limit deeper C-states https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/processor_state_control.html#c-states
grubby --update-kernel=ALL --args="intel_idle.max_cstate=1 processor.max_cstate=1"
reboot

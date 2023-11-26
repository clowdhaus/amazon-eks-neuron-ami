#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

tee /etc/yum.repos.d/neuron.repo > /dev/null <<EOF
[neuron]
name=Neuron YUM Repository
baseurl=https://yum.repos.neuron.amazonaws.com
enabled=1
metadata_expire=0
EOF
rpm --import https://yum.repos.neuron.amazonaws.com/GPG-PUB-KEY-AMAZON-AWS-NEURON.PUB

# Update OS packages
yum update -y

# Remove preinstalled packages
yum remove aws-neuron-dkms \
  aws-neuronx-dkms \
  aws-neuronx-oci-hook \
  aws-neuronx-runtime-lib \
  aws-neuronx-collectives \
  aws-neuron-tools \
  aws-neuronx-tools -y

# Install Neuron Driver and tools
yum install aws-neuronx-dkms-2.* \
  aws-neuronx-tools-2.*  -y

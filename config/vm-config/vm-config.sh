#!/bin/bash

set -e

# -------------
# HTCondor v8.8
# -------------

# Install HTCondor
wget -qO - "https://research.cs.wisc.edu/htcondor/ubuntu/HTCondor-Release.gpg.key" | sudo apt-key add - 
sudo bash -c 'echo "deb     http://research.cs.wisc.edu/htcondor/repo/ubuntu/8.8 bionic main" > /etc/apt/sources.list.d/htcondor.list'
sudo apt-get update 
sudo apt-get install htcondor=8.8.* -y

# Configure HTCondor v8.8

# Submit machine
sudo sh -c 'echo "use ROLE: Submit" > /etc/condor/config.d/51-role-submit'

# Execute machine
sudo sh -c 'echo "use ROLE: Execute" > /etc/condor/config.d/51-role-exec'

# Central Manager machine
sudo sh -c 'echo "use ROLE: CentralManager" > /etc/condor/config.d/51-role-cm'

# Do not change this
sudo bash -c 'cat > /etc/condor/config.d/01-common.conf' <<EOF
CONDOR_HOST=$1
TCP_FORWARDING_HOST=$1
ALLOW_WRITE=*
EOF

# Your configuration goes here
sudo bash -c 'cat > /etc/condor/config.d/02-cm.conf' <<EOT

EOT

# Start HTCondor services v8.8
sudo systemctl enable condor
sudo systemctl start condor

# -------
# Pegasus
# -------

# Install Pegasus

# Download and install the repository key
wget -O - http://download.pegasus.isi.edu/pegasus/gpg.txt | sudo apt-key add - 

# Create repository file, update, and install Pegasus
echo 'deb [arch=amd64] http://download.pegasus.isi.edu/pegasus/ubuntu bionic main' | sudo tee /etc/apt/sources.list.d/pegasus.list
sudo apt-get update
sudo apt-get install pegasus -y

# --------
# Firewall
# --------

# Do not change this
sudo ufw allow 9618

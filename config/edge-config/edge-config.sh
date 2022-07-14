#!/bin/bash

# Configure HTCondor Execute Node
apt-get install sudo -y
sudo sh -c 'echo "use ROLE: Execute" > /etc/condor/config.d/51-role-exec' 

# Do not change this
cat > /etc/condor/config.d/01-common.conf <<EOF
CCB_ADDRESS = \$(COLLECTOR_HOST)
PRIVATE_NETWORK_NAME = \$(COLLECTOR_HOST)

DC_ID = "dc-1"
STARTD_ATTRS = $(STARTD_ATTRS) DC_ID
EOF

# Your configuration goes here
cat > /etc/condor/config.d/02-edge.conf <<EOF
CONDOR_HOST=$1
EOF

# Do not change this
condor_reconfig

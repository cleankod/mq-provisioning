#!/bin/bash

# Solves the problem with the
# "AMQ6024: Insufficient resources are available to complete a system request."
# error message:
sysctl -w kernel.shmmax=73834496

# Proxy (in this case cntlm on host machine):
echo 'export http_proxy=http://10.0.2.2:3128' > /etc/profile.d/proxy.sh
chmod +x /etc/profile.d/proxy.sh

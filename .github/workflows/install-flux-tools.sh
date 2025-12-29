#! /bin/bash -e

curl -s https://fluxcd.io/install.sh | sudo bash

curl -Lo /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v3.8.0/sops-v3.8.0.linux.amd64
chmod +x /usr/local/bin/sops

apt install -y age


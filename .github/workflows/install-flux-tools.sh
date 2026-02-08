#! /bin/bash -e

curl -s https://fluxcd.io/install.sh | sudo bash

curl -Lo /usr/local/bin/sops https://github.com/getsops/sops/releases/download/v3.8.0/sops-v3.8.0.linux.amd64
chmod +x /usr/local/bin/sops

apt install -y age

curl --location -s https://github.com/smallstep/cli/releases/download/v0.24.4/step_linux_0.24.4_amd64.tar.gz | tar  -xzf - step_0.24.4/bin/step
mv step_0.24.4/bin/step /usr/local/bin
chmod +x /usr/local/bin/step

curl --location -s https://github.com/mikefarah/yq/releases/download/v4.34.1/yq_linux_amd64.tar.gz  |\
  tar xz ./yq_linux_amd64 && mv ./yq_linux_amd64 /usr/bin/yq && chmod +x /usr/bin/yq

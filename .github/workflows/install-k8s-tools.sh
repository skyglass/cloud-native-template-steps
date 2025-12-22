#! /bin/bash -e

curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

curl https://get.helm.sh/helm-v3.10.2-linux-amd64.tar.gz | tar xfz -
cp linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm            

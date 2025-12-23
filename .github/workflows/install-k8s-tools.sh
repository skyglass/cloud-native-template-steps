#! /bin/bash -e

curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

curl https://get.helm.sh/helm-v3.15.2-linux-amd64.tar.gz | tar xfz -
cp linux-amd64/helm /usr/local/bin/helm
chmod +x /usr/local/bin/helm            

curl -s --location https://github.com/yannh/kubeconform/releases/download/v0.6.6/kubeconform-linux-amd64.tar.gz | tar -C /usr/local/bin -z -xf - kubeconform
chmod +x /usr/local/bin/kubeconform

curl -SsL https://packages.httpie.io/deb/KEY.gpg | apt-key add -
curl -SsL -o /etc/apt/sources.list.d/httpie.list https://packages.httpie.io/deb/httpie.list
apt update
apt install httpie

apt-get install jq


#!/usr/bin/env bash

green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

step() {
    echo "${yellow}[STEP] $1${reset}"
}

ok() {
    echo "${green}[OK] $1${reset}"
}

# save the locally published katana-kubernetes image
step "Saving katana-kubernetes to katana-kubernetes.tar."
docker save magneticio/vamp:katana-kubernetes > katana-kubernetes.tar

step "Retrieving minikube ip."
MINIKUBE_IP=$(minikube ip)
ok "Found minikube ip address: $MINIKUBE_IP."

# copy the katana-kubernetes.tar to minikube
step "Copying katana-kubernetes.tar to minikube virtual machine."
scp -i ~/.minikube/machines/minikube/id_rsa katana-kubernetes.tar \
  docker@$MINIKUBE_IP:~/

# load the katana-kubernetes.tar in the minikube local docker
step "Loading katana-kubernetes.tar into minikube docker."
ssh -t -i ~/.minikube/machines/minikube/id_rsa docker@$MINIKUBE_IP \                     \
  "docker load -i katana-kubernetes.tar"

ok "Finished loading magnetnicio/vamp:katana-kubernetes to minikube."

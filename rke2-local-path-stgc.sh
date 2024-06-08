#!/bin/bash
set -e
shopt -s expand_aliases
if [ $(whoami) != "root" ] ; then exit 1 ; fi
alias kubectl='/var/lib/rancher/rke2/bin/kubectl'
cat > /root/cluster.yaml <<-EOF
nodes:
- address: 127.0.0.1
  port: "22"
  role:
  - controlplane
  - worker
  - etcd
  user: root
  ssh_key_path: /root/.ssh/rke-key
EOF
ssh-keygen -t ed25519 -b 8192 -f /root/.ssh/rke-key -C "rke-key" -N ""
cat /root/.ssh/rke-key.pub >> /root/.ssh/authorized_keys
ssh -o StrictHostKeyChecking=no root@127.0.0.1 -i /root/.ssh/rke-key "echo 'test access'"
curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION='v1.28.9+rke2r1' sh -
systemctl daemon-reload
systemctl enable --now rke2-server.service
install -Dm600 /etc/rancher/rke2/rke2.yaml /root/.kube/config
curl -L https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.27/deploy/local-path-storage.yaml -o /root/local-path-storage.yaml
sed -i "s/reclaimPolicy: Delete/reclaimPolicy: Retain/g" /root/local-path-storage.yaml
kubectl apply -f /root/local-path-storage.yaml
kubectl get pods -A --watch

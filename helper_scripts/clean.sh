#!/usr/bin/env bash
# 2nd step (wait a bit after 1st): taint/label nodes and delete traefik preinstalled
# Due to hte fact that k3d is bugged and it can't be setup normally otherwise

# IMPORTANT: Makes sure the ingress controller containers can go somewhere
kubectl label nodes k3d-k3s-default-worker-0 type=entry
kubectl label node k3d-k3s-default-server node-role.kubernetes.io/master=true
kubectl taint nodes k3d-k3s-default-server node-role.kubernetes.io/master=:NoSchedule


kubectl delete service traefik --namespace=kube-system
kubectl delete deploy traefik --namespace=kube-system
# Remove leftover helm pod
kubectl get pods --all-namespaces | grep Completed |  awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod
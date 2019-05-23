#!/usr/bin/env bash

# IMPORTANT: Makes sure the ingress controller containers can go somewhere
kubectl label nodes k3d-k3s-default-worker-0 type=entry

kubectl delete service traefik --namespace=kube-system
kubectl delete deploy traefik --namespace=kube-system
# Remove leftover helm pod
kubectl get pods --all-namespaces | grep Completed |  awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod
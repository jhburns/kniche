#!/usr/bin/env bash
kubectl delete service traefik --namespace=kube-system
kubectl delete deploy traefik --namespace=kube-system
# Remove leftover helm pod
kubectl get pods --all-namespaces | grep Completed |  awk '{print $2 " --namespace=" $1}' | xargs kubectl delete pod
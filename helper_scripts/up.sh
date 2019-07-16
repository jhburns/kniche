#!/usr/bin/env bash
# 3rd step: install resources and add password secret to each namespace after

linkerd install | kubectl apply -f -
linkerd check
linkerd inject ../kube-resources | kubectl apply -f -

kubectl create secret generic mysecret --from-file ../secrets/auth --namespace=whoami
kubectl create secret generic mysecret --from-file ../secrets/auth --namespace=kube-system
kubectl create secret generic mysecret --from-file ../secrets/auth --namespace=linkerd
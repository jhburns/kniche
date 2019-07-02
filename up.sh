#!/usr/bin/env bash

linkerd install | kubectl apply -f -
linkerd check

kubectl apply -f linkerd/
linkerd inject kube-config/ | kubectl apply -f -
kubectl apply -f no-inject/

kubectl create secret generic mysecret --from-file ./secrets/auth --namespace=whoami
kubectl create secret generic mysecret --from-file ./secrets/auth --namespace=kube-system
kubectl create secret generic mysecret --from-file ./secrets/auth --namespace=linkerd
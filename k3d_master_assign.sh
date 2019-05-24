#!/usr/bin/env bash
kubectl label node k3d-k3s-default-server node-role.kubernetes.io/master=true
kubectl taint nodes k3d-k3s-default-server node-role.kubernetes.io/master=:NoSchedule

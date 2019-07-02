#!/usr/bin/env bash

k3d delete
k3d create --api-port 6551 --publish 8282:30666 --workers 3
sleep 2 # Waits 0.5 second.

# Have to wait until the server is ready, so this part retires until the config is outputted
while [ 1 ]
do
  k3d get-kubeconfig && break
  sleep 0.1 # Wait until retry
done

# Sets both bash and fish var
export KUBECONFIG=/home/hat/.config/k3d/k3s-default/kubeconfig.yaml
echo "set -Ux KUBECONFIG /home/hat/.config/k3d/k3s-default/kubeconfig.yaml" | fish




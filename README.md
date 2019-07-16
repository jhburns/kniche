# Kniche

Create a lightweight, but capable kubernetes cluster using [k3s](https://k3s.io/).
Tested on only $5/month virtual private servers (from [Vultr](https://www.vultr.com/)) meaning a very inexpensive cluster and comes with these features:

- [Traefik](https://traefik.io/) ingress controller for easy, fast pathing to each service. 
  Additionally Traefik secures the cluster with free Let's Encrypt certificated, setting up https automatically.
- Read-Only kubernetes web dashboard like `kubectl`, but available to anyone. Useful to show-off the cluster's internals or monitor resources from anywhere.
- [Linkerd2](https://linkerd.io/2/overview/) service mesh installed, providing feautes like security, and observability.
- Automated deployment to Vultr, using Ansible + Packer + Terraform to create immutable infrastructure.

## Setup Locally

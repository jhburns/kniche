# Kniche

Create a lightweight, but capable kubernetes cluster using [k3s](https://k3s.io/).
Tested on only $5/month virtual private servers (from [Vultr](https://www.vultr.com/)) and comes with these features:

- [Traefik](https://traefik.io/) ingress controller for easy, fast pathing to each service. 
  Additionally, Traefik secures the cluster with free Let's Encrypt certificates, setting up https automatically.
- Read-Only Kubernetes web dashboard, like `kubectl` but available to anyone. Useful to show-off the cluster's internals or monitor resources from anywhere.
- [Linkerd2](https://linkerd.io/2/overview/) service mesh installed, providing features like security, and observability.
- Automated deployment to Vultr, using Ansible + Packer + Terraform to create immutable infrastructure.

(Keep in mind Kniche is primarily supported on Linux for now, although other operating systems may work, and early in development)

## Setup Locally

First fork, then clone this repository locally.

Kniche is designed to run efficiently locally too, so install [Docker](https://docs.docker.com/install/) then [k3d](https://github.com/rancher/k3d). 
k3d is service that helps run k3s in Docker, like [kind](https://github.com/kubernetes-sigs/kind) for normal Kubernetes.
Also, [install Linkerd2](https://linkerd.io/2/getting-started/).

After installation, if you're on Linux/MacOS the scripts in *helper_scripts/* 
can help you get setup with a little modification. They work as follows:
1. *reinstall.sh*: Deletes the current cluster, creates a new one, and sets `$KUBECONFIG`.
  Change the paths at the bottom/shells to match your environment. 
1. *clean.sh*: Labels/Taints nodes as needed and deletes Traefik stuff that isn't needed. Run this command a bit after
*reinstall.sh* to give the installation a bit of time to complete.
1. *up.sh*: Installs Linkerd, then injects proxies into every resource inside *kube-resources/*. Will error if the next step isn't done. 

### Generate Credentials 

Traefik expects a Kubernetes secret for the admin endpoints, in [basic authentication](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication) format.
You can do so using `htpasswd` which may need to be installed:
1. `mkdir secrects` from the root of this project.
1. Run `htpasswd -cB ./secrets/auth [username]`.
1. Input a password when prompted.
1. Run *helper_scripts/up.sh* to add the *auth* file to each namespace.

### Verify

The command `kubectl get pods -A` should return with all pods `Ready` if everything is successfully installed.


### Strip Specific Configs

The cluster will be accessible from `https://localhost:8282`, but for now will try to redirect to
`https://localhost/` and error with `ERR_CONNECTION_REFUSED`. This is due to production arguments being
used by Traefik, swap them in the file *kube-resources/ingress-traefik.yaml* like so:
```$xslt
      - args:
        #- "--entrypoints=Name:http Address::80 Redirect.EntryPoint:https"
        - "--entrypoints=Name:http Address::80" #no redirect for local testing
```
And change Traefik to use ACME staging, to prevent being rate limited, by uncommenting:
```$xslt
        - "--acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
```

None `localhost:8282` should only 404, not error. That is caused by my specific url being the host in each ingress resource.
That can be changed replacing with `localhost`:
```
spec:
  rules:
  - host: localhost
    http:
      paths:
      - path: /whoami
        backend:
          serviceName: whoami-service
          servicePort: http
```
to (for each ingress)
```
spec:
  rules:
  - host: localhost
    http:
      paths:
      - path: /whoami
        backend:
          serviceName: whoami-service
          servicePort: http
```

(kustomize is planned to solve all this manual replacement, but for now I've tried to make everything as general as possible besides these exceptions)

### End Goal

Check out `http://localhost:8282/traefik` if everything is functional to see all the neat paths to check out.
Congrats you've got local development setup! 🎉

## Setup on Vultr

This section is Linux only for now, although a Linux virtual machine or container could be potentially used.
First head over to your Vultr account and acquire an API token under Account > API.

### Install everything
There are a lot of dependencies needed, and this project ships with multiple binaries due to the
difficulty of having to build them from source each time.

First install these locally, version number is confirmed to work:
- [Terraform (v0.11.1)](https://releases.hashicorp.com/terraform/0.11.1/terraform_0.11.1_linux_amd64.zip)
- [Ansible (v2.8.2)](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

Next unzip all the tar files in *vultr/custom_binaries/*. They need to go in the following locations:
- *packer_binary.tgz* to *vultr/packer* or else relative links won't work.
- *terraform-provider-vplus.tgz* and *terraform-provider-vultr.tgz* to *.terraform.d/plugins/*, see https://www.terraform.io/docs/plugins/basics.html

#### Explanation
Reason Kniche has custom binaries is that the Packer Vultr plugin https://github.com/dradtke/packer-builder-vultr lacks any releases.
Additionally, the Terraform Vultr provider used https://github.com/squat/terraform-provider-vultr doesn't have
reserved ips as a data source. I took the time to create my a custom provider (source in *vultr/custom_provider/*)
that gets reserved ips as a data source. The main provider also needs a patch to use the data though, so the file
in *vultr/custom_provider/patches* has to be copied over before compiling a new version of it. Therefore, the need
for all three binaries.

### Revert Configurations

If you changed anything in the previous "Strip Specific Configs" step, make sure to change Traefik's args back 
when heading into production. Also, substitute your host url for each ingress.  

### Build

To build and snapshot a cluster of three VMs, run `./packer build -var vultr_api_key=[Your API Key] build.json` in the `vultr/` folder.
Building is actually handled asynchronously across all three hosts, and uses the untracked *secrets/* 
folder to pass messages. If a build fails, make sure *secrets/build_output.json* is deleted before retrying.

When building the ssh keys used to access each node can be saved externally though Vultr's portal, or else
they will be lost when restoring the snapshot. The process is pretty slow so don't rush. A successful set of builds
will be pretty evident.

### Customize Terraform

These modifications are recommended for *vultr/provision.tf* 

The `vplus_reserved_ip` data resource can be removed, if DNS isn't handled by having records pointing
at a permanently reserved IP. I choose to setup my domain's DNS to point at a reserved IP so its possible
to destroy/create clusters at will without waiting for DNS to propagate.

Change the plan/region for Vultr if wanted.

### Provision servers

Finally, the command `VULTR_API_KEY=[Your API Key] terraform apply -auto-approve` will setup your cluster if everything goes well.
(Note: due to IP changes nodes may have to be manually rejoined. Deleting the master server and retrying can also work but is even more hacky)

`VULTR_API_KEY=[Your API Key] terraform destroy -force` naturally brings the cluster down.

## Misc

A decent amount of Kniche is still under developed, and there are a decent number of limitations 
due to using many new technologies and a cumbersome hosting platform. I'd like to document some of the
more interesting choices/issues, feedback is welcome or open a PR.

### SSH Optional Firewall

When provisioning with Terraform four different firewalls are created, extra for ssh. Because
ssh access to production is controversial I decided to allow either, but at the networking level.
They can be chosen when provisioning or afterwards through the Vultr portal. 

### Haproxy

Haproxy is included as part of the deployment install, due to the fact that Kubernetes doesn't allow pods to
be directly exposed on ports :80 or :443. The only to expose a service are ClusterIP (only internal), NodePort (high range of port ~30000),
or LoadBalancer (Needs an external service). Because LoadBalancers are expensive I chose to use two NodePorts on Traefik 
and proxy to them using Haproxy. Haproxy only is used as a passthough proxy.

###  Linkerd on a Subdomain

Unlike other paths, its `linkerd.localhost:8282` instead of `localhost:8282/linkerd/`. This is due
to the fact that Linkerd's dashboard doesn't use relative pathing for requesting the server. Hopefully
this will change as Linkerd develops.

### Traefik Running One Replica

Traefik would be running with multiple pods, but there is currently a bug preventing that from
working. Let's Encrypt requires a backend to store certificates in, but doing so causes the TLS
challenge to fail. There is an open issue to fix this bug, and the *.WIP/* folder contains
resources needed by Traefik in high availability mode for when that gets fixed.

## Wrapping Up

Goal of Kniche is to use k3s in a substantial way. I've felt that Kubernetes isn't
covered practically online and full deployments rare. There are too many tutorials
that go `helm install blah` and not enough of the gritty details. So I decided to
create this, hopefully as something good enough to grow from. 🌱  

I developed all this mainly as a learning experience, so I would recommend using it for anything serious.
Although most parts are decently developed, plenty can be done to tighten up security, document, add features,
fix, etc. 

I'm open to suggestions, just open up a Pull Request.


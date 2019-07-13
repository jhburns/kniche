## Todo

1. Ansible automatic build/deploy
    - terraform env  
    - Clustering
    - install linkerd/k3s for each
1. Basic app at root
    - steal matteos?
1. kustomize templating
1. Documentation
1. Docker install bundler

# Notepad

kubectl get pod -o=custom-columns=NODE:.spec.nodeName,NAME:.metadata.name --all-namespaces

> The best command in existence

>>>> Don't forget to issue a new API key
## Todo

- Lets encrypt automatic SSL
- Basic app at root
- kustomize templating
- Terraform + packer + ansible automatic build/deploy
- Documentation
- CPU/Memory usage*


# Notepad

kubectl -n linkerd port-forward (kubectl -n linkerd get pod -l app=l5d -o jsonpath='{.items[0].metadata.name}') 9990

> The best command in existence
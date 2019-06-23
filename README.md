# kniche-infrastructure
TODO

### Connect to linkerd (temp) -> localhost:9990
`kubectl -n linkerd port-forward (kubectl -n linkerd get pod -l app=l5d -o jsonpath='{.items[0].metadata.name}') 9990`

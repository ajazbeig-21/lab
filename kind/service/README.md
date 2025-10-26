# Kubernetes Services — Practice & Interview Prep (kind)

Purpose
- Hands-on examples for Kubernetes Service types (ClusterIP, NodePort, LoadBalancer, ExternalName) using an nginx Deployment.
- Local testing on macOS with kind (kubernetes-in-docker).
- Troubleshooting and interview-focused notes.

Repository files
- deployment.yaml — nginx Deployment (3 replicas)
- nodeport.yaml — Service type: NodePort (nodePort: 30007)
- clusterip.yaml — Service type: ClusterIP
- load-balancer.yaml — Service type: LoadBalancer
- external.yaml — Service type: ExternalName
- cluster-config.yaml — kind cluster config with extraPortMappings for localhost access

Prerequisites (macOS)
- Docker running
- kind installed (brew install kind)
- kubectl installed (brew install kubectl)
- Optional: aws/metalLB if testing real LoadBalancer behaviour

Quick start (create cluster)
1. Change directory:
```bash
cd /Users/ajazbeig/Documents/git-repo/lab/kind/service
```
2. Create kind cluster (maps host 30007 → node 30007):
```bash
kind create cluster --config cluster-config.yaml --name kind-services
kubectl cluster-info --context kind-kind-services
kubectl get nodes -o wide
```

Deploy application and services
1. Deploy nginx:
```bash
kubectl apply -f deployment.yaml
kubectl get pods -l app=nginx
```
2. Deploy services (you can apply one or several):
```bash
kubectl apply -f nodeport.yaml    # NodePort: nodePort 30007
kubectl apply -f clusterip.yaml   # ClusterIP: internal only
kubectl apply -f load-balancer.yaml # LoadBalancer: pending in kind by default
kubectl apply -f external.yaml    # ExternalName: DNS alias in-cluster
```
3. Check status:
```bash
kubectl get svc,pods -o wide
kubectl describe svc nginx-nodeport
```

How to access services (practical)
- NodePort
  - If cluster-config maps port: open http://localhost:30007
  - If not mapped: use port-forward:
    kubectl port-forward svc/nginx-nodeport 30007:80
- ClusterIP
  - Not reachable from host directly.
  - Test from a pod:
    kubectl run --rm -it --restart=Never busybox --image=busybox -- sh
    # inside pod: wget -qO- http://nginx-cluster-ip:80
  - Or port-forward:
    kubectl port-forward svc/nginx-cluster-ip 8080:80 && open http://localhost:8080
- LoadBalancer
  - In kind this will stay `<pending>`. Options:
    - Install MetalLB to simulate LBs.
    - Use NodePort or port-forward for local testing.
- ExternalName
  - Resolves to an external DNS name for in-cluster clients (example.com in manifest).

Common troubleshooting
- NodePort not reachable on localhost:
  - Confirm kind cluster-config.extraPortMappings maps hostPort:30007 → containerPort:30007 and recreate cluster if changed.
  - Alternative: kubectl port-forward svc/nginx-nodeport 30007:80
- Service has no endpoints:
  - Ensure service selector labels match pod labels (app: nginx).
  - Check pod readiness (readinessProbe) and pod status.
  - kubectl get endpoints <svc-name>
- SSH/Pod issues:
  - kubectl logs <pod>
  - kubectl exec -it <pod> -- /bin/sh
- LoadBalancer pending:
  - Kind does not provision cloud LBs. Install MetalLB or use NodePort.

Useful commands
- kubectl get pods,svc,endpoints -o wide
- kubectl describe svc nginx-nodeport
- kubectl logs <pod-name>
- kubectl exec -it <pod-name> -- /bin/sh
- kubectl port-forward svc/<svc-name> <localPort>:<svcPort>

Cleanup
```bash
kubectl delete -f nodeport.yaml -f clusterip.yaml -f load-balancer.yaml -f external.yaml -f deployment.yaml
kind delete cluster --name kind-services
```

Interview prep — concise Q&A
- What are Service types?
  - ClusterIP: internal access (default).
  - NodePort: exposes a static port on each node (30000–32767).
  - LoadBalancer: cloud LB provisioning (external IP).
  - ExternalName: maps in-cluster name to external DNS.
- How to access ClusterIP from laptop?
  - Use kubectl port-forward or run a pod inside cluster and curl service.
- Why NodePort may not work on localhost with kind?
  - kind runs in a container; nodePort must be mapped to a host port via extraPortMappings or use port-forward.
- How to debug "no endpoints"?
  - Check svc.selector vs pod labels, pod readiness and describe endpoints.
- When to use Ingress vs LoadBalancer?
  - Ingress provides HTTP(S) routing for multiple services; LoadBalancer provisions an external IP per service.

Best practices
- Avoid hardcoding nodePort in manifests for portability.
- Use labels/selectors carefully and verify endpoints after apply.
- Use readinessProbe to prevent routing to non-ready pods.
- For bootstrapping, prefer user-data, baked images, or config management over service-side provisioners.

References
- Services: https://kubernetes.io/docs/concepts/services-networking/service/
- kind docs: https://kind.sigs.k8s.io/
- kubectl reference: https://kubernetes.io/docs/reference/kubectl/

Notes
- Replace any hardcoded values (nodePort, image, etc.) before using in other environments.
- Recreate kind cluster after changing cluster-config.yaml to apply extraPortMappings
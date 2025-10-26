# Pods in Kubernetes — CKA Cheat Sheet

This file is a concise reference for working with Pods in Kubernetes, focused on commands and patterns useful for the CKA (Certified Kubernetes Administrator) exam. Use the declarative approach with manifests for reproducibility, and know the imperative commands for quick tasks during labs and the exam.

Files in this folder:
- [pod.yaml](pod.yaml) (example Pod manifest with name `nginx-pod`)
- [pod-new.yaml](pod-new.yaml)
- [pod-new-1.json](pod-new-1.json)
- [test.yaml](test.yaml)

Quick conceptual notes
- Pod = smallest deployable unit in Kubernetes (one or more containers that share network and storage).
- Prefer declarative (manifests + `kubectl apply`) for reproducibility. Imperative (`kubectl run`, `kubectl create`) is useful for quick tasks.

Common short references
- Inspect API for a resource: `kubectl explain pod`
- View pods: `kubectl get pods`, `kubectl get pods -o wide`
- Describe: `kubectl describe pod <pod-name>`

Imperative approach (fast, interactive)
- Create a simple pod:
  kubectl run nginx-pod --image=nginx:latest --restart=Never
- Create from generated manifest (dry-run -> file):
  kubectl run nginx --image=nginx --restart=Never --dry-run=client -o yaml > pod-generated.yaml
- Expose a pod (creates a service):
  kubectl expose pod nginx-pod --port=80 --target-port=80 --name=nginx-svc
- Update image:
  kubectl set image pod/nginx-pod nginx=nginx:1.19
- Exec into container:
  kubectl exec -it nginx-pod -- /bin/sh
- Get logs:
  kubectl logs nginx-pod
- Delete:
  kubectl delete pod nginx-pod

Declarative approach (recommended for CKA)
- Apply a manifest:
  kubectl apply -f pod.yaml
- Create from manifest (equivalent to `apply` for new objects):
  kubectl create -f pod.yaml
- Replace using file:
  kubectl apply -f pod.yaml
- Delete by file:
  kubectl delete -f pod.yaml

Useful exam patterns and flags
- Generate manifests for learning: `--dry-run=client -o yaml`
- Output formats: `-o yaml`, `-o json`, `-o jsonpath='{...}'`
- Selectors: `kubectl get pods -l app=nginx` and `kubectl label pod <name> key=value`
- Namespace: `-n <namespace>` or `--namespace=<ns>`
- For debugging: `kubectl describe pod <pod>` and `kubectl get events --sort-by='.metadata.creationTimestamp'`
- Replace a pod quickly: `kubectl delete pod <pod> --grace-period=0 --force` then `kubectl apply -f pod.yaml` (use with caution)

Troubleshooting commands
- Show recent events: `kubectl get events -n <ns>`
- View previous logs (crash loops): `kubectl logs -p <pod>`
- Port forward: `kubectl port-forward pod/<pod> 8080:80`
- Copy files to/from pod: `kubectl cp localfile <pod>:/path`
- Check cluster and node status: `kubectl get nodes`, `kubectl top pod`

Exam tips (CKA)
- Practice switching contexts and namespaces quickly.
- Use `--dry-run=client -o yaml` to create correct manifests during the exam.
- Memorize common `kubectl` verbs: get, describe, apply, create, delete, replace, exec, logs, port-forward.
- Prefer manifests for state you must reproduce; use imperative commands for temporary or one-off changes.
- Keep commands short and precise; use `-o` and labels to filter outputs.

Examples in this workspace
- Apply the provided pod manifest:
  kubectl apply -f pod.yaml
  See the manifest at [pod.yaml](pod.yaml).
- Alternative manifests: [pod-new.yaml](pod-new.yaml) and [pod-new-1.json](pod-new-1.json).
- Misc YAML example: [test.yaml](test.yaml)

See also
- `kubectl explain pod` — understand the Pod spec fields.
- Use `kubectl get pods -o jsonpath='{.items[*].metadata.name}'` to extract names programmatically.

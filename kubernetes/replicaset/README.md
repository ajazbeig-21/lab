# Kubernetes ReplicaSet: nginx-rc

This folder contains a simple ReplicaSet manifest (replicaset.yaml) that ensures 3 replicas of an nginx pod (containerPort 80).

## Files
- `replicaset.yaml` — ReplicaSet manifest (apps/v1) creating 3 nginx pods.

## Prerequisites
- kubectl configured to target your cluster (e.g., kind).
- Network access to pull `nginx:latest` or a local image registry.

## Quick commands

Apply the ReplicaSet:
```bash
kubectl apply -f replicaset.yaml
```

Verify ReplicaSet and pods:
```bash
kubectl get rs
kubectl get pods -l app=nginx
kubectl describe rs nginx-rc
```

Scale the ReplicaSet:
```bash
kubectl scale rs nginx-rc --replicas=5
kubectl get pods -l app=nginx
```

Update image / replace pods:
- ReplicaSet does not provide rolling updates like Deployment. To change the image, update the manifest and re-apply:
```bash
# edit replicaset.yaml -> image: nginx:1.25.0
kubectl apply -f replicaset.yaml
# you may need to delete existing pods so the ReplicaSet recreates them with the new image
kubectl delete pod -l app=nginx
```

Cleanup:
```bash
kubectl delete -f replicaset.yaml
```

## Notes
- For controlled rolling updates and declarative rollbacks, use a Deployment instead of a raw ReplicaSet.
- Pin image tags for reproducible deployments and add resource requests/limits and probes for production use.
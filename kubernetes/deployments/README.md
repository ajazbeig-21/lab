# Kubernetes Deployment: nginx-rc

This folder contains a simple Deployment manifest (deployment.yaml) that deploys an nginx ReplicaSet with 3 replicas.

## Files
- `deployment.yaml` — Deployment manifest (apps/v1) creating 3 nginx pods listening on containerPort 80.

## Prerequisites
- kubectl configured to target your cluster (e.g., kind cluster).
- Internet access to pull `nginx:latest` or a local image registry available.

## Quick commands

Apply the deployment:
```bash
kubectl apply -f deployment.yaml
```

Verify deployment and pods:
```bash
kubectl get deployments
kubectl get pods -l app=nginx
kubectl describe deployment nginx-rc
```

Scale the deployment:
```bash
kubectl scale deployment nginx-rc --replicas=5
kubectl get pods -l app=nginx
```

Perform a rolling update (change image):
```bash
kubectl set image deployment/nginx-rc nginx=nginx:1.25.0
kubectl rollout status deployment/nginx-rc
kubectl rollout history deployment/nginx-rc
```

Rollback:
```bash
kubectl rollout undo deployment/nginx-rc
```

Cleanup:
```bash
kubectl delete -f deployment.yaml
```

## Notes
- The manifest uses `image: nginx:latest`. For reproducible deployments, pin to a specific tag.
- Adjust resource requests/limits and readiness/liveness probes for production use.
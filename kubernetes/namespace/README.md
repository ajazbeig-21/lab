# Kubernetes Namespaces — notes and cross-namespace examples

This document explains Kubernetes Namespaces, how they relate to Pods and Services that live in other namespaces, and how to interact with them using kubectl and DNS names. It also includes brief notes on NetworkPolicy and RBAC as they affect cross-namespace access.

## What is a Namespace?

- A Namespace provides a scope for names. Names of resources (like Pods, Services, Deployments) are unique within a namespace but not across the cluster.
- Namespaces are useful for isolating environments (development, staging, production), teams, or projects within the same cluster.
- There are some built-in namespaces: `default`, `kube-system`, `kube-public`. You can create custom namespaces — see `ns.yaml` in this directory for a minimal example.

Reference: `namespace/ns.yaml` in this repo defines a namespace named `demo`:

	- `apiVersion: v1`
	- `kind: Namespace`
	- `metadata.name: demo`

You can create it with:

```sh
kubectl apply -f namespace/ns.yaml
```

## Resource scoping and kubectl

- Create or operate in a namespace with `-n <name>` or `--namespace=<name>`.
- To list pods in `demo`:

```sh
kubectl get pods -n demo
```

To create a resource directly into a namespace, include `metadata.namespace` in the YAML or use `kubectl -n`:

```sh
kubectl apply -f my-pod.yaml -n demo
```

## How Services and Pods interact across namespaces

- Pods are cluster-scoped network endpoints (they receive an IP on the cluster network). By default (unless restricted by NetworkPolicy), pods can talk to any other pod across namespaces using IP addresses.
- Services are namespaced resources. A Service in namespace `A` only selects Endpoints (pods) in namespace `A` (selectors are namespace-scoped), and its DNS name is namespaced.

### DNS and service discovery

Kubernetes DNS resolves service names using this general pattern:

- Short name (from same namespace): `my-service`
- With namespace: `my-service.my-namespace`
- Fully qualified: `my-service.my-namespace.svc.cluster.local`

When a pod in namespace `default` wants to call a service called `web` in namespace `demo`, it should use:

```text
http://web.demo.svc.cluster.local
```

or the shorter:

```text
http://web.demo.svc
```

Note: Shorter names like `web` will only resolve to services in the caller's namespace.

### Example: Service in `demo`, Pod in `default` accessing it

1. Create the namespace (if not already created):

```sh
kubectl apply -f namespace/ns.yaml
```

2. Example Service + Deployment in `demo` (conceptual YAML):

```yaml
apiVersion: v1
kind: Service
metadata:
	name: demo-web
	namespace: demo
spec:
	ports:
	- protocol: TCP
		port: 80
		targetPort: 8080
	selector:
		app: demo-web

---
apiVersion: apps/v1
kind: Deployment
metadata:
	name: demo-web
	namespace: demo
spec:
	replicas: 2
	selector:
		matchLabels:
			app: demo-web
	template:
		metadata:
			labels:
				app: demo-web
		spec:
			containers:
			- name: web
				image: nginx:stable-alpine
				ports:
				- containerPort: 8080
```

Apply the above with `kubectl apply -f demo-web.yaml` (or split into multiple files) and verify the service exists in the `demo` namespace:

```sh
kubectl get svc -n demo
```

3. From a pod in `default` namespace, access the service in `demo`:

Run a one-off curl pod in `default` (or any other namespace) and curl the service FQDN:

```sh
kubectl run -n default -it --rm curl-test --image=curlimages/curl --restart=Never -- sh
# inside the pod shell:
curl -sS http://demo-web.demo.svc.cluster.local:80
```

If DNS and networking are working and there are no NetworkPolicies blocking traffic, the curl should connect to the `demo-web` service and return the service response.

## Important details and gotchas

- Service selectors are namespace-scoped. A Service in `demo` cannot select pods in `default` even if pod labels match; pods must be in the same namespace as the Service for them to be its endpoints.
- If you need cross-namespace load balancing to select pods in different namespaces, you must use different approaches (ExternalName, headless services with manually created Endpoints, or an Ingress/Gateway/Service mesh that routes across namespaces).
- By default, cluster networking allows any pod to reach any pod/service IP across namespaces. To restrict this, use NetworkPolicy (implemented by a CNI that supports it). If NetworkPolicy is in effect, you must allow traffic between namespaces explicitly.

### Example: NetworkPolicy blocking cross-namespace traffic

If a NetworkPolicy in `demo` allows only traffic from pods in namespace `demo`, a pod in `default` won't be able to access `demo-web` even if it uses the correct DNS name.

Example NetworkPolicy (deny all, allow same-namespace only) — conceptual:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
	name: allow-same-namespace-only
	namespace: demo
spec:
	podSelector: {}
	policyTypes:
	- Ingress
	ingress:
	- from:
		- podSelector: {}
			namespaceSelector:
				matchLabels:
					name: demo
```

If you want to permit selected namespaces, create NetworkPolicy ingress rules that include a `namespaceSelector` matching the allowed namespace(s).

## RBAC and API access across namespaces

- Kubernetes RBAC (Role / RoleBinding) is namespace-scoped. A `RoleBinding` that binds a `Role` is limited to the same namespace unless you use a `ClusterRoleBinding` or bind a `ClusterRole` in a RoleBinding specifying subjects.
- If a ServiceAccount in namespace `A` needs to access/kubectl resources in namespace `B`, you must grant it appropriate permissions via Roles/RoleBindings or ClusterRoles.

Example: grant a ServiceAccount in `default` read access to `pods` in `demo`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
	name: pod-reader
	namespace: demo
rules:
- apiGroups: [""]
	resources: ["pods"]
	verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
	name: read-pods-from-default-sa
	namespace: demo
subjects:
- kind: ServiceAccount
	name: default
	namespace: default
roleRef:
	kind: Role
	name: pod-reader
	apiGroup: rbac.authorization.k8s.io
```

With the above, the `default` ServiceAccount in namespace `default` can list/get pods in `demo` (subject to authentication and admission).

## Troubleshooting tips

- If DNS doesn't resolve a service from another namespace, check:
	- `kubectl get svc -A` to ensure the service exists
	- `kubectl exec -n <caller-namespace> <pod> -- nslookup <service>.<namespace>` or use `dig`/`ping` from a debug pod
	- CoreDNS logs (`kubectl -n kube-system logs -l k8s-app=kube-dns` or similar) if cluster DNS seems broken
- If connectivity is refused or times out, check for NetworkPolicy objects and CNI enforcement.
- If you see a service but no endpoints, `kubectl get endpoints -n <namespace>` to verify matching pods exist and the Service selector is correct.

## Summary

- Namespaces scope resource names and provide isolation and multi-tenancy within a cluster.
- Pods can generally talk across namespaces (pod IPs) unless NetworkPolicies restrict them.
- Services are namespaced; their DNS includes the namespace (`<svc>.<ns>.svc.cluster.local`). To access a service from another namespace, use the fully-qualified service DNS or the `<svc>.<ns>` form.
- For API-level access across namespaces, use Roles/RoleBindings or ClusterRoles and RoleBindings appropriately.

If you want, I can add ready-to-apply example YAML files in this directory that demonstrate a working demo: a `demo` namespace with a service and a `default` namespace pod that curls it, plus a version that shows NetworkPolicy blocking and then permitting access.


Rough notes - clean up later

What this is:
Cassandra on k3d, deployed via cass-operator, managed by ArgoCD. Prometheus/Grafana added on top for monitoring.

Setup order:
k3d cluster -> cert-manager -> cass-operator (helm) -> ArgoCD -> Cassandra via ArgoCD Application -> monitoring stack via ArgoCD Application

Issues hit:
* ArgoCD install hit a CRD annotation size limit (262144 byte k8s limit) -> fixed with --server-side + --force-conflicts
* Same CRD size issue with kube-prometheus-stack's CRDs -> fixed with ServerSideApply=true + Replace=true in the Application's syncOptions
* Prometheus/Alertmanager pods never got created even though ArgoCD said "Synced/Healthy" - operator's reconcile loop was silently stuck (no errors seen, checked logs/RBAC/events). Fixed by restarting the operator pod. Not fully sure of root cause, likely resource pressure
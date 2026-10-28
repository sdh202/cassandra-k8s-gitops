# Incidents from this lab

Notes from actually standing this up. These are the talking points if someone asks “what went wrong?”

## 1. Argo CD install: CRD annotation size limit

**Symptom:** `kubectl apply` of the Argo CD install manifest failed. Kubernetes rejected a CRD because the `kubectl.kubernetes.io/last-applied-configuration` annotation exceeded **262144 bytes**.

**Why:** Client-side apply stores the full last-applied object in an annotation. Argo CD (and later kube-prometheus-stack) CRDs are larger than that cap.

**Fix:** Install with server-side apply and allow conflict resolution:

```bash
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Admin UI was verified after install.

## 2. kube-prometheus-stack: same CRD size issue on sync

**Symptom:** The monitoring Argo CD Application failed to sync CRDs for the same annotation-size reason.

**Fix:** On `argocd-apps/monitoring-app.yaml`:

```yaml
syncOptions:
  - CreateNamespace=true
  - ServerSideApply=true
  - Replace=true
```

`Replace=true` is a blunt tool (it replaces resources instead of three-way merging). It was the reliable way to get these CRDs onto a small cluster. Fine for a lab; I would not default to it in production without knowing which objects are being replaced.

## 3. Argo CD Healthy, Prometheus still missing

**Symptom:** Application showed **Synced** and **Healthy**. No Prometheus (or Alertmanager) pods were created.

**What I checked:** operator logs, RBAC, Kubernetes events. No loud error that explained a stuck reconcile.

**Fix:** Restart the Prometheus operator pod. After that, the reconcile loop created the workloads.

**Likely cause:** resource pressure on the 4-node k3d cluster (Cassandra already requesting ~1Gi per pod). Not fully proven — the important lesson is that **Argo CD health is not the same as the operator’s desired state**. Git sync succeeded; the controller did not finish its work.

## Bootstrap versions (as deployed)

| Component | Version |
| --- | --- |
| cert-manager | v1.21.2 |
| cass-operator chart | 0.67.2 (app 1.32.0) |
| Cassandra | 4.1.5 |
| kube-prometheus-stack | 65.8.1 |

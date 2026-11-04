# 1. cert-manager (with CRDs enabled)
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.16.2"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# 2. cass-operator
resource "helm_release" "cass_operator" {
  name             = "cass-operator"
  repository       = "https://helm.k8ssandra.io/stable"
  chart            = "cass-operator"
  version          = "0.67.2"
  namespace        = "cass-operator"
  create_namespace = true

  depends_on = [helm_release.cert_manager]
}

# 3. Argo CD
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.16"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "crds.install"
    value = "true"
  }
}

# 4. GitOps Seed: Argo CD Applications
# Executes after Argo CD and cass-operator are fully running
resource "terraform_data" "argocd_apps" {
  depends_on = [
    helm_release.argocd,
    helm_release.cass_operator
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../argocd-apps/cassandra-app.yaml -f ${path.module}/../argocd-apps/monitoring-app.yaml"
  }
}
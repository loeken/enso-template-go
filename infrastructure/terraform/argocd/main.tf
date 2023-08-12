resource "helm_release" "argocd" {

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  create_namespace = true
  namespace = "argocd"
  version = "5.39.0"
  
  values = [
    "${file("argocd-values.yaml")}"
  ]
}
resource "helm_release" "sealed-secrets" {
  name       = "sealed-secrets-controller"
  chart      = "sealed-secrets"
  create_namespace = true 
  namespace = "kube-system"
  repository = "https://bitnami-labs.github.io/sealed-secrets/"
  version = "2.11.0"
}
resource "local_file" "secret" {
  for_each = { for k, v in var.RepoList : k => v }

  filename = "${replace(each.key, "/", "-")}-secret.yaml"
  content = <<-EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${replace(each.key, "/", "-")}
      namespace: argocd
      labels:
        argocd.argoproj.io/secret-type: repository
    stringData:
      name: ${replace(each.key, "/", "-")}
      url: ssh://git@github.com/${each.key}
      sshPrivateKey: |
        ${indent(4,trimspace(base64decode(each.value.private_key)))}
  EOF
  depends_on = [
    helm_release.sealed-secrets,
    helm_release.argocd
  ]
}


resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.module}/kubeconfig"
  content = <<-EOF
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority-data: ${var.CertificateAuthorityData}
        server: "https://127.0.0.1:${var.tunnel_port}"
      name: kubernetes
    contexts:
    - context:
        cluster: kubernetes
        user: kube-admin
      name: kube-admin@kubernetes
    current-context: kube-admin@kubernetes
    kind: Config
    users:
    - name: kube-admin
      user:
        client-certificate-data: ${var.ClientCertificateData}
        client-key-data: ${var.ClientKeyData}
  EOF
  file_permission = "0600"
  depends_on = [
    local_file.secret
  ]
}

resource "null_resource" "apply_secret" {
  for_each = { for k, v in var.RepoList : k => v }

  triggers = {
    secret_content = local_file.secret[each.key].content
  }

  provisioner "local-exec" {
    command = "export KUBECONFIG=${local_sensitive_file.kubeconfig.filename} && cat ${local_file.secret[each.key].filename} | kubeseal | kubectl apply -f -"
  }

  depends_on = [local_sensitive_file.kubeconfig]
}

//core apps
resource "local_file" "argocd_app_core" {
  for_each = { for k, v in var.RepoList : k => v }

  filename = "${replace(each.key, "/", "-")}-argocd-app-core.yaml"
  content = <<-EOF
  apiVersion: argoproj.io/v1alpha1
  kind: Application
  metadata:
    name: argocd-core-${replace(each.key, "/", "-")}
    namespace: argocd
  spec:
    project: default
    source:
      repoURL: ssh://git@github.com/${each.key}
      path: deploy/argocd/bootstrap-core-apps
      targetRevision: HEAD
      helm:
        valueFiles:
        - values.yaml
    destination:
      namespace: argocd
      server: https://kubernetes.default.svc
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
  EOF
}
resource "null_resource" "apply_argocd_app_core" {
  for_each = { for k, v in var.RepoList : k => v }

  triggers = {
    argocd_app_content = local_file.argocd_app_core[each.key].content
  }

  provisioner "local-exec" {
    command = "export KUBECONFIG=${local_sensitive_file.kubeconfig.filename} && kubectl apply -f ${local_file.argocd_app_core[each.key].filename}"
  }

  depends_on = [local_file.argocd_app_core]
}

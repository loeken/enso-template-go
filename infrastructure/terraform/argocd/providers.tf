provider "helm" {
    kubernetes {
        host                   = "https://127.0.0.1:${var.tunnel_port}"
        client_certificate     = base64decode(var.ClientCertificateData)
        client_key             = base64decode(var.ClientKeyData)
        cluster_ca_certificate = base64decode(var.CertificateAuthorityData)
    }
}

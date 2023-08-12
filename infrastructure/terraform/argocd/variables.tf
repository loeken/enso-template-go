variable "CertificateAuthorityData" {
    sensitive   = true
}
variable "ClientKeyData" {
    sensitive   = true
}
variable "ClientCertificateData" {
    sensitive   = true
}
variable "Server" {}
variable "RepoList" {
    type = map(map(string))
}
variable "tunnel_port" {
    type = string
    default = "20000"
    description = "port used for ssh tunnel connections"

}
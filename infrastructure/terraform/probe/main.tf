resource "null_resource" "server_probing" {
  provisioner "remote-exec" {
    inline = [
      "echo 'Probing server...'",
      "whoami",
      "sleep 10",
    ]

    connection {
      type     = "ssh"
      user     = var.user_name
      host     = var.hostname
      port     = var.port
      private_key = file("~/.ssh/id_ed25519")
    }
  }
}

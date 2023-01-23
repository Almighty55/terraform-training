resource "null_resource" "local-linux" {
  for_each = toset(var.endpoint_ips)

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/keys/${var.key_name}")
    host        = each.key
  }

  provisioner "file" {
    source      = "./scripts/setup.sh"
    destination = "/tmp/setup.sh"

  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "yes | /tmp/setup.sh",
    ]

  }
}
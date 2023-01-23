#? optionally pull in instances dynamically 
data "aws_instances" "destHosts" {
  #   instance_tags = {
  #     Role = "HardWorker"
  #   }

  #   filter {
  #     name   = "instance.group-id"
  #     values = ["sg-12345678"]
  #   }

  instance_state_names = ["running"]
}

provisioner "file" {
  for_each    = var.destinationHost
  source      = each.value.source
  destination = each.value.destination
  connection {
    type        = each.value.type
    user        = each.value.user
    private_key = each.value.private_key
    host        = each.value.host
  }
}
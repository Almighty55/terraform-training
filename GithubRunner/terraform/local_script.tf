resource "null_resource" "kube_config" {
  provisioner "local-exec" {
    command     = "..\\gh_runner_setup_new.ps1"
    interpreter = ["pwsh", "-Command"]
  }

  depends_on = [
    aws_eks_cluster.gha,
    aws_eks_node_group.general
  ]
}

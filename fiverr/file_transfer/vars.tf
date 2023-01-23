#? https://stackoverflow.com/questions/64008302/question-re-terraform-and-github-actions-secrets
variable "linuxKey" {
  type = map(any)
  default = {
    "server1" = {
      source      = ""
      destination = ""
      type        = ""
      user        = ""
      private_key = ""
      host        = ""
    },
    "server2" = {
      source      = ""
      destination = ""
      type        = ""
      user        = ""
      private_key = ""
      host        = ""
    }
    "server3" = {
      source      = ""
      destination = ""
      type        = ""
      user        = ""
      private_key = ""
      host        = ""
    }
  }
}
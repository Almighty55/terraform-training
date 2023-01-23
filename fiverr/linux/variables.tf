variable "endpoint_ips" {
  type        = list(string)
  description = "Linux endpoint IP's"
  #* seperate multiple ip's by comma Example: ["127.0.0.1", "127.0.0.2", "127.0.0.3"]
  default = ["54.166.105.3"]
}

variable "key_name" {
  type        = string
  description = "private key name for linux endpoints"
  default = "id_rsa.pem"
}
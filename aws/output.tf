output "webserver_publicIP" {
  # tell terraform to pull the output from modules\webserver\output.tf
  value = module.webserver.webserver_publicIP
  # could use the below to format outputs
  #value = format("%s/%s","custom text","${module.webserver.webserver_publicIP}")
}
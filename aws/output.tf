output "webserver_publicIP" {
  # tell terraform to pull the output from modules\webserver\output.tf
  value = module.webserver.webserver_publicIP
  # could use the below to format outputs
  #value = format("%s/%s","custom text","${module.webserver.webserver_publicIP}")
}

output "guac_publicIP" {
  #value = format("%s/%s",module.guacamole.guac_publicIP,":8080/guacamole")
  value = "http://${module.guacamole.guac_publicIP}:8080/guacamole"
}

output "sqlserver_privateIP" {
  value = module.sql.sqlserver_privateIP
}
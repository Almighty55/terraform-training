module "infrastructure" {
  source = "./modules/infrastructure"
}

module "backend" {
  source = "./modules/backend"
}

module "webserver" {
  source = "./modules/webserver"
}
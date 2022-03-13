module "backend" {
  source = "./modules/backend"
}

module "webserver" {
  source = "./modules/webserver"
  # get the value from the vpc module output to use within webserver module
  vpc_id = module.vpc.vpc_id 
}

module "vpc" {
  source = "./modules/vpc"
}
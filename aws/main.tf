module "backend" {
  source = "./modules/backend"
}

module "vpc" {
  source = "./modules/vpc"
}

module "webserver" {
  source = "./modules/ec2/webserver"
  # get the value from the vpc module output to use within webserver module
  vpc_output   = module.vpc.vpc_output
  subnet_ouput = module.vpc.subnet_ouput
  web_sg_output = module.sg.web_sg_output
}

module "sg" {
  source     = "./modules/ec2/sg"
  vpc_output = module.vpc.vpc_output
}
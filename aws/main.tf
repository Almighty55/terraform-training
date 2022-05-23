module "backend" {
  source = "./modules/backend"
}

module "vpc" {
  source = "./modules/vpc"
}

module "nat" {
  source                = "./modules/vpc/nat"
  igw_output            = module.vpc.igw
  public_subnet_output  = module.vpc.public_subnet_output
  private_subnet_output = module.vpc.private_subnet_output
  vpc_output            = module.vpc.vpc_output
}

module "sg" {
  source     = "./modules/ec2/sg"
  vpc_output = module.vpc.vpc_output
}

module "webserver" {
  source = "./modules/ec2/instances/webserver"
  # get the value from the vpc module output to use within webserver module
  public_subnet_output = module.vpc.public_subnet_output
  web_sg_output        = module.sg.web_sg_output
}

module "guacamole" {
  source = "./modules/ec2/instances/guacamole"
  # get the value from the vpc module output to use within guacamole module
  public_subnet_output    = module.vpc.public_subnet_output
  guac_sg_output          = module.sg.guac_sg_output
  sqlserver_privateIP     = module.sql.sqlserver_privateIP
  sqlserver_pwd_decrypted = module.sql.sqlserver_pwd_decrypted
}

module "sql" {
  source = "./modules/ec2/instances/sql"
  # get the value from the vpc module output to use within sql module
  private_subnet_output = module.vpc.private_subnet_output
  sql_sg_output         = module.sg.sql_sg_output
}

module "jump" {
  source               = "./modules/ec2/instances/jump"
  public_subnet_output = module.vpc.public_subnet_output
  jump_sg_output       = module.sg.jump_sg_output
}

# module "juypterhub" {
#   source                = "./modules/jhub"
#   vpc_output            = module.vpc.vpc_output
#   public_subnet_output  = module.vpc.public_subnet_output
#   private_subnet_output = module.vpc.private_subnet_output
# }
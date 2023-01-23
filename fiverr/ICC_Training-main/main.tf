# module "backend" {
#   source = "./modules/backend"
# }

module "prov" {
  source = "./prov"
  public_ip = module.windows_pub.windows_public_ip
  password = module.windows_pub.password
  depends_on = [module.ad]
}

module "vpc" {
  source = "./vpc"
}

module "nat" {
  source                 = "./vpc/nat"
  igw_output             = module.vpc.igw
  public_subnet_output   = module.vpc.public_subnet_output
  private_subnet_output  = module.vpc.private_subnet_output
  private_subnet2_output = module.vpc.private_subnet2_output
  vpc_output             = module.vpc.vpc_output
}

module "sg" {
  source     = "./ec2/sg"
  vpc_output = module.vpc.vpc_output
}

module "ad" {
  source                 = "./AD"
  vpc_output             = module.vpc.vpc_output
  private_subnet_output  = module.vpc.private_subnet_output
  private_subnet2_output = module.vpc.private_subnet2_output
}

module "windows_pub" {
  source                = "./ec2/instances/windows/public"
  public_subnet_output  = module.vpc.public_subnet_output
  windows_pub_sg_output = module.sg.windows_pub_sg_output
  aws_managed_ad_output = module.ad.aws_managed_ad_output
}

# module "workspaces" {
#   source = "./workspaces"
#   aws_managed_ad_output = module.ad.aws_managed_ad_output
#   private_subnet_output  = module.vpc.private_subnet_output
#   private_subnet2_output = module.vpc.private_subnet2_output
#   depends_on = [module.prov]
# }
locals {
  azs = ["us-east-1a", "us-east-1b"]

  public_subnets = {
    for i, subnet in local.azs : subnet => {
      cidr_block = cidrsubnet(aws_vpc.gha.cidr_block, 8, ((i * 2) + 1)) # index 3rd octet and reserve odd numbers for public subnets
    }
  }

  private_subnets = {
    for i, subnet in local.azs : subnet => {
      cidr_block = cidrsubnet(aws_vpc.gha.cidr_block, 8, (i * 2)) # index 3rd octet and reserve even numbers for private subnets
    }
  }
}
resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.gha.id
  cidr_block        = values(local.private_subnets)[count.index].cidr_block
  availability_zone = local.azs[count.index]

  tags = {
    "Name"                            = "private-gha-${local.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/gha"       = "owned"
  }
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id            = aws_vpc.gha.id
  cidr_block        = values(local.public_subnets)[count.index].cidr_block
  availability_zone = local.azs[count.index]

  tags = {
    "Name"                      = "public-gha-${local.azs[count.index]}"
    "kubernetes.io/role/elb"    = "1"
    "kubernetes.io/cluster/gha" = "owned"
  }
}
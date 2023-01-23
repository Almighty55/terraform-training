variable "region" {
  default     = "us-east-1"
  type        = string
  description = "AWS region to deploy into."
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block to use for the VPC. Defaults to 10.0.0.0/16"
  default     = "10.0.0.0/16"
}

variable "aws_availability_zones" {
  type        = set(string)
  description = "List of availability Zones for us-east-2. Defaults to us-east-2a, us-east-2b, us-east-2c"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ChargeCode" {
  type        = string
  description = "ChargeCode for resources. Defaults to 04NSOC.SUPP.0000.NSV"
  default     = "04NSOC.SUPP.0000.NSV"
}

variable "private_cidr_block" {
  type        = set(string)
  description = "List of private cidr blocks. 10.0.1xx.x designates private"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_cidr_block" {
  type        = set(string)
  description = "List of public cidr blocks. 10.0.2xx.x designates public"
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}
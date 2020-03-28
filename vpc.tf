module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "carlton-vpc-test"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = false
  # single_nat_gateway = false

  tags = {
    Terraform = "true"
    Environment = "test"
  }
}

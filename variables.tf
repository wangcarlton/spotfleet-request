variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-southeast-2"
}


variable "allow_cidr_block" {
  default     = "0.0.0.0/0"
  description = "Specify cidr block that is allowd to acces the LoadBalancer"
}

variable "vpc_cidr" {
  default     = "22.0.0.0/16"
  description = "Specify cidr block for VPC"
}

variable "key_name" {
  default     = "carlton-aws"
  description = "SSH key pair to instances"
}

variable "availability_zones" {
  default     = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  description = "availability_zones"
}

variable "private_subnets" {
  default     = ["22.0.6.0/24", "22.0.7.0/24", "22.0.8.0/24"]
  description = "private_subnet_cidrs"
}

variable "public_subnets" {
  default     = ["22.0.1.0/24", "22.0.2.0/24", "22.0.3.0/24"]
  description = "public_subnet_cidrs"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "instance_type"
}

variable "aws_ami" {
  default     = "ami-02a599eb01e3b3c5b"
  description = "aws_ami"
}

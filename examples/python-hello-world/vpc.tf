data "aws_availability_zones" "available" {
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "python-hello-world-vpc"
  cidr = "10.0.0.0/16"

  azs = [
    data.aws_availability_zones.available.names[0],
  ]

  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  create_vpc = true

  enable_dns_support   = true
  enable_dns_hostnames = false

  enable_nat_gateway = true
  single_nat_gateway = true
}

# VPC wide security group
resource "aws_security_group" "internal_sec_group" {
  name        = "python-hello-world-internal-sec-group"
  description = "Allow all inbound from within the VPC and allow all outbound to Internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = -1
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

module "python-hello-world-image" {
  source      = "github.com/mathspace/terraform-aws-ecr-docker-image?ref=v2.0"
  image_name  = "python-hello-world"
  source_path = "${path.module}/src"
}

module "python-hello-world-task" {
  source               = "../.."
  name                 = "python-hello-world"
  image_repository_url = module.python-hello-world-image.repository_url
  image_tag            = module.python-hello-world-image.tag
  subnets              = [module.vpc.private_subnets[0]]
  security_groups      = [aws_security_group.internal_sec_group.id]

  environment = {
    FROM_NAME = "a Fargate task!"
  }
}

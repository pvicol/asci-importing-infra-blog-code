module "main" {
  source = "terraform-aws-modules/vpc/aws"

  name = "ASCI Demo VPC"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false

  tags = {
    Terraform   = "true"
    Environment = "DEMO"
  }
}

resource "aws_subnet" "main_management" {
  vpc_id            = "${module.main.vpc_id}"
  cidr_block        = "10.0.5.0/28"
  availability_zone = "us-east-1a"

  tags {
    Name = "Public - Management - us-east-1a"
  }
}

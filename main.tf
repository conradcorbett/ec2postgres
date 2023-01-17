provider "aws" {
  region  = var.region
}

/*module "create_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = "${var.app}-vpc"
  cidr               = "10.0.0.0/16"
}*/

data "aws_vpc" "vpc-seesquared" {
  filter {
    name = "tag:Name"
    values = ["SeeSquared-us-west-2-vpc"]
  }
}

module "ec2vm" {
  source = "./module-ec2"
  vpc_id            = data.aws_vpc.vpc-seesquared.id
  name              = "${var.app}-vm"
  tags              = { Owner = "conrad.corbett@hashicorp.com", Environment = "test", Name = "${var.app}-vm" }
  public_key        = aws_key_pair.awskey.key_name
}
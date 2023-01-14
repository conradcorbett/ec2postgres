terraform {
  required_version = ">= 0.12"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    #values = ["ubuntu/images/hvm-ssd/ubuntu-disco-19.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_subnet" "subnet-seesquared-public" {
  filter {
    name = "tag:Name"
    values = ["SeeSquared-us-west-2-subnet-public1-us-west-2a"]
  }
}

resource "aws_security_group" "sg-mysql" {
  name = "sg_${var.name}"
  vpc_id = var.vpc_id
  tags = {
    Name = "sg-${var.name}"
  }

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress {
    description      = "mysql"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "instance" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = data.aws_subnet.subnet-seesquared-public.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [ aws_security_group.sg-mysql.id ]
  key_name                    = var.public_key
  tags                        = var.tags
  user_data                   = templatefile("${path.module}/configs/${var.name}.tpl", { vm_name = var.name })

  provisioner "local-exec" {
    command = "sudo wget -O mysql.sh https://raw.githubusercontent.com/conradcorbett/ec2postgres/master/module-ec2/configs/mysql.sh"
  }
/*
  provisioner "local-exec" {
    command = <<-EOT

      sudo chmod +x mysql.sh 
      ./mysql.sh

      sudo wget -O hello.sql https://raw.githubusercontent.com/conradcorbett/ec2postgres/master/module-ec2/configs/hello.sql
      sudo chmod +x hello.sql
      /postgres/bin/psql -U postgres -f /hello.sql
    EOT
  }
*/
}

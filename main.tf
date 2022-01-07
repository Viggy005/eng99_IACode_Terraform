# let Terraform know who is our cloud provider

# AWS plugins/dependencies will be downloaded
provider "aws" {
    region = "eu-west-1"
    # this will allow terraform to create services on eu-west-1
    
}
# let's start with launching an ec2 insatnce using terraform script
resource "aws_instance" "app_instance"{
    #vpc
    # add ami ID for ubutu 18.04
    ami = var.app_ami_id
    # choose t2.micro
    instance_type = var.type_of_machine
    # Enable IP as it is our app instance
    associate_public_ip_address = true
    # specift which usbnet should this ec2 be laucnhed in(public in this case)
    subnet_id = var.public_subnet_1b
    vpc_security_group_ids = ["sg-0e7269c42cdc2422b"]
    # add tag for Name
    tags = {
        Name = var.name
    }
    # .pem key to ssh into machine
    key_name = var.aws_key_name
}
# to initialise we use terraform init
# terraform plan
# terraform apply
# apply DRY
# my own testing from here

# create VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

# create security group

resource "aws_security_group" "allow_tls" {
  name        = "eng99_vigneshraj_terraform"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id
  #
  ingress{
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # allow access to port 3000 from any where
  ingress {
    description      = "access the app from anywhere world"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  # allow access to ssh from anywhere
  ingress {
    description      = "ssh from world"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
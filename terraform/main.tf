#############################################################
# VPC
#############################################################

resource "aws_vpc" "main" {

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

#############################################################
# Internet Gateway
#############################################################

resource "aws_internet_gateway" "main" {

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

#############################################################
# Public Subnet
#############################################################

resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

#############################################################
# Route Table
#############################################################

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.main.id

  }

  tags = {

    Name = "${var.project_name}-public-rt"

  }

}

#############################################################
# Route Table Association
#############################################################

resource "aws_route_table_association" "public" {

  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

}

#############################################################
# Security Group
#############################################################

resource "aws_security_group" "ec2" {

  name        = "${var.project_name}-sg"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {

    description = "Cube.js"

    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {

    Name = "${var.project_name}-sg"

  }

}

#############################################################
# IAM Role
#############################################################

resource "aws_iam_role" "ec2" {

  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

        Action = "sts:AssumeRole"

      }

    ]

  })

}

#############################################################
# IAM Instance Profile
#############################################################

resource "aws_iam_instance_profile" "ec2" {

  name = "${var.project_name}-instance-profile"

  role = aws_iam_role.ec2.name

}

#############################################################
# IAM Policy Attachment
#############################################################

resource "aws_iam_role_policy_attachment" "cloudwatch" {

  role = aws_iam_role.ec2.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

}

resource "aws_iam_role_policy_attachment" "ecr" {

  role = aws_iam_role.ec2.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

#############################################################
# ECR Repository
#############################################################

resource "aws_ecr_repository" "cube" {

  name = var.project_name

  image_scanning_configuration {

    scan_on_push = true

  }

  image_tag_mutability = "MUTABLE"

}

#############################################################
# CLOUDWATCH LOG GROUP
#############################################################

resource "aws_cloudwatch_log_group" "cube" {

  name              = "/cube-analytics-platform/application"
  retention_in_days = 7

}

#############################################################
# AMAZON LINUX AMI
#############################################################

data "aws_ami" "amazon_linux" {

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

}

#############################################################
# EC2 INSTANCE
#############################################################

resource "aws_instance" "cube" {

  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.ec2.name

  key_name = "cube-key-ap-south-1"

  user_data = file("${path.module}/user-data.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "cube-server"
  }

}
# Corrected and complete Terraform script for a single-file configuration.

# -----------------------------------------------------------
# VPC and Network Resources
# -----------------------------------------------------------

resource "aws_vpc" "project_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "final-project-vpc"
  }
}

# Public Subnet: For resources that need to be internet-accessible.
resource "aws_subnet" "project_public_sn" {
  vpc_id                  = aws_vpc.project_vpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "final-project-public-subnet"
  }
}

# Private Subnet 1: For private resources (e.g., RDS).
resource "aws_subnet" "project_private_sn_1" {
  vpc_id            = aws_vpc.project_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = var.private_subnet_cidr_1

  tags = {
    Name = "final-project-private-subnet-1"
  }
}

# Private Subnet 2: A second private subnet to meet RDS Availability Zone requirement.
resource "aws_subnet" "project_private_sn_2" {
  vpc_id            = aws_vpc.project_vpc.id
  availability_zone = "us-east-1c"
  cidr_block        = var.private_subnet_cidr_2

  tags = {
    Name = "final-project-private-subnet-2"
  }
}


# Internet Gateway: Allows communication between the VPC and the internet.
resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "final-project-igw"
  }
}

# Public Route Table: Routes traffic from the public subnet to the internet.
resource "aws_route_table" "project_public_rt" {
  vpc_id = aws_vpc.project_vpc.id

  route {
    cidr_block = var.everything_through_cidr
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = {
    Name = "final-project-public-rt"
  }
}

# Associate the public route table with the public subnet.
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.project_public_sn.id
  route_table_id = aws_route_table.project_public_rt.id
}

# Private Route Table: Keeps resources private with no route to the internet.
resource "aws_route_table" "project_private_rt" {
  vpc_id = aws_vpc.project_vpc.id

  tags = {
    Name = "final-project-private-rt"
  }
}

# Associate the private route table with both private subnets.
resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.project_private_sn_1.id
  route_table_id = aws_route_table.project_private_rt.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.project_private_sn_2.id
  route_table_id = aws_route_table.project_private_rt.id
}

# Security Group for EC2
resource "aws_security_group" "project_sg" {
  name        = "final-project-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.project_vpc.id

  dynamic "ingress" {
    for_each = var.sg_ingress_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.everything_through_cidr]
    }
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = [var.everything_through_cidr]
  }

  tags = {
    Name = "final-project-sg"
  }
}

# Security Group for RDS DB
resource "aws_security_group" "project_rds_sg" {
  name   = "project_rds_sg"
  vpc_id = aws_vpc.project_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.project_sg.id]
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = [var.everything_through_cidr]
  }

  tags = {
    Name = "project-rds-sg"
  }
}

# -----------------------------------------------------------
# EC2 and S3 Resources
# -----------------------------------------------------------

# SSH Key Pair: Required for EC2 instance.
resource "aws_key_pair" "final_pem" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

resource "aws_instance" "project_ec2" {
  subnet_id                   = aws_subnet.project_public_sn.id
  vpc_security_group_ids      = [aws_security_group.project_sg.id]
  ami                         = var.ec2_ami
  instance_type               = var.ec2_type
  associate_public_ip_address = true
  key_name                    = aws_key_pair.final_pem.key_name

  root_block_device {
    volume_size = "8"
    volume_type = "gp3"
  }

  tags = {
    Name = "final-project-ec2"
  }
}

resource "aws_s3_bucket" "project_bucket" {
  bucket = "final-project-bucket-unique-name" # Change this to a globally unique name

  tags = {
    Name = "final-project-bucket"
  }
}

# -----------------------------------------------------------
# RDS and ECR Resources
# -----------------------------------------------------------

# DB Subnet Group: Groups the private subnets for the RDS instance.
# This now includes two private subnets to meet the Availability Zone requirement.
resource "aws_db_subnet_group" "project_dbsubnet_group" {
  name        = "project-db-subnet-group"
  subnet_ids  = [
    aws_subnet.project_private_sn_1.id,
    aws_subnet.project_private_sn_2.id
  ]
  description = "DB subnet group for project-db"

  tags = {
    Name = "project-db-subnet-group"
  }
}

resource "aws_db_instance" "project_mysql_db" {
  identifier          = "project-serpent-surge"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = var.rds_instance_type
  allocated_storage   = 20
  storage_type        = "gp2"
  username            = var.mysql_db_user
  password            = var.mysql_db_password
  db_name             = "serpentsurge"
  publicly_accessible = false
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.project_rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.project_dbsubnet_group.name

  tags = {
    Name = "project-serpent-surge"
  }
}

resource "aws_ecr_repository" "project_ecr" {
  name                 = "bfinal-project-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform = "true"
  }
}


# -----------------------------------------------------------
# Outputs
# -----------------------------------------------------------

output "ecr_repository_url" {
  value = aws_ecr_repository.project_ecr.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.project_ec2.public_ip
}

output "db_endpoint" {
  value = aws_db_instance.project_mysql_db.address
}

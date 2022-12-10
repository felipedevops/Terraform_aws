data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block_vpc #"10.10.0.0/16"
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops"
  }
}

#======= PUBLIC SUBNET
resource "aws_subnet" "PublicSubnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PublicSubnet1 #"10.10.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = var.aws_az_1
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops_PublicSubnet1"
  }
}

resource "aws_subnet" "PublicSubnet2" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = "true"
  cidr_block              = var.PublicSubnet2 #"10.10.2.0/24"
  availability_zone       = var.aws_az_2
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops_PublicSubnet2"
  }
}

## Criação do Internet Gateway
resource "aws_internet_gateway" "tcb_blog_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops_igw"
  }
}
#
## Criação da Tabela de Roteamento
#resource "aws_route_table" "tcb_blog_rt" {
#  vpc_id = aws_vpc.main.id
#
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.tcb_blog_igw.id
#  }
#
#  tags = {
#    Name = "tcb_blog_rt"
#  }
#}
#
## Criação da Rota Default para Acesso à Internet
#resource "aws_route" "tcb_blog_routetointernet" {
#  route_table_id            = aws_route_table.tcb_blog_rt.id
#  destination_cidr_block    = "0.0.0.0/0"
#  gateway_id                = aws_internet_gateway.tcb_blog_igw.id
#}
#
## Associação da Subnet Pública com a Tabela de Roteamento
#resource "aws_route_table_association" "tcb_blog_pub_association" {
#  subnet_id      = aws_subnet.PublicSubnet1.id
#  route_table_id = aws_route_table.tcb_blog_rt.id
#}

#======= PRIVATE SUBNET
resource "aws_subnet" "PrivateSubnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.PrivateSubnet3 #"10.10.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.aws_az_1
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops_PrivateSubnet3"
  }
}

resource "aws_subnet" "PrivateSubnet4" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = "false"
  cidr_block              = var.PrivateSubnet4
  availability_zone       = var.aws_az_2
  tags = {
    Env  = "${var.infra_env}"
    Name = "${var.infra_env}_devops_PrivateSubnet4"
  }
}
resource "aws_key_pair" "teleport-kp" {
  key_name   = "teleport-deployer-key"
  public_key = file(var.ssh-pub)
}

data "aws_ami" "ubuntu" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "teleport-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    app = "teleport"
  }
}

resource "aws_security_group" "ingress-all-test" {
  name   = "allow-all-sg"
  vpc_id = aws_vpc.teleport-vpc.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port   = 3000
    to_port     = 3100
    protocol    = "tcp"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "teleport-gw" {
  vpc_id = aws_vpc.teleport-vpc.id

  tags = {
    app = "teleport"
  }
}

resource "aws_subnet" "teleport-subnet" {
  cidr_block = "172.16.10.0/24"
  vpc_id     = aws_vpc.teleport-vpc.id
  tags       = {
    app = "teleport"
  }
}

resource "aws_route_table" "teleport-rt" {
  vpc_id = aws_vpc.teleport-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.teleport-gw.id
  }
  tags   = {
    app = "teleport"
  }
}
resource "aws_route_table_association" "teleport-rt-association" {
  subnet_id      = aws_subnet.teleport-subnet.id
  route_table_id = aws_route_table.teleport-rt.id
}

resource "aws_instance" "teleport" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.teleport-kp.key_name
  user_data                   = templatefile("config/teleport.sh", {
    domain = var.fqdn
    email  = var.email
  })
  subnet_id                   = aws_subnet.teleport-subnet.id
  security_groups             = [
    aws_security_group.ingress-all-test.id
  ]
  tags                        = {
    app = "teleport"
  }
  associate_public_ip_address = false

}

resource "aws_eip" "teleport-eip-manager" {
  instance = aws_instance.teleport.id
  vpc      = true
  tags     = {
    app = "teleport"
  }
}

resource "aws_eip_association" "teleport-eip-assoc" {
  instance_id   = aws_instance.teleport.id
  allocation_id = aws_eip.teleport-eip-manager.id
}

output "ip" {
  value = aws_eip.teleport-eip-manager.public_ip
}
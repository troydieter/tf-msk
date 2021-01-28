resource "aws_security_group" "MSKClusterSG" {
  name        = "msk-${lower(var.environment)}-sg-${random_id.rando.hex}"
  description = "Allow MSK cluster traffic"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-${lower(var.environment)}-sg-${random_id.rando.hex}"
    )
  )
}

resource "aws_security_group" "MSKClientInstanceSG" {
  name        = "msk-sg-${random_id.rando.hex}"
  description = "Allow TLS inbound traffic to MSK client"
  vpc_id      = aws_vpc.msk_vpc.id

  ingress {
    description = "SSH port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common-tags,
    map(
      "Name", "msk-sg-${random_id.rando.hex}"
    )
  )
}
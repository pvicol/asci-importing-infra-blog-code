resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "ASCI Demo VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "ASCI Demo IGW"
  }
}

resource "aws_network_acl" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "ASCI Demo ACL"
  }
}

resource "aws_route_table" "main_private" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "ASCI Demo - Private RT"
  }
}

resource "aws_route_table" "main_public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "ASCI Demo - Public RT"
  }
}

resource "aws_subnet" "main_private_a" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags {
    Name = "Private - us-east-1a"
  }
}

resource "aws_subnet" "main_private_b" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"

  tags {
    Name = "Private - us-east-1b"
  }
}

resource "aws_subnet" "main_public_a" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"

  tags {
    Name = "Public - us-east-1a"
  }
}

resource "aws_subnet" "main_public_b" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-east-1b"

  tags {
    Name = "Public - us-east-1b"
  }
}

resource "aws_subnet" "main_management" {
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "10.0.1.0/28"
  availability_zone = "us-east-1a"

  tags {
    Name = "Public - Management - us-east-1a"
  }
}

resource "aws_main_route_table_association" "main_private" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main_private.id}"

  depends_on = [
    "aws_vpc.main",
    "aws_route_table.main_private",
  ]
}

resource "aws_route" "main_public" {
  route_table_id         = "${aws_route_table.main_public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"

  depends_on = [
    "aws_route_table.main_public",
    "aws_internet_gateway.main",
  ]
}
